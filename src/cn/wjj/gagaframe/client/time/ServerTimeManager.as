package cn.wjj.gagaframe.client.time
{
	import cn.wjj.g;
	
	public class ServerTimeManager
	{
		/** 同步服务器时间 **/
		private var _serverTime:IServerTime;
		/** FLASH系统模拟的真实时间 **/
		private var sysTime:Number   = 0;
		/** FLASH系统开始时间 **/
		private var sysStar:Number   = 0;
		/** FLASH系统度过时间 **/
		private var sysAll:Number    = 0;
		/** 服务器和系统时间的差距 **/
		private var serverBug:Number = 0;
		/** 不符合数量 **/
		private var bugMax:int       = 0;
		/** 每一帧的时间 **/
		private var frameTime:Number;
		/** 服务器时间 **/
		public var getServerTime:Number = 0;
		/** 服务器所在的时区与本地时区的时间差 */
		public var difference:Number = 0;
		//-----------------------本系统内部使用
		/**  **/
		private var lastTime:Number = 0;
		/** 当前的时间 **/
		private var thisTime:Number = 0;
		/**  **/
		private var syslastTime:Number = 0;
		
		/**这个Flash是多少幀的**/
		private var stageFPS:int = 0;
		
		public function ServerTimeManager():void
		{
			initSystemInfo();
		}
		
		/** 获取系统的一些数据 **/
		private function initSystemInfo():void
		{
			if(g.bridge && g.bridge.stage != null)
			{
				stageFPS = g.bridge.stage.frameRate;
				frameTime = Math.round(1000 / stageFPS * 10000) / 10000;
			}
		}
		
		/** 服务器同步时间操作对象 **/
		public function get serverTime():IServerTime
		{
			return _serverTime;
		}
		public function set serverTime(value:IServerTime):void
		{
			_serverTime = value;
			if(_serverTime.enable && _serverTime.isWork == false)
			{
				_serverTime.startServerTime();
			}
		}
		
		/**
		 * 当调用_serverTime的时候,_serverTime完成了时间同步,_serverTime将把同步时间返回到这里
		 * 
		 * @param startTime			连接有数据产生的时间点
		 * @param completeTime		连接完成的时间点
		 * @param serverTime		服务器告诉的服务器时间点
		 * @param difference		服务器所在的时区与本地时区的时间差
		 * 
		 */
		public function pushServerTime(startTime:Number, completeTime:Number, serverTime:Number,_difference:Number):void
		{
			difference = _difference;
			if(stageFPS == 0)
			{
				initSystemInfo();
			}
			//停掉当前进行中的
			stop();
			sysStar = new Date().getTime();
			//发送时间间隔
			var useTime:int = completeTime - startTime;
			//与服务器的时间差
			var differTime:Number = (completeTime + useTime) - serverTime;
			var now_date:Date = new Date();
			thisTime = now_date.getTime();
			lastTime = thisTime;
			serverBug = thisTime - sysStar - differTime;
			getServerTime = Number((serverTime + difference).toFixed(0));
			g.event.addEnterFrame(runFrame);
		}
		/** 现在的服务器时间 **/
		public function get time():Number
		{
			return getServerTime;
		}
		private function runFrame():void {
			var now_date:Date = new Date();
			thisTime = now_date.getTime();
			syslastTime = lastTime;
			//本地模拟时间
			if(Math.abs(thisTime - syslastTime) < 5*frameTime)
			{
				lastTime = thisTime;
				sysAll = sysAll + (thisTime - syslastTime);
				syslastTime = thisTime;
			}
			else
			{
				//如果间隔超过十分钟就重新去获取服务器时间
				if(Math.abs(thisTime - syslastTime) > 300000)
				{
					stop();
					_serverTime.startServerTime();
				}
				else
				{
					bugMax++;
					lastTime = thisTime;
					//自动和服务器时间同步
					if(bugMax%10 == 0 && _serverTime)
					{
						stop();
						_serverTime.startServerTime();
					}
				}
				sysAll = sysAll + thisTime - (lastTime + frameTime);
				syslastTime = thisTime;
			}
			sysTime = sysStar + sysAll;
			getServerTime = Number((sysTime + serverBug + difference).toFixed(0));
		}
		/**
		 *  
		 * 停掉当前服务器同步的时间 
		 * 
		 */
		public function stop():void
		{
			g.event.removeEnterFrame(runFrame);
			bugMax = 0;
			sysTime = 0;
			serverBug = 0;
			sysAll = 0;
			sysStar = 0;
		}
	}
}

