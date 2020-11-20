package cn.wjj.gagaframe.client.data.manage.ClientToClient
{
	
	import cn.wjj.data.ObjectClone;
	
	/**
	 * 客户端到客户端传输使用的类.
	 * 
	 * 客户端打开一个   ClientToClient  数据传输层.
	 * 
	 * 客户端打开服务器的   API 的 List 列表,这里记录着全部的API列表
	 * 
	 * 连接到另一个		API的ID上.
	 * 或者被另一个		API的ID获取
	 * 
	 * 获取服务器上的API的ID列表.
	 * 
	 * 推送和接受数据
	 */
	public class ClientToClient
	{
		
		public function ClientToClient() { }
		
		/**
		 * 将info的数据传递给ID的API对象.
		 */
		public function sendToAPI(ID:String, info:Object):void
		{
			var o:Object = new Object();
			o.ID = ID;
			o.info = ObjectClone.deepClone(info);
		}
		
		/**
		 * 从一个API的ID里发送到这个swf里的数据
		 * 
		 * 当一个API的数据发送到服务器的时候需要转发到另一个API客户端去
		 */
		public function readToAPI(ID:String, info:Object):void
		{
			
		}
	}
}