package cn.wjj.data
{
	import cn.wjj.data.SocketBata;
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	import cn.wjj.gagaframe.client.speedfact.SByte;
	import cn.wjj.time.TimeToString;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.utils.ByteArray;
	
	/**
	 * 持久连接的Socket对象
	 * 
	 * socket.endian = Endian.BIG_ENDIAN;
	 * 
	 * @version 1.0.0
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 */
	public class ForeverSocket
	{
		/** 服务器IP地址 **/
		public var ip:String = "0.0.0.0";
		/** 服务器端口 **/
		public var port:int = 0;
		/** 服务器连接的地址 **/
		public var startTime:Number;
		/** 这个客户端总共有多少数据量 **/
		public var dataReceive:uint = 0;
		/** 这个客户端总共发送多少数据量 **/
		public var dataSend:uint = 0;
		/** 包头尺寸 **/
		public var packageHeadSize:uint = 0;
		/** Socket对象 **/
		public var socket:SocketBata;
		/** 当客户端有数据过来的时候自动运行的函数,传递参数 : ForeverSocket **/
		public var onDataMethod:Function;
		/** 当客户端有数据过来的时候自动运行的函数,传递参数 : ForeverSocket,如果还没有关闭Socket允许继续发出信息 **/
		public var onCloseMethod:Function;
		/** 当Socket有连接的时候自动运行,传递参数 : ForeverSocket **/
		public var onConnectMethod:Function;
		/** 这个客户端里的数据,取数据完毕后要将所取数据移除掉,剩余数据复制给这个对象,如果没有了,就设置byte.length = 0来新建一个新的 **/
		public var byte:SByte = new SByte();
		
		/**
		 * 创建一个 Socket 对象。 若未指定参数，将创建一个最初处于断开状态的套接字。 若指定了参数，则尝试连接到指定的主机和端口。
		 * @param	host	— 要连接的主机的名称。 若未指定此参数，将创建一个最初处于断开状态的套接字。
		 * @param	port
		 */
		public function ForeverSocket(ip:String = "", port:int = 0):void
		{
			if (ip && ip.length > 0 && port > 0)
			{
				connect(ip, port);
			}
		}
		
		/**
		 * 创建服务器Socket连接
		 * @param	ip			服务IP地址
		 * @param	port		端口名
		 */
		public function connect(ip:String = "", port:int = 0):void
		{
			if (ip && ip.length > 0 && port > 0 && (this.ip != ip || this.port != port))
			{
				this.ip = ip;
				this.port = port;
				close();
				socket = new SocketBata();
				socket.addEventListener(Event.CLOSE, closeHandler);
				socket.addEventListener(Event.CONNECT, connectHandler);
				socket.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
				socket.addEventListener(ProgressEvent.SOCKET_DATA, dataHandler);
				try 
				{
					socket.connect(ip, port);
				}
				catch (e:Error)
				{
					g.log.pushLog(this, LogType._SocketInfo, "ForeverSocket 错误 : " + e.toString());
					close();
					return;
				}
				startTime = new Date().time;;
				g.log.pushLog(this, LogType._SocketInfo, "ForeverSocket 启动 : " + TimeToString.NumberToChinaTime(startTime));
			}
			else
			{
				g.log.pushLog(this, LogType._SocketInfo, "ForeverSocket 配置IP错误或重复");
			}
		}
		
		/** 关闭Socket **/
		public function close():void
		{
			if(socket != null)
			{
				if (onCloseMethod != null)
				{
					onCloseMethod(this);
				}
				/*
				socket.removeEventListener(Event.CONNECT, connectHandler);
				socket.removeEventListener(Event.CLOSE, closeHandler);
				socket.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
				socket.removeEventListener(ProgressEvent.SOCKET_DATA, dataHandler);
				*/
				socket.close();
				socket = null;
			}
		}
		
		/** 将byteFlush的数据发送出去 **/
		public function flush(byte:ByteArray):void
		{
			if(socket && socket.connected)
			{
				dataSend += byte.length;
				byte.position = 0;
				socket.writeBytes(byte as ByteArray);
				socket.flush();
			}
		}
		
		/** 测试连接成功与否 **/
		private function connectHandler(e:Event):void
		{
			if (e.currentTarget == socket)
			{
				if (socket.connected)
				{
					if (onConnectMethod != null)
					{
						onConnectMethod(this);
					}
					g.log.pushLog(this, LogType._SocketInfo, "ForeverSocket 连接成功 : " + e.toString());
				}
				else
				{
					g.log.pushLog(this, LogType._SocketInfo, "ForeverSocket 连接失败 : " + e.toString());
				}
			}
		}
		
		/** 数据有数据产生 **/
		private function dataHandler(e:ProgressEvent):void
		{
			if(socket.bytesAvailable >= packageHeadSize)
			{
				byte.position = byte.length;
				socket.readBytes(byte, 0, socket.bytesAvailable);
				if (onDataMethod != null)
				{
					onDataMethod(this);
				}
			}
		}
		
		/** 关闭连接 **/
		private function closeHandler(e:Event):void
		{
			g.log.pushLog(this, LogType._SocketInfo, "ForeverSocket 关闭 : " + e.toString());
			if (e.currentTarget == socket) close();
		}
		
		/** IO错误了 **/
		private function ioErrorHandler(e:IOErrorEvent):void
		{
			g.log.pushLog(this, LogType._SocketInfo, "ForeverSocket IO错误 : " + e.toString());
			if (e.currentTarget == socket)
			{
				close();
			}
			else
			{
				e.currentTarget.removeEventListener(Event.CONNECT, connectHandler);
				e.currentTarget.removeEventListener(Event.CLOSE, closeHandler);
				e.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				e.currentTarget.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
				e.currentTarget.removeEventListener(ProgressEvent.SOCKET_DATA, dataHandler);
			}
		}
		
		/** 沙箱错误 **/
		private function securityErrorHandler(e:SecurityErrorEvent):void
		{
			g.log.pushLog(this, LogType._SocketInfo, "ForeverSocket 沙箱错误 : " + e.toString());
			if (e.currentTarget == socket)
			{
				close();
			}
			else
			{
				e.currentTarget.removeEventListener(Event.CONNECT, connectHandler);
				e.currentTarget.removeEventListener(Event.CLOSE, closeHandler);
				e.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				e.currentTarget.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
				e.currentTarget.removeEventListener(ProgressEvent.SOCKET_DATA, dataHandler);
			}
		}
	}
}