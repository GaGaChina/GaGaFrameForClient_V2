package cn.wjj.display.ui2d.info
{
	import cn.wjj.gagaframe.client.speedfact.SByte;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	/**
	 * 独立的信息,将BitmapData融入信息,所以比较大
	 * 
	 * @author GaGa
	 */
	public class U2InfoBitmapX extends U2InfoBase 
	{
		/** 缓存的区域 **/
		private static var rect:Rectangle = new Rectangle();
		
		/** 数据的版本号 **/
		public var ver:uint = 2;
		/** 原始图的MD5 **/
		public var md5:String = "";
		/** 位图数据的宽度 **/
		public var width:uint = 0;
		/** 位图数据的高度 **/
		public var height:uint = 0;
		/** 注册点X,x为0的时候的x坐标 **/
		public var offsetX:int = 0;
		/** 注册点Y,y为0的时候的y坐标 **/
		public var offsetY:int = 0;
		/** 比例偏移量,比例为1的时候的比例(乘过1000) **/
		public var offsetScale:Number = 1;
		/** 比例偏移量,比例为1的时候的比例 **/
		public var offsetScaleX:Number = 1;
		/** 比例偏移量,比例为1的时候的比例 **/
		public var offsetScaleY:Number = 1;
		/** 图片是否透明 **/
		public var transparent:Boolean = true;
		/** 图片缩放的时候是否平滑 **/
		public var smoothing:Boolean = false;
		/** 位图数据 **/
		public var bitmapData:BitmapData;
		/** 原始数据 **/
		public var sourceByte:SByte;
		/** 移除偏移量的原始宽度 **/
		public var sourceWidth:uint = 0;
		/** 移除偏移量的原始高度 **/
		public var sourceHeigth:uint = 0;
		
		public function U2InfoBitmapX(parent:U2InfoBaseInfo):void
		{
			super(parent);
			type = U2InfoType.bitmapX;
		}
		
		/** 获取这个对象的全部属性信息 **/
		override public function getByte():SByte 
		{
			var b:SByte = SByte.instance();
			b.writeByte(2);
			b.writeUTF(md5);
			b.writeShort(width);
			b.writeShort(height);
			b.writeShort(offsetX);
			b.writeShort(offsetY);
			b.writeInt(int(offsetScale * 1000));
			b.writeBoolean(transparent);
			b.writeBoolean(smoothing);
			b.writeShort(sourceWidth);
			b.writeShort(sourceHeigth);
			if (sourceByte)
			{
				b._w_CByteArray(sourceByte);
			}
			else if (bitmapData)
			{
				var c:SByte = SByte.instance();
				rect.width = bitmapData.width;
				rect.height = bitmapData.height;
				var byte:ByteArray = bitmapData.getPixels(rect);
				byte.compress("lzma");
				byte.position = 0;
				c.writeBytes(byte);
				c.position = 0;
				b._w_CByteArray(c, 32);
			}
			return b;
		}
		
		/** 读取这个内容 **/
		override public function setByte(b:SByte):void
		{
			ver = b.readUnsignedByte();
			md5 = b.readUTF();
			width = b.readUnsignedShort();
			height = b.readUnsignedShort();
			if (ver < 2)
			{
				offsetX = b.readInt() / 1000;
				offsetY = b.readInt() / 1000;
			}
			else
			{
				offsetX = b.readShort();
				offsetY = b.readShort();
			}
			offsetScale = b.readInt() / 1000;
			transparent = b.readBoolean();
			smoothing = b.readBoolean();
			if (ver > 1)
			{
				sourceWidth = b.readUnsignedShort();
				sourceHeigth = b.readUnsignedShort();
				offsetScaleX = sourceWidth / width;
				offsetScaleY = sourceHeigth / height;
			}
			else
			{
				offsetX = offsetX * offsetScale;
				offsetY = offsetY * offsetScale;
				offsetScaleX = offsetScale;
				offsetScaleY = offsetScale;
				offsetScale = 1 / offsetScale;
				ver = 2;
			}
			if (b.position < b.length)
			{
				if (bitmapData)
				{
					bitmapData.dispose();
					bitmapData = null;
				}
				bitmapData = new BitmapData(width, height, transparent, 0);
				var byte:SByte = b._r_CByteArray(32);
				byte.uncompress("lzma");
				byte.position = 0;
				rect.width = width;
				rect.height = height;
				bitmapData.setPixels(rect, byte);
				byte.dispose();
			}
		}
		
		override public function dispose():void 
		{
			super.dispose();
			if (bitmapData)
			{
				bitmapData.dispose();
				bitmapData = null;
			}
			if (sourceByte) sourceByte = null;
		}
		
		/** 克隆一个对象 **/
		public function clone(parent:U2InfoBitmapX):U2InfoBitmapX
		{
			var o:U2InfoBitmapX = new U2InfoBitmapX(o.parent);
			o.ver = ver;
			o.md5 = md5;
			o.width = width;
			o.height = height;
			o.offsetX = offsetX;
			o.offsetY = offsetY;
			o.offsetScale = offsetScale;
			o.transparent = transparent;
			o.bitmapData = bitmapData;
			o.sourceByte = sourceByte;
			o.sourceWidth = sourceWidth;
			o.sourceHeigth = sourceHeigth;
			o.offsetScaleX = offsetScaleX;
			o.offsetScaleY = offsetScaleY;
			return o;
		}
	}
}