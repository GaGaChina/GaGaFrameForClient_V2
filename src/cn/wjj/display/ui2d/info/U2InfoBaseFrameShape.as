package cn.wjj.display.ui2d.info
{
	import cn.wjj.gagaframe.client.speedfact.SByte;
	
	/**
	 * 适量图层,存放Shape的对象
	 * @author GaGa
	 */
	public class U2InfoBaseFrameShape extends U2InfoBaseFrame 
	{
		/** 记录帧的显示对象 **/
		public var display:U2InfoShape;
		
		public function U2InfoBaseFrameShape(parent:U2InfoBaseInfo):void
		{
			super(parent);
			this.type = U2InfoType.baseFrameShape;
			display = new U2InfoShape(parent);
		}
		
		/** 获取这个对象的全部属性信息 **/
		override public function getByte():SByte 
		{
			var b:SByte = super.getByte();
			b._w_CByteArray(display.getByte());
			return b;
		}
		
		/** 读取这个内容 **/
		override public function setByte(b:SByte):void
		{
			super.setByte(b);
			b.readUnsignedShort();
			display.setByte(b);
		}
		
		override public function dispose():void 
		{
			super.dispose();
			display.dispose();
			display = null;
		}
		
		/** 克隆一个对象 **/
		override public function clone(parent:U2InfoBaseInfo):U2InfoBaseFrame
		{
			var o:U2InfoBaseFrameShape = new U2InfoBaseFrameShape(parent);
			copyThis(o, parent);
			o.display = display.clone(parent);
			return o;
		}
	}
}