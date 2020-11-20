package cn.wjj.gagaframe.client.data.manage
{
	import cn.wjj.data.DictValue;
	import cn.wjj.data.ForeverSocket;

	internal class DebugItem
	{
		/** 最后一次发送的时间 **/
		internal var time:Number = 0;
		/** Bridge里的强制连接的对象 **/
		internal var bridgeLink:Object;
		/** Bridge里的非强制连接的对象 **/
		internal var bridgeNoLink:Object;
		/** 这个对象的连接对象 **/
		internal var socket:ForeverSocket;
		/** 最后一条发送的日志 **/
		internal var endLog:DictValue = new DictValue();
		/** 最后一条发送的性能日志 **/
		internal var endSysLog:DictValue = new DictValue();
		
		public function DebugItem():void{}
	}
}