package cn.wjj.display.ui2d.info
{
	import cn.wjj.gagaframe.client.speedfact.SByte;
	
	/**
	 * 一个碰撞范围,是以圆为标准
	 * @author GaGa
	 */
	public class U2InfoCollideCircle extends U2InfoBase 
	{
		/** 圆的碰撞范围 **/
		public var x:int = 0;
		public var y:int = 0;
		public var r:uint = 0;
		
		public function U2InfoCollideCircle(parent:U2InfoBaseInfo):void
		{
			super(parent);
			this.type = U2InfoType.collideCircle;
		}
		
		/** 获取这个对象的全部属性信息 **/
		override public function getByte():SByte 
		{
			var b:SByte = SByte.instance();
			b.writeShort(x);
			b.writeShort(y);
			b.writeShort(r);
			return b;
		}
		
		/** 读取这个内容 **/
		override public function setByte(b:SByte):void
		{
			x = b.readShort();
			y = b.readShort();
			r = b.readUnsignedShort();
		}
		
		/** 克隆一个对象 **/
		public function clone(parent:U2InfoBaseInfo):U2InfoCollideCircle
		{
			var o:U2InfoCollideCircle = new U2InfoCollideCircle(parent);
			o.x = x;
			o.y = y;
			o.r = r;
			return o;
		}
	}
}