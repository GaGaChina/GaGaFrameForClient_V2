package cn.wjj.data.file 
{
	import cn.wjj.display.ui2d.info.U2InfoBitmapX;
	import cn.wjj.gagaframe.client.speedfact.SByte;
	
	/**
	 * 将框架的多语言内容,转换为二进制,里面包含图片的数据
	 * 
	 * @version 1.0.0
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 */
	public class GU2BitmapX extends GFileBase
	{
		public function GU2BitmapX():void
		{
			type = GFileType.U2BitmapX;
		}
		
		/** 写入包体的内容,直接写入的是包内容二进制 **/
		override public function setBodyByte(b:SByte, disposeByte:Boolean = false):*
		{
			//已经错误了,多取了一个Package的内容,其实是要做映射
			b.position = 0;
			var bitmapX:U2InfoBitmapX = new U2InfoBitmapX(null);
			bitmapX.setByte(b);
			if (isBuilder)
			{
				sourceByte = b;
			}
			else if (disposeByte)
			{
				b.dispose();
			}
			this.obj = bitmapX;
			return bitmapX;
		}
		
		/** 把包体的内容输出 **/
		override public function getBodyByte():SByte
		{
			if (isBuilder && sourceByte)
			{
				sourceByte.position = 0;
				return sourceByte;
			}
			return (obj as U2InfoBitmapX).getByte();
		}
	}
}