package cn.wjj.gagaframe.client.time 
{
	import cn.wjj.g;
	import flash.text.TextField;
	
	/**
	 * 时间模块
	 * 
	 * //添加一个循环计时器,名叫:测试,添加任务后自动启动,以1000毫秒触发一次go函数的频率,共触发5次,触发完毕自动删除
	 * import cn.wjj.g;
	 * import cn.wjj.gagaframe.client.time.TimerItemInterval;
	 * var timerGo:TimerItemInterval = g.time.addIntervalTimer("测试");
	 * timerGo.setIntervalTime(go,1000,5,true,true);
	 * function go():void{
	 * 	 trace(g.time.getTime());
	 * }
	 * //为一个文本框添加倒计时
	 * g.time.addAutoForRemaining(tx, 5000, TimeToString.NumberToSecond, 结束运行函数);
	 * //提前删除
	 * g.time.delAutoForText(tx, false);
	 * 
	 * @author 5Ga.cn
	 */
	public class TimeObj
	{
		/** FLASH模拟时间,框架自己算出来的时间 **/
		internal var flashTime:Number = 0;
		/** 那些倒计时等的计时模块 **/
		internal var timerManager:TimerManager;
		/** 文本倒计时模块 **/
		private var timeTextField:TimeTextField;
		/** 服务器同步模块 **/
		public var serverTime:ServerTimeManager;
		/** 启动后的EnterFrame时间累计总和 **/
		public var frameTime:FrameTimeManager;
		
		public function TimeObj()
		{
			timerManager = new TimerManager();
			timeTextField = new TimeTextField();
			serverTime = new ServerTimeManager();
			frameTime = new FrameTimeManager();
		}
		
		/**
		 * 获取一个时间,可以获取系统时间,模拟时间,和Server同步的时间
		 * @param timeType		cn.wjj.gagaframe.client.time.GetTimeType的这几种类型
		 * @return 
		 */
		public function getTime(timeType:String = ""):Number
		{
			if (timeType == "")
			{
				return new Date().time;
			}
			switch(timeType)
			{
				case GetTimeType.SERVER:
					return serverTime.time;
					break;
				case GetTimeType.SYSTEM:
					//return new Date().getTime();
					break;
				case GetTimeType.GAGAFRAME:
					if(flashTime != 0)
					{
						return flashTime;
					}
					break;
				case GetTimeType.EnterFrame:
					return frameTime.time;
					break;
			}
			return new Date().time;
		}
		
		/**
		 * 添加一个定时触发的时间
		 * @param name
		 * @return 
		 */
		public function addRunTimer(name:String):TimerItemRunTime
		{
			return timerManager.addRunTimer(name);
		}
		/** 通过名称添加一个定时器 **/
		public function getRunTimerForName(name:String):TimerItemRunTime
		{
			return timerManager.getRunTimerForName(name);
		}
		/** 添加一个定时炸弹,如果没有就新建一个 **/
		public function getRunTimer(name:String):TimerItemRunTime
		{
			return timerManager.getRunTimer(name);
		}
		
		/** 查询是否有特定的计时器,如果有就删除掉 **/
		public function delRunTimer(name:String):void
		{
			timerManager.delRunTimer(name);
		}
		
		/**
		 * 添加一个循环计时的时间
		 * @param name 这个计时器的名称,如果重复,将自动重新起一个新名称.如果没有就随机给一个名称
		 * @return 
		 */
		public function addIntervalTimer(name:String):TimerItemInterval
		{
			return timerManager.addIntervalTimer(name);
		}
		
		/** 通过名称添加一个循环计时 **/
		public function getIntervalTimerForName(name:String):TimerItemInterval
		{
			return timerManager.getIntervalTimerForName(name);
		}
		
		/** 添加一个循环计时,如果没有就新建一个 **/
		public function getIntervalTimer(name:String):TimerItemInterval
		{
			return timerManager.getIntervalTimer(name);
		}
		/** 查询是否有特定的计时器,如果有就删除掉 **/
		public function delIntervalTimer(name:String):void
		{
			timerManager.delIntervalTimer(name);
		}
		
		/** 通过名称获取计时器对象 **/
		internal function getTimerForName(name:String):TimerItemBase
		{
			return timerManager.getTimerForName(name);
		}
		/**
		 * 为textField添加结束时间倒计时,输出格式00:00:00
		 * @param textField		(弱引用)引用的文本框
		 * @param endTime		结束时间
		 * @param textFormat	时间要用的格式化函数(默认:99:59:59 , TimeToString.NumberToBaseLengString == 09:59)
		 * @param complete		完成倒计时的时候自动调用的函数
		 * @param languageId    作为 bitmaptext绑定的id
		 */
		public function addAutoForPoint(textField:TextField, endTime:Number, textFormat:Function = null, complete:Function = null,languageId:String=""):void
		{
			timeTextField.addAutoTime(textField, endTime, textFormat, complete,languageId);
		}
		
		/**
		 * 为textField添加剩余毫秒数倒计时,输出格式00:00:00
		 * @param textField			文本框
		 * @param remainingTime		剩余毫秒数
		 * @param textFormat		时间将要使用的格式化函数(默认:99:59:59 , TimeToString.NumberToBaseLengString == 09:59)
		 * @param complete			完成倒计时的时候自动调用的函数
		 */
		public function addAutoForRemaining(textField:TextField, remainingTime:Number, textFormat:Function = null, complete:Function = null):void
		{
			var endTime:Number = g.time.getTime() + remainingTime;
			timeTextField.addAutoTime(textField, endTime, textFormat, complete);
		}
		
		/**
		 * 删除一个文本的自动倒计时
		 * @param	textField		文本的引用
		 * @param	runComplete		是否自动运行结束函数
		 */
		public function delAutoForText(textField:TextField, runComplete:Boolean = false):void
		{
			timeTextField.delAutoTime(textField, runComplete);
		}
	}
}