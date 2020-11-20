package cn.wjj.gagaframe.client.time
{
	public class GetTimeType
	{
		/** 电脑的系统时间,就是右下角的时间 **/
		public static const SYSTEM:String = "System";
		/** 框架模拟时间 **/
		public static const GAGAFRAME:String = "Frame";
		/** 服务器时间,有时间同步的时候的时间 **/
		public static const SERVER:String = "Server";
		/** 全部的EnterFrame所累计的时间 **/
		public static const EnterFrame:String = "EnterFrame";
	}
}