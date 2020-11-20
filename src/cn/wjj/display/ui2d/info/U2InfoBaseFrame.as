package cn.wjj.display.ui2d.info
{
	import cn.wjj.gagaframe.client.speedfact.SByte;
	
	/**
	 * 层里的每一幀的情况
	 * 
	 * @author GaGa
	 */
	public class U2InfoBaseFrame extends U2InfoBase 
	{
		/** MovieClip 的 currentLabel, label,可以延续 **/
		public var label:String = "";
		
		public function U2InfoBaseFrame(parent:U2InfoBaseInfo):void
		{
			super(parent);
			this.type = U2InfoType.baseFrame;
		}
		
		/** 获取这个对象的全部属性信息 **/
		override public function getByte():SByte 
		{
			var b:SByte = SByte.instance();
			b._w_String(label);
			return b;
		}
		
		/** 读取这个内容 **/
		override public function setByte(b:SByte):void
		{
			if (parent.ver < 5)
			{
				label = b._r_String();
				b.readUnsignedByte();
				b.readUnsignedShort();
				b.readUnsignedShort();
				var length:int = b.readUnsignedByte();
				var s:U2InfoSound;
				var bb:SByte
				if (length == 1)
				{
					s = new U2InfoSound(this.parent);
					b.readUnsignedShort();
					s.setByte(b);
				}
				else if (length == 0) { }
				else
				{
					//版本兼容,所以特意加的
					while (--length > -1) 
					{
						s = new U2InfoSound(this.parent);
						b.readUnsignedShort();
						s.setByte(b);
					}
				}
				var collide:U2InfoCollide;
				if (b.readUnsignedByte() == 1)
				{
					collide = new U2InfoCollide(this.parent);
					b.readUnsignedShort();
					collide.setByte(b);
				}
			}
			else
			{
				label = b._r_String();
			}
		}
		
		/** 克隆一个对象 **/
		public function clone(parent:U2InfoBaseInfo):U2InfoBaseFrame
		{
			var o:U2InfoBaseFrame = new U2InfoBaseFrame(parent);
			copyThis(o, parent);
			return o;
		}
		
		public function copyThis(o:U2InfoBaseFrame, parent:U2InfoBaseInfo):void
		{
			o.label = label;
		}
	}
}