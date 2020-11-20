package cn.wjj.display.ui2d.info
{
	import cn.wjj.display.ui2d.engine.EnginePathType;
	import cn.wjj.gagaframe.client.speedfact.SByte;
	
	/**
	 * 显示对象
	 * @author GaGa
	 */
	public class U2InfoBitmap extends U2InfoBase 
	{
		/** 保存的路径,只能是path或是缩略图U2BitmapX **/
		public var path:String = "";
		/** 路径类型,0:无,1:u2,2:jpg,3:png,99:未知 **/
		public var pathType:int = 0;
		/** 注册点X,x为0的时候的x坐标(乘过1000) **/
		public var offsetX:Number = 0;
		/** 注册点Y,y为0的时候的y坐标(乘过1000) **/
		public var offsetY:Number = 0;
		/** 透明度偏移量,实际的是和这个相乘 **/
		public var offsetAlpha:Number = 1;
		/** 角度偏移量,0度的时候的角度(0-360范围)(乘过1000) **/
		public var offsetRotation:Number = 0;
		/** 比例偏移量,比例为1的时候的比例(乘过1000) **/
		public var offsetScaleX:Number = 1;
		/** 比例偏移量,比例为1的时候的比例(乘过1000) **/
		public var offsetScaleY:Number = 1;
		
		public function U2InfoBitmap(parent:U2InfoBaseInfo):void
		{
			super(parent);
			this.type = U2InfoType.bitmap;
		}
		
		/** 获取这个对象的全部属性信息 **/
		override public function getByte():SByte 
		{
			var b:SByte = SByte.instance();
			b._w_String(path);
			b.writeInt(int(offsetX * 1000));
			b.writeInt(int(offsetY * 1000));
			var alpha:uint = uint(Number(offsetAlpha * 100));
			if (alpha > 100) alpha = 100;
			b.writeByte(alpha);
			b.writeInt(int(offsetRotation * 1000));
			b.writeInt(int(offsetScaleX * 1000));
			b.writeInt(int(offsetScaleY * 1000));
			b.writeByte(pathType);
			return b;
		}
		
		/** 读取这个内容 **/
		override public function setByte(b:SByte):void
		{
			path = b._r_String();
			offsetX = b.readInt() / 1000;
			offsetY = b.readInt() / 1000;
			offsetAlpha = b.readUnsignedByte() / 100;
			offsetRotation = b.readInt() / 1000;
			offsetScaleX = b.readInt() / 1000;
			offsetScaleY = b.readInt() / 1000;
			if (parent.ver < 6)
			{
				pathType = EnginePathType.getPathType(path);
			}
			else
			{
				pathType = b.readUnsignedByte();
			}
		}
		
		/** 克隆一个对象 **/
		public function clone(parent:U2InfoBaseInfo):U2InfoBitmap
		{
			var o:U2InfoBitmap = new U2InfoBitmap(parent);
			o.path = path;
			o.offsetX = offsetX;
			o.offsetY = offsetY;
			o.offsetAlpha = offsetAlpha;
			o.offsetRotation = offsetRotation;
			o.offsetScaleX = offsetScaleX;
			o.offsetScaleY = offsetScaleY;
			o.pathType = pathType;
			return o;
		}
	}
}