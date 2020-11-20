package cn.wjj.display.ui2d.info
{
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	import cn.wjj.gagaframe.client.speedfact.SByte;
	
	/**
	 * 一个节点信息的总入口
	 * 
	 * @author GaGa
	 */
	public class U2InfoBaseInfo extends U2InfoBase 
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
		public var ver:uint = 11;
		/**
		 * (无效)文件的类型(变为自动判断)
		 * 
		 * u2Layer 还是根据这个判断
		 * 
		 * 0:容器Sprite多层
		 * 1:非容器,Bitmap 单层 , 层内容不能调整坐标,并且是单帧
		 * 2:非容器,Shape 单层 , 层内容不能调整坐标
		 * 9:九宫格
		 */
		public var dType:uint = 0;
		/** 背景信息 **/
		public var stageInfo:U2InfoBaseStageInfo;
		/** 参考的格子 **/
		public var grid:U2InfoBaseGrid;
		/** 全部的图层信息 **/
		public var layer:U2InfoBaseLayerLib;
		/** 记录范围值会有一定的范围偏离 **/
		public var contour:U2InfoContourRect;
		/** 事件列表[声音,事件桥,等] **/
		public var eventLib:U2InfoEventLib;
		/** 是否开启鼠标模式 **/
		public var mouseEnabled:Boolean = false;
		/** true,移除显示对象的同时移除声音,false,不管声音的移除 **/
		public var disposeSound:Boolean = false;
		
		public function U2InfoBaseInfo(parent:U2InfoBaseInfo):void
		{
			if (parent == null) parent = this;
			super(parent);
			type = U2InfoType.baseInfo;
			stageInfo = new U2InfoBaseStageInfo(parent);
			grid = new U2InfoBaseGrid(parent);
			layer = new U2InfoBaseLayerLib(parent);
			contour = new U2InfoContourRect(parent);
			eventLib = new U2InfoEventLib(parent);
		}
		
		/** 获取这个对象的全部属性信息 **/
		override public function getByte():SByte 
		{
			var b:SByte = SByte.instance();
			b._w_String(name);
			b._w_String(gfileName);
			b._w_String(path);
			b._w_Uint8(10);//写入版本号
			b._w_Uint8(dType);
			var bb:SByte = stageInfo.getByte();
			b._w_CByteArray(bb);
			bb.dispose();
			bb = grid.getByte();
			b._w_CByteArray(bb);
			bb.dispose();
			bb = layer.getByte();
			b._w_CByteArray(bb, 32);
			bb.dispose();
			bb = contour.getByte()
			b._w_CByteArray(bb);
			bb.dispose();
			bb = eventLib.getByte();
			b._w_CByteArray(bb, 32);
			bb.dispose();
			b.writeBoolean(mouseEnabled);
			b.writeBoolean(disposeSound);
			return b;
		}
		
		/** 读取这个内容 **/
		override public function setByte(b:SByte):void
		{
			try
			{
				name = b._r_String();
				gfileName = b._r_String();
				path = b._r_String();
				ver = b.readUnsignedByte();
				dType = b.readUnsignedByte();
				if (dType == 5) { dType = 0; }
				else if (dType == 3) { dType = 1; }
				else if (dType == 4) { dType = 2; }
				//使用偏移量来读取数据
				var p:uint = b.position;
				p = p + b.readUnsignedShort() + 2;
				stageInfo.setByte(b);
				if (b.position != p) b.position = p;
				p = p + b.readUnsignedShort() + 2;
				grid.setByte(b);
				if (b.position != p) b.position = p;
				if (ver > 8)
				{
					p = p + b.readUnsignedInt() + 4;
					layer.setByte(b);
					if (b.position != p) b.position = p;
					p = p + b.readUnsignedShort() + 2;
					contour.setByte(b);
					if (b.position != p) b.position = p;
					p = p + b.readUnsignedInt() + 4;
					eventLib.setByte(b);
					if (b.position != p) b.position = p;
					mouseEnabled = b.readBoolean();
					disposeSound = b.readBoolean();
				}
				else
				{
					p = p + b.readUnsignedShort() + 2;
					layer.setByte(b);
					if (b.position != p) b.position = p;
					if (ver < 5)
					{
						//需要重置 contour 的属性
					}
					else
					{
						p = p + b.readUnsignedShort() + 2;
						contour.setByte(b);
						if (b.position != p) b.position = p;
						p = p + b.readUnsignedShort() + 2;
						eventLib.setByte(b);
						if (b.position != p) b.position = p;
						mouseEnabled = b.readBoolean();
						disposeSound = b.readBoolean();
					}
				}
			}
			catch(e:Error)
			{
				g.log.pushLog(this, LogType._UserAction, "长度出错,版本不同");
			}
		}
		
		override public function dispose():void 
		{
			super.dispose();
			stageInfo.dispose();
			stageInfo = null;
			grid.dispose();
			grid = null;
			layer.dispose();
			layer = null;
			contour.dispose();
			contour = null;
			eventLib.dispose();
			eventLib = null;
			gfile = null;
		}
		
		/** 获取这个界面的保存文件名称 .u2 **/
		public function get fileName():String { return name + ".u2"; }
		/** 获取这个界面的相对路径,包含文件名 **/
		public function get filePath():String { return path + fileName; }
		
		/** 克隆一个对象 **/
		public function clone(parent:U2InfoBaseInfo):U2InfoBaseInfo
		{
			var o:U2InfoBaseInfo = new U2InfoBaseInfo(parent);
			o.name = name;
			o.gfileName = gfileName;
			o.path = path;
			o.ver = ver;
			o.dType = dType;
			o.stageInfo = stageInfo.clone(parent);
			o.grid = grid.clone(parent);
			o.layer = layer.clone(parent);
			o.contour = contour.clone(parent);
			o.eventLib = eventLib.clone(parent);
			o.mouseEnabled = mouseEnabled;
			o.disposeSound = disposeSound;
			o.gfile = gfile;
			return o;
		}
	}
}