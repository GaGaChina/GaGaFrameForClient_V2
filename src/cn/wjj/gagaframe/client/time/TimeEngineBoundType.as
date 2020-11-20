package cn.wjj.gagaframe.client.time 
{
	/**
	 * 时间驱动器的绑定时间驱动的传递时间的类型
	 * 
	 * @author GaGa
	 */
	public class TimeEngineBoundType 
	{
		
		/** 以本时间驱动器的频率传递 **/
		public static const sameFrequency:int = 1;
		/** 以外界传入时间驱动器的频率 **/
		public static const highFrequency:int = 1;
		/** 以外界频率在本驱动器发生频率全部震动后 **/
		public static const lowFrequency:int = 1;
		
		public function TimeEngineBoundType() {}
	}
}