package cn.wjj.gagaframe.client.worker 
{
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	/**
	 * 队列的任务列表,有全局唯一 ID
	 * @author GaGa
	 */
	public class WorkerTask 
	{
		/**
		 * 任务列表的状态
		 * 
		 * 0 : 空列表
		 * 1 : 设置完毕,等待线程运行
		 * 2 : 等待发送到其他线程
		 * 3 : 线程正在发送到其他线程
		 * 4 : 等待其他线程返回结果
		 * 5 : 处理其他线程结果
		 * 6 : 线程完成
		 * 
		 * 10 : 本线接受任务
		 * 11 : 本线程处于排队等待处理
		 * 12 : 本线程已经运行处理
		 * 13 : 本线程处理完毕,等待发送
		 * 14 : 本线程发送完毕
		 */
		internal var state:uint = 0;
		/** 处理的数据包ID **/
		internal var _id:uint = 0;
		/** 任务发起方,0:主进程 1:子线程 **/
		internal var _sendType:int = 0;
		/** 有多少列表,大于1就是list,否则是item **/
		internal var length:int = 0;
		/** 处理的列表 **/
		public var list:Vector.<WorkerInfo> = new Vector.<WorkerInfo>();
		/** 处理单个对象 **/
		public var item:WorkerInfo;
		/** 现在处理到第几个了 **/
		internal var runIndex:int = -1;
		/** 处理完毕了多少Item **/
		private var finishLength:int = 0;
		/** 是否按顺序执行列表, false为并发处理 **/
		public var useOrder:Boolean = true;
		/** 接收任务时间 **/
		public var timeReceive:Number = 0;
		/** 任务开始执行时间点 **/
		public var timeRun:Number = 0;
		/** 任务结束时间 **/
		public var timeOver:Number = 0;
		/**
		 * 对任务进行跟踪 Function(WorkerTask)
		 * 
		 * 完成任务将清理未发送的状态.
		 * 俺优先顺序发送状态.
		 * 发送状态的时候会将本地的状态一股脑全发送出去.
		 * 发现下载量没有全部量,但是完成了,这是正常的.
		 * 同一任务状态会覆盖,比如有1条还未发送,但有新的将不发送遗留的
		 */
		public var track:Function;
		/** 需要提交状态的列表 **/
		internal var trackList:Vector.<WorkerInfo> = new Vector.<WorkerInfo>();
		/** 需要提交状态的列表的长度 **/
		internal var trackLength:int = 0;
		/** 本任务是否支持跟踪 **/
		internal var needTrack:Boolean = false;
		/** 任务完成后的回调, 当任务完成的时候回调Function(WorkerTask) **/
		public var complete:Function;
		/** 处理完的任务需要将结果返回到发起进程么 **/
		internal var needReturn:Boolean = true;
		/** 是否自己处理的任务 **/
		internal var selfJob:Boolean = false;
		
		public function WorkerTask() { }
		
		/** 处理的数据包ID **/
		public function get id():uint { return _id; }
		/** 任务发起方,0:主进程 1:子线程 **/
		public function get sendType():int { return _sendType; }
		
		/**
		 * 获取另一个线程传递过来的任务
		 * @param	id			标记
		 * @param	sendType	任务发起者
		 * @param	byte		任务其他内容
		 */
		internal function readTask(id:uint, sendType:int, byte:WorkerByteArray):void
		{
			timeReceive = new Date().time;
			_id = id;
			_sendType = sendType;//获取任务发起方
			if (g.worker._isPrimordial)
			{
				if (_sendType == 0)
				{
					throw new Error("获取任务类型不匹配");
				}
			}
			else
			{
				if (_sendType == 1)
				{
					throw new Error("获取任务类型不匹配");
				}
			}
			needTrack = byte.readBoolean();
			needReturn = byte.readBoolean();
			length = byte._r_Uint16();
			if (length > 1)
			{
				list.length = 0;
				for (var i:int = 0; i < length; i++) 
				{
					list.push(readTaskItem(i, byte));
				}
			}
			else
			{
				item = readTaskItem(0, byte);
			}
			state = 11;
			start();
		}
		
		/** 获取一个子Item **/
		private function readTaskItem(index:int, byte:WorkerByteArray):WorkerInfo
		{
			var o:WorkerInfo = WorkerInfo.instance();
			o._index = index;
			o.type = byte._r_Uint32();
			o.send.readByte(byte);
			o.task = this;
			return o;
		}
		
		/** 开始处理本队列里的内容 **/
		internal function start():void
		{
			if (state == 11 || (selfJob && state == 2))
			{
				timeRun = new Date().time;
				state = 12;
				var i:WorkerInfo;
				if (length == 1)
				{
					g.worker.job.run(item);
					runIndex = 0;
				}
				else
				{
					if (useOrder)
					{
						runIndex++;
						i = list[runIndex];
						g.worker.job.run(i);
					}
					else
					{
						//并发
						for each (i in list)
						{
							g.worker.job.run(i);
						}
						runIndex = length - 1;
					}
				}
			}
			else
			{
				throw new Error("非正常逻辑");
			}
		}
		
		/** 已经处理完毕,返回结果, byte 处理不允许异步 **/
		internal function finish(byte:WorkerByteArray):void
		{
			if (state == 4)
			{
				state = 5;
				var l:uint = byte._r_Uint16();
				var i:WorkerInfo;
				//是否切换到主线程在运算一遍
				var changePrimordial:Boolean = false;
				if (l == length)
				{
					if (length > 1)
					{
						for each (i in list) 
						{
							i.out.readByte(byte);
							if (changePrimordial == false && i.type == 3000000001 && i.out.info.state == 2)
							{
								changePrimordial = true;
							}
						}
					}
					else
					{
						item.out.readByte(byte);
						if (item.type == 3000000001 && item.out.info.state == 2)
						{
							changePrimordial = true;
						}
					}
				}
				else
				{
					throw new Error("线程返回的处理结果的结果数量和本地不符");
				}
				if (changePrimordial)
				{
					g.log.pushLog(this, LogType._Warning, "发现子线程无法处理内容,自动切主线程运行");
					this.state = 2;//直接处理掉任务
					this.selfJob = true;
					this.start();
				}
				else
				{
					//读入结果内容
					if (complete != null)
					{
						var method:Function = complete;
						complete = null;
						method(this);
					}
				}
			}
			else
			{
				throw new Error("逻辑错误");
			}
		}
		
		/** 有运行中的状态数据传送回来 **/
		internal function trackIn(byte:WorkerByteArray):void
		{
			var itemLength:int = byte._r_Uint16();
			var index:int;
			var info:WorkerInfo;
			while (--itemLength > -1)
			{
				index = byte._r_Uint16();
				if (length > 1)
				{
					info = list[index];
					info.track.readByte(byte);
				}
				else if(index == 0)
				{
					item.track.readByte(byte);
				}
				else
				{
					throw new Error("逻辑错误");
				}
			}
			if (track != null)
			{
				track(this);
			}
		}
		
		/**
		 * 子线程处理完毕
		 * @param	index
		 */
		internal function completeItem(info:WorkerInfo):void
		{
			if (state == 12)
			{
				finishLength++;
				if (length == finishLength)
				{
					timeOver = new Date().time;
					//全部完成, 应该是要发送出去
					if (needReturn)
					{
						if (selfJob)
						{
							state = 5;
							//读入结果内容
							if (complete != null)
							{
								var method:Function = complete;
								complete = null;
								method(this);
							}
						}
						else
						{
							state = 13;
							g.worker.sendList.push(this);
							g.worker.sendListLength++;
							g.worker.messageSend();
						}
					}
					else
					{
						state = 14;
						dispose();
					}
				}
				else
				{
					//继续弄或等待
					if (useOrder && runIndex != (length - 1))
					{
						runIndex++;
						var runItem:WorkerInfo = list[runIndex];
						g.worker.job.run(runItem);
					}
				}
			}
			else
			{
				throw new Error("逻辑错误");
			}
		}
		
		/** 推送本条影响的Info的状态数据 **/
		internal function trackItem(info:WorkerInfo):void
		{
			if (selfJob)
			{
				if (track != null)
				{
					track(this);
				}
			}
			else
			{
				//全部完成, 应该是要发送出去
				var index:int = trackList.indexOf(info);
				if (index != -1)
				{
					trackList.splice(index, 1);
					trackLength--;
				}
				trackList.push(info);
				trackLength++;
				//添加列表
				index = g.worker.sendList.indexOf(this);
				if (index == -1)
				{
					g.worker.sendList.push(this);
					g.worker.sendListLength++;
				}
				g.worker.messageSend();
			}
		}
		
		/** 摧毁对象 **/
		public function dispose():void
		{
			//帮其他线程的处理已经完成
			if (state == 14 && selfJob == false)
			{
				if (length > 1)
				{
					for each (var info:WorkerInfo in list) 
					{
						info.dispose();
					}
					list.length = 0;
				}
				else if(length == 1)
				{
					item.dispose();
					item = null;
				}
				length = 0;
			}
			else
			{
				if (complete != null)
				{
					var method:Function = complete;
					complete = null;
					method(this);
				}
			}
		}
	}
}