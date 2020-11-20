package cn.wjj.gagaframe.client.worker 
{
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	import flash.events.Event;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.system.WorkerState;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	/**
	 * 多线程管理器
	 * 
	 * 提供阻塞锁和非阻塞锁
	 * 提供异步非顺序执行
	 * 
	 * 内存块,读写分别处理
	 * 单独内存块记录状态.
	 * 
	 * 关闭进程停掉其他现场处理,
	 * 
	 * 
	 * 锁定内存块
	 * 主进程		: uint8 [要执行的操作类型]
	 * 				0	主进程写入未锁定
	 * 				1	主进程写入锁定
	 * 				2	主进程数据写入完毕
	 * 				3	次线程读取锁定(读完就切回未锁定)
	 * 				253	关闭进程 (未完成进程自己处理)
	 * 				254	未激活
	 * 				255	激活
	 * 次进程		: uint8 [要执行的操作类型]
	 * 				0	线程写入未锁定
	 * 				1	线程写入锁定
	 * 				2	线程数据写入完毕
	 * 				3	主进程读取锁定(读完就切回未锁定)
	 * 				253	关闭进程
	 * 
	 * 
	 * id		: uint32 [每个线程处理的序号]
	 * 				id++的数字
	 * length	: uint16 子任务数量
	 * type 	: uint16 [类型,处理类型]
	 * 
	 * send -> 线程
	 * 堆栈 [byte][id][回调函数][o.init 初始记录值, o.out 返回值]
	 * 
	 * send -> 线程 [队列]
	 * 堆栈 [byte list][id][回调函数][o.list -> o.init 初始记录值, o.out 返回值]
	 * 全部完成后返回
	 * 
	 * 堆栈处理数
	 * 堆栈剩余量
	 * 
	 * @author GaGa
	 */
	public class WorkerManage 
	{
		/** 线程是否启动 **/
		internal var _isStart:Boolean = false;
		/** 是否为主线程 **/
		internal var _isPrimordial:Boolean = true;
		/** 线程启动时间 **/
		private var startTime:int;
		/** 进程处理管理器 **/
		public var job:WorkerJobManage;
		
		/** 线程初始化情况回调函数 **/
		private var complete:Function;
		/** 多线程对象 **/
		private var worker:Worker;
		/** 框架提供接收器 **/
		private var channel_W_G:MessageChannel;
		/** 框架提供接收器 **/
		private var channel_G_W:MessageChannel;
		/** 公用内存块 本线程使用二进制 **/
		private var byteThis:WorkerByteArray;
		/** 公用内存块 其他线程使用内容 **/
		private var byteWorker:WorkerByteArray;
		/** 公用内存块 处理各种状态 **/
		private var byteState:WorkerByteArray;
		
		/** 本线程请求的序号 **/
		private var activeId:int = -1;
		/** 本线程请求的列表 **/
		private var activeLib:Object = new Object();
		/** 线程里接受的序号 **/
		private var receiveId:int = -1;
		/** 线程里接受的处理列表 **/
		private var receiveLib:Object = new Object();
		/** 要等待发送的列表 **/
		internal var sendList:Vector.<WorkerTask> = new Vector.<WorkerTask>();
		/** 等待发送的列表 **/
		internal var sendListLength:int = 0;
		
		public function WorkerManage() 
		{
			job = new WorkerJobManage();
		}
		
		/** 线程是否启动 **/
		public function get isStart():Boolean { return _isStart; }
		/** 是否为主线程,默认true **/
		public function get isPrimordial():Boolean { return _isPrimordial; }
		
		/**
		 * 初始化线程
		 * @param	worker			线程引用
		 * @param	isPrimordial	是否是主线程
		 * @param	complete		完成的时候回调
		 */
		public function init(worker:Worker, isPrimordial:Boolean, complete:Function):void
		{
			this.worker = worker;
			this.complete = complete;
			startTime = getTimer();
			if (isPrimordial)
			{
				_isPrimordial = true;
				g.event.addEnterFrame(completeWorker, this);
				worker.addEventListener(Event.WORKER_STATE, workerState);
				//IOS上不能start
				worker.start();
			}
			else
			{
				_isPrimordial = false;
				g.event.addEnterFrame(completeLink, this);
				completeLink();
			}
		}
		
		/** 多线程中有严重问题,比如沙箱问题,将停掉多线程 **/
		public function stop():void
		{
			if (_isStart)
			{
				if (_isPrimordial)
				{
					byteState.position = 0;
				}
				else
				{
					//传输出去停止的信号
					byteState.position = 1;
				}
				var state:uint = byteState._r_Uint8();
				if (state == 0)
				{
					g.event.removeEnterFrame(stop, this);
					if (_isPrimordial)
					{
						byteState.position = 0;
						byteState._w_Uint8(253);
						channel_G_W.send(-253);
					}
					else
					{
						byteState.position = 1;
						byteState._w_Uint8(253);
						channel_W_G.send(-253);
					}
					stopPrimordial();
				}
				else
				{
					//等待其他的处理
					g.event.addEnterFrame(stop, this);
				}
			}
		}
		
		/** 运行线程内要停止的内容 **/
		private function stopPrimordial():void
		{
			if (_isStart)
			{
				_isStart = false;
			}
		}
		
		/** 多线程回调 **/
		private function workerState(e:Event):void
		{
			g.log.pushLog(this, LogType._UserAction, "多线程回调 : " + e.toString());
			worker.removeEventListener(Event.WORKER_STATE, workerState);
			g.event.removeEnterFrame(completeWorker, this);
			if (worker.state == WorkerState.RUNNING)
			{
				g.log.pushLog(this, LogType._UserAction, "多线程回调 WORKER_STATE 成功");
				channel_G_W = Worker.current.createMessageChannel(worker);
				worker.setSharedProperty("G->W", channel_G_W);
				
				channel_W_G = worker.createMessageChannel(Worker.current);
				channel_W_G.addEventListener(Event.CHANNEL_MESSAGE, messageWorker)
				worker.setSharedProperty("W->G", channel_W_G);
				
				//创建框架数据写入器
				var byte:ByteArray = new ByteArray();
				byte.shareable = true;
				worker.setSharedProperty("B-GaGaFrame", byte);
				byteThis = new WorkerByteArray(byte);
				//创建子对象数据写入器
				byte = new ByteArray();
				byte.shareable = true;
				worker.setSharedProperty("B-Worker", byte);
				byteWorker = new WorkerByteArray(byte);
				//创建对象数据状态记录器
				byte = new ByteArray();
				byte.shareable = true;
				worker.setSharedProperty("B-State", byte);
				byteState = new WorkerByteArray(byte);
				byteState._w_Uint8(254);
				byteState._w_Uint8(0);
			}
			else
			{
				g.log.pushLog(this, LogType._UserAction, "多线程回调 WORKER_STATE 失败");
				if (complete != null)
				{
					complete(false);
					complete = null;
				}
			}
		}
		
		/** 检测框架是否主动握手成功,如果在5秒内没有握手成功,将放弃 **/
		private function completeWorker():void
		{
			if (getTimer() > (startTime + 3000))
			{
				g.event.removeEnterFrame(completeWorker, this);
				g.log.pushLog(this, LogType._Frame, "多线程倒计时超时,启动失败");
				if (complete != null)
				{
					complete(false);
					complete = null;
				}
			}
		}
		
		/** 不停的检测是否连接上了 **/
		private function completeLink():void
		{
			if (getTimer() > (startTime + 3000))
			{
				g.event.removeEnterFrame(completeLink, this);
				g.log.pushLog(this, LogType._Frame, "子进程倒计时超时,启动失败");
				if (complete != null)
				{
					complete(false);
					complete = null;
				}
			}
			else
			{
				var b1:ByteArray = worker.getSharedProperty("B-GaGaFrame");
				var b2:ByteArray = worker.getSharedProperty("B-Worker");
				var b3:ByteArray = worker.getSharedProperty("B-State");
				if (b1 && b2 && b3)
				{
					return;
					if (byteWorker == null) byteWorker = new WorkerByteArray(b1);
					if (byteThis == null) byteThis = new WorkerByteArray(b2);
					if (byteState == null) byteState = new WorkerByteArray(b3);
					if (byteState.bytesAvailable)
					{
						g.event.removeEnterFrame(completeLink, this);
						byteState.position = 0;
						channel_G_W = worker.getSharedProperty("G->W") as MessageChannel;
						channel_W_G = worker.getSharedProperty("W->G") as MessageChannel;
						var state:uint = byteState._r_Uint8();
						if (state == 254 && channel_G_W && channel_W_G)
						{
							channel_G_W.addEventListener(Event.CHANNEL_MESSAGE, messageWorker);
							byteState.position = 0;
							byteState._w_Uint8(255);
							_isStart = true;
							channel_W_G.send(-1);
							if (complete != null)
							{
								complete(true);
								complete = null;
							}
						}
					}
				}
			}
		}
		
		/** 从列表中获取将要发送的内容 **/
		internal function messageSend():void
		{
			if (sendListLength)
			{
				var task:WorkerTask;
				if (_isStart)
				{
					if (_isPrimordial)
					{
						byteState.position = 0;
					}
					else
					{
						byteState.position = 1;
					}
					var state:uint = byteState._r_Uint8();
					//没有锁定框架写入二进制
					if (state == 0)
					{
						g.event.removeEnterFrame(messageSend, this);
						task = sendList.shift();
						var info:WorkerInfo;
						if (task.selfJob)
						{
							//不能在这里执行,都要绕过
							throw new Error("提前绕过执行");
						}
						else
						{
							if (_isPrimordial)
							{
								byteState.position = 0;
							}
							else
							{
								byteState.position = 1;
							}
							byteState._w_Uint8(1);
							sendListLength--;
							byteThis.clear();
							byteThis._w_Uint16(task.id);
							byteThis._w_Uint8(task._sendType);
							if (task.state == 13)//发送结果
							{
								task.state = 14;
								//把回传的内容写进去
								//任务已完成
								byteThis.writeBoolean(true);
								byteThis._w_Uint16(task.length);
								if (task.length > 1)
								{
									for each (info in task.list) 
									{
										info.out.writeByte(byteThis);
									}
								}
								else
								{
									task.item.out.writeByte(byteThis);
								}
								task.dispose();
							}
							else if (task.state == 2)//发送处理任务
							{
								task.state = 3;//线程正在发送到其他线程
								byteThis.writeBoolean(task.needTrack);
								byteThis.writeBoolean(task.needReturn);
								byteThis._w_Uint16(task.length);
								if (task.length > 1)
								{
									for each (info in task.list) 
									{
										byteThis._w_Uint32(info.type);
										info.send.writeByte(byteThis);
									}
								}
								else
								{
									byteThis._w_Uint32(task.item.type);
									task.item.send.writeByte(byteThis);
								}
								task.state = 4;//线程正在发送到其他线程
							}
							else if (task.state == 12)
							{
								if (task.trackLength)
								{
									//任务未完成
									byteThis.writeBoolean(false);
									byteThis._w_Uint16(task.trackLength);
									for each (info in task.trackList) 
									{
										byteThis._w_Uint16(info._index);
										info.track.writeByte(byteThis);
									}
								}
								else
								{
									throw new Error("逻辑出错");
								}
							}
							else
							{
								throw new Error("逻辑出错");
							}
							if (_isPrimordial)
							{
								byteState.position = 0;
							}
							else
							{
								byteState.position = 1;
							}
							byteState._w_Uint8(2);
							if (_isPrimordial)
							{
								channel_G_W.send(task.id);
							}
							else
							{
								channel_W_G.send(task.id);
							}
						}
					}
					else if (state == 253)
					{
						g.event.removeEnterFrame(messageSend, this);
						stop();
					}
					else
					{
						//等待其他的处理
						g.event.addEnterFrame(messageSend, this);
					}
				}
				else
				{
					if (_isPrimordial)
					{
						//等待线程启动,如果是本地可以运行的线程,就自动走本地
						g.event.removeEnterFrame(messageSend, this);
						//发送处理任务
						task = sendList.shift();
						sendListLength--;
						if (task.state == 13)//发送结果
						{
							if (task.selfJob == true)
							{
								//自己已经处理完毕
								task.state = 5;
								if (task.complete != null)
								{
									var method:Function = task.complete;
									task.complete = null;
									method(task);
								}
							}
							else
							{
								//把任务删除掉
							}
						}
						else if (task.state == 2)//直接处理掉任务
						{
							task.selfJob = true;
							task.start();
						}
						else if (task.state == 12)
						{
							if (task.selfJob == true)
							{
								//发送给自己
								if (task.track != null)
								{
									task.track(task);
								}
							}
							else
							{
								//把任务删除掉
							}
						}
						else
						{
							throw new Error("逻辑出错");
						}
						messageSend();
					}
					else
					{
						//清理掉全部任务,子线程已经被关闭
						
						//task = sendList.shift();
						//sendListLength--;
						
					}
				}
			}
		}
		
		/** 从线程上取数据 Worker -> GaGaFrame **/
        private function messageWorker(e:Event):void
        {
			var id:int;
			if (_isPrimordial)
			{
				id = channel_W_G.receive();
			}
			else
			{
				id = channel_G_W.receive();
			}
			var state:uint;
			if (id == -1)
			{
				byteState.position = 0;
				state = byteState._r_Uint8();
				if (state == 255)
				{
					g.event.removeEnterFrame(completeWorker, this);
					byteState.position = 0;
					byteState._w_Uint8(0);
					_isStart = true;
					if (complete != null)
					{
						complete(true);
						complete = null;
					}
					return;
				}
				if (complete != null)
				{
					complete(false);
					complete = null;
				}
				return;
			}
			else if (id == -2)//线程请求继续发送内容
			{
				//其他线程已经接收完二进制,处理其他信息了
				messageSend();
			}
			else if (id > -1)
			{
				if (_isPrimordial)
				{
					byteState.position = 1;
				}
				else
				{
					byteState.position = 0;
				}
				state = byteState._r_Uint8();
				if (state == 2)//线程数据写入完毕
				{
					if (_isPrimordial)
					{
						byteState.position = 1;
					}
					else
					{
						byteState.position = 0;
					}
					byteState._w_Uint8(3);
					byteWorker.position = 0;
					var task:WorkerTask;
					var byteId:int = byteWorker._r_Uint16();
					if (byteId == id)
					{
						//任务发起方,0:主进程 1:子线程
						var sendType:int = byteWorker._r_Uint8();
						if (((_isPrimordial && sendType == 1) || (_isPrimordial == false && sendType == 0)) && id > receiveId)
						{
							//有处理的任务切换进来
							receiveId = id;
							task = new WorkerTask();
							//task.state = 10;
							task.readTask(id, sendType, byteWorker);
						}
						else
						{
							task = taskGet(id, sendType);
							if (task)
							{
								try
								{
									if (byteWorker.readBoolean())
									{
										task.finish(byteWorker);
									}
									else
									{
										task.trackIn(byteWorker);
									}
								}
								catch (e:Error)
								{
									g.log.pushLog(this, LogType._Frame, "线程处理出现错误");
								}
							}
							else
							{
								g.log.pushLog(this, LogType._Frame, "未找到任务ID");
							}
						}
					}
					else
					{
						g.log.pushLog(this, LogType._Frame, "ID校验失败");
					}
					byteWorker.clear();
					if (_isPrimordial)
					{
						byteState.position = 1;
					}
					else
					{
						byteState.position = 0;
					}
					byteState._w_Uint8(0);
					//传递处理完毕的信息,请求其他线程继续发送内容
					if (_isPrimordial)
					{
						channel_G_W.send( -2);
					}
					else
					{
						channel_W_G.send( -2);
					}
				}
				else
				{
					throw new Error("非自然锁定, 线程废掉 T_T");
				}
			}
			else
			{
				throw new Error("未知回传ID");
			}
        }
		
		/**
		 * 向其他线程派遣任务
		 * @param	task	多线程任务
		 * @param	type	1.异步处理, 2.阻塞
		 * @return
		 */
		public function taskSend(task:WorkerTask, type:int = 1):int
		{
			activeId++;
			task._id = activeId;
			activeLib[activeId] = task;
			if (_isPrimordial)
			{
				task._sendType = 0;
			}
			else
			{
				task._sendType = 1;
			}
			task.state = 2;
			task.length = 1;
			if (task.list && task.list.length)
			{
				var index:int = 0;
				task.length = task.list.length;
				for each (var info:WorkerInfo in task.list) 
				{
					info._index = index;
					info.task = task;
					index++;
				}
			}
			else if(task.item)
			{
				task.item._index = 0;
				task.item.task = task;
			}
			else
			{
				throw new Error("没有内容");
			}
			if (task.complete == null)
			{
				task.needReturn = false;
			}
			else
			{
				task.needReturn = true;
			}
			if (task.track == null)
			{
				task.needTrack = false;
			}
			else
			{
				task.needTrack = true;
			}
			sendList.push(task);
			sendListLength++;
			messageSend();
			return activeId;
		}
		
		/**
		 * 通过返回的ID列表获取任务
		 * @param	id			
		 * @param	sendType	任务发起方,0:主进程 1:子线程
		 * @return
		 */
		public function taskGet(id:int, sendType:int):WorkerTask
		{
			if (sendType)
			{
				if (id <= receiveId && receiveLib.hasOwnProperty(id))
				{
					return receiveLib[id];
				}
			}
			else
			{
				if (id <= activeId && activeLib.hasOwnProperty(id))
				{
					return activeLib[id];
				}
			}
			return null;
		}
		
		/**
		 * 删除一个任务
		 * @param	id
		 * @param	sendType
		 * @return
		 */
		public function taskRemoveId(id:int, sendType:int):WorkerTask
		{
			var out:WorkerTask;
			if (sendType)
			{
				if (id <= receiveId && receiveLib.hasOwnProperty(id))
				{
					out = receiveLib[id];
					delete receiveLib[id];
				}
			}
			else
			{
				if (id <= activeId && activeLib.hasOwnProperty(id))
				{
					out = activeLib[id];
					delete activeLib[id];
				}
			}
			if (out)
			{
				var index:int = sendList.indexOf(out);
				if (index != -1)
				{
					sendList.splice(index, 1);
				}
			}
			return out;
		}
		
		/** 删除一个 WorkerTask **/
		public function taskRemove(task:WorkerTask):Boolean
		{
			var index:int = sendList.indexOf(task);
			if (index != -1)
			{
				sendList.splice(index, 1);
			}
			var id:String;
			if (task.sendType)
			{
				for (id in receiveLib) 
				{
					if (receiveLib[id] == task)
					{
						delete receiveLib[id];
						return true;
					}
				}
			}
			else
			{
				for (id in activeLib) 
				{
					if (activeLib[id] == task)
					{
						delete activeLib[id];
						return true;
					}
				}
			}
			return false;
		}
	}
}