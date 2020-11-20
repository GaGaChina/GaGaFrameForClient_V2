package cn.wjj.gagaframe.client.time 
{
	/**
	 * 时间驱动的处于的状态类型
	 * @author GaGa
	 */
	public class TimeEngineType 
	{
		/** 以本时间驱动器的频率传递 **/
		public static const no:int = 1;
		/** 运行中 **/
		public static const run:int = 2;
		/** 暂停中 **/
		public static const pause:int = 3;
		
		
		public function TimeEngineType() { }
	}

}