package cn.wjj.gagaframe.client.time
{
	public class TimerItemRunTime extends TimerItemBase
	{
		/** 在某一个时间点到达的时候运行 **/
		private var _runTime:Number = 0;
		
		public function TimerItemRunTime()
		{
			super();
		}
		
		/** 自动判断时间是否要做处理 **/
		override internal function run():void{
			//处理每过一秒触发一次
			if(secondsRun){
				if (Math.round(getTime() / 1000) != secondsOld)
				{
					secondsOld = Math.round(getTime()/1000);
					runMethod(this.secondsMethodList);
				}
			}
			if (_runTime != 0)
			{
				runRunTime();
			}
		}
		
		/** 检测时间点到的监听,这个没有暂停 **/
		private function runRunTime():void
		{
			if (getTime() >= this._runTime)
			{
				var tempMethodList:Vector.<Function> = this.methodList;
				del();
				this.runMethod(tempMethodList);
			}
		}
		
		/**
		 * 自动在时间点runTime的时候运行函数method,如果现在时间已经过了runTime,就马上运行
		 * @param runTime	在某一个时间点运行本函数
		 * @param method	需要回调的函数的引用
		 * @param autoDel	运行任务完毕后自动删除
		 */
		public function setRunTime(runTime:Number, method:Function):void
		{
			if (getTime() >= runTime)
			{
				var tempMethod:Function = method;
				del();
				tempMethod();
			}
			else
			{
				this._runTime = runTime;
				this.pushMethod(method);
			}
		}
		
		/**
		 * 添加运行的时间
		 * @param theTime	毫秒
		 */
		public function addTime(timeNumber:Number):void
		{
			this._runTime = this._runTime + timeNumber;
		}
		
		/**
		 * 修改运行时间
		 * @param runTime
		 */
		public function changeRunTime(runTime:Number):void{
			if (getTime() >= runTime)
			{
				var tempMethodList:Vector.<Function> = this.methodList;
				del();
				this.runMethod(tempMethodList);
			}
			else
			{
				this._runTime = runTime;
			}
		}
		
		/** 复位计时器的时间设置,初始化所有已设置的值 **/
		public function reSet():void
		{
			_runTime = 0;
			this.methodList = null;
			secondsRun = false;
			this.secondsMethodList = null;
		}
		
		/** 获取运行的时间点 **/
		public function get runTime():Number
		{
			return _runTime;
		}
		
		/** 删除这个计时器 **/
		override public function del():void
		{
			reSet();
			super.del();
		}

	}
}