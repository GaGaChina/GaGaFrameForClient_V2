package cn.wjj.display.ui2d
{
	import cn.wjj.display.ui2d.engine.EngineSprite;
	import cn.wjj.display.ui2d.info.U2InfoBase;
	import cn.wjj.display.ui2d.info.U2InfoBaseInfo;
	import cn.wjj.gagaframe.client.speedfact.SpeedLib;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	/**
	 * UI2D的场景
	 * @author GaGa
	 */
	public class U2Sprite extends Sprite implements IU2Base
	{
		/** 对象池 **/
		private static var __f:SpeedLib = new SpeedLib(300);
		/** 对象池强引用的最大数量 **/
		static public function get __m():uint {return __f.length;}
		/** 对象池强引用的最大数量 **/
		static public function set __m(value:uint):void { __f.length = value; }
		
		public function U2Sprite()
		{
			mouseEnabled = false;
			mouseChildren = false;
		}
		/** 初始化 U2Sprite **/
		public static function instance(isFactory:Boolean):U2Sprite
		{
			var o:U2Sprite = __f.instance() as U2Sprite;
			if (o == null) o = new U2Sprite();
			if (o.isFactory != isFactory) o.isFactory = isFactory;
			return o;
		}
		
		/** 移除,清理,并回收 **/
		public function dispose():void
		{
			if (this.parent) this.parent.removeChild(this);
			if (isFactory)
			{
				U2Sprite.clear(this);
				__f.recover(this);
			}
			else
			{
				EngineSprite.handleCloseMouse(this);
				if (_mouseSprite) _mouseSprite = null;
				if (timer)
				{
					var t:U2Timer = this.timer;
					timer = null;
					t.dispose();
					t = null;
				}
				this.graphics.clear();
				if (this._data != null) this._data = null;
				if (this.cacheAsBitmap != false) this.cacheAsBitmap = false;
				if (this.mask != null) this.mask = null;
				//删除全部的图形
				var i:int = this.numChildren;
				if (i)
				{
					var d:Object;
					while (--i > -1)
					{
						d = this.getChildAt(i);
						if ("dispose" in d) d.dispose();
					}
					this.removeChildren();
				}
			}
		}
		
		/** 清理 U2Sprite 对象, 及里面的全部内容 **/
		public static function clear(o:U2Sprite):void
		{
			EngineSprite.handleCloseMouse(o);
			if (o._mouseSprite) o._mouseSprite = null;
			if (o.timer)
			{
				var t:U2Timer = o.timer;
				o.timer = null;
				t.dispose();
				t = null;
			}
			if (o.path != "") o.path = "";
			if (o.isEmpty == false) o.isEmpty = true;
			if (o._data != null) o._data = null;
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
		}
		
		/** 动画控制对象 **/
		public var timer:U2Timer;
		/** 如果这个对象被u2设置,就把设置的u2路径设置上,来防止多次设置u2路径 **/
		public var path:String = "";
		/** [暂留]是否内容为空 **/
		public var isEmpty:Boolean = true;
		/** 这个画布所使用的数据 **/
		public var _data:U2InfoBaseInfo;
		
		/**
		 * 一直向上传递
		 * mouseType : 记录已经添加的鼠标事件
		 * Object[鼠标事件类型] = Object[显示对象:array[事件数据],显示对象:[事件数据]]
		 * 用取走的方式,把内容取走,如果有进行合并
		 * 
		 * 对比本地事件,如果已经有不添加,缺少的添加,多余的移除
		 * 
		 * 如果去移除,每次播放的时候都要进行移除,否则这个完蛋了~~>_<
		 * 会不会很消耗~~>_<
		 */
		/** 数据是否开启鼠标模式 **/
		public var startMouse:Boolean = false;
		/** 鼠标事件的数量 **/
		public var mouseLength:int = 0;
		/** 记录全部鼠标事件的原数据 **/
		public var mouseInfo:Object;
		/** 已经添加的鼠标类型名称 **/
		public var mouseOpenType:Vector.<String>;
		/** 已经添加的鼠标类型数量 **/
		public var mouseOpenLength:int = 0;
		/** 是否启用对象池 **/
		public var isFactory:Boolean = false;
		/** 将U2鼠标监听对象切换(母体),添加代替监听的Sprite **/
		private var _mouseSprite:Sprite;
		
		/** 按钮事件的处理方式 **/
		public function mouseEvent(e:MouseEvent):void
		{
			if (mouseOpenLength)
			{
				EngineSprite.handleMouseEvent(this, e.type, false);
			}
			else
			{
				throw new Error();
			}
		}
		
		/** 按钮事件的Stage的处理方式 **/
		public function stageMouseEvent(e:MouseEvent):void
		{
			if (mouseOpenLength)
			{
				EngineSprite.handleMouseEvent(this, e.type, true);
			}
			else
			{
				throw new Error();
			}
		}
		
		/** 对象里包含的数据 **/
		public function get data():U2InfoBase { return this._data; }
		/** 对象里包含的数据 **/
		public function set data(o:U2InfoBase):void { this._data = o as U2InfoBaseInfo; }
		
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
			if (this.x != x) this.x = x;
			if (this.y != y) this.y = y;
			if (this.alpha != alpha) this.alpha = alpha;
			if (this.rotation != rotation) this.rotation = rotation;
			if (this.scaleX != scaleX) this.scaleX = scaleX;
			if (this.scaleY != scaleY) this.scaleY = scaleY;
		}
		
		public function get smoothing():Boolean { return false; }
		public function set smoothing(value:Boolean):void { if (timer) timer.smoothing = value; }
		
		/** 本对象和子集对象是否播放 **/
		public function setPlay(value:Boolean, core:int = -1):void
		{
			if (timer)
			{
				timer.setPlayThis(value, core);
				timer.setPlayChild(value, core);
			}
		}
		/** 是否正在播放 **/
		public function getPlayThis():Boolean
		{
			if(timer) timer.getPlayThis();
			return false;
		}
		/** 是否正在播放 **/
		public function setPlayThis(value:Boolean, core:int = -1):void
		{
			if (timer) timer.setPlayThis(value, core);
		}
		
		/** 子对象是否正播放 **/
		public function setPlayChild(value:Boolean, core:int = -1):void
		{
			if (timer) timer.setPlayChild(value, core);
		}
		
		/** 速率,加速的时候使用 **/
		public function get speed():Number
		{
			if (timer) return timer._speed;
			return 1;
		}
		/** 速率,加速的时候使用 **/
		public function set speed(value:Number):void { if (timer) timer.speed = value; }
		
		/** 将U2鼠标监听对象切换(母体),添加代替监听的Sprite **/
		public function get mouseSprite():Sprite 
		{
			return _mouseSprite;
		}
		/** 将U2鼠标监听对象切换(母体),添加代替监听的Sprite **/
		public function set mouseSprite(value:Sprite):void 
		{
			if (_mouseSprite != value)
			{
				if (value)
				{
					//添加新事件,然后把老事件里的值,丢过来
					//删除老的全部鼠标事件,然后添加新的鼠标事件
					EngineSprite.handleMouseClear(this);
					_mouseSprite = value;
					EngineSprite.handleMouseInfo(this);
				}
				else
				{
					//清理鼠标事件
					EngineSprite.handleMouseClear(this);
				}
			}
		}
		
		/** 通过层的名称获取层对象 **/
		public function getLayerByName(name:String):U2Layer
		{
			if (timer)
			{
				for each (var item:U2Layer in timer.listLayer) 
				{
					if (item.layer.name == name) return item;
				}
			}
			return null;
		}
		
		/**
		 * 将播放头移到影片剪辑的指定帧并停在那里
		 * @param	scene			层名称或帧ID
		 * @param	playChild		子对象是否播放
		 * @param	core			是否修正下核心时间
		 */
		public function gotoStop(scene:* = null, playChild:Boolean = false, core:int = -1):void
		{
			if (timer) timer.gotoStop(scene, playChild, core);
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
			if (timer) timer.gotoPlay(scene, loop, method, overLabel, stopBegin, playChild, core);
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
			if (timer) timer.playTime(time, loop, method, overLabel, stopBegin, playChild, core);
		}
		/**
		 * 播放那一帧,循环几次,播放完毕后执行函数
		 * @param	time		毫秒
		 * @param	playChild	是否播放子对象
		 * @param	core		内核时间
		 */
		public function stopTime(time:uint, playChild:Boolean = false, core:int = -1):void
		{
			if (timer) timer.stopTime(time, playChild, core);
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
			if (timer) timer.playLabel(label, loop, method, overLabel, stopBegin, playChild, core);
		}
	}
}