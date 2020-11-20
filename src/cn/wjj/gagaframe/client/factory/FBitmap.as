package cn.wjj.gagaframe.client.factory
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	/**
	 * 仓库管理类,提供Bitmap的管理
	 * @author GaGa
	 */
	public class FBitmap extends Bitmap
	{
		
		/**
		 * 初始化 Bitmap 对象以引用指定的 BitmapData 对象。
		 * @param	bitmapData		被引用的 BitmapData 对象。
		 * @param	pixelSnapping	Bitmap 对象是否贴紧至最近的像素。
		 * @param	smoothing		在缩放时是否对位图进行平滑处理。例如，下例显示使用系数 3 缩放的同一位图，smoothing 设置为 false（左侧）和 true（右侧）：
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 */
		public function FBitmap(bitmapData:BitmapData = null, pixelSnapping:String = "auto", smoothing:Boolean = false):void
		{
			super(bitmapData, pixelSnapping, smoothing);
		}
		
		/**
		 * 初始化 Bitmap 对象以引用指定的 BitmapData 对象。
		 * @param	bitmapData		被引用的 BitmapData 对象。
		 * @param	pixelSnapping	Bitmap 对象是否贴紧至最近的像素。
		 * @param	smoothing		在缩放时是否对位图进行平滑处理。例如，下例显示使用系数 3 缩放的同一位图，smoothing 设置为 false（左侧）和 true（右侧）：
		 */
		public static function instance(bitmapData:BitmapData = null, pixelSnapping:String = "auto", smoothing:Boolean = false):FBitmap
		{
			return new FBitmap(bitmapData, pixelSnapping, smoothing);
		}
		
		/** 移除,清理,并回收 **/
		public function dispose():void
		{
			if (this.parent) this.parent.removeChild(this);
			if (cacheAsBitmap != false) cacheAsBitmap = false;
			if (bitmapData != null) bitmapData = null;
			if (filters != null) filters = null;
		}
	}
}