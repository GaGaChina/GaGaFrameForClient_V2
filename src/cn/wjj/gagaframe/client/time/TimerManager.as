package cn.wjj.gagaframe.client.time
{
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	import flash.utils.getTimer;
	
	/**
	 * 倒计时管理者,可以管理倒计时,多少时间后触发某函数.,添加,删除等动作
	 * flash.utils.getTimer 也是选的幀的频率,不是很准的.
	 * 
	 * 提供基础了几个计时
	 * 判断 : 使用0.5秒的基准判断,当系统的时间变化在一秒内,都考虑是正常的,因为没人调整系统时间会一秒秒调整
	 *        3幀的时间.
	 * 
	 * 精准 : 检查系统时间,然后参考每幀的变化,当某幀的毫秒数加大,但在判断范围内(Flash被减速),就还是使用系统正常值.
	 *                                      当某幀的毫秒数减少,但在判断范围内(Flash被加速),就还是加上系统的正常值
	 *        系统的时间突然减少或增加超过判断的时间基准的时候,就加上每幀的毫秒数.
	 * 
	 * 
	 * 
	 * 下面这个好像没什么用~~ 唉哦!
	 * 
	 * 最短 : 使用地方,比如一个倒计时比赛,给1分钟完成某项任务.
	 *        检查系统时间,然后参考每幀的变化,当某幀的毫秒数加大,但在判断范围内(Flash被减速),就还是使用系统正常值.
	 *                                      当某幀的毫秒数减少,但在判断范围内(Flash被加速),就还是加上系统的正常值
	 *        系统的时间突然减少或增加超过判断的时间基准的时候,就加上每幀的毫秒数.
	 * 
	 * 最长 : 使用地方,比如一个倒计时比赛,给1分钟完成某项任务.
	 *        检查系统时间,然后参考每幀的变化,当某幀的毫秒数加大,但在判断范围内(Flash被减速),就还是使用系统正常值.
	 *                                      当某幀的毫秒数减少,但在判断范围内(Flash被加速),就还是加上系统的正常值
	 *        系统的时间突然减少或增加超过判断的时间基准的时候,就加上每幀的毫秒数.
	 * 
	 * @author GaGa
	 */
	internal class TimerManager
	{
		/**这个Flash是多少幀的**/
		private var stageFPS:int = 0;
		/**每一帧的时间**/
		private var frameTime:Number	= 0;
		/**不符合时间数量**/
		private var bugMax:int = 0;
		/**出现BUG所需的偏离倍数**/
		private var bugNum:int	= 3;
		/**出现几次BUG需要去服务器重置**/
		private var bugTime:int = 3;
		
		//-----------------------本系统内部使用
		/** 上个幀经历的时间 **/
		private var lastTime:Number = 0;
		/** 记录停止的时候的时间,最晚的时间 **/
		private var stopTime:Number = 0;
		
		/** 整个Flash的开始时间 **/
		private var _flashStartTime:Number;
		/** 存放倒计时使用的对象,或触发事件使用的对象 **/
		internal var timerList:Vector.<TimerItemBase> = new Vector.<TimerItemBase>;
		
		public function TimerManager()
		{
			initSystemInfo();
			g.event.addEnterFrame(timerDoing);
			_flashStartTime = new Date().getTime() - getTimer();
		}
		
		/**整个Flash的开始时间**/
		public function get flashStartTime():Number
		{
			return _flashStartTime;
		}

		/** 获取系统的一些数据 **/
		public function initSystemInfo():void
		{
			if(g.bridge && g.bridge.stage != null)
			{
				stageFPS = g.bridge.stage.frameRate;
				frameTime = Math.round(1000 / stageFPS * 10000) / 10000;
				g.log.pushLog(this, LogType._Frame, "FPS : " + stageFPS + " 折合每幀 " + frameTime + " 毫秒 ");
			}
		}
		
		/**
		 * 添加一个定时爆炸的时间
		 * @param name
		 * @return 
		 */
		public function addRunTimer(name:String):TimerItemRunTime
		{
			if(stageFPS == 0)
			{
				initSystemInfo();
			}
			var timerBase:TimerItemBase = new TimerItemRunTime();
			timerBase.name = name;
			timerList.push(timerBase);
			return timerBase as TimerItemRunTime;
		}
		
		/** 通过名称添加一个定时炸弹 **/
		public function getRunTimerForName(name:String):TimerItemRunTime
		{
			var temp:* = getTimerForName(name);
			if(temp)
			{
				return temp as TimerItemRunTime;
			}
			return null;
		}
		
		/** 添加一个定时炸弹,如果没有就新建一个 **/
		public function getRunTimer(name:String):TimerItemRunTime
		{
			var temp:TimerItemRunTime = getRunTimerForName(name);
			if(temp)
			{
				return temp;
			}
			else
			{
				return addRunTimer(name);
			}
		}
		/** 查询是否有特定的计时器,如果有就删除掉 **/
		public function delRunTimer(name:String):void
		{
			var temp:TimerItemRunTime = getRunTimerForName(name);
			if(temp)
			{
				temp.del();
			}
		}
		
		/**
		 * 添加一个循环计时的时间
		 * @param name	这个计时器的名称,如果重复,将自动重新起一个新名称.如果没有就随机给一个名称
		 * @return 
		 */
		public function addIntervalTimer(name:String):TimerItemInterval
		{
			if(stageFPS == 0)
			{
				initSystemInfo();
			}
			var timerBase:TimerItemInterval = new TimerItemInterval();
			timerBase.name = name;
			timerList.push(timerBase);
			return timerBase as TimerItemInterval;
		}
		
		/** 通过名称添加一个循环计时 **/
		public function getIntervalTimerForName(name:String):TimerItemInterval
		{
			var temp:* = getTimerForName(name);
			if(temp)
			{
				return temp as TimerItemInterval;
			}
			return null;
		}
		
		/** 添加一个循环计时,如果没有就新建一个 **/
		public function getIntervalTimer(name:String):TimerItemInterval
		{
			var temp:TimerItemInterval = getIntervalTimerForName(name);
			if(temp)
			{
				return temp;
			}
			else
			{
				return addIntervalTimer(name);
			}
		}
		/** 查询是否有特定的计时器,如果有就删除掉 **/
		public function delIntervalTimer(name:String):void
		{
			var temp:TimerItemInterval = getIntervalTimerForName(name);
			if(temp)
			{
				temp.del();
			}
		}
		
		
		/** 通过名称获取计时器对象 **/
		internal function getTimerForName(name:String):TimerItemBase
		{
			for each (var item:TimerItemBase in timerList)
			{
				if (item.name == name)
				{
					return item;
				}
			}
			return null;
		}
		
		/**计时器运行时不断的检测时间**/
		private function timerDoing():void
		{
			for each (var item:TimerItemBase in timerList)
			{
				item.run();
			}
		}
	}
}