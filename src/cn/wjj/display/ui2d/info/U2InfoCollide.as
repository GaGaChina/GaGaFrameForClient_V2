package cn.wjj.display.ui2d.info
{
	import cn.wjj.gagaframe.client.speedfact.SByte;
	
	/**
	 * 坐标点
	 * @author GaGa
	 */
	public class U2InfoCollide extends U2InfoBase 
	{
		/** 碰撞的范围列表 **/
		public var lib:Vector.<U2InfoBase>;
		
		public function U2InfoCollide(parent:U2InfoBaseInfo):void
		{
			super(parent);
			this.type = U2InfoType.collide;
		}
		
		/** 获取这个对象的全部属性信息 **/
		override public function getByte():SByte 
		{
			var b:SByte = SByte.instance();
			if (lib)
			{
				b.writeByte(lib.length);
				for each (var item:U2InfoBase in lib) 
				{
					b.writeShort(item.type);
					b._w_CByteArray(item.getByte());
				}
			}
			else
			{
				b.writeByte(0);
			}
			return b;
		}
		
		/** 读取这个内容 **/
		override public function setByte(b:SByte):void
		{
			var i:uint = b.readUnsignedByte();
			if (i == 0)
			{
				lib = null;
			}
			else
			{
				if (lib)
				{
					if (lib.length != 0) lib.length = 0;
				}
				else
				{
					lib = new Vector.<U2InfoBase>();
				}
				var cType:uint = 0;
				var item:U2InfoBase;
				var itemByte:SByte;
				while (--i > -1) 
				{
					cType = b.readUnsignedShort();
					switch (cType) 
					{
						case U2InfoType.collideCircle:
							item = new U2InfoCollideCircle(parent);
							break;
						case U2InfoType.collideRect:
							item = new U2InfoCollideRect(parent);
							break;
					}
					b.readUnsignedShort();
					item.setByte(b);
					lib.push(item);
				}
			}
		}
		
		/** 克隆一个对象 **/
		public function clone(parent:U2InfoBaseInfo):U2InfoCollide
		{
			var o:U2InfoCollide = new U2InfoCollide(parent);
			for each (var item:U2InfoBase in lib) 
			{
				o.lib.push((item as Object).clone(parent));
			}
			return o;
		}
	}
}