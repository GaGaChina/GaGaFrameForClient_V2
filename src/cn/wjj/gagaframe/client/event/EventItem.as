package cn.wjj.gagaframe.client.event
{
	
	public class EventItem
	{
		/**确定侦听器是运行于捕获阶段、目标阶段还是冒泡阶段**/
		public var useCapture:Boolean = false;
		/**事件侦听器的优先级**/
		public var priority:int = 0;
		/**确定对侦听器的引用是强引用，还是弱引用**/
		public var useWeakReference:Boolean = false;
		
		public function EventItem():void{}
	}
}