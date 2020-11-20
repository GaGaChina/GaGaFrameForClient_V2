package cn.wjj.gagaframe.client.data.manage
{
	import cn.wjj.data.ForeverSocket;
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	import cn.wjj.gagaframe.client.speedfact.SByte;
	import cn.wjj.gagaframe.client.time.TimerItemInterval;
	import flash.utils.ByteArray;
	
	/**
	 * 把框架里的一些数据推送出去
	 * 
	 * 这个包只负责内容的交互
	 * 
	 */
	public class DataManage
	{
		/** 和服务器相连的socket列表 **/
		private var list:Vector.<DebugItem> = new Vector.<DebugItem>();
		/** 刷新数据的时间间隔 **/
		private var autoTimer:TimerItemInterval;
		
		public function DataManage() { }
		
		/**
		 * 连接一个Server客户端
		 * @param ip
		 * @param port
		 * 
		 */
		public function connect(ip:String, port:uint):void
		{
			var socket:ForeverSocket = new ForeverSocket();
			socket.onCloseMethod = socketClose;
			socket.onDataMethod = socektData;
			socket.onConnectMethod = socketConnect;
			socket.connect(ip, port);
		}
		
		/** 有多少个连接上的 **/
		public function connectLength():uint
		{
			var l:uint = 0;
			for each (var item:DebugItem in list) 
			{
				if(item.socket && item.socket.socket && item.socket.socket.connected)
				{
					l++;
				}
			}
			return l;
		}
		
		/**
		 * 把用户的唯一码发过去,做位统计数据
		 * @param	key
		 */
		public function sendUserKey(key:String):void
		{
			var obj:Object = new Object();
			obj.cmd = Distributor.GetUserKey;
			obj.info = new Object();
			obj.info.key = key;
			for each (var item:DebugItem in list) 
			{
				infoSend(item, obj);
			}
		}
		
		/**
		 * 当socket产生连接的时候
		 * @param socket
		 */
		private function socketConnect(socket:ForeverSocket):void
		{
			var item:DebugItem = new DebugItem();
			item.socket = socket;
			list.push(item);
			Distributor.frameInfo(item);
			g.log.pushLog(this, LogType._Frame, "DataManage 连接上Debug IP:" + socket.ip + " Port:" + socket.port);
		}
		
		/**
		 * 当关闭Socket客户端的时候
		 * @param socket
		 */
		private function socketClose(socket:ForeverSocket):void
		{
			var del:DebugItem;
			for (var i:* in list)
			{
				if(list[i].socket === socket)
				{
					del = list.splice(i,1) as DebugItem;
				}
			}
		}
		
		/**
		 * 当有数据收到的时候
		 * @param socket
		 */
		private function socektData(socket:ForeverSocket):void
		{
			infoGet(socket);
		}
		
		
		/**
		 * 通过一个ForeverSocket,来获取存放在list里的item对象
		 * @param socket
		 * @return 
		 * 
		 */
		private function getDebugItem(socket:ForeverSocket):DebugItem
		{
			for each (var item:DebugItem in list) 
			{
				if(item.socket === socket)
				{
					return item;
				}
			}
			return null;
		}
		
		/**
		 * 给一个对象发送一段信息
		 * @param socket
		 * @param info
		 * 
		 */
		public function infoSend(item:DebugItem, info:Object):void
		{
			if(item)
			{
				var byte:SByte = SByte.instance();
				byte.writeObject(info);
				byte.position = 0;
				var out:SByte = SByte.instance();
				//写入长度
				out._w_Uint32(byte.length);
				//写入内容
				out.writeBytes(byte);
				item.socket.flush(out as ByteArray);
				byte.dispose();
				out.dispose();
			}
		}
		
		/**
		 * 从外面获取到数据,进行分析拆解
		 * 
		 * uint8 : 里面叠加包的个数,标识可以拆解出来几个包
		 * uint32: 包的尺寸
		 * 
		 */
		public function infoGet(socket:ForeverSocket):void
		{
			var headSize:uint = 4;
			var info:SByte = socket.byte;
			if(info.length >= headSize)
			{
				info.position = 0;
				var l:uint = info._r_Uint32();
				if(info.length >= (headSize + l))
				{
					var out:SByte = SByte.instance();
					out.endian = info.endian;
					info.readBytes(out, 0, l);
					var newByte:SByte = SByte.instance();
					newByte.endian = info.endian;
					info.readBytes(newByte);
					newByte.position = 0;
					info.length = 0;
					info.writeBytes(newByte);
					var o:Object = out.readObject();
					Distributor.getInfo(getDebugItem(socket), o);
					infoGet(socket);
				}
			}
		}
	}
}