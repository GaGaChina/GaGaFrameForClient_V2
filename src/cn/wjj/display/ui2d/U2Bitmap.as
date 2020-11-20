package cn.wjj.display.ui2d
{
	import cn.wjj.display.ui2d.info.U2InfoBase;
	import cn.wjj.gagaframe.client.speedfact.SpeedLib;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	/**
	 * UI2D的场景
	 * @author GaGa
	 */
	public class U2Bitmap extends Bitmap implements IU2Base
	{
		/** 对象池 **/
		private static var __f:SpeedLib = new SpeedLib(500);
		/** 对象池强引用的最大数量 **/
		static public function get __m():uint {return __f.length;}
		/** 对象池强引用的最大数量 **/
		static public function set __m(value:uint):void { __f.length = value; }
		
		public function U2Bitmap(bitmapData:BitmapData = null, pixelSnapping:String = "auto", smoothing:Boolean = false) 
		{
			super(bitmapData, pixelSnapping, smoothing);
		}
		
		/**
		 * 初始化 Bitmap 对象以引用指定的 BitmapData 对象。
		 * @param	bitmapData		被引用的 BitmapData 对象。
		 * @param	pixelSnapping	Bitmap 对象是否贴紧至最近的像素。
		 * @param	smoothing		在缩放时是否对位图进行平滑处理。例如，下例显示使用系数 3 缩放的同一位图，smoothing 设置为 false（左侧）和 true（右侧）：
		 * @param	isFactory		是否启用对象池
		 * @return
		 */
		public static function instance(bitmapData:BitmapData = null, pixelSnapping:String = "auto", smoothing:Boolean = false, isFactory:Boolean = false):U2Bitmap
		{
			var o:U2Bitmap = __f.instance() as U2Bitmap;
			if (o)
			{
				if (bitmapData) o.bitmapData = bitmapData;
				if (pixelSnapping != "auto") o.pixelSnapping = pixelSnapping;
				if (smoothing) o.smoothing = true;
				if (o.isFactory != isFactory) o.isFactory = isFactory;
			}
			else
			{
				o = new U2Bitmap(bitmapData, pixelSnapping, smoothing);
				if (o.isFactory != isFactory) o.isFactory = isFactory;
			}
			return o;
		}
		
		/** 清理 Bitmap 对象, 及里面的全部内容 **/
		public static function clear(o:U2Bitmap):void
		{
			if (o._timer)
			{
				var t:U2Timer = o._timer;
				o._timer = null;
				t.dispose();
				t = null;
			}
			if (o.path != "") o.path = "";
			if (o.isEmpty != true) o.isEmpty = true;
			if (o._data != null) o._data = null;
			if (o.cacheAsBitmap != false) o.cacheAsBitmap = false;
			if (o.bitmapData != null) o.bitmapData = null;
			if (o.filters != null) o.filters = null;
			if (o.visible != true) o.visible = true;
			if (o.name != "") o.name = "";
			if (o.smoothing != false) o.smoothing = false;
			if (o.pixelSnapping != "auto") o.pixelSnapping = "auto";
			if (o.mask != null) o.mask = null;
			if (o.opaqueBackground  != null) o.opaqueBackground  = null;
			if (o.scale9Grid != null) o.scale9Grid = null;
			o.clearPosition();
		}
		/** 对象里包含的数据 **/
		public function get data():U2InfoBase { return this._data; }
		/** 对象里包含的数据 **/
		public function set data(o:U2InfoBase):void { this._data = o; }
		/** 移除,清理,并回收 **/
		public function dispose():void
		{
			if (this.parent) this.parent.removeChild(this);
			if (isFactory)
			{
				U2Bitmap.clear(this);
				__f.recover(this);
			}
			else
			{
				if (bitmapData != null) bitmapData = null;
				if (mask != null) mask = null;
				if (cacheAsBitmap != false) cacheAsBitmap = false;
			}
		}
		/** 这个画布所使用的数据 **/
		private var _data:U2InfoBase;
		/** 动画控制对象 **/
		public var _timer:U2Timer;
		/** 如果这个对象被u2设置,就把设置的u2路径设置上,来防止多次设置u2路径 **/
		public var path:String = "";
		/** [暂留]是否内容为空 **/
		public var isEmpty:Boolean = true;
		/** 是否启用对象池 **/
		public var isFactory:Boolean = false;
		/** 记录对外的值 **/
		private var _x:Number = 0;
		private var _y:Number = 0;
		private var _alpha:Number = 1;
		private var _rotation:Number = 0;
		private var _scaleX:Number = 1;
		private var _scaleY:Number = 1;
		/** 原始的宽度和高度 **/
		//private var _width:uint = 0;
		//private var _height:uint = 0;
		
		/** 注册点X,x为0的时候的x坐标 **/
		private var _offsetX:Number = 0;
		/** 注册点Y,y为0的时候的y坐标 **/
		private var _offsetY:Number = 0;
		/** 透明度偏移量 **/
		private var _offsetAlpha:Number = 1;
		/** 角度偏移量,0度的时候的角度 **/
		private var _offsetRotation:Number = 0;
		/** 比例偏移量,比例为1的时候的比例 **/
		private var _offsetScaleX:Number = 1;
		/** 比例偏移量,比例为1的时候的比例 **/
		private var _offsetScaleY:Number = 1;
		
		/** BitmapX 注册点X,x为0的时候的x坐标,无缩放的偏移 **/
		private var _oxX:int = 0;
		/** BitmapX 注册点Y,y为0的时候的y坐标,无缩放的偏移 **/
		private var _oxY:int = 0;
		/** BitmapX 比例偏移量,比例为1的时候的比例 **/
		private var _oxSX:Number = 1;
		/** BitmapX 比例偏移量,比例为1的时候的比例 **/
		private var _oxSY:Number = 1;
		
		/** 叠加值 偏移量 X坐标 **/
		private var _oX:Number = 0;
		/** 叠加值 偏移量 Y坐标 **/
		private var _oY:Number = 0;
		/** 叠加值 **/
		private var _oSX:Number = 1;
		/** 叠加值 **/
		private var _oSY:Number = 1;
		
		/** 偏离中心点的角度(弧度),添加缩放比例的 **/
		private var offsetAngle:Number = 0;
		/** 偏离中心点的长度,添加缩放比例的 **/
		private var offsetLength:Number = 0;
		
		/** 重置全部的位置信息 **/
		public function clearPosition():void
		{
			if (_x != 0) _x = 0;
			if (_y != 0) _y = 0;
			if (_alpha != 1) _alpha = 1;
			if (_rotation != 0) _rotation = 0;
			if (_scaleX != 1) _scaleX = 1;
			if (_scaleY != 1) _scaleY = 1;
			if (_offsetX != 0) _offsetX = 0;
			if (_offsetY != 0) _offsetY = 0;
			if (_offsetAlpha != 1) _offsetAlpha = 1;
			if (_offsetRotation != 0) _offsetRotation = 0;
			if (_offsetScaleX != 1) _offsetScaleX = 1;
			if (_offsetScaleY != 1) _offsetScaleY = 1;
			if (_oxX != 0) _oxX = 0;
			if (_oxY != 0) _oxY = 0;
			if (_oxSX != 1) _oxSX = 1;
			if (_oxSY != 1) _oxSY = 1;
			if (_oX != 0) _oX = 0;
			if (_oY != 0) _oY = 0;
			if (_oSX != 1) _oSX = 1;
			if (_oSY != 1) _oSY = 1;
			if (offsetAngle != 0) offsetAngle = 0;
			if (offsetLength != 0) offsetLength = 0;
			if (super.x != 0) super.x = 0;
			if (super.y != 0) super.y = 0;
			if (z != 0) z = 0;
			if (super.rotation != 0) super.rotation = 0;
			if (super.scaleX != 1) super.scaleX = 1;
			if (super.scaleY != 1) super.scaleY = 1;
			if (scaleZ != 1) scaleZ = 1;
			if (super.alpha != 1) super.alpha = 1;
			if (rotationX != 0) rotationX = 0;
			if (rotationY != 0) rotationY = 0;
			if (rotationZ != 0) rotationZ = 0;
		}
		
		override public function set width(value:Number):void { super.width = value; _scaleX = super.scaleX / _oSX; }
		override public function set height(value:Number):void { super.height = value; _scaleY = super.scaleY / _oSY; }
		override public function get x():Number { return _x; }
		override public function set x(value:Number):void { if (_x != value) { _x = value; offsetCount(); }}
		override public function get y():Number { return _y; }
		override public function set y(value:Number):void { if (_y != value) { _y = value; offsetCount(); }}
		override public function get rotation():Number { return _rotation; }
		override public function set rotation(value:Number):void { if (_rotation != value) { _rotation = value; offsetCount(); }}
		override public function get alpha():Number { return _alpha; }
		override public function set alpha(value:Number):void { if (_alpha != value) { _alpha = value; offsetCount(); }}
		override public function get scaleX():Number { return _scaleX; }
		override public function set scaleX(value:Number):void { if (_scaleX != value) { _scaleX = value; offsetCount(); }}
		override public function get scaleY():Number { return _scaleY; }
		override public function set scaleY(value:Number):void { if (_scaleY != value) { _scaleY = value; offsetCount(); }}
		public function get offsetX():Number { return _offsetX; }
		public function set offsetX(value:Number):void { if (_offsetX != value) { _offsetX = value; offsetAngleCount(); }}
		public function get offsetY():Number { return _offsetY; }
		public function set offsetY(value:Number):void { if (_offsetY != value) { _offsetY = value; offsetAngleCount(); }}
		public function get offsetScaleX():Number { return _offsetScaleX; }
		public function set offsetScaleX(value:Number):void { if (_offsetScaleX != value) { _offsetScaleX = value; offsetAngleCount(); }}
		public function get offsetScaleY():Number { return _offsetScaleY; }
		public function set offsetScaleY(value:Number):void { if (_offsetScaleY != value) { _offsetScaleY = value; offsetAngleCount(); }}
		public function get offsetRotation():Number { return _offsetRotation; }
		public function set offsetRotation(value:Number):void { if (_offsetRotation != value) { _offsetRotation = value; offsetCount(); }}
		public function get offsetAlpha():Number { return _offsetAlpha; }
		public function set offsetAlpha(value:Number):void { if (_offsetAlpha != value) { _offsetAlpha = value; offsetCount(); }}
		public function get oxX():int { return _oxX; }
		public function set oxX(value:int):void { if (_oxX != value) { _oxX = value; offsetAngleCount(); }}
		public function get oxY():int { return _oxY; }
		public function set oxY(value:int):void { if (_oxY != value) { _oxY = value; offsetAngleCount(); }}
		public function get oxSX():Number { return _oxSX; }
		public function set oxSX(value:Number):void { if (_oxSX != value) { _oxSX = value; offsetAngleCount(); }}
		public function get oxSY():Number { return _oxSY; }
		public function set oxSY(value:Number):void { if (_oxSY != value) { _oxSY = value; offsetAngleCount(); }}
		public function get superX():Number { return super.x; }
		public function get superY():Number { return super.y; }
		
		/**
		 * [效率更快]设置这个对象的偏移属性
		 * @param	x
		 * @param	y
		 * @param	rotation
		 * @param	alpha
		 * @param	scaleX
		 * @param	scaleY
		 */
		public function setOffsetInfo(x:Number = 0, y:Number = 0, alpha:Number = 1, rotation:Number = 0, scaleX:Number = 1, scaleY:Number = 1):void
		{
			/*
			var isChange:Boolean = false;
			var isChangeS:Boolean = false;
			if (_offsetX != x) { _offsetX = x; isChange = true; }
			if (_offsetY != y) { _offsetY = y; isChange = true; }
			if (_offsetRotation != rotation) { _offsetRotation = rotation; isChangeS = true; }
			if (_offsetAlpha != alpha) { _offsetAlpha = alpha; isChangeS = true; }
			if (_offsetScaleX != scaleX) { _offsetScaleX = scaleX; isChange = true; }
			if (_offsetScaleY != scaleY) { _offsetScaleY = scaleY; isChange = true; }
			if (isChange)
			{
				offsetAngleCount();
			}
			else if (isChangeS)
			{
				offsetCount();
			}
			*/
			if (_offsetX != x || _offsetY != y || _offsetScaleX != scaleX || _offsetScaleY != scaleY)
			{
				_offsetX = x;
				_offsetY = y;
				_offsetScaleX = scaleX;
				_offsetScaleY = scaleY;
				//其他
				_offsetRotation = rotation;
				_offsetAlpha = alpha;
				offsetAngleCount();
			}
			else if (_offsetRotation != rotation || _offsetAlpha != alpha)
			{
				_offsetRotation = rotation;
				_offsetAlpha = alpha;
				offsetCount();
			}
		}
		
		/**
		 * [效率更快]设置BitmapX偏移属性
		 * @param	x
		 * @param	y
		 * @param	scaleX
		 * @param	scaleY
		 */
		public function setOffsetX(x:Number, y:Number, scaleX:Number, scaleY:Number):void
		{
			/*
			var isChange:Boolean = false;
			if (_oxX != x) { _oxX = x; isChange = true; }
			if (_oxY != y) { _oxY = y; isChange = true; }
			if (_oxSX != scaleX) { _oxSX = scaleX; isChange = true; }
			if (_oxSY != scaleY) { _oxSY = scaleY; isChange = true; }
			if (isChange) offsetAngleCount();
			*/
			if (_oxX != x || _oxY != y || _oxSX != scaleX || _oxSY != scaleY)
			{
				_oxX = x;
				_oxY = y;
				_oxSX = scaleX;
				_oxSY = scaleY;
				offsetAngleCount();
			}
		}
		
		/**
		 * [效率更快]设置这个对象的位置基本属性
		 * @param	x			X轴坐标
		 * @param	y			Y轴坐标
		 * @param	rotation	角度
		 * @param	alpha		透明度
		 * @param	scaleX		X轴缩放
		 * @param	scaleY		Y轴缩放
		 */
		public function setSizeInfo(x:Number = 0, y:Number = 0, alpha:Number = 1, rotation:Number = 0, scaleX:Number = 1, scaleY:Number = 1):void
		{
			/*
			var isChange:Boolean = false;
			if (_x != x) { _x = x; isChange = true; }
			if (_y != y) { _y = y; isChange = true; }
			if (_alpha != alpha) { _alpha = alpha; isChange = true; }
			if (_rotation != rotation) { _rotation = rotation; isChange = true; }
			if (_scaleX != scaleX) { _scaleX = scaleX; isChange = true; }
			if (_scaleY != scaleY) { _scaleY = scaleY; isChange = true; }
			if (isChange) offsetCount();
			*/
			if (_x != x || _y != y || _alpha != alpha || _rotation != rotation || _scaleX != scaleX || _scaleY != scaleY)
			{
				_x = x;
				_y = y;
				_alpha = alpha;
				_rotation = rotation;
				_scaleX = scaleX;
				_scaleY = scaleY;
				offsetCount();
			}
		}
		
		/** 根据偏移量算出角度 **/
		private function offsetAngleCount():void
		{
			offsetAngle = 0;
			offsetLength = 0;
			//_oX = (_oxX * _oxSX + _offsetX) * _offsetScaleX;
			//_oY = (_oxY * _oxSY + _offsetY) * _offsetScaleY;
			_oX = (_oxX + _offsetX) * _offsetScaleX;
			_oY = (_oxY + _offsetY) * _offsetScaleY;
			_oSX = _offsetScaleX * _oxSX;
			_oSY = _offsetScaleY * _oxSY;
			if (_oX != 0 && _oY != 0)
			{
				offsetLength = Math.sqrt(_oX * _oX + _oY * _oY);
				offsetAngle = Math.atan2( -_oY, -_oX);
			}
			else if (_oX == 0 && _oY == 0) { }
			else if (_oX == 0)
			{
				offsetAngle = 2 * Math.PI;
				offsetLength = _oY;
			}
			else if (_oY == 0)
			{
				offsetAngle = 0;
				offsetLength = _oX;
			}
			offsetCount();
		}
		
		/** 存放弧度变量 **/
		private static var tempAngle:Number;
		
		/** 现实的角度,对角度进行360度转换 **/
		private static var tempR:Number;
		private static var tempX:Number;
		private static var tempY:Number;
		private static var tempSX:Number;
		private static var tempSY:Number;
		public function offsetCount():void
		{
			tempR = (_rotation + _offsetRotation) % 360;
			if (tempR < 0) tempR += 360;
			tempX = _x;
			tempY = _y;
			tempSX = _scaleX * _oSX;
			tempSY = _scaleY * _oSY;
			if (tempR == 0)
			{
				if (_oX != 0) tempX += _oX * _scaleX;
				if (_oY != 0) tempY += _oY * _scaleY;
			}
			else if (tempR == 90)
			{
				//X轴的便宜将变为Y轴偏移,Y轴便宜转换为X轴便宜
				if (_oX != 0) tempY += _oX * _scaleX;
				if (_oY != 0) tempX -= _oY * _scaleY;
			}
			//容器和Shape可以去掉180的参数
			/*
			else if (tempR == 180)
			{
				if (_oX != 0) tempX -= (_width + _oX) * tempSX;
				if (_oY != 0) tempY -= (_height + _oY) * tempSY;
			}
			*/
			else if (tempR == 270)
			{
				if (_oX != 0) tempY -= _oX * _scaleX;
				if (_oY != 0) tempX += _oY * _scaleY;
			}
			else
			{
				if (_oX != 0 && _oY != 0)
				{
					tempAngle = tempR / 180 * Math.PI + offsetAngle;
					tempX -= Math.cos(tempAngle) * offsetLength * _scaleX;
					tempY -= Math.sin(tempAngle) * offsetLength * _scaleY;
				}
			}
			var alpha:Number = _alpha * this._offsetAlpha;
			if (super.alpha != alpha) super.alpha = alpha;
			if (super.rotation != tempR) super.rotation = tempR;
			if (super.scaleX != tempSX) super.scaleX = tempSX;
			if (super.scaleY != tempSY) super.scaleY = tempSY;
			if (super.x != tempX) super.x = tempX;
			if (super.y != tempY) super.y = tempY;
		}
		
		/** 本对象和子集对象是否播放 **/
		public function setPlay(value:Boolean, core:int = -1):void
		{
			if (_timer) _timer.setPlayThis(value, core);
			//无子对象
		}
		
		/** 是否正在播放 **/
		public function getPlayThis():Boolean
		{
			if(_timer) _timer.getPlayThis();
			return false;
		}
		/** 是否正在播放 **/
		public function setPlayThis(value:Boolean, core:int = -1):void
		{
			if (_timer) _timer.setPlayThis(value, core);
		}
		/** 子对象是否正播放 **/
		public function setPlayChild(value:Boolean, core:int = -1):void { }
		
		/** 速率,加速的时候使用 **/
		public function get speed():Number
		{
			if (_timer) return _timer._speed;
			return 1;
		}
		/** 速率,加速的时候使用 **/
		public function set speed(value:Number):void
		{
			if (_timer) _timer._speed = value;
		}
		
		/** 时间控制器 **/
		public function get timer():U2Timer { return _timer; }
		
		/**
		 * 将播放头移到影片剪辑的指定帧并停在那里
		 * @param	scene			层名称或帧ID
		 * @param	playChild		子对象是否播放
		 * @param	core			是否修正下核心时间
		 */
		public function gotoStop(scene:* = null, playChild:Boolean = false, core:int = -1):void
		{
			if (_timer) _timer.gotoStop(scene, playChild, core);
		}
		/**
		 * 播放那一帧,循环几次,播放完毕后执行函数
		 * @param frame			播放的标签或第几帧
		 * @param loop			循环的次数.
		 * @param method		播放完毕后触发函数
		 * @param overLabel		播放完毕后播放那个区间
		 * @param stopBegin		播放完毕后是停留在开始,还是停留在最后幀,如果设置overPlayLabel就忽略这个参数
		 */
		public function gotoPlay(scene:*, loop:int = 0, method:Function = null, overLabel:String = "", stopBegin:Boolean = true, playChild:Boolean = true, core:int = -1):void
		{
			if (_timer) _timer.gotoPlay(scene, loop, method, overLabel, stopBegin, playChild, core);
		}
		
		/**
		 * 调整到播放某一个时间点,循环几次,播放完毕后执行函数
		 * @param time			毫秒
		 * @param loop			循环的次数.
		 * @param method		播放完毕后触发函数
		 * @param overLabel		播放完毕后播放那个区间
		 * @param stopBegin		播放完毕后是停留在开始,还是停留在最后幀,如果设置overLabel就忽略这个参数
		 * @param playChild		子对象是否播放
		 * @param core			内核时间
		 */
		public function playTime(time:uint, loop:int = 0, method:Function = null, overLabel:String = "", stopBegin:Boolean = true, playChild:Boolean = true, core:int = -1):void
		{
			if (_timer) _timer.playTime(time, loop, method, overLabel, stopBegin, playChild, core);
		}
		/**
		 * 播放那一帧,循环几次,播放完毕后执行函数
		 * @param	time		毫秒
		 * @param	playChild	是否播放子对象
		 * @param	core		内核时间
		 */
		public function stopTime(time:uint, playChild:Boolean = false, core:int = -1):void
		{
			if (_timer) _timer.stopTime(time, playChild, core);
		}
		/**
		 * 播放名称为labelName的几个幀的序列
		 * @param	label
		 * @param	loop		循环次数,0无限循环,1循环一次停止
		 * @param	method		播放完毕后触发函数
		 * @param	overLabel	播放完毕后播放那个区间
		 * @param	stopBegin	播放完毕后是停留在开始,还是停留在最后幀,如果设置overPlayLabel就忽略这个参数
		 * @param	playChild	子对象是否播放
		 * @param	core		内核时间
		 */
		public function playLabel(label:String, loop:int = 0, method:Function = null, overLabel:String = "", stopBegin:Boolean = true, playChild:Boolean = true, core:int = -1):void
		{
			if (_timer) _timer.playLabel(label, loop, method, overLabel, stopBegin, playChild, core);
		}
	}
}