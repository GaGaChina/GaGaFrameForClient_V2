package cn.wjj.gagaframe.client.time 
{
	/**
	 * 时间类型
	 * @author GaGa
	 */
	public class TimeEngineTimeType 
	{
		
		/** 以本时间驱动器的频率传递 **/
		public static const useFPS:int = 1;
		/** 以毫秒叠加来驱动 **/
		public static const useFrequency:int = 2;
		/** 使用系统自带的EnterFrame **/
		public static const useEnterFrame:int = 3;
		
		public function TimeEngineTimeType() { }
	}

}