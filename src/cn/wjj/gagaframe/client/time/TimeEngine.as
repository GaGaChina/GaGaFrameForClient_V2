package cn.wjj.gagaframe.client.time 
{
	import cn.wjj.g;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	/**
	 * 一个模拟时间的对象
	 * 可以模拟出时间来
	 * 
	 * 相当于一个时钟, 可以和FPS等其他内容一起工作
	 * 不要用于混合作用的内容,适用与显示对象等内容
	 * 
	 * 需要一个传递频率比较高的时间传递者,将频率传递过来
	 * 
	 * 接收的函数为 function(times:int) 跳动次数
	 * 
	 * 时间变频器
	 * 时间震频降解器
	 * 将高频的时间,在本降解器中降低每次震动,而以固有的频率发生震荡
	 * 
	 * 1.可以从外面传入 changeTime
	 * 2.启用自己的频率设定, 自动执行里面的 changeTime
	 * 3.被其他的 TimeEngine 绑定, 其他 TimeEngine,推进 changeTime
	 * 
	 * @author GaGa
	 */
	public class TimeEngine 
	{
		/**
		 * 现在控制器时间
		 * uint 方案
		 * 		4294967295
		 * 		4294967295 = 1193小时 = 49天 = 4233600000, 在3888000000转换,有4天17小时的机会时间
		 * Number 方案
		 * 		4294967295  uint 最大的数
		 * 		Number(String(time).split(.)[0]);
		 */
		public var time:uint = 0;
		/** 内核时间,每次外部出入新时间,就会叠加进内核 **/
		private var core:Number = 0;
		/** 正在运行第几轮,从1开始 **/
		public var round:uint = 0;
		/** 时间控制器的速度 **/
		public var speed:Number = 1;
		/** 时间器的状态 **/
		private var _type:int;
		/** 是否已经设置过时间 **/
		private var isSet:Boolean = false;
		/** 本轮执行了几次循环 **/
		private var _round:uint = 0;
		/** 上一次执行的时间 **/
		private var prevTime:Number = 0;
		/** 下一次运行的时间 **/
		private var nextTime:Number = 0;
		/** 暂停的时间点 **/
		private var pauseTime:Number = 0;
		/** 发动机准备运行到的时间 **/
		private var timeTarget:uint;
		/** totalRun 必须为true 否则将根据round运算出time值(未达到nextTime不会运算),还是直接叠加进入目标时间值(不会直接用带入值) **/
		private var _useTarget:Boolean = false;
		/** 频率 **/
		private var _fps:Number = 0;
		/** 变频器的频率,毫秒,0标识EnterFrame,毫秒区间设定为±20% **/
		private var _frequency:Number = 0;
		/** 使用FPS还是其他类型 **/
		private var _useType:int = TimeEngineTimeType.useFPS;
		/** 是否自己驱动时间 **/
		private var _selfEngine:Boolean = false;
		/** 自己驱动震荡频率, -1,负数为超级震荡,1为EnterFrame震荡 **/
		private var _engineFPS:Number = 0;
		/** 驱动器的安全值(防变速齿轮),当震荡频率超过倍数,修正为单倍震荡, 0不修复 **/
		private var _engineSafe:Number = 0;
		//-----------------------------------------时钟处理模块
		/** 运行函数的时候是以整体运行,还是一次次运行,重复执行函数,和单次执行,带入新加次数 **/
		private var _totalRun:Boolean = false;
		/** 每个帧的时候运行的函数 **/
		private var enterFrameLib:Dictionary = new Dictionary(true);
		/** 有多少回调函数 **/
		private var length:int = 0;
		/** 捆绑其他的时钟 **/
		public var boundType:int = TimeEngineBoundType.sameFrequency;
		public var boundList:Vector.<TimeEngine>;
		public var boundLength:int = 0;
		
		/**
		 * 时间引擎
		 * @param	fps				频率检测FPS
		 * @param	frequency		没条一次增加的时间
		 * @param	useType			使用FPS还是其他类型, TimeEngineTimeType
		 * @param	useTarget		totalRun 必须为true 否则将根据round运算出time值(未达到nextTime不会运算),还是直接叠加进入目标时间值(不会直接用带入值)
		 * @param	totalRun		运行函数的时候是以整体运行,还是一次次运行,重复执行函数,和单次执行,带入新加次数
		 * @param	selfEngine		是否自己驱动震荡
		 * @param	engineFPS		自己驱动震荡频率, -1,负数为超级震荡,0为EnterFrame震荡
		 * @param	engineSafe		驱动器的安全值(防变速齿轮),当震荡频率超过倍数,修正为单倍震荡, 0不修复
		 */
		public function TimeEngine(fps:Number = 0, frequency:Number = 0, useType:int = 1, useTarget:Boolean = false, totalRun:Boolean = false, selfEngine:Boolean = true, engineFPS:Number = 0, engineSafe:Number = 0) 
		{
			this._fps = fps;
			this._frequency = frequency;
			this._useType = useType;
			this._useTarget = useTarget;
			this._totalRun = totalRun;
			this._selfEngine = selfEngine;
			this._engineFPS = engineFPS;
			this._engineSafe = engineSafe;
			switch (useType) 
			{
				case TimeEngineTimeType.useFPS:
					_frequency = 1000 / fps;
					break;
				case TimeEngineTimeType.useFrequency:
					_fps = 1000 / _frequency;
					break;
				case TimeEngineTimeType.useEnterFrame:
					//如果是这个就>_<,啥都没法搞
					_fps = 1000 / g.status.stageFPS;
					_frequency = 1000 / g.status.stageFPS;
					break;
			}
		}
		
		/** 频率 **/
		public function get fps():Number { return this._fps; }
		/** 变频器的频率,毫秒,0标识EnterFrame,毫秒区间设定为±20% **/
		public function get frequency():Number { return this._frequency; }
		/** 时间器的状态 **/
		public function get type():int { return _type; }
		/** 是否自己驱动时间 **/
		public function get selfEngine():Boolean { return _selfEngine; }
		/** 自己驱动震荡频率, -1,负数为超级震荡,1为EnterFrame震荡 **/
		public function get engineFPS():Number { return _engineFPS; }
		
		/**
		 * 启动, 如果没有设置过,就会使用t值开始
		 * @param	t	-1 取系统的 getTimer();
		 */
		public function run(t:int = -1):void
		{
			if (_type != TimeEngineType.run)
			{
				_type = TimeEngineType.run;
				if (isSet == false)
				{
					isSet = true;
					if (t == -1)
					{
						prevTime = getTimer();
					}
					else
					{
						prevTime = t;
					}
					timeTarget = prevTime;
					nextTime = prevTime + _frequency;
				}
				if (_selfEngine)
				{
					if (_engineFPS < 0)
					{
						g.event.addSuperEnterFrame(changeTime, this);
					}
					else if (_engineFPS == 0)
					{
						g.event.addEnterFrame(changeTime, this);
					}
					else
					{
						g.event.addFPSEnterFrame(_engineFPS, changeTime, this);
					}
				}

			}
		}
		
		/** 暂停 **/
		public function pause():void
		{
			if (_type != TimeEngineType.pause)
			{
				_type = TimeEngineType.pause;
				pauseTime = time;
				if (_selfEngine)
				{
					if (_engineFPS < 0)
					{
						g.event.removeSuperEnterFrame(changeTime, this);
					}
					else if (_engineFPS == 0)
					{
						g.event.removeEnterFrame(changeTime, this);
					}
					else
					{
						g.event.removeFPSEnterFrame(_engineFPS, changeTime, this);
					}
				}
			}
		}
		
		/** 把现在的时间重置为0, 循环次数也重置为0 **/
		public function clear():void
		{
			time = 0;
			round = 0;
			switch (_type) 
			{
				case TimeEngineType.run:
					
					break;
				case TimeEngineType.pause:
					
					break;
				default:
			}
		}
		
		/**
		 * 将驱动器的运行时间和其他对象绑定起来
		 * @param	obj			要去特性对象获取时间的对象
		 * @param	Property	通过上面对象的某一个参数来获取时间
		 */
		public function boundAdd(engine:TimeEngine, sameCore:Boolean):void
		{
			if (engine.selfEngine == false && boundInTree(engine))
			{
				if (boundLength) boundList = new Vector.<TimeEngine>();
				boundList.push(engine);
				boundLength++;
			}
			else
			{
				g.log.pushLog(this, g.logType._ErrorLog, "不能互相绑定时间控制器");
				throw new Error("不能互相绑定时间控制器");
			}
		}
		
		/**
		 * 解除一个对象的绑定
		 * @param	engine
		 */
		public function boundRomve(engine:TimeEngine):void
		{
			if (boundLength)
			{
				var index:int = boundList.indexOf(engine);
				if (index != -1)
				{
					boundList.splice(index, 1);
					boundLength--;
					if (boundLength == 0) boundList = null;
				}
			}
		}
		
		/**
		 * 查询一个时间对象有没有在子集或者是目录一下的地方
		 * @param	engine
		 * @return
		 */
		public function boundInTree(engine:TimeEngine):Boolean
		{
			if (boundLength)
			{
				if (boundList.indexOf(engine) != -1)
				{
					return true;
				}
				var itemHave:Boolean = false;
				for each (var item:TimeEngine in boundList) 
				{
					itemHave = item.boundInTree(engine);
					if (itemHave) return true;
				}
			}
			return false;
		}
		
		/**
		 * 通过外界的输入时间来控制本时间模块,相当于绑定外面一个时间驱动器,会绕开最大帧的限制
		 * @param	t	-1 取系统的 getTimer();
		 */
		public function changeTime(t:int = -1):void
		{
			if (t == -1) t = getTimer();
			if (t > timeTarget && _type == TimeEngineType.run)
			{
				if (_engineSafe != 0 && _frequency < (t - timeTarget) * _engineSafe)
				{
					t = timeTarget + _frequency;
				}
				core = (t - timeTarget) * speed + core;
				this.timeTarget = t;
				//运行
				if (core > nextTime)
				{
					//一把把新的时间传递过去
					_round = uint((core - prevTime) / _frequency);
					var method:*;
					var item:TimeEngine;
					if (_totalRun)
					{
						prevTime = _frequency * _round + prevTime;
						nextTime = prevTime + _frequency;
						//设置时间
						if (_useTarget)
						{
							if (core < 4294967295)
							{
								time = uint(core);
							}
							else
							{
								time = Number(String(core).split(".")[0]);
							}
						}
						else
						{
							if (prevTime < 4294967295)
							{
								time = uint(prevTime);
							}
							else
							{
								time = Number(String(prevTime).split(".")[0]);
							}
						}
						//设置循环次数
						round += _round;
						//运行函数
						for (method in enterFrameLib) 
						{
							method(_round);
						}
						//将本地时间传递进绑定时间中
						if (boundLength)
						{
							for each (item in boundList) 
							{
								item.changeTime(time);
							}
						}
					}
					else
					{
						//重复频率的执行函数形
						while (_round > 0)
						{
							_round--;
							prevTime = _frequency + prevTime;
							nextTime = prevTime + _frequency;
							//设置频率
							if (prevTime < 4294967295)
							{
								time = uint(prevTime);
							}
							else
							{
								time = Number(String(prevTime).split(".")[0]);
							}
							if (_round == 0)
							{
								if(_useTarget)
								{
									if (core < 4294967295)
									{
										time = uint(core);
									}
									else
									{
										time = Number(String(core).split(".")[0]);
									}
								}
							}
							//设置循环次数
							round++;
							//运行函数
							for (method in enterFrameLib) 
							{
								method(1);
							}
							//将本地时间传递进绑定时间中
							if (boundLength)
							{
								for each (item in boundList) 
								{
									item.changeTime(time);
								}
							}
						}
					}
					method = null;
				}
				else if(_useTarget)
				{
					if (core < 4294967295)
					{
						time = uint(core);
					}
					else
					{
						time = Number(String(core).split(".")[0]);
					}
				}
			}
			else
			{
				timeTarget = t;
			}
		}
	}
}