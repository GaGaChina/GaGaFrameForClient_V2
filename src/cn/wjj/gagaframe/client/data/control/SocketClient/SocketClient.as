package cn.wjj.gagaframe.client.data.control.SocketClient
{
	
	import cn.wjj.data.ObjectClone;
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	
	/**
	 * Socket 传输层
	 */
	public class SocketClient extends EventDispatcher
	{
		
		public static var READ:String = "read";
		
		private var IP:String = "";
		private var Port:int = 0;
		private var socket:Socket;
		
		private var packageOver:Boolean = true;						//是否传输完包
		private var packageDataType:int = 0;						//包类型
		private var packageStartLength:uint = 0;					//原始包长度
		private var packageEndLength:uint = 0;						//加密包长度
		private var packageMD5:ByteArray = new ByteArray();			//MD5加密码
		private var packageData:ByteArray = new ByteArray();		//内容
		private var packageMaxLength:uint = 1024;					//超长包尺寸;
		private var packageHeadLen:int = 26;						//包头长度
		
		public function SocketClient(_IP:String,_Port:int)
		{
			IP = _IP;
			Port = _Port;
			socket = new Socket();
			socket.connect(IP,Port);
			socket.addEventListener(Event.CONNECT,onConnect);
			socket.addEventListener(Event.CLOSE,onClose);
			socket.addEventListener(IOErrorEvent.IO_ERROR,onError);
			socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onseError);
			socket.addEventListener(ProgressEvent.SOCKET_DATA,read);
		}
		
		private function onConnect(e:Event):void
		{
			g.log.pushLog(this, LogType._SocketInfo, "连接成功", IP, Port);
		}
		
		private function onError(e:IOErrorEvent):void
		{
			g.log.pushLog(this, LogType._SocketInfo, "连接失败，IO错误", e.text);
			closeSocket();
		}
		
		private function onseError(e:SecurityErrorEvent):void
		{
			g.log.pushLog(this, LogType._SocketInfo, "连接失败，安全错误", e.text);
			closeSocket();
		}
		
		private function onClose(e:Event):void
		{
			closeSocket();
		}
		
		//关闭这个Socket对象
		public function closeSocket():void
		{
			//isConnect = false;
			g.log.pushLog(this, LogType._SocketInfo, "Socket 执行关闭连接.", IP, Port);
			socket.removeEventListener(Event.CONNECT, onConnect);
			socket.removeEventListener(Event.CLOSE, onClose);
			socket.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			socket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onseError);
			socket.removeEventListener(ProgressEvent.SOCKET_DATA, read);
			socket.close();
			socket = null;
		}
		
		//重置超长包
		private function reSetPackage():void
		{
			packageOver = true;
			packageDataType = 0;
			packageStartLength = 0;
			packageEndLength = 0;
			packageMD5 = null;
			packageMD5 = new ByteArray();
			packageData = null;
			packageData = new ByteArray();
		}
		
		//收到Socket的数据的时候.
		private function read(e:ProgressEvent):void
		{
			//包类型			普通包 1    合并包 2
			var readFlag:Boolean = false;//开始读取数据的标记
			while (socket.bytesAvailable)
			{
				packageData.position = 0;//指针回归
				if (packageOver)
				{
					//处理新包
					if (!readFlag && socket.bytesAvailable >= packageHeadLen)
					{
						packageDataType = socket.readShort();				//读取包头类型
						packageStartLength = socket.readUnsignedInt();		//读取原始包体长度
						packageEndLength = socket.readUnsignedInt();		//读取加密包体长度.
						socket.readBytes(packageMD5,0, 16);					//MD5验证码,16字节二进制.
						readFlag = true;
					}
					if (readFlag && socket.bytesAvailable >= packageEndLength)
					{
						//已经取得包头,数据也够
						socket.readBytes(packageData, 0, packageEndLength);		//取出指定长度的字节
						readOver(packageDataType,packageStartLength,packageEndLength,packageMD5,packageData);//读完毕一个包
						reSetPackage();
						readFlag = false;
					}
					else
					{
						if (packageDataType == 2)
						{						//超长包
							packageOver = false;
							socket.readBytes(packageData, 0, socket.bytesAvailable);
						}else {
							//长度不对,剩余长度还不够真实长度
							socket.readUTFBytes(socket.bytesAvailable);
							readFlag = false;
							reSetPackage();
							g.log.pushLog(this, LogType._SocketInfo, "Socket ← 接收数据,长度不对,废弃包!");
						}
					}
				}
				else
				{
					//连接层超长包
					if ((packageData.length + socket.bytesAvailable) > packageEndLength)
					{
						socket.readBytes(packageData, 0, (packageEndLength - packageData.length));
					}
					else
					{
						socket.readBytes(packageData, 0, socket.bytesAvailable);
					}
					if (packageData.length == packageEndLength)
					{
						readOver(packageDataType,packageStartLength,packageEndLength,packageMD5,packageData);//读完毕一个包
						reSetPackage();
						readFlag = false;
					}
				}
			}
			
		}
		
		//发送数据
		public function send(startLength:uint, endLength:uint, info:ByteArray):void
		{
			var infoType:int = 1;					//包的类型,1普通包,2连接包.
			//现在包的大小    2 + 4 + 4 + 16 + desLength
			if((packageMaxLength - packageHeadLen) < endLength)
			{
				infoType = 2;
			}
			else
			{
				infoType = 1;
			}
			var temp:ByteArray = new ByteArray();	//复制要传输的数据
			temp.writeShort(infoType);				//包类型
			temp.writeUnsignedInt(startLength);		//原始包体长度
			temp.writeUnsignedInt(endLength);		//加密包体长度.
			//temp.writeBytes(md5.hash(info));		//写入MD5 这个 16 个字节长度的二进制
			temp.writeBytes(info);
			var inputLength:uint;
			while(temp.length)
			{
				temp.position = 0;
				if(temp.length > packageMaxLength)
				{
					inputLength = packageMaxLength;
				}
				else
				{
					inputLength = temp.length;
				}
				socket.writeBytes(temp, 0, inputLength);
				socket.flush();
			}
			g.log.pushLog(this, LogType._SocketInfo, "Socket ↑ 数据原始长度:", startLength);
			temp = null;
			info = null;
		}
		
		/**
		 * 回传要处理的包,拆解包类型,读取完毕
		 * @param	dataType		包头类型
		 * @param	dataLength		接收到的数据长度
		 * @param	dataBuffer		数据缓存
		 */
		private function readOver(type:int,start:uint,end:uint,dataMD5:ByteArray,packageData:ByteArray):void
		{
			//长度不对,放弃
			if(packageData.length != end)
			{
				return;
			}
			g.dataControl.readOver(this, start, ObjectClone.deepClone(packageData), "Socket");
		}
	}
}