package cn.wjj.gagaframe.client.time{
//	
//	import cn.wjj.gagaframe.client.GaGaFrame;
//	
	public class TimerItem {
//		
//		/** 框架的引用 **/
//		private var frame:GaGaFrame;
//		/** 计时器名称 **/
//		private var _name:String;
//		/** 回调函数 **/
//		private var method:Function;
//		/** 是否运行完毕后自动删除这个事件.清理这个连接 **/
//		private var autoDel:Boolean = true;
//		/** 从什么地方获取时间 **/
//		private var _getTimeType:String = GetTimeType.GAGAFRAME;
//		//-------------------------------------固定时间点触发
//		/** 在某一个时间点到达的时候运行 **/
//		private var runTime:Number = 0;
//		//-------------------------------------周期触发类型
//		/** 周期,或者是间隔 **/
//		private var interval:Number = 0;
//		/** 上一个周期的时候运行的时间 **/
//		private var intervalOld:Number = 0;
//		/** 运行次数 **/
//		private var times:int = 0;
//		/** 计时器现在的状态 **/
//		private var _timerType:String = TimerType.NO;
//		//-------------------------------------当秒值发生变化的时候触发
//		/** 当秒的值发生变化的时候触发 **/
//		private var secondsRun:Boolean = false;
//		/** 每秒触发函数 **/
//		private var secondsMethod:Function;
//		/**旧的秒的时间**/
//		private var secondsOld:Number = 0;
//		//-------------------------------------计数器自己使用的一些值
//		/** 开始时间,会被调整 **/
//		private var starTime:Number = 0;
//		/** 暂停时间,上面区别啊,我草 **/
//		private var pauseTime:Number = 0;
//		/** 这个是干嘛的了? **/
//		private var pauseStarTime:Number = 0;
//		
//		public function TimerItem(frame:GaGaFrame){
//			this.frame = frame;
//		}
//		
//		public function get name():String{
//			return _name;
//		}
//		public function set name(value:String):void{
//			if(frame.time.getTimerForName(value)){
//				var nameOld:String = value;
//				value = "timerItem" + frame.time.getTime();
//				frame.log.pushLog(this,frame.log.logType._Warning,"你添加的计时器名称"+ nameOld +"已经存在,系统自动生成名称:" + value);
//			}
//			_name = value;
//		}
//		/** 从什么地方获取时间 **/
//		public function get getTimeType():String{
//			return _getTimeType;
//		}
//		/** 从什么地方获取时间 **/
//		public function set getTimeType(value:String):void{
//			frame.log.pushLog(this,frame.log.logType._Frame,"请在初始化这个计时器前设置getTimeType,否则不准确!");
//			switch(value){
//				case GetTimeType.SYSTEM:
//					_getTimeType = GetTimeType.SYSTEM;
//					break;
//				case GetTimeType.SERVER:
//					_getTimeType = GetTimeType.SERVER;
//					break;
//				default:
//					_getTimeType = GetTimeType.GAGAFRAME;
//			}
//		}
//		
//		/** 设置时间的状态:计时,暂停,未启动 **/
//		public function get timerType():String{
//			return _timerType;
//		}
//		/** 设置时间的状态:计时,暂停,未启动 **/
//		public function set timerType(value:String):void{
//			switch(value){
//				case TimerType.NO:
//					starTime = 0;
//					pauseTime = 0;
//					pauseStarTime = 0;
//					break;
//				case TimerType.PLAY:
//					if(pauseStarTime != 0){
//						pauseTime = pauseTime + getTime() - pauseStarTime;
//						pauseStarTime = 0;
//					}
//					if(starTime == 0){
//						starTime = getTime();
//					}
//					break;
//				case TimerType.PAUSE:
//					if(pauseStarTime == 0){
//						pauseStarTime = getTime();
//					}
//					break;
//				default:
//					break;
//			}
//			_timerType = value;
//		}
//		
//		/** 开始记时 **/
//		public function start():void {
//			if (timerType != TimerType.PLAY) {
//				//countTime();
//				timerType = TimerType.PLAY;
//			}
//		}
//		
//		/**暂停一段计时**/
//		public function pause():void {
//			if (timerType != TimerType.PAUSE) {
//				timerType = TimerType.PAUSE;
//			}
//		}
//		
//		/**计时器停止**/
//		public function stop():void {
//			if (timerType != TimerType.NO) {
//				timerType = TimerType.NO;
//			}
//		}
//		
//		/** 获取计时器在运行的时间,包含暂停的时间 **/
//		public function get runAllTime():Number{
//			return getTime() - starTime;
//		}
//		
//		/** 获取计时器在运行Play的时间 **/
//		public function get runPlayTime():Number{
//			var tempPauseTime:Number = 0
//			if(pauseStarTime != 0){
//				tempPauseTime = getTime() - pauseStarTime;
//			}
//			return this.runAllTime - pauseTime - tempPauseTime;
//		}
//		
//		/** 自动判断时间是否要做处理 **/
//		internal function run():void{
//			//处理每过一秒触发一次
//			if(secondsRun && _timerType == TimerType.PLAY){
//				if(Math.round(getTime()/1000) != secondsOld){
//					secondsOld = Math.round(getTime()/1000);
//					secondsMethod();
//				}
//			}
//			if(runTime != 0){
//				//时间点的运行
//				runRunTime();
//			}else{
//				//周期运行
//				if(interval != 0){
//					if(timerType == TimerType.PLAY){
//						runIntervalTime();
//					}
//				}
//			}
//		}
//		
//		/** 检测时间点到的监听,这个没有暂停 **/
//		private function runRunTime():void{
//			if(getTime() >= this.runTime){
//				this.method();
//				del();
//			}
//		}
//		
//		private function runIntervalTime():void{
//			if(intervalOld == 0){
//				intervalOld = starTime;
//			}
//			if(times > 0){
//				//trace(runAllTime,starTime,runPlayTime ,intervalOld);
//				if((starTime + runPlayTime - intervalOld) >= interval){
//					intervalOld = getTime();
//					method();
//					times--;
//				}
//			}else{
//				if(autoDel){
//					del();
//				}
//			}
//		}
//		
//		/**
//		 * 自动在时间点runTime的时候运行函数method,如果现在时间已经过了runTime,就马上运行
//		 * @param runTime	在某一个时间点运行本函数
//		 * @param method	需要回调的函数的引用
//		 * @param autoDel	运行任务完毕后自动删除
//		 */
//		public function setRunTime(runTime:Number,method:Function):void{
//			if(getTime() >= runTime){
//				method();
//				del();
//			}else{
//				this.runTime = runTime;
//				this.method = method;
//			}
//		}
//		
//		/**
//		 * 设置这个定时器为interval秒的周期运行,运行times次,添加完毕后autoRun自动运行,autoDel并且自动删除
//		 * @param method		回调函数
//		 * @param interval		运行周期
//		 * @param times			运行次数
//		 * @param autoRun		添加任务完成后自动运行
//		 * @param autoDel		运行任务完毕后自动删除
//		 */
//		public function setIntervalTime(method:Function, interval:Number = 0, times:int = 0, autoRun:Boolean = true, autoDel:Boolean = true):void{
//			timerType = TimerType.NO;
//			this.method = method;
//			this.interval = interval;
//			this.times = times;
//			this.autoDel = autoDel;
//			if(autoRun){
//				start();
//			}else {
//				stop();
//			}
//		}
//		
//		/**
//		 * 添加运行的时间
//		 * @param theTime	毫秒
//		 */
//		public function addTime(theTime:Number):void{
//			this.interval = this.interval + theTime;
//		}
//		
//		/** 获取一个周期的时间 **/
//		public function get intervalTime():Number{
//			return this.interval;
//		}
//		
//		/**
//		 * 每过一秒运行一次,这个当计时器结束的时候会自动删除
//		 */
//		public function setIntervalSeconds(method:Function):void{
//			this.secondsRun = true;
//			this.secondsMethod = method;
//		}
//		
//		/** 复位计时器的时间设置,初始化所有已设置的值 **/
//		public function reSet():void{
//			method = null;
//			//固定时间点触发
//			runTime = 0;
//			//周期触发类型
//			interval = 0;
//			intervalOld = 0;
//			times = 0;
//			_timerType = TimerType.NO;
//			//当秒值发生变化的时候触发
//			secondsRun = false;
//			secondsMethod = null;
//			
//			starTime = 0;
//			pauseTime = 0;
//			pauseStarTime = 0;
//		}
//		
//		/** 删除这个计时器 **/
//		public function del():void{
//			reSet();
//			if(frame && frame.time._timerManager.timerList.length){
//				for(var item:String in frame.time._timerManager.timerList) {
//					if (frame.time._timerManager.timerList[item] == this) {
//						frame.time._timerManager.timerList.splice(Number(item), 1);
//					}
//				}
//			}
//			frame = null;
//		}
//		
//		/** 根据设置的获取值的位置,获取一个值使用 **/
//		private function getTime():Number{
//			return frame.time.getTime(_getTimeType);
//		}
//
	}
}