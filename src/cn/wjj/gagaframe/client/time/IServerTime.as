package cn.wjj.gagaframe.client.time
{
	/**
	 * 服务器时间同步对象
	 */	
	public interface IServerTime
	{
		/** 服务器时间是否可用 **/
		function get enable():Boolean;
		/** 服务器时间是否可用 **/
		function set enable(vers:Boolean):void;
		
		/** 是否正在同步 **/
		function get isWork():Boolean;
		
		/** 开始运行服务器时间同步 **/
		function startServerTime():void;
	}
}