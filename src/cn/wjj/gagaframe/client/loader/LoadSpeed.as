package cn.wjj.gagaframe.client.loader
{
	
	import cn.wjj.g;
	import flash.utils.Dictionary;
	
	/**
	 * 记载用户下载网速的模块.
	 * 
	 * @version 0.0.1
	 * @author GaGa wjjhappy@Gmail.com
	 * @copy 王加静 www.5ga.cn
	 * @date 2012-08-09
	 */
	internal class LoadSpeed
	{
		/** 记录全部下载原始对象上次记录的下载大小,以便对比获取刚下载了多少量 **/
		private var loaderLib:Dictionary = new Dictionary(true);
		/** 每次发生尺寸变化的时间和尺寸 **/
		private var progressList:Object = new Object();
		
		public function LoadSpeed(){}
		
		/**
		 * 从一个下载对象中获取下载的数量,并记录起来
		 * @param loaderObj
		 * @param bytesLoaded
		 */
		internal function pushProgress(loaderObj:*, bytesLoaded:Number):void
		{
			if (g.loader.config_runSpeed)
			{
				if(!loaderLib[loaderObj])
				{
					loaderLib[loaderObj] = 0;
				}
				var time:Number = g.time.getTime();
				if (!progressList.hasOwnProperty(time))
				{
					progressList[time] = 0;
				}
				progressList[time] = progressList[time] + (bytesLoaded - Number(loaderLib[loaderObj]));
				loaderLib[loaderObj] = bytesLoaded;
				autoDelProgress();
			}
		}
		
		/** 自动删除时间长的数据包记录 **/
		private function autoDelProgress():void
		{
			for (var i:* in progressList) 
			{
				if((i + g.loader.config_autoDelProgressTime) < g.time.getTime())
				{
					delete progressList[i];
				}
			}
		}
		
		/**
		 * 获取Loader里下载的时候的网速
		 * @return 
		 * 
		 */		
		internal function getLoaderSpeed():Number
		{
			if(!g.loader.config_runSpeed)
			{
				return 0;
			}
			var speed:Number = 0;
			var minTime:Number = 0;
			var maxTime:Number = 0;
			for (var i:* in progressList) 
			{
				if((Number(i) + g.loader.config_useSpeedTime) > g.time.getTime()){
					speed = speed + Number(progressList[i]);
					if(minTime == 0 || minTime > Number(i))
					{
						minTime = Number(i);
					}
					if(maxTime == 0 || maxTime < Number(i))
					{
						maxTime = Number(i);
					}
				}
				else if(g.loader.config_autoDelProgressTime == g.loader.config_useSpeedTime)
				{
					delete progressList[i];
				}
			}
			if((maxTime - minTime) > 1000)
			{
				return speed / ((maxTime - minTime) / 1000);
			}
			return speed;
		}
	}
}