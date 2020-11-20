package cn.wjj.gagaframe.client.language 
{
	import flash.text.Font;
	
	/**
	 * 字体的内容
	 * @author GaGa
	 */
	public class FontItem 
	{
		/** 字体 **/
		public var font:Font;
		/** 类引用 **/
		public var fontClass:Class;
		/** 类的全名 **/
		public var className:String;
		/** 是否注全局 **/
		public var register:Boolean;
		/** 是否是嵌入字体 **/
		public var embed:Boolean = false;
		/** 所使用的连接 **/
		public var url:String = "";
		
		public function FontItem() { }
	}
}