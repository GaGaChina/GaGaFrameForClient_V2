package cn.wjj.display.ui2d.info
{
	import cn.wjj.display.ui2d.engine.EnginePathType;
	import cn.wjj.gagaframe.client.speedfact.SByte;
	
	/**
	 * 显示对象
	 * 如果是Sprite对象的列表必须使用这个显示对象来记录
	 * 如果是非容器,直接帧就是使用普通帧
	 * 
	 * @author GaGa
	 */
	public class U2InfoDisplay extends U2InfoBase 
	{
		/** 对象坐标(乘过1000) **/
		public var x:Number = 0;
		/** 对象坐标(乘过1000) **/
		public var y:Number = 0;
		/** 比例偏移量,比例为1的时候的比例(乘过1000) **/
		public var scaleX:Number = 1;
		/** 比例偏移量,比例为1的时候的比例(乘过1000) **/
		public var scaleY:Number = 1;
		/** 透明度 **/
		public var alpha:Number = 1;
		/** 角度(乘过1000) **/
		public var rotation:Number = 0;
		/** 显示对象是否是一个引用,U2,Bitmap **/
		public var path:String = "";
		/** 路径类型,0:无,1:u2,2:jpg,3:png,99:未知 **/
		public var pathType:int = 0;
		
		public function U2InfoDisplay(parent:U2InfoBaseInfo):void
		{
			super(parent);
			this.type = U2InfoType.bitmap;
		}
		
		/** 获取这个对象的全部属性信息 **/
		override public function getByte():SByte 
		{
			var b:SByte = SByte.instance();
			b.writeInt(int(x * 1000));
			b.writeInt(int(y * 1000));
			b.writeInt(int(scaleX * 1000));
			b.writeInt(int(scaleY * 1000));
			b.writeByte(uint(alpha * 100));
			b.writeInt(int(rotation * 1000));
			b._w_String(path);
			b.writeByte(pathType);
			return b;
		}
		
		/** 读取这个内容 **/
		override public function setByte(b:SByte):void
		{
			x = b.readInt() / 1000;
			y = b.readInt() / 1000;
			scaleX = b.readInt() / 1000;
			scaleY = b.readInt() / 1000;
			alpha = b.readUnsignedByte() / 100;
			rotation = b.readInt() / 1000;
			path = b._r_String();
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
		public function clone(parent:U2InfoBaseInfo):U2InfoDisplay
		{
			var o:U2InfoDisplay = new U2InfoDisplay(parent);
			o.x = x;
			o.y = y;
			o.scaleX = scaleX;
			o.scaleY = scaleY;
			o.alpha = alpha;
			o.rotation = rotation;
			o.path = path;
			o.pathType = pathType;
			return o;
		}
	}
}