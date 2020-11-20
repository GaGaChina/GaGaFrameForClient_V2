package cn.wjj.display.ui2d.info
{
	import cn.wjj.gagaframe.client.speedfact.SByte;
	
	/**
	 * 整个动画的范围
	 * 
	 * 
	 * @author GaGa
	 */
	public class U2InfoContourRect extends U2InfoBase 
	{
		/** 矩形碰撞范围信息 **/
		public var startX:int = 0;
		public var startY:int = 0;
		public var endX:int = 0;
		public var endY:int = 0;
		
		public function U2InfoContourRect(parent:U2InfoBaseInfo):void
		{
			super(parent);
			this.type = U2InfoType.contourRect;
		}
		
		/** 获取这个对象的全部属性信息 **/
		override public function getByte():SByte 
		{
			var b:SByte = SByte.instance();
			b.writeShort(startX);
			b.writeShort(startY);
			b.writeShort(endX);
			b.writeShort(endY);
			return b;
		}
		
		/** 读取这个内容 **/
		override public function setByte(b:SByte):void
		{
			startX = b.readShort();
			startY = b.readShort();
			endX = b.readShort();
			endY = b.readShort();
		}
		
		/** 克隆一个对象 **/
		public function clone(parent:U2InfoBaseInfo):U2InfoContourRect
		{
			var o:U2InfoContourRect = new U2InfoContourRect(parent);
			o.startX = startX;
			o.startY = startY;
			o.endX = endX;
			o.endY = endY;
			return o;
		}
	}
}