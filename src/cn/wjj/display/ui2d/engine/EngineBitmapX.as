package cn.wjj.display.ui2d.engine
{
	import cn.wjj.display.ui2d.info.U2InfoBitmapX;
	import cn.wjj.display.ui2d.U2Bitmap;
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.speedfact.SByte;
	
	
	/**
	 * 对BitmapX对象进行操作
	 * 
	 * @author GaGa
	 */
	public class EngineBitmapX
	{
		
		public function EngineBitmapX() { }
		
		
		/**
		 * 对一个对象引用数据
		 * 
		 * @param	display
		 * @param	gfile
		 * @param	path
		 */
		public static function openForDisplay(display:U2Bitmap, gfile:*, path:String):void
		{
			var o:U2InfoBitmapX;
			if (path != "") o = openGFilePath(gfile, path);
			if (o)
			{
				useInfo(display, o);
			}
			else if(display)
			{
				U2Bitmap.clear(display);
			}
		}
		
		/**
		 * 对 U2Bitmap 设置 U2InfoBitmapX 数据
		 * @param	display
		 * @param	o
		 */
		public static function useInfo(display:U2Bitmap, o:U2InfoBitmapX):void
		{
			display.bitmapData = o.bitmapData;
			display.setOffsetX(o.offsetX, o.offsetY, o.offsetScaleX, o.offsetScaleY);
			if (display.bitmapData)
			{
				if (display.isEmpty) display.isEmpty = false;
			}
			else if (display.isEmpty == false)
			{
				display.isEmpty = true;
			}
		}
		
		/**
		 * 获取一个数据的内容
		 * @param	byte	原始数据
		 * @return
		public static function openByte(byte:SByte):U2InfoBitmapX
		{
			var o:U2InfoBitmapX = new U2InfoBitmapX(null);
			o.setByte(byte);
			return o;
		}
		 */
		
		/** 打开GFile文件里二进制,并获取数据对象 **/
		public static function openGFilePath(gfile:*, path:String):U2InfoBitmapX
		{
			if(path)
			{
				return g.gfile.getPathObj(gfile, path) as U2InfoBitmapX;

			}
			return null;
		}
	}
}