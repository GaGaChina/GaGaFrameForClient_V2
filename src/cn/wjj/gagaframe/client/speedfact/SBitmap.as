package cn.wjj.gagaframe.client.speedfact
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	/**
	 * 仓库管理类,提供Bitmap的管理
	 * @author GaGa
	 */
	public class SBitmap extends Bitmap
	{
		/** 对象池 **/
		private static var __f:SpeedLib = new SpeedLib(400);
		/** 对象池强引用的最大数量 **/
		static public function get __m():uint { return __f.length; }
		/** 对象池强引用的最大数量 **/
		static public function set __m(value:uint):void { __f.length = value; }
		
		/**
		 * 初始化 Bitmap 对象以引用指定的 BitmapData 对象。
		 * @param	bitmapData		被引用的 BitmapData 对象。
		 * @param	pixelSnapping	Bitmap 对象是否贴紧至最近的像素。
		 * @param	smoothing		在缩放时是否对位图进行平滑处理。例如，下例显示使用系数 3 缩放的同一位图，smoothing 设置为 false（左侧）和 true（右侧）：
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 */
		public function SBitmap(bitmapData:BitmapData = null, pixelSnapping:String = "auto", smoothing:Boolean = false):void
		{
			super(bitmapData, pixelSnapping, smoothing);
		}
		
		/**
		 * 初始化 Bitmap 对象以引用指定的 BitmapData 对象。
		 * @param	bitmapData		被引用的 BitmapData 对象。
		 * @param	pixelSnapping	Bitmap 对象是否贴紧至最近的像素。
		 * @param	smoothing		在缩放时是否对位图进行平滑处理。例如，下例显示使用系数 3 缩放的同一位图，smoothing 设置为 false（左侧）和 true（右侧）：
		 */
		public static function instance(bitmapData:BitmapData = null, pixelSnapping:String = "auto", smoothing:Boolean = false):SBitmap
		{
			var o:SBitmap = __f.instance() as SBitmap;
			if (o)
			{
				if (bitmapData) o.bitmapData = bitmapData;
				if (pixelSnapping != "auto") o.pixelSnapping = pixelSnapping;
				if (smoothing == true) o.smoothing = true;
				return o;
			}
			return new SBitmap(bitmapData, pixelSnapping, smoothing);;
		}
		
		/** 移除,清理,并回收 **/
		public function dispose():void
		{
			if (this.parent) this.parent.removeChild(this);
			if (this.cacheAsBitmap != false) this.cacheAsBitmap = false;
			if (this.bitmapData != null) this.bitmapData = null;
			if (this.filters != null) this.filters = null;
			if (this.x != 0) this.x = 0;
			if (this.y != 0) this.y = 0;
			if (this.z != 0) this.z = 0;
			if (this.rotation != 0) this.rotation = 0;
			if (this.rotationX != 0) this.rotationX = 0;
			if (this.rotationY != 0) this.rotationY = 0;
			if (this.rotationZ != 0) this.rotationZ = 0;
			if (this.scaleX != 1) this.scaleX = 1;
			if (this.scaleY != 1) this.scaleY = 1;
			if (this.scaleZ != 1) this.scaleZ = 1;
			if (this.visible != true) this.visible = true;
			if (this.alpha != 1) this.alpha = 1;
			if (this.name != "") this.name = "";
			if (this.pixelSnapping != "auto") this.pixelSnapping = "auto";
			if (this.smoothing != false) this.smoothing = false;
			if (this.mask != null) this.mask = null;
			if (this.opaqueBackground  != null) this.opaqueBackground  = null;
			if (this.scale9Grid != null) this.scale9Grid = null;
			//if (o.transform != null) o.transform = null;
			__f.recover(this);
		}
	}
}