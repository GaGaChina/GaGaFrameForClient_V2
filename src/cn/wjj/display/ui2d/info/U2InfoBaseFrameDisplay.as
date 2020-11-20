package cn.wjj.display.ui2d.info
{
	import cn.wjj.gagaframe.client.speedfact.SByte;
	
	/**
	 * 位图层帧类型,所使用的存储类型,存放位图,或序列帧动画
	 * @author GaGa
	 */
	public class U2InfoBaseFrameDisplay extends U2InfoBaseFrame 
	{
		/** 记录帧的显示对象 **/
		public var display:U2InfoDisplay;
		
		public function U2InfoBaseFrameDisplay(parent:U2InfoBaseInfo):void
		{
			super(parent);
			this.type = U2InfoType.baseFrameDisplay;
			display = new U2InfoDisplay(parent);
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
			var o:U2InfoBaseFrameDisplay = new U2InfoBaseFrameDisplay(parent);
			copyThis(o, parent);
			o.display = display.clone(parent);
			return o;
		}
	}
}