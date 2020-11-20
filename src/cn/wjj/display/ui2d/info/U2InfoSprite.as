package cn.wjj.display.ui2d.info
{
	import cn.wjj.gagaframe.client.speedfact.SByte;
	
	/**
	 * 显示对象
	 * @author GaGa
	 */
	public class U2InfoSprite extends U2InfoBase 
	{
		/** 注册点X,x为0的时候的x坐标 **/
		public var offsetX:Number = 0;
		/** 注册点Y,y为0的时候的y坐标 **/
		public var offsetY:Number = 0;
		/** 透明度偏移量,实际的是和这个相乘 **/
		public var offsetAlpha:Number = 1;
		/** 角度偏移量,0度的时候的角度(0-360范围) **/
		public var offsetRotation:Number = 0;
		/** 比例偏移量,比例为1的时候的比例 **/
		public var offsetScaleX:Number = 1;
		/** 比例偏移量,比例为1的时候的比例 **/
		public var offsetScaleY:Number = 1;
		
		/** 全部和绘画相关的数据 **/
		public var drog:Vector.<U2InfoBase>;
		/** 容器内内容 **/
		public var lib:Vector.<U2InfoDisplay>
		
		public function U2InfoSprite(parent:U2InfoBaseInfo):void
		{
			super(parent);
			this.type = U2InfoType.sprite;
			drog = new Vector.<U2InfoBase>();
			lib = new Vector.<U2InfoDisplay>();
		}
		
		/** 获取这个对象的全部属性信息 **/
		override public function getByte():SByte 
		{
			var b:SByte = SByte.instance();
			b.writeInt(int(offsetX * 1000));
			b.writeInt(int(offsetY * 1000));
			var alpha:uint = uint(Number(offsetAlpha * 100));
			if (alpha > 100) alpha = 100;
			b.writeByte(alpha);
			b.writeInt(int(offsetRotation * 1000));
			b.writeInt(int(offsetScaleX * 1000));
			b.writeInt(int(offsetScaleY * 1000));
			
			b.writeShort(drog.length);
			var item:U2InfoBase;
			for each (item in drog) 
			{
				b.writeShort(item.type);
				b._w_CByteArray(item.getByte());
			}
			
			b.writeShort(lib.length);
			for each (item in lib) 
			{
				b._w_CByteArray(item.getByte());
			}
			return b;
		}
		
		/** 读取这个内容 **/
		override public function setByte(b:SByte):void
		{
			offsetX = b.readInt() / 1000;
			offsetY = b.readInt() / 1000;
			offsetAlpha = b.readUnsignedByte() / 100;
			offsetRotation = b.readInt() / 1000;
			offsetScaleX = b.readInt() / 1000;
			offsetScaleY = b.readInt() / 1000;
			
			var i:int = b.readUnsignedShort();
			var d:U2InfoBase;
			var dType:uint = 0;
			while (--i > -1) 
			{
				dType = b.readUnsignedShort();
				switch (dType) 
				{
					case U2InfoType.drogRect:
						d = new U2InfoDrogRect(this.parent);
						break;
				}
				b.readUnsignedShort();
				d.setByte(b);
				drog.push(d);
			}
			i = b.readUnsignedShort();
			while (--i > -1) 
			{
				d = new U2InfoDisplay(this.parent);
				b.readUnsignedShort();
				d.setByte(b);
				lib.push(d);
			}
		}
		
		override public function dispose():void 
		{
			super.dispose();
			if (drog)
			{
				for each (var item:U2InfoBase in drog) 
				{
					item.dispose();
				}
				drog.length = 0;
				drog = null;
			}
			if (lib)
			{
				for each (var d:U2InfoDisplay in lib) 
				{
					d.dispose();
				}
				lib.length = 0;
				lib = null;
			}
		}
		
		/** 是否包含了显示对象 **/
		public function haveDisplay():Boolean
		{
			if (lib && lib.length)
			{
				return true;
			}
			if (drog && drog.length)
			{
				return true;
			}
			return false;
		}
		
		/** 克隆一个对象 **/
		public function clone(parent:U2InfoBaseInfo):U2InfoSprite
		{
			var o:U2InfoSprite = new U2InfoSprite(parent);
			o.offsetX = offsetX;
			o.offsetY = offsetY;
			o.offsetAlpha = offsetAlpha;
			o.offsetRotation = offsetRotation;
			o.offsetScaleX = offsetScaleX;
			o.offsetScaleY = offsetScaleY;
			for each (var item:U2InfoBase in drog) 
			{
				o.drog.push((item as Object).clone(parent));
			}
			for each (var d:U2InfoDisplay in lib) 
			{
				o.lib.push((d as Object).clone(parent));
			}
			return o;
		}
	}
}