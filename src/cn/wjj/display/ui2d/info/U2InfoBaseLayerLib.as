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
	public class U2InfoBaseLayerLib extends U2InfoBase 
	{
		/** 存放名称对应的图层信息 **/
		private var libName:Object = new Object();
		/** 现在最大的图层ID **/
		public var length:int = 0;
		/** [禁止直接操作]将全部的图层都保存起来,index小的在下面 **/
		public var lib:Vector.<U2InfoBaseLayer> = new Vector.<U2InfoBaseLayer>();
		/** 整个动画帧的时长 **/
		public var timeLength:Number = 0;
		/** 本级是否可以播放 **/
		public var isPlay:Boolean = false;
		/** 本层是否可以播放 **/
		public var isPlayThis:Boolean = false;
		/** [-1.子不可播放 1.可以播放]是否可以播放子集 **/
		public var isPlayChild:Boolean = false;
		/** 是否根据全局的坐标来判断是否还在场景区域,如果没有在就自动移除 **/
		public var autoRemove:Boolean = false;
		/** 自动移除[是否需要直接处理掉] **/
		public var autoDispose:Boolean = false;
		
		public function U2InfoBaseLayerLib(parent:U2InfoBaseInfo):void
		{
			super(parent);
			this.type = U2InfoType.baseLayerLib;
		}
		
		/**
		 * 获取某一个层级的图层信息
		 * @param	index
		 * @return
		 */
		public function getIdLayer(index:int):U2InfoBaseLayer
		{
			if (lib.length > index && index > -1)
			{
				return lib[index];
			}
			return null;
		}
		
		/**
		 * 删除选中的图层
		 * @param	info
		 */
		public function removeLayer(info:U2InfoBaseLayer):Boolean
		{
			var index:int = lib.indexOf(info);
			if (index != -1)
			{
				length--;
				lib.splice(index, 1);
				libName[info.name] = null;
				delete libName[info.name];
				return true;
			}
			return false;
		}
		
		/**
		 * 重命名图层
		 * @param	info
		 * @param	newName
		 */
		public function reSetLayerName(info:U2InfoBaseLayer, newName:String):void
		{
			if (info.name != newName)
			{
				libName[info.name] = null;
				delete libName[info.name];
				info.name = newName;
				libName[info.name] = info;
			}
		}
		
		/**
		 * 获取某一个名称的图层ID
		 * @param	index
		 * @return
		 */
		public function getLayerName(name:String):U2InfoBaseLayer
		{
			return libName[name];
		}
		
		/**
		 * 添加一个图层信息
		 * @param	info
		 */
		public function addLayer(info:U2InfoBaseLayer):Boolean
		{
			if (lib.indexOf(info) != -1)
			{
				g.log.pushLog(this, LogType._ErrorLog, "图层已经存在");
			}
			else if (info.name == "")
			{
				g.log.pushLog(this, LogType._ErrorLog, "图层缺少名称");
			}
			else if (libName[info.name] == null)
			{
				libName[info.name] = info;
				lib.push(info);
				length++;
				return true;
			}
			else
			{
				g.log.pushLog(this, LogType._ErrorLog, "图层重名");
			}
			return false;
		}
		
		/**
		 * 把a和b的位置互换
		 * @param	a
		 * @param	b
		 */
		public function swap(a:U2InfoBaseLayer, b:U2InfoBaseLayer):void
		{
			var aIndex:int = lib.indexOf(a);
			var bIndex:int = lib.indexOf(b);
			if (aIndex == -1 )
			{
				g.log.pushLog(this, LogType._ErrorLog, "A没有在列表中");
			}
			else if(bIndex == -1)
			{
				g.log.pushLog(this, LogType._ErrorLog, "B没有在列表中");
			}
			else
			{
				if (aIndex > bIndex)
				{
					var i:int = aIndex;
					aIndex = bIndex;
					bIndex = i;
					var tempLayer:U2InfoBaseLayer = a;
					a = b;
					b = tempLayer;
				}
				//把大的删除
				//把小的删除
				lib.splice(bIndex, 1);
				lib.splice(aIndex, 1);
				//把大的放小的位置
				lib.splice(aIndex, 0, b);
				//把小的放大的位置
				lib.splice(bIndex, 0, a);
			}
		}
		
		/**
		 * 把a和b的位置互换
		 * @param	a
		 * @param	b
		 */
		public function swapId(aIndex:int, bIndex:int):void
		{
			var a:U2InfoBaseLayer = getIdLayer(aIndex);
			var b:U2InfoBaseLayer = getIdLayer(bIndex);
			if (a == null )
			{
				g.log.pushLog(this, LogType._ErrorLog, "A没有在列表中");
			}
			else if(b == null)
			{
				g.log.pushLog(this, LogType._ErrorLog, "B没有在列表中");
			}
			else
			{
				if (aIndex > bIndex)
				{
					var i:int = aIndex;
					aIndex = bIndex;
					bIndex = i;
					var tempLayer:U2InfoBaseLayer = a;
					a = b;
					b = tempLayer;
				}
				//把大的删除
				//把小的删除
				lib.splice(bIndex, 1);
				lib.splice(aIndex, 1);
				//把大的放小的位置
				lib.splice(aIndex, 0, b);
				//把小的放大的位置
				lib.splice(bIndex, 0, a);
			}
		}
		
		/** 获取这个对象的全部属性信息 **/
		override public function getByte():SByte 
		{
			var b:SByte = SByte.instance();
			b.writeBoolean(isPlay);
			b.writeBoolean(isPlayThis);
			b.writeBoolean(isPlayChild);
			b.writeBoolean(autoRemove);
			b.writeBoolean(autoDispose);
			b._w_Uint16(length);
			var bb:SByte;
			for each (var item:U2InfoBaseLayer in lib) 
			{
				bb = item.getByte();
				b._w_CByteArray(bb, 32);
				bb.dispose();
			}
			return b;
		}
		
		/** 读取这个内容 **/
		override public function setByte(b:SByte):void
		{
			if (lib.length != 0) lib.length = 0;
			for (var key:String in libName) 
			{
				delete libName[key];
			}
			var i:int;
			var l:U2InfoBaseLayer;
			var p:uint;
			if (parent.ver > 8)
			{
				//获取版本号
				isPlay = b.readBoolean();
				isPlayThis = b.readBoolean();
				isPlayChild = b.readBoolean();
				autoRemove = b.readBoolean();
				autoDispose = b.readBoolean();
				length = b.readUnsignedShort();
				i = length;
				timeLength = 0;
				p = b.position;
				while (--i > -1)
				{
					l = new U2InfoBaseLayer(parent);
					if (b.position != p) b.position = p;
					p = p + b.readUnsignedInt() + 4;
					l.setByte(b);
					lib.push(l);
					libName[l.name] = l;
					if (timeLength < l.timeLength)
					{
						timeLength = l.timeLength;
					}
				}
			}
			else if (parent.ver < 5)
			{
				length = b.readUnsignedShort();
				i = length;
				timeLength = 0;
				p = b.position;
				while (--i > -1) 
				{
					if (b.position != p) b.position = p;
					l = new U2InfoBaseLayer(parent);
					p = p + b.readUnsignedShort() + 2;
					l.setByte(b);
					lib.push(l);
					libName[l.name] = l;
					if (timeLength < l.timeLength)
					{
						timeLength = l.timeLength;
					}
				}
				EngineLayer.autoConfigLib(parent);
			}
			else
			{
				//获取版本号
				isPlay = b.readBoolean();
				isPlayThis = b.readBoolean();
				isPlayChild = b.readBoolean();
				autoRemove = b.readBoolean();
				autoDispose = b.readBoolean();
				length = b.readUnsignedShort();
				i = length;
				timeLength = 0;
				p = b.position;
				while (--i > -1) 
				{
					if (b.position != p) b.position = p;
					l = new U2InfoBaseLayer(parent);
					p = p + b.readUnsignedShort() + 2;
					l.setByte(b);
					lib.push(l);
					libName[l.name] = l;
					if (timeLength < l.timeLength) timeLength = l.timeLength;
				}
			}
		}
		
		override public function dispose():void 
		{
			super.dispose();
			for each (var item:U2InfoBaseLayer in lib) 
			{
				item.dispose();
			}
			lib.length = 0;
			libName = null;
		}
		
		/** 克隆一个对象 **/
		public function clone(parent:U2InfoBaseInfo):U2InfoBaseLayerLib
		{
			var o:U2InfoBaseLayerLib = new U2InfoBaseLayerLib(parent);
			o.isPlay = isPlay;
			o.isPlayThis = isPlayThis;
			o.isPlayChild = isPlayChild;
			o.autoRemove = autoRemove;
			o.autoDispose = autoDispose;
			o.length = length;
			var i:int = length;
			var copy:U2InfoBaseLayer;
			for each (var item:U2InfoBaseLayer in lib) 
			{
				copy = item.clone(parent);
				o.lib.push(copy);
				o.libName[copy.name] = copy;
			}
			return o;
		}
	}
}