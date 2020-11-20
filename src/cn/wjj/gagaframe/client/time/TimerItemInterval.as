package cn.wjj.gagaframe.client.time
{
	
	public class TimerItemInterval extends TimerItemBase
	{
		//-------------------------------------周期触发类型
		/** 周期,或者是间隔 **/
		private var interval:Number = 0;
		/** 上一个周期的时候运行的时间 **/
		private var intervalOld:Number = 0;
		/** 运行次数 **/
		private var times:int = 0;
		/** 计时器现在的状态 **/
		private var _timerType:String = TimerType.NO;
		//-------------------------------------计数器自己使用的一些值
		/** 计时器Start的时间 **/
		private var starTime:Number = 0;
		/** 暂停时间,暂停的合计 **/
		private var _pauseTime:Number = 0;
		/** 运行的时间 **/
		private var _playTime:Number = 0;
		/** 停止的时间 **/
		private var stopTime:Number = 0;
		/** 记时用的特殊时间 **/
		private var tempTime:Number = 0;
		
		public function TimerItemInterval()
		{
			super();
		}
		
		/** 设置时间的状态:计时,暂停,未启动 **/
		public function get timerType():String
		{
			return _timerType;
		}
		/** 设置时间的状态:计时,暂停,未启动 **/
		public function set timerType(value:String):void
		{
			switch(value)
			{
				case TimerType.NO:
					starTime = 0;
					_pauseTime = 0;
					_playTime = 0;
					stopTime = 0;
					tempTime = 0;
					intervalOld = 0;
					break;
				case TimerType.START:
					break;
				case TimerType.PLAY:
					break;
				case TimerType.PAUSE:
					break;
				default:
					break;
			}
			_timerType = value;
		}
		
		/** 开始记时 **/
		public function start():void
		{
			if (timerType != TimerType.PLAY)
			{
				timerType = TimerType.START;
				timerType = TimerType.PLAY;
			}
		}
		
		/**暂停一段计时**/
		public function pause():void
		{
			if (timerType != TimerType.PAUSE)
			{
				timerType = TimerType.PAUSE;
			}
		}
		
		/** 计时器继续执行或者开始 **/
		public function play():void
		{
			if (timerType != TimerType.PLAY)
			{
				timerType = TimerType.PLAY;
			}
		}
		
		/** 停止计时器,并且关闭 **/
		public function stop():void{
			reSet();
		}
		
		/** 获取计时器在运行的时间,包含暂停的时间 **/
		public function get runAllTime():Number
		{
			return _playTime + _pauseTime;
		}
		
		/** 获取计时器在运行Play的时间 **/
		public function get playTime():Number
		{
			return this._playTime;
		}
		
		/** 自动判断时间是否要做处理 **/
		override internal function run():void
		{
			if (timerType != TimerType.NO)
			{
				//处理每过一秒触发一次
				if (secondsRun && _timerType == TimerType.PLAY)
				{
					if (Math.round(getTime() / 1000) != secondsOld)
					{
						secondsOld = Math.round(getTime() / 1000);
						this.runMethod(this.secondsMethodList);
					}
				}
				//周期运行
				if (this.methodList != null && this.methodList.length)
				{
					if (timerType != TimerType.NO)
					{
						runIntervalTime();
					}
				}
			}
		}
		
		/** 获取当前周期的剩余的时间 **/
		public function get surplusTime():Number
		{
			return (interval - _playTime);
		}
		
		private function runIntervalTime():void
		{
			if(starTime == 0)
			{
				starTime = this.getTime();
			}
			if(times >= 0)
			{
				if(tempTime == 0)
				{
					tempTime = getTime();
				}
				if(timerType == TimerType.PAUSE)
				{
					_pauseTime = _pauseTime + getTime() - tempTime;
					tempTime = getTime();
				}
				else if (timerType == TimerType.PLAY)
				{
					_playTime = _playTime + getTime() - tempTime;
					tempTime = getTime();
					if (_playTime >= interval)
					{
						_playTime = 0;
						_pauseTime = 0;
						intervalOld = getTime();
						var tempMethodList:Vector.<Function> = this.methodList;
						if (times != 0)
						{
							times--;
							if (times == 0)
							{
								if(autoDel)
								{
									del();
								}
							}
						}
						this.runMethod(tempMethodList);
					}
				}
			}
			else
			{
				if(autoDel)
				{
					del();
				}
			}
		}
		
		/**
		 * 设置这个定时器为interval秒的周期运行,运行times次,添加完毕后autoRun自动运行,autoDel并且自动删除
		 * @param method		回调函数
		 * @param interval		运行周期毫秒数
		 * @param times			运行次数,0是循环不断
		 * @param autoRun		添加任务完成后自动运行
		 * @param autoDel		运行任务完毕后自动删除
		 */
		public function setIntervalTime(method:Function, interval:Number = 0, times:int = 0, autoRun:Boolean = true, autoDel:Boolean = true):void
		{
			timerType = TimerType.NO;
			if(interval < 0)
			{
				var tempMethod:Function = method;
				if(autoDel)
				{
					del();
				}
				tempMethod();
			}
			else
			{
				this.pushMethod(method);
				this.interval = interval;
				this.times = times;
				this.autoDel = autoDel;
				if(autoRun)
				{
					start();
				}
			}
		}
		
		/**
		 * 添加运行的时间
		 * @param theTime	毫秒
		 */
		public function addTime(theTime:Number):void
		{
			this.interval = this.interval + theTime;
		}
		
		/** 获取一个周期的时间 **/
		public function get intervalTime():Number
		{
			return this.interval;
		}
		
		/** 复位计时器的时间设置,初始化所有已设置的值 **/
		public function reSet():void
		{
			_timerType = TimerType.NO;
			interval = 0;
			times = 0;
			this.methodList = null;
			//当秒值发生变化的时候触发
			secondsRun = false;
			this.secondsMethodList = null;
		}
		
		/** 删除这个计时器 **/
		override public function del():void
		{
			reSet();
			super.del();
		}
	}
}