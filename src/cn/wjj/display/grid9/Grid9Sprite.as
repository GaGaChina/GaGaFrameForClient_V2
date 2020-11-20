package cn.wjj.display.grid9
{
	import cn.wjj.g;
	import cn.wjj.display.ui2d.U2Timer;
	import cn.wjj.gagaframe.client.speedfact.SpeedLib;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	/**
	 * UI2D的场景
	 * @author GaGa
	 */
	public class Grid9Sprite extends Sprite
	{
		/** 对象池 **/
		private static var __f:SpeedLib = new SpeedLib(50);
		/** 对象池强引用的最大数量 **/
		static public function get __m():uint {return __f.length;}
		/** 对象池强引用的最大数量 **/
		static public function set __m(value:uint):void { __f.length = value; }
		
		public function Grid9Sprite()
		{
			mouseEnabled = false;
			mouseChildren = false;
		}
		/** 初始化 Grid9Sprite **/
		public static function instance():Grid9Sprite
		{
			var o:Grid9Sprite = __f.instance() as Grid9Sprite;
			if (o == null) o = new Grid9Sprite();
			return o;
		}
		
		/** 移除,清理,并回收 **/
		public function dispose():void
		{
			if (this.parent) this.parent.removeChild(this);
			Grid9Sprite.clear(this);
			__f.recover(this);
		}
		
		/** 清理 Grid9Sprite 对象, 及里面的全部内容 **/
		public static function clear(o:Grid9Sprite):void
		{
			if (o.timer)
			{
				var t:U2Timer = o.timer;
				o.timer = null;
				t.dispose();
				t = null;
			}
			if (o.path != "") o.path = "";
			if (o.data != null) o.data = null;
			o.graphics.clear();
			if (o.x != 0) o.x = 0;
			if (o.y != 0) o.y = 0;
			if (o.z != 0) o.z = 0;
			if (o.rotation != 0) o.rotation = 0;
			if (o.rotationX != 0) o.rotationX = 0;
			if (o.rotationY != 0) o.rotationY = 0;
			if (o.rotationZ != 0) o.rotationZ = 0;
			if (o.scaleX != 1) o.scaleX = 1;
			if (o.scaleY != 1) o.scaleY = 1;
			if (o.scaleZ != 1) o.scaleZ = 1;
			if (o.visible != true) o.visible = true;
			if (o.alpha != 1) o.alpha = 1;
			if (o.cacheAsBitmap != false) o.cacheAsBitmap = false;
			if (o.name != "") o.name = "";
			if (o.mask != null) o.mask = null;
			if (o.opaqueBackground  != null) o.opaqueBackground  = null;
			if (o.filters != null) o.filters = null;
			if (o.tabChildren != true) o.tabChildren = true;
			if (o.buttonMode != false) o.buttonMode = false;
			if (o.mouseEnabled != false) o.mouseEnabled = false;
			if (o.mouseChildren != false) o.mouseChildren = false;
			if (o.useHandCursor != true) o.useHandCursor = true;
			if (o.scale9Grid != null) o.scale9Grid = null;
			//if (o.transform != null) o.transform = null;
			//删除全部的图形
			var i:int = o.numChildren;
			if (i)
			{
				var d:Object;
				while (--i > -1)
				{
					d = o.getChildAt(i);
					if ("dispose" in d) d.dispose();
				}
				o.removeChildren();
			}
			if (o.list)
			{
				if (o.list.length)
				{
					for each (var item:DisplayObject in o.list) 
					{
						if ("dispose" in item)
						{
							d.dispose();
						}
						if (item.parent)
						{
							item.parent.removeChild(item);
						}
					}
				}
				g.speedFact.d_vector(DisplayObject, o.list);
				o.list = null;
			}
		}
		
		/** 动画控制对象 **/
		public var timer:U2Timer;
		/** 如果这个对象被u2设置,就把设置的u2路径设置上,来防止多次设置u2路径 **/
		public var path:String = "";
		/** 这个画布所使用的数据 **/
		public var data:Grid9Info;
		
		/** 缓存的宽度 **/
		private var _width:uint = 0;
		/** 缓存的高度 **/
		private var _height:uint = 0;
		/** 缓存的比例 **/
		private var _sx:Number = 0;
		/** 缓存的比例 **/
		private var _sy:Number = 0;
		
		/**
		 * 缓存全部的显示对象(数字是图片在数组里的位置)
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
		 */
		internal var list:Vector.<DisplayObject>;
		/** 方格1现在所占用的图形数量 **/
		internal var no1:int = 0;
		/** 方格3现在所占用的图形数量 **/
		internal var no3:int = 0;
		/** 方格4现在所占用的图形数量 **/
		internal var no4:int = 0;
		/** 方格5现在所占用的图形数量 **/
		internal var no5:int = 0;
		/** 方格7现在所占用的图形数量 **/
		internal var no7:int = 0;
		
		/** 除了左上角对齐,其他都要叠加偏移量 **/
		private static var _ox:int, _oy:int;
		
		override public function get width():Number { return _width; }
		override public function set width(value:Number):void { setSize(value, _height, _sx, _sy); }
		override public function get height():Number { return _height; }
		override public function set height(value:Number):void { setSize(_width, value, _sx, _sy); }
		override public function get scaleX():Number { return _sx; }
		override public function set scaleX(value:Number):void { setSize(_width, _height, value, _sy); }
		override public function get scaleY():Number { return _sy; }
		override public function set scaleY(value:Number):void { setSize(_width, _height, _sx, value); }
		
		/**
		 * 设置九宫格尺寸
		 * 
		 * 如果小于最小宽度,将缩放
		 * 如果大于最小高度,也将缩放
		 * @param	w			九宫格的宽度
		 * @param	h			九宫格的高度
		 * @param	sx			九宫格在w和h基础上继续缩放比例
		 * @param	sy			九宫格在w和h基础上继续缩放比例
		 * @param	refresh		当宽度高度是一样的时候,是否执行强制刷新尺寸
		 */
		public function setSize(w:uint, h:uint,sx:Number = 1, sy:Number = 1, refresh:Boolean = false):void
		{
			if (data && w > 0 && h > 0 && data.list.length)
			{
				if (w < data.width)
				{
					w = data.width;
				}
				if (h < data.height)
				{
					h = data.height;
				}
				if (_width != w || _height != h || _sx != sx || _sy != sy || refresh)
				{
					if (list == null)
					{
						list = g.speedFact.n_vector(DisplayObject);
						if (list == null)
						{
							list = new Vector.<DisplayObject>();
						}
					}
					else if (refresh)
					{
						//如果是刷新就全部从头制作, 否则已经有的图片不用处理
						Grid9EngineSprite.clearDisplay(this);
					}
					_width = w;
					_height = h;
					_sx = sx;
					_sy = sy;
					var s:Number = 1;
					switch (data.face) 
					{
						case 2:
							if (h != data.height)
							{
								s = h / data.height;
							}
							w = uint(w / s);
							h = data.height;
							break;
					}
					super.scaleX = sx * s;
					super.scaleY = sy * s;
					//计算出整体的偏移量
					switch (data.align)
					{
						case 0://暂时不做自定义
						case 1://左上顶点
							_ox = 0;
							_oy = 0;
							break;
						case 2://中上顶点
							_ox = -int(w / 2);
							_oy = 0;
							break;
						case 3://右上顶点
							_ox = -w;
							_oy = 0;
							break;
						case 4://左中顶点
							_ox = 0;
							_oy = -int(h / 2);
							break;
						case 5://中心顶点
							_ox = -int(w / 2);
							_oy = -int(h / 2);
							break;
						case 6://右中顶点
							_ox = -w;
							_oy = -int(h / 2);
							break;
						case 7://左下顶点
							_ox = 0;
							_oy = -h;
							break;
						case 8://中下顶点
							_ox = -int(w / 2);
							_oy = -h;
							break;
						case 9://右下顶点
							_ox = -w;
							_oy = -h;
							break;
					}
					//开始设置图片
					switch (data.face)
					{
						case 2:
							Grid9EngineSprite.face_2(this, w, h, _ox, _oy);
							break;
						case 3:
							Grid9EngineSprite.face_3(this, w, h, _ox, _oy);
							break;
						case 6:
							Grid9EngineSprite.face_6(this, w, h, _ox, _oy);
							break;
						case 9:
							
							break;
					}
				}
			}
			else
			{
				Grid9EngineSprite.clearDisplay(this);
			}
		}
	}
}