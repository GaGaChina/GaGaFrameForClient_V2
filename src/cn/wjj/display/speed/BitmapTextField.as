package cn.wjj.display.speed
{
	import flash.display.Bitmap;
	import flash.text.TextField;
	
	/**
	 * 一个Bitmap的TextField对象
	 * 
	 * @version 0.0.1
	 * @author GaGa wjjhappy@Gmail.com
	 * @copy 王加静 www.5ga.cn
	 * @date 2013-05-04
	 */
	public class BitmapTextField extends Bitmap
	{
		
		/** 被引用的TextField **/
		private var _textField:TextField;
		/** 这个对象引用的原先的数据对象 **/
		private var item:BitmapDataItem;
		/** 是否启用偏离量 **/
		private var isOffset:Boolean = true;
		
		/**
		 * 自动抽取TextField对象,然后移除,把Bitmap移入,设置前要addChild先
		 * @param textField
		 */
		public function BitmapTextField(textField:TextField):void
		{
			if(textField)
			{
				this._textField = textField;
			}
		}
		
		/**
		 * 继承于Bitmap的对象
		 * @param info
		 */
		public static function instance(textField:TextField):BitmapTextField
		{
			return new BitmapTextField(textField);
		}
		
		/** 清理位图信息 **/
		public function clear():void
		{
			if (this.item)
			{
				this.item.bitmapData.dispose();
				this.item.dispose();
				this.item = null;
			}
			if (this.bitmapData)
			{
				this.bitmapData.dispose();
				this.bitmapData = null;
			}
			if(_textField.cacheAsBitmap)
			{
				_textField.cacheAsBitmap = false;
			}
		}
		
		/** 移除,清理,并回收 **/
		public function dispose():void
		{
			if (this.parent) this.parent.removeChild(this);
			clear();;
		}
		
		/** 抓取text的信息,并重置坐标 **/
		public function setThisInfo(txt:TextField):void
		{
			clear();
			if (txt) this._textField = txt;
			if(isOffset && txt)
			{
				this.name = txt.name;
				super.x = txt.x;
				super.y = txt.y;
				super.scaleX = txt.scaleX;
				super.scaleY = txt.scaleY;
				super.rotation = txt.rotation;
				if(txt.parent)
				{
					txt.parent.addChildAt(this, (txt.parent.getChildIndex(txt) + 1));
					txt.parent.removeChild(txt);
				}
			}
		}
		
		/** 内容有变化的时候进行刷新 **/
		public function refresh(info:BitmapDataItem = null):void
		{
			var oldX:Number = x;
			var oldY:Number = y;
			if(info)
			{
				if(item && item.bitmapData != info.bitmapData)
				{
					item.bitmapData.dispose();
					item.bitmapData = null;
				}
				item = info;
			}
			else
			{
				if(item)
				{
					item.bitmapData.dispose();
					item.bitmapData = null;
				}
				item = GetBitmapData.cacheBitmap(textField, true, 0x00000000, 1, true, "best", false);
			}
			this.bitmapData = item.bitmapData;
			this.x = oldX;
			this.y = oldY;
		}
		
		/** 设置这个对象置顶 **/
		public function setIndexTop():void
		{
			if (this.parent)
			{
				this.parent.setChildIndex(this, (this.parent.numChildren - 1));
			}
		}
		
		/** 是否启用偏移量 **/
		public function useOffset(isOffset:Boolean):void
		{
			this.isOffset = isOffset;
		}
		
		/** 操作对象内的TextField **/
		public function get textField():TextField
		{
			return _textField;
		}
		
		//----------------------------------------------------覆盖的方法-----------------------------------------------------
		override public function get x():Number 
		{
			if(isOffset && item)
			{
				return super.x - item.x * this.scaleX;
			}
			else
			{
				return super.x;
			}
		}
		
		override public function set x(value:Number):void 
		{
			if(isOffset && item) value = value + item.x * this.scaleX;
			if(super.x != value) super.x = value;
		}
		
		override public function get y():Number 
		{
			if(isOffset && item)
			{
				return super.y - item.y * this.scaleY;
			}
			else
			{
				return super.y;
			}
		}
		
		override public function set y(value:Number):void 
		{
			if(isOffset && item) value = value + item.y * this.scaleY;
			if(super.y != value) super.y = value;
		}
		
		override public function get scaleX():Number 
		{
			return super.scaleX;
		}
		
		override public function set scaleX(value:Number):void 
		{
			var temp:Number = this.x;
			super.scaleX = value;
			this.x = temp;
		}
		
		override public function get scaleY():Number 
		{
			return super.scaleY;
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
	}
}