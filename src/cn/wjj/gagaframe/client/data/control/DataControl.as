package cn.wjj.gagaframe.client.data.control
{
	import cn.wjj.data.ObjectClone;
	import cn.wjj.gagaframe.client.data.control.SocketClient.SocketClient;
	import flash.utils.ByteArray;
	
	/**
	 * 数据传递,和数据总集成
	 * 
	 * 进行一个初步的加密.调用不通的数据层传输比如,JSON,soctet
	 * Socket 连接对象库.
	 * 
	 * 
	 * SocketList[ApiID].IP				连接的IP
	 * SocketList[ApiID].Port			连接的Port
	 * SocketList[ApiID].SocketClient	连接的SocketClient对象
	 * 
	 */
	public class DataControl
	{
		
		private var InfoType:String = "Socket";			//数据连接层的地方,Socket走Socket,JSON走JSON.
		private var SocketList:Object = new Object();		//Socket 连接对象的列表. 
		
		private static var instance:DataControl;
		
		//在这里初始化key
		public function DataControl() { }
		
		//连接到一个API,通过socket.并记录这个socket的库
		public function linkSocketToApi(ApiID:String, IP:String, Port:int):void
		{
			if (getSocketForID(ApiID))
			{
				getSocketForID(ApiID).closeSocket();
				SocketList[ApiID].SocketClient = null;
			}
			else
			{
				SocketList[ApiID] = new Object();
			}
			SocketList[ApiID].IP = IP;
			SocketList[ApiID].Port = Port;
			SocketList[ApiID].SocketClient = new SocketClient(IP,Port);
			SocketList[ApiID].SocketClient.addEventListener(SocketClient.READ,readOver2);
		}
		
		//通过一个APIID,获取这个SocketClient
		public function getSocketForID(ApiID:String):SocketClient
		{
			if (SocketList.hasOwnProperty(ApiID))
			{
				return SocketList[ApiID].SocketClient;
			}
			else
			{
				return null;
			}
		}
		
		//通过SocketClient返回API
		public function getAPIIDForSocketClient(theSocketObj:SocketClient):Number
		{
			for (var theId:* in SocketList)
			{
				if (SocketList[theId].SocketClient == theSocketObj)
				{
					return Number(theId);
				}
			}
			return 0;
		}
		
		//数据层获取到数据后,准备移交给数据处理层
		public function readOver(temp:SocketClient, startLength:uint, info:ByteArray, InfoType:String = "Socket"):void
		{
			switch(InfoType)
			{
				case "Socket":
					if (info.length == startLength)
					{
						//theSocketObj
						var tempObj:Object = info.readObject();
					}
					else
					{
						//发现真实的长度有变化.
						return;
					}
					break;
				case "JSON":
					//数据加密
					//数据长度
					//JSON发送
					break;
			}
			//frame.dataManage.getIn(getAPIIDForSocketClient(temp),tempObj);
		}
		
		public function readOver2(e:SocketClient):void
		{
			//
		}
		
		//给一个API发送数据.数据类型为对象.
		public function sendOut(ApiID:String, info:Object, InfoType:String = "Socket"):void
		{
			var startLength:uint = 0;	//数据初始长度.
			var endLength:uint = 0;		//数据机密后长度
			switch(InfoType)
			{
				case "Socket":
					var SocketTemp:ByteArray = new ByteArray();								//复制要传输的数据
					SocketTemp.writeObject(ObjectClone.deepClone(info));			//拷贝进二进制里,AMF格式
					startLength = SocketTemp.length;										//原始包长
					endLength = SocketTemp.length;											//加密后的包体长度
					getSocketForID(ApiID).send(startLength, endLength, SocketTemp);			//推送数据
					break;
			}
		}
	}
}