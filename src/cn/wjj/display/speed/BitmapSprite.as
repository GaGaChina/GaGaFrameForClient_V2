package cn.wjj.display.speed
{
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	import flash.display.Bitmap;
	
	/**
	 * 效率 : ★★★★★
	 * 将一个显示对象转换为一个Bitmap,当然这个Bitmap也是没有鼠标事件的
	 * 对象继承与Bitmap,所以没MouseEvent事件
	 */
	public class BitmapSprite extends Bitmap
	{
		
		//item 的xy 在计算时当作注册点来用
		/** 这个对象引用的原先的数据对象 **/
		private var item:BitmapDataItem;
		
		/**
		 * 通过一个显示对象或者一个显示对象的类中,获取这个对象的BitmapSprite对象
		 * @param displayOrClass	BitmapDataItem, Movie, MovieClass对象
		 * @param saveThis			是否在内存里存储,以便下次可以快速抽取内容
		 * @param scale				缓存的比例
		 * @param smoothing
		 * @param quality
		 * @param pushInLib
		 * @return 
		 */
		public static function create(displayOrClass:*, saveThis:Boolean = true, scale:Number = 1, smoothing:Boolean = true, quality:String = "best", pushInLib:Boolean = true):BitmapSprite
		{
			var data:BitmapDataItem = BitmapDisplayLib.getBitmap(displayOrClass, saveThis, scale, smoothing, quality, pushInLib);
			if(data != null)
			{
				return new BitmapSprite(data);
			}
			g.log.pushLog(BitmapSprite, LogType._ErrorLog, "参数类型不符!");
			return null;
		}
		
		/**
		 * 继承于Bitmap的对象
		 * @param info
		 */
		public function BitmapSprite(info:BitmapDataItem = null):void
		{
			if (info) setDataItem(info);
		}
		
		/**
		 * 继承于Bitmap的对象
		 * @param info
		 */
		public static function instance(info:BitmapDataItem = null):BitmapSprite
		{
			return new BitmapSprite(info);
		}
		
		/**
		 * 重置这个对象的BitmapData图形
		 * @param	info
		 */
		public function setDataItem(info:BitmapDataItem):void
		{
			var oldX:Number = 0;
			var oldY:Number = 0;
			if (item)
			{
				oldX = this.x;
				oldY = this.y;
			}
			item = info;
			this.bitmapData = item.bitmapData;
			this.x = oldX;
			this.y = oldY;
		}
		
		//----------------------------------------------------覆盖的方法-----------------------------------------------------
		override public function get x():Number 
		{
			if(item)
			{
				return super.x - item.x * this.scaleX;
			}
			return super.x;
		}
		
		override public function set x(value:Number):void 
		{
			if(item)
			{
				value = value + item.x * this.scaleX;
			}
			if(super.x != value) super.x = value;
		}
		
		override public function get y():Number 
		{
			if(item)
			{
				return super.y - item.y * this.scaleY;
			}
			return super.y;
		}
		
		override public function set y(value:Number):void 
		{
			if(item)
			{
				value = value + item.y * this.scaleY;
			}
			if(super.y != value) super.y = value;
		}
		
		override public function set scaleX(value:Number):void 
		{
			var temp:Number = this.x;
			super.scaleX = value;
			this.x = temp;
		}
		
		override public function set scaleY(value:Number):void 
		{
			var temp:Number = this.y;
			super.scaleY = value;
			this.y = temp;
		}
		
		/** X坐标的偏移量 **/
		public function get shiftingX():Number
		{
			return item.x;
		}
		
		/** Y坐标的偏移量 **/
		public function get shiftingY():Number
		{
			return item.y;
		}
		
		//----------------------------------------------------一些其他的方法---------------------------------------------------
		/** 移除,清理,并回收 **/
		public function dispose():void
		{
			if (this.parent) this.parent.removeChild(this);
			if (item  != null) item  = null;
			if (cacheAsBitmap != false) cacheAsBitmap = false;
			if (bitmapData != null) bitmapData = null;
			if (filters != null) filters = null;
		}
		
		/**
		 * 点p绕点pcenter旋转N度之后的坐标
		 * @param	p
		 * @param	pcenter
		 * @param	angle
		 * @return
		
		private function rotatePoint(p:MPoint, pcenter:MPoint, angle:Number):MPoint
		{
			var length:Number = Math.sqrt((p.x - pcenter.x) * (p.x - pcenter.x) + (p.y - pcenter.y) * (p.y - pcenter.y));
			var l:Number = ((angle) * Math.PI) / 180.0;
			var cosv:Number = Math.cos(l);
			var sinv:Number = Math.sin(l);
			//此点代表方向
			var newXDirc:Number = ((p.x - pcenter.x) * cosv + (p.y - pcenter.y) * sinv + pcenter.x);
			var newYDirc:Number = (-(p.x - pcenter.x) * sinv + (p.y - pcenter.y) * cosv + pcenter.y);
			return new MPoint(newXDirc, newYDirc);
		}
		 */
	}
}