package cn.wjj.display.ui2d.info
{
	import cn.wjj.gagaframe.client.speedfact.SByte;
	
	/**
	 * 绘制 : 矩形
	 * @author GaGa
	 */
	public class U2InfoDrogRect extends U2InfoBase 
	{
		/** 线条粗细 **/
		public var lineStrokes:uint;
		/** 线条颜色 **/
		public var lineColor:uint;
		/** 线条透明度 **/
		public var lineAlpha:uint;
		/** 背景颜色 **/
		public var bgColor:uint;
		/** 背景透明度 **/
		public var bgAlpha:uint;
		
		/** 绘制信息 **/
		public var x:int = 0;
		public var y:int = 0;
		public var w:uint = 0;
		public var h:uint = 0;
		
		public function U2InfoDrogRect(parent:U2InfoBaseInfo):void
		{
			super(parent);
			this.type = U2InfoType.bitmap;
		}
		
		/** 获取这个对象的全部属性信息 **/
		override public function getByte():SByte 
		{
			var b:SByte = SByte.instance();
			
			b.writeByte(lineStrokes);
			b.writeUnsignedInt(lineColor);
			b.writeByte(lineAlpha);
			b.writeUnsignedInt(bgColor);
			b.writeByte(bgAlpha);
			
			b.writeShort(x);
			b.writeShort(y);
			b.writeShort(w);
			b.writeShort(h);
			
			return b;
		}
		
		/** 读取这个内容 **/
		override public function setByte(b:SByte):void
		{
			lineStrokes = b.readUnsignedByte();
			lineColor = b.readUnsignedInt();
			lineAlpha = b.readUnsignedByte();
			bgColor = b.readUnsignedInt();
			bgAlpha = b.readUnsignedByte();
			
			x = b.readShort();
			y = b.readShort();
			w = b.readUnsignedShort();
			h = b.readUnsignedShort();
		}
		
		/** 克隆一个对象 **/
		public function clone(parent:U2InfoBaseInfo):U2InfoDrogRect
		{
			var o:U2InfoDrogRect = new U2InfoDrogRect(parent);
			o.lineStrokes = lineStrokes;
			o.lineColor = lineColor;
			o.lineAlpha = lineAlpha;
			o.bgColor = bgColor;
			o.bgAlpha = bgAlpha;
			o.x = x;
			o.y = y;
			o.w = w;
			o.h = h;
			return o;
		}
	}
}