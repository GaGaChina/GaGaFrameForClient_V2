package cn.wjj.gagaframe.client.time 
{
	/**
	 * 内部的函数传递频率的方式
	 * 
	 * allTimes
	 * 
	 * @author GaGa
	 */
	public class TimeEngineRunType 
	{
		
		/** 时间引擎被震荡的时间,首先使得时间震荡停止到下个震荡点前,然后 **/
		/**
		 * 时间引擎受到震荡的时候,首先计算出受到的时间在此时间引擎中被震荡的次数
		 * 一直使得时间引擎停在最靠近目标时间的地方
		 * 
		 * 这样,这个引擎内的内容永远要比本引擎的时间慢一些
		 * 
		 */
		public static const all:int = 1;
		/** 时间引擎的内部震荡传递,函数执行的次数和引擎的频率相关 **/
		public static const every:int = 2;
		
		public function TimeEngineRunType() { }
	}
}