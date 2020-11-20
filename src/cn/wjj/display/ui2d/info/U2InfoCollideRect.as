package cn.wjj.display.ui2d.info
{
	import cn.wjj.gagaframe.client.speedfact.SByte;
	
	/**
	 * 一个碰撞范围,是以矩形为范围
	 * @author GaGa
	 */
	public class U2InfoCollideRect extends U2InfoBase 
	{
		/** 矩形碰撞范围信息 **/
		public var x:int = 0;
		public var y:int = 0;
		public var width:uint = 0;
		public var height:uint = 0;
		
		public function U2InfoCollideRect(parent:U2InfoBaseInfo):void
		{
			super(parent);
			this.type = U2InfoType.collideRect;
		}
		
		/** 获取这个对象的全部属性信息 **/
		override public function getByte():SByte 
		{
			var b:SByte = SByte.instance();
			b.writeShort(x);
			b.writeShort(y);
			b.writeShort(width);
			b.writeShort(height);
			return b;
		}
		
		/** 读取这个内容 **/
		override public function setByte(b:SByte):void
		{
			x = b.readShort();
			y = b.readShort();
			width = b.readUnsignedShort();
			height = b.readUnsignedShort();
		}
		
		/** 克隆一个对象 **/
		public function clone(parent:U2InfoBaseInfo):U2InfoCollideRect
		{
			var o:U2InfoCollideRect = new U2InfoCollideRect(parent);
			o.x = x;
			o.y = y;
			o.width = width;
			o.height = height;
			return o;
		}
	}
}