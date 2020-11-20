package cn.wjj.data.file 
{
	import cn.wjj.gagaframe.client.speedfact.SByte;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	/**
	 * 将框架的多语言内容,转换为二进制,里面包含图片的数据
	 * 
	 * @version 1.0.0
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 */
	public class GLanguage extends GFileBase
	{
		
		/** 全局设置区域使用的Rectangle **/
		private static var rect:Rectangle = new Rectangle();
		
		public function GLanguage():void
		{
			type = GFileType.language;
		}
		
		/** 写入包体的内容 **/
		override public function setBodyByte(b:SByte, disposeByte:Boolean = false):*
		{
			var o:Object = b.readObject();
			if (isBuilder)
			{
				sourceByte = b;
			}
			else if(disposeByte)
			{
				b.dispose();
			}
			obj = o;
			var imgByte:SByte;
			var bitByte:ByteArray;
			var info:Object = obj;
			var width:uint, height:uint;
			for each(var temp:* in info)
			{
				if(temp.hasOwnProperty("type") && temp.type == "img" && temp.data is ByteArray)
				{
					bitByte = temp.data as ByteArray;
					width = bitByte.readUnsignedShort();
					height = bitByte.readUnsignedShort();
					var bmd:BitmapData = new BitmapData(width, height, true, 0x00000000);//32位支持alpha通道的位图
					imgByte = SByte.instance();
					bitByte.readBytes(imgByte);
					rect.width = width;
					rect.height = height;
					bmd.setPixels(rect, imgByte);//数据的position指向第5个字节了
					temp.data = bmd;
					imgByte.dispose();
				}
			}
			return o;
		}
		
		/** 把包体的内容输出 **/
		override public function getBodyByte():SByte
		{
			if (isBuilder && sourceByte)
			{
				return sourceByte;
			}
			var b:SByte = SByte.instance();
			b.writeObject(obj);
			b.position = 0;
			return b;
		}
	}
}