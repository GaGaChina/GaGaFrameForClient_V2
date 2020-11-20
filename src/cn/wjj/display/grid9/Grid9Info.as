package cn.wjj.display.grid9
{
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	import cn.wjj.gagaframe.client.speedfact.SByte;
	
	/**
	 * 一个节点信息的总入口
	 * 
	 * @author GaGa
	 */
	public class Grid9Info 
	{
		/** 图层名称 **/
		public var name:String = "";
		/** 图层所用的GFile数据对象 **/
		public var gfile:*;
		/** [只对编辑的时候有用]编辑的时候的GFile名称 **/
		public var gfileName:String = "";
		/** 保存的路径 **/
		public var path:String = "";
		/** 数据的版本号 **/
		public var ver:uint = 1;
		/** 里面是否有U2对象 **/
		public var u2:Boolean = false;
		/** 最小宽度(小于会直接被缩放) **/
		public var width:uint = 0;
		/** 最小高度(小于会直接被缩放) **/
		public var height:uint = 0;
		/**
		 * 九宫格的面数
		 * 
		 * 2:2面九宫格
		 * 3:3面九宫格
		 * 6:6面九宫格
		 * 9:9面九宫格
		 */
		public var face:uint = 0;
		/**
		 * 九宫格延伸时候对齐方式
		 * 
		 * 0 : 暂时不做自定义
		 * 1 : 左上顶点
		 * 2 : 中上顶点
		 * 3 : 右上顶点
		 * 4 : 左中顶点
		 * 5 : 中心顶点
		 * 6 : 右中顶点
		 * 7 : 左下顶点
		 * 8 : 中下顶点
		 * 9 : 右下顶点
		 */
		public var align:uint = 0;
		
		/** 是否监控鼠标 **/
		public var mouseEnabled:Boolean = false;
		/**
		 * 每一片的数据
		 * 
		 * 2面九宫格
		 * 		1 0 (1为水平拉伸)
		 * 3面九宫格
		 * 		0 1 2 (1为水平拉伸)
		 * 6面九宫格
		 * 		0 1 2
		 * 		3 4 5 (1, 3, 5 3个方向, 4 四方向拉伸)
		 * 9面九宫格
		 * 		0 1 2 (1水平拉伸)
		 * 		3 4 5 (3, 5 垂直拉伸 , 4 四方向拉伸)
		 * 		6 7 8 (7水平拉伸)
		 * 
		 */
		public var list:Vector.<Grid9InfoPiece> = new Vector.<Grid9InfoPiece>();
		
		public function Grid9Info():void { }
		
		/** 获取这个对象的全部属性信息 **/
		public function getByte():SByte 
		{
			var b:SByte = SByte.instance();
			b._w_String(name);
			b._w_String(gfileName);
			b._w_String(path);
			b.writeByte(1);//写入版本号
			b.writeBoolean(u2);
			b.writeShort(width);
			b.writeShort(height);
			b.writeByte(face);
			b.writeByte(align);
			b.writeBoolean(mouseEnabled);
			b.writeByte(list.length);
			var bb:SByte;
			for each (var p:Grid9InfoPiece in list) 
			{
				bb = p.getByte();
				b._w_CByteArray(bb, 8);
				bb.dispose();
			}
			return b;
		}
		
		/** 读取这个内容 **/
		public function setByte(b:SByte):void
		{
			try
			{
				name = b._r_String();
				gfileName = b._r_String();
				path = b._r_String();
				ver = b.readUnsignedByte();
				u2 = b.readBoolean();
				width = b.readShort();
				height = b.readShort();
				face = b.readUnsignedByte();
				align = b.readUnsignedByte();
				mouseEnabled = b.readBoolean();
				var i:int = b.readUnsignedByte();
				var p:uint = b.position;
				var piece:Grid9InfoPiece;
				while (--i > -1)
				{
					piece = new Grid9InfoPiece();
					p = p + b.readUnsignedShort() + 2;
					piece.setByte(b);
					list.push(piece);
				}
			}
			catch(e:Error)
			{
				g.log.pushLog(this, LogType._UserAction, "长度出错,版本不同");
			}
		}
		
		public function dispose():void 
		{
			name = "";
			gfileName = "";
			path = "";
			if (list)
			{
				if (list.length)
				{
					for each (var piece:Grid9InfoPiece in list)
					{
						piece.dispose();
					}
					list.length = 0;
				}
				list = null;
			}
			gfile = null;
		}
		
		/** 获取这个界面的保存文件名称 .u2 **/
		public function get fileName():String { return name + ".g9"; }
		/** 获取这个界面的相对路径,包含文件名 **/
		public function get filePath():String { return path + fileName; }
		
		/** 克隆一个对象 **/
		public function clone():Grid9Info
		{
			var o:Grid9Info = new Grid9Info();
			o.name = name;
			o.gfileName = gfileName;
			o.path = path;
			o.ver = ver;
			o.u2 = u2;
			o.width = width;
			o.height = height;
			o.face = face;
			o.align = align;
			o.mouseEnabled = mouseEnabled;
			for each (var piece:Grid9InfoPiece in list) 
			{
				o.list.push(piece.clone());
			}
			return o;
		}
	}
}