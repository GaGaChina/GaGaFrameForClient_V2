package cn.wjj.display.ui2d.info
{
	import cn.wjj.display.ui2d.engine.EngineLayer;
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	import cn.wjj.gagaframe.client.speedfact.SByte;
	
	/**
	 * 坐标点
	 * @author GaGa
	 */
	public class U2InfoBaseLayer extends U2InfoBase 
	{
		/** 图层名称 **/
		public var name:String = "";
		/** 使用的FPS为多少, 0就是不变,单幀 **/
		public var fps:Number = 0;
		/**
		 * 图层的类型
		 * 0:  容器 多层 单帧 范类型		U2InfoBaseFrameDisplay
		 * 1:非容器 单层 单帧 Bitmap 		U2InfoBaseFrameBitmap
		 * 2:非容器 单层 单帧 Shape 		U2InfoBaseFrameShape
		 */
		public var dType:uint = 0;
		/** [isPlayChild可以标识子集是否包含u2]一个u2动画是否连贯贯通整个动画 **/
		public var pathLine:Boolean = false;
		/** [图层多帧或图层中包含u2对象,这个对象很可能是动画]本级是否可以播放 **/
		public var isPlay:Boolean = false;
		/** [图层多帧]本层是否可以播放 **/
		public var isPlayThis:Boolean = false;
		/** [-1.子不可播放 1.可以播放]是否可以播放子集 **/
		public var isPlayChild:Boolean = false;
		/** 每一幀对应的Bitmap对象,这个对象从0开始 **/
		public var lib:Vector.<U2InfoBaseFrame>;
		/** 帧数量 **/
		public var length:int = 0;
		
		/** 是否有鼠标事件 **/
		public var mouseLength:int = 0;
		/** 鼠标事件内容 **/
		public var mouseList:Vector.<U2InfoMouseEvent>;
		
		/** 每一帧的毫秒数 **/
		public var frequency:Number = 0;
		/** 整个动画帧的时长 **/
		public var timeLength:Number = 0;
		
		/**
		 * 层类型
		 * 
		 * 切换型(序列帧动画)
		 * 
		 * 移动型
		 * 只能有一个U2InfoBaseFrame,并且里面类型还必须一样(从A到B等动画)
		 * FPS几幀从哪里到哪里,或多少时间从哪里到哪里
		 */
		public function U2InfoBaseLayer(parent:U2InfoBaseInfo):void
		{
			super(parent);
			this.type = U2InfoType.baseLayer;
			lib = new Vector.<U2InfoBaseFrame>();
		}
		
		/** 获取这个对象的全部属性信息 **/
		override public function getByte():SByte 
		{
			var b:SByte = SByte.instance();
			b._w_String(name);
			b._w_Number32(fps);
			b._w_Uint8(dType);
			b.writeBoolean(pathLine);
			b.writeBoolean(isPlay);
			b.writeBoolean(isPlayThis);
			b.writeBoolean(isPlayChild);
			b.writeShort(lib.length);
			var bb:SByte;
			for each (var f:U2InfoBaseFrame in lib) 
			{
				b.writeShort(f.type);
				bb = f.getByte();
				b._w_CByteArray(bb, 32);
				bb.dispose();
			}
			b.writeShort(mouseLength);
			if (mouseLength)
			{
				for each (var e:U2InfoMouseEvent in mouseList) 
				{
					bb = e.getByte();
					b._w_CByteArray(bb, 32);
					bb.dispose();
				}
			}
			return b;
		}
		
		/** 读取这个内容 **/
		override public function setByte(b:SByte):void
		{
			var i:int;
			var f:U2InfoBaseFrame;
			var cType:uint;
			var mouseEvent:U2InfoMouseEvent;
			var p:uint;
			if (parent.ver > 8)
			{
				//获取版本号
				name = b._r_String();
				fps = b.readFloat();
				dType = b.readUnsignedByte();
				pathLine = b.readBoolean();
				isPlay = b.readBoolean();
				isPlayThis = b.readBoolean();
				isPlayChild = b.readBoolean();
				if (lib.length != 0) lib.length = 0;
				length = b.readUnsignedShort();
				i = length;
				//算图层的最长时长
				if (fps)
				{
					frequency = 1000 / fps;
					timeLength = frequency * i;
				}
				else
				{
					frequency = 0;
					timeLength = 0;
				}
				p = b.position;
				while (--i > -1) 
				{
					if (b.position != p) b.position = p;
					cType = b.readUnsignedShort();
					switch (cType) 
					{
						case U2InfoType.baseFrameDisplay:
							f = new U2InfoBaseFrameDisplay(parent);
							break;
						case U2InfoType.baseFrameBitmap:
							f = new U2InfoBaseFrameBitmap(parent);
							break;
						case U2InfoType.baseFrameShape:
							f = new U2InfoBaseFrameShape(parent);
							break;
					}
					p = p + b.readUnsignedInt() + 6;
					f.setByte(b);
					lib.push(f);
				}
				if (b.position != p) b.position = p;
				mouseLength = b.readUnsignedShort();
				if (mouseLength)
				{
					i = mouseLength;
					if (mouseList == null)
					{
						mouseList = new Vector.<U2InfoMouseEvent>();
					}
					else
					{
						mouseList.length = 0;
					}
					p = p + 2;
					while (--i > -1) 
					{
						if (b.position != p) b.position = p;
						mouseEvent = new U2InfoMouseEvent(parent);
						p = p + b.readUnsignedInt() + 4;
						mouseEvent.setByte(b);
						mouseList.push(mouseEvent);
					}
				}
			}
			else if (parent.ver < 5)
			{
				name = b._r_String();
				fps = b.readFloat();
				b.readUnsignedByte();//废弃
				b.readUnsignedByte();//废弃
				b._r_String();//废弃
				b.readUnsignedByte();
				dType = b.readUnsignedByte();
				if (dType == 5) { dType = 0; }
				else if (dType == 3) { dType = 1; }
				else if (dType == 4) { dType = 2; }
				lib.length = 0;
				length = b.readUnsignedShort();
				i = length;
				//算图层的最长时长
				if (fps)
				{
					frequency = 1000 / fps;
					timeLength = frequency * i;
				}
				else
				{
					frequency = 0;
					timeLength = 0;
				}
				p = b.position;
				while (--i > -1) 
				{
					if (b.position != p) b.position = p;
					cType = b.readUnsignedShort();
					switch (cType) 
					{
						case U2InfoType.baseFrameDisplay:
							f = new U2InfoBaseFrameDisplay(parent);
							break;
						case U2InfoType.baseFrameBitmap:
							f = new U2InfoBaseFrameBitmap(parent);
							break;
						case U2InfoType.baseFrameShape:
							f = new U2InfoBaseFrameShape(parent);
							break;
					}
					p = p + b.readUnsignedShort() + 4;
					f.setByte(b);
					lib.push(f);
				}
				EngineLayer.autoConfig(this);
			}
			else
			{
				//获取版本号
				name = b._r_String();
				fps = b.readFloat();
				dType = b.readUnsignedByte();
				pathLine = b.readBoolean();
				isPlay = b.readBoolean();
				isPlayThis = b.readBoolean();
				isPlayChild = b.readBoolean();
				lib.length = 0;
				length = b.readUnsignedShort();
				i = length;
				//算图层的最长时长
				if (fps)
				{
					frequency = 1000 / fps;
					timeLength = frequency * i;
				}
				else
				{
					frequency = 0;
					timeLength = 0;
				}
				p = b.position;
				while (--i > -1) 
				{
					if (b.position != p) b.position = p;
					cType = b.readUnsignedShort();
					switch (cType) 
					{
						case U2InfoType.baseFrameDisplay:
							f = new U2InfoBaseFrameDisplay(parent);
							break;
						case U2InfoType.baseFrameBitmap:
							f = new U2InfoBaseFrameBitmap(parent);
							break;
						case U2InfoType.baseFrameShape:
							f = new U2InfoBaseFrameShape(parent);
							break;
					}
					p = p + b.readUnsignedShort() + 4;
					f.setByte(b);
					lib.push(f);
				}
				if (b.position != p) b.position = p;
				mouseLength = b.readUnsignedShort();
				if (mouseLength)
				{
					i = mouseLength;
					if (mouseList == null)
					{
						mouseList = new Vector.<U2InfoMouseEvent>();
					}
					else
					{
						mouseList.length = 0;
					}
					p = p + 2;
					while (--i > -1) 
					{
						if (b.position != p) b.position = p;
						mouseEvent = new U2InfoMouseEvent(parent);
						p = p + b.readUnsignedShort() + 2;
						mouseEvent.setByte(b);
						mouseList.push(mouseEvent);
					}
				}
			}
		}
		
		override public function dispose():void 
		{
			super.dispose();
			for each (var item:U2InfoBaseFrame in lib) 
			{
				item.dispose();
			}
			lib.length = 0;
			lib = null;
			length = 0;
		}
		
		/** 添加一帧 **/
		public function pushFrame(o:U2InfoBaseFrame):Boolean
		{
			if (lib.indexOf(o) == -1)
			{
				lib.push(o);
				length++;
				timeLength = frequency * length;
				return true;
			}
			g.log.pushLog(this, LogType._ErrorLog, "已经添加过本帧");
			return false;
		}
		
		/** 添加帧到指定位置 **/
		public function pushFrameIn(o:U2InfoBaseFrame, id:int):Boolean
		{
			if (lib.indexOf(o) == -1)
			{
				if (id == length)
				{
					lib.push(o);
					length++;
					return true;
				}
				else if (id > length)
				{
					g.log.pushLog(this, LogType._ErrorLog, "添加的位置超出现在帧数");
				}
				else
				{
					lib.splice(id, 0, o);
					length++;
					return true;
				}
			}
			else
			{
				g.log.pushLog(this, LogType._ErrorLog, "添加的帧类型不符");
			}
			return false;
		}
		
		/** 获取里面帧的ID号 **/
		public function getFrameId(o:U2InfoBaseFrame):int
		{
			if (length > 0) return lib.indexOf(o);
			return -1;
		}
		
		/** 获取里面帧的ID号 **/
		public function getIdFrame(id:int):U2InfoBaseFrame
		{
			if (length > id && length > 0) return lib[id];
			return null;
		}
		
		/** 删除一帧 **/
		public function removeFrameId(id:int):Boolean
		{
			if (length > id && length > 0)
			{
				lib.splice(id, 1);
				length--;
				return true;
			}
			return false;
		}
		
		/** 删除图层中的一帧 **/
		public function removeFrame(frame:U2InfoBaseFrame):Boolean
		{
			if (length > 0)
			{
				var id:int = lib.indexOf(frame);
				if (id != -1)
				{
					return removeFrameId(id);
				}
			}
			return false;
		}
		
		/** 克隆一个对象 **/
		public function clone(parent:U2InfoBaseInfo):U2InfoBaseLayer
		{
			var o:U2InfoBaseLayer = new U2InfoBaseLayer(parent);
			o.name = name;
			o.fps = fps;
			o.frequency = frequency;
			o.dType = dType;
			o.pathLine = pathLine;
			o.isPlay = isPlay;
			o.isPlayThis = isPlayThis;
			o.isPlayChild = isPlayChild;
			o.timeLength = timeLength;
			o.length = length;
			for each (var f:U2InfoBaseFrame in lib)
			{
				o.lib.push(f.clone(parent));
			}
			if (mouseLength)
			{
				o.mouseLength = mouseLength;
				o.mouseList = new Vector.<U2InfoMouseEvent>();
				for each (var e:U2InfoMouseEvent in mouseList) 
				{
					o.mouseList.push(e.clone(parent));
				}
			}
			return o;
		}
	}
}