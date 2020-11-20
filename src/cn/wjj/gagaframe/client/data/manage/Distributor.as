package cn.wjj.gagaframe.client.data.manage
{
	import cn.wjj.g;
	
	public class Distributor
	{
		/** 获取框架信息 **/
		public static const FrameInfo:uint = 1;
		/** 获取日志 **/
		public static const GetLog:uint = 2;
		/** 获取全部日志 **/
		public static const GetAllLog:uint = 3;
		/** 获取常连的数据桥 **/
		public static const GetBridgeLink:uint = 6;
		/** 获取弱连的数据桥 **/
		public static const GetBridgeNoLink:uint = 7;
		/** 获取用户的key **/
		public static const GetUserKey:uint = 8;
		/** 心跳包 **/
		public static const HeartBeat:uint = 9;
		/** 获取字体 **/
		public static const CLOSE_SOCKET:uint = 99;
		
		public static const CLOSE_ALL_SOCKET:uint = 100;
		
		/**
		 * 从服务器获取数据
		 * 数据:
		 * cmd:命令
		 * 
		 * 
		 * @param frame
		 * @param info
		 * 
		 */
		public static function getInfo(item:DebugItem, info:Object):void
		{
			switch(info.cmd)
			{
				case Distributor.FrameInfo:
					frameInfo(item);
					break;
				case Distributor.GetLog:
					getLog(item, false);
					break;
				case Distributor.GetAllLog:
					getLog(item, true);
					break;
				case Distributor.GetBridgeLink:
					getBridgeInfo(item, true, info.config);
					break;
				case Distributor.GetBridgeNoLink:
					getBridgeInfo(item, false, info.config);
					break;
				case Distributor.CLOSE_SOCKET:
					break;
				case Distributor.CLOSE_ALL_SOCKET:
					break;
			}
		}
		
		/** 获取客户端API信息 **/
		internal static function frameInfo(item:DebugItem):void
		{
			var obj:Object = new Object();
			obj.cmd = Distributor.FrameInfo;
			obj.info = new Object();
			//API的ID号
			obj.info.id = g.id;
			//API版本号
			obj.info.ver = g.ver;
			g.dataManage.infoSend(item, obj);
		}
		
		/** 获取服务器的日志 **/
		private static function getLog(item:DebugItem, getAll:Boolean):void
		{
			var obj:Object = new Object();
			obj.info = new Object();
			var log:Array = new Array();
			if (getAll)
			{
				obj.cmd = Distributor.GetAllLog;
				log.push.apply(null, g.log.getLogUsePosition(null));
			}
			else
			{
				obj.cmd = Distributor.GetLog;
				log.push.apply(null, g.log.getLogUsePosition(item.endLog.value));
			}
			obj.info.log = log;
			if (log.length)
			{
				item.endLog.value = log[log.length - 1];
				g.dataManage.infoSend(item, obj);
			}
		}
		
		/**
		 * 获取数据桥的内容
		 * @param	item		那个对象发出的
		 * @param	isLink		是否是常连对象
		 * @param	config		获取参数的时候的配置
		 */
		private static function getBridgeInfo(item:DebugItem, isLink:Boolean, config:Object):void
		{
			var obj:Object = new Object();
			obj.info = new Object();
			obj.info.bridge = new Object();
			var groupName:String = "";
			if (config.hasOwnProperty("groupName"))
			{
				groupName = String(config.groupName);
			}
			if (isLink)
			{
				obj.cmd = Distributor.GetBridgeLink;
				obj.info.bridge.link = g.bridge.getLinkObj(groupName);
			}
			else
			{
				obj.cmd = Distributor.GetBridgeNoLink;
				obj.info.bridge.nolink = g.bridge.getNoLinkObj(groupName);
			}
			g.dataManage.infoSend(item, obj);
		}
	}
}