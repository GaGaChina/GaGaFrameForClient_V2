package cn.wjj.display.speed
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	/**
	 * 一个Bitmap的TextField对象
	 * 
	 * @version 1.0.0
	 * @author GaGa wjjhappy@Gmail.com
	 * @copy 王加静 www.5ga.cn
	 * @date 2013-10-17
	 */
	public class BitmapText extends Bitmap
	{
		/**
		 * 创建多语言文本显示对象
		 */
		public function BitmapText(bitmapData:BitmapData = null, pixelSnapping:String = "auto", smoothing:Boolean = false):void
		{
			super(bitmapData, pixelSnapping, smoothing);
		}
		
		/**
		 * 创建多语言文本显示对象
		 * @param info
		 */
		public static function instance(bitmapData:BitmapData = null, pixelSnapping:String = "auto", smoothing:Boolean = false):BitmapText
		{
			return new BitmapText(bitmapData, pixelSnapping, smoothing);
		}
		
		/** 移除,清理,并回收 **/
		public function dispose():void
		{
			if (this.parent) this.parent.removeChild(this);
			if (bitmapData != null) bitmapData = null;
			if (filters != null) filters = null;
		}
		
		/** 设置这个对象置顶 **/
		public function indexTop():void
		{
			if (this.parent)
			{
				this.parent.setChildIndex(this, (this.parent.numChildren - 1));
			}
		}
	}
}