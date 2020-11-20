package cn.wjj.display.ui2d
{
	import cn.wjj.display.ui2d.engine.EngineInfo;
	import cn.wjj.display.ui2d.info.U2InfoBaseFrameDisplay;
	import cn.wjj.display.ui2d.info.U2InfoBaseInfo;
	import cn.wjj.display.ui2d.info.U2InfoBaseLayer;
	import cn.wjj.display.ui2d.U2Sprite;
	import cn.wjj.gagaframe.client.speedfact.SpeedLib;
	import flash.display.DisplayObject;
	
	/**
	 * 容器动画控制器
	 * 
	 * @author GaGa
	 */
	public class U2Layer 
	{
		/** 对象池 **/
		private static var __f:SpeedLib = new SpeedLib(500);
		/** 对象池强引用的最大数量 **/
		static public function get __m():uint {return __f.length;}
		/** 对象池强引用的最大数量 **/
		static public function set __m(value:uint):void {__f.length = value;}
		public function U2Layer() { }
		/** 初始化 U2Layer **/
		public static function instance():U2Layer
		{
			var o:U2Layer = __f.instance() as U2Layer;
			if (o) return o;
			return new U2Layer();
		}
		/** 重置属性,回收对象 **/
		public function recover():void { U2Layer.recover(this); }
		/** 移除,清理,并回收 **/
		public function dispose():void { U2Layer.recover(this); }
		/** 重置属性,回收对象 **/
		public static function recover(o:U2Layer):void { clear(o); __f.recover(o); }
		/** 清理 Shape 对象, 及里面的全部内容 **/
		public static function clear(o:U2Layer):void
		{
			if (o._display != null)
			{
				o._display.dispose();
				o._display = null;
			}
			if (o._layer != null) o._layer = null;
			if (o.frame != null) o.frame = null;
			if (o.timer != null)
			{
				var t:U2Timer = o.timer;
				o.timer = null;
				t.dispose();
				t = null;
			}
			if (o.parent != null) o.parent = null;
			if (o._smoothing) o._smoothing = false;
			if (o._speed != 1) o._speed = 1;
		}
		
		/** 对应的显示对象 **/
		public var _display:IU2Base;
		/** 这个画布所使用的数据 **/
		private var _layer:U2InfoBaseLayer;
		/** 显示对象所使用的图形信息 **/
		public var frame:U2InfoBaseFrameDisplay;
		/** 时间模块 **/
		public var timer:U2Timer;
		/** 这个层所属的 U2Sprite **/
		public var parent:U2Sprite;
		/** 是否平滑 **/
		private var _smoothing:Boolean = false;
		/** 播放的速度 **/
		private var _speed:Number = 1;
		
		public function get smoothing():Boolean { return _smoothing; }
		public function set smoothing(value:Boolean):void
		{
			if (_smoothing != value)_smoothing = value;
			timer.smoothing = value;
		}
		
		public function get speed():Number { return _speed; }
		public function set speed(value:Number):void
		{
			if (_speed != value)_speed = value;
			timer.speed = value;
		}
		
		/** 这个画布所使用的数据 **/
		public function get layer():U2InfoBaseLayer { return _layer; }
		/** 这个画布所使用的数据 **/
		public function set layer(value:U2InfoBaseLayer):void 
		{
			_layer = value;
			if (_layer && _layer.length)
			{
				frame = _layer.lib[0] as U2InfoBaseFrameDisplay;
			}
			else
			{
				frame = null;
			}
		}
		/** 对应的显示对象 **/
		public function get display():DisplayObject
		{
			if (_layer && frame)
			{
				if (_layer.pathLine && _display)
				{
					return _display as DisplayObject;
				}
				if (frame.display.pathType)
				{
					//依靠这个path来获取显示对象
					if (frame.display.pathType == 1)
					{
						//获取信息
						var baseInfo:U2InfoBaseInfo = EngineInfo.openGFilePath(layer.parent.gfile, frame.display.path);
						if (baseInfo)
						{
							if (baseInfo.dType == 1 || baseInfo.dType == 3)
							{
								if (_display)
								{
									if (_display is U2Bitmap == false)
									{
										_display.dispose();
										_display = U2Bitmap.instance(null, "auto", _smoothing, true);
									}
								}
								else
								{
									_display = U2Bitmap.instance(null, "auto", _smoothing, true);
								}
							}
							else
							{
								if (_display)
								{
									if (_display is U2Sprite == false)
									{
										_display.dispose();
										_display = U2Sprite.instance(true);
									}
								}
								else
								{
									_display = U2Sprite.instance(true);
								}
							}
						}
						else if (_display)
						{
							_display.dispose();
							_display = null;
						}
					}
					else if (frame.display.pathType == 2 || frame.display.pathType == 3)
					{
						if (_display)
						{
							if (_display is U2Bitmap == false)
							{
								_display.dispose();
								_display = U2Bitmap.instance(null, "auto", _smoothing, true);
							}
						}
						else
						{
							_display = U2Bitmap.instance(null, "auto", _smoothing, true);
						}
					}
				}
				else if(_display)
				{
					_display.dispose();
					_display = null;
				}
			}
			else if(_display)
			{
				_display.dispose();
				_display = null;
			}
			return _display as DisplayObject;
		}
	}
}