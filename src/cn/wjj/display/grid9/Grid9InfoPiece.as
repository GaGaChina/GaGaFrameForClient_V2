package cn.wjj.display.grid9
{
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	import cn.wjj.gagaframe.client.speedfact.SByte;
	
	/**
	 * 每一片的数据
	 * 
	 * 拉伸部分件在最下层
	 * 
	 * @author GaGa
	 */
	public class Grid9InfoPiece
	{
		/** 图片路径 **/
		public var path:String = "";
		/** 图片的类型, 0:普通, 1:U2, 2:九宫格 **/
		public var pathType:int = 0;
		
		/**
		 * 拉伸方式
		 * 
		 * 0 : 不变
		 * 1 : 拉伸
		 * 2 : 平铺
		 */
		public var layout:uint = 0;
		
		/** 平铺模式是否开启遮罩 **/
		public var mask:Boolean = false;
		
		/**
		 * 旋转角度
		 * 0 : 0度
		 * 1 : 90度
		 * 2 : 180度
		 * 3 : 270度
		 * 4 : 水平对折
		 * 5 : 垂直对折
		 */
		public var r:int = 0;
		/** 素材的原始偏离坐标,旋转中心点 **/
		public var x:int = 0;
		/** 素材的原始偏离坐标,旋转中心点 **/
		public var y:int = 0;
		/** 素材的原始宽度 **/
		public var width:uint = 0;
		/** 素材的原始高度 **/
		public var height:uint = 0;
		/** (旋转)素材的原始偏离坐标,旋转中心点 **/
		public var r_x:int = 0;
		/** (旋转)素材的原始偏离坐标,旋转中心点 **/
		public var r_y:int = 0;
		/** (旋转)素材的原始宽度 **/
		public var r_width:uint = 0;
		/** (旋转)素材的原始高度 **/
		public var r_height:uint = 0;
		
		/**
		 * 每一片的数据
		 */
		public function Grid9InfoPiece():void { }
		
		/** 获取这个对象的全部属性信息 **/
		public function getByte():SByte 
		{
			var b:SByte = SByte.instance();
			b._w_String(path);
			b.writeByte(pathType);
			b.writeByte(layout);
			b.writeBoolean(mask);
			b.writeByte(r);
			b.writeShort(x);
			b.writeShort(y);
			b.writeShort(width);
			b.writeShort(height);
			b.writeShort(r_x);
			b.writeShort(r_y);
			b.writeShort(r_width);
			b.writeShort(r_height);
			return b;
		}
		
		/** 读取这个内容 **/
		public function setByte(b:SByte):void
		{
			try
			{
				path = b._r_String();
				pathType = b.readByte();
				layout = b.readByte();
				mask = b.readBoolean();
				r = b.readByte();
				x = b.readShort();
				y = b.readShort();
				width = b.readShort();
				height = b.readShort();
				r_x = b.readShort();
				r_y = b.readShort();
				r_width = b.readShort();
				r_height = b.readShort();
			}
			catch(e:Error)
			{
				g.log.pushLog(this, LogType._UserAction, "长度出错,版本不同");
			}
		}
		
		public function dispose():void 
		{
			path = "";
		}
		
		/** 克隆一个对象 **/
		public function clone():Grid9InfoPiece
		{
			var o:Grid9InfoPiece = new Grid9InfoPiece();
			o.path = path;
			o.pathType = pathType;
			o.layout = layout;
			o.mask = mask;
			o.r = r;
			o.x = x;
			o.y = y;
			o.width = width;
			o.height = height;
			o.r_x = r_x;
			o.r_y = r_y;
			o.r_width = r_width;
			o.r_height = r_height;
			return o;
		}
	}
}