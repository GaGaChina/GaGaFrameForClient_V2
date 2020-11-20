package cn.wjj.display.ui2d.info
{
	import cn.wjj.gagaframe.client.speedfact.SByte;
	
	/**
	 * 坐标点
	 * @author GaGa
	 */
	public class U2InfoBaseGrid extends U2InfoBase 
	{
		/** x的终点 **/
		public var width:int = 0;
		/** y的终点 **/
		public var height:int = 0;
		/** 线条颜色 **/
		public var color:uint = 0;
		/** 线条透明度 **/
		public var alpha:uint = 0;
		
		public function U2InfoBaseGrid(parent:U2InfoBaseInfo):void
		{
			super(parent);
			this.type = U2InfoType.baseGrid;
		}
		
		/** 获取这个对象的全部属性信息 **/
		override public function getByte():SByte 
		{
			var b:SByte = SByte.instance();
			b.writeShort(width);
			b.writeShort(height);
			b.writeInt(color);
			b.writeByte(alpha);
			return b;
		}
		
		/** 读取这个内容 **/
		override public function setByte(b:SByte):void
		{
			width = b.readUnsignedShort();
			height = b.readUnsignedShort();
			color = b.readInt();
			alpha = b.readUnsignedByte();
		}
		
		/** 克隆一个对象 **/
		public function clone(parent:U2InfoBaseInfo):U2InfoBaseGrid
		{
			var o:U2InfoBaseGrid = new U2InfoBaseGrid(parent);
			o.width = width;
			o.height = height;
			o.color = color;
			o.alpha = alpha;
			return o;
		}
	}
}