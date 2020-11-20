package cn.wjj.display.ui2d 
{
	import cn.wjj.display.ui2d.engine.EngineDisplay;
	import cn.wjj.display.ui2d.engine.EngineEvent;
	import cn.wjj.display.ui2d.engine.EngineInfo;
	import cn.wjj.display.ui2d.engine.EngineMovie;
	import cn.wjj.display.ui2d.engine.EngineSprite;
	import cn.wjj.display.ui2d.info.U2InfoBase;
	import cn.wjj.display.ui2d.info.U2InfoBaseFrame;
	import cn.wjj.display.ui2d.info.U2InfoBaseFrameBitmap;
	import cn.wjj.display.ui2d.info.U2InfoBaseFrameDisplay;
	import cn.wjj.display.ui2d.info.U2InfoBaseInfo;
	import cn.wjj.display.ui2d.info.U2InfoBaseLayer;
	import cn.wjj.display.ui2d.info.U2InfoBaseLayerLib;
	import cn.wjj.display.ui2d.info.U2InfoBitmap;
	import cn.wjj.display.ui2d.info.U2InfoDisplay;
	import cn.wjj.display.ui2d.info.U2InfoEventBridge;
	import cn.wjj.display.ui2d.info.U2InfoPlayEvent;
	import cn.wjj.display.ui2d.info.U2InfoSound;
	import cn.wjj.display.ui2d.info.U2InfoType;
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	import cn.wjj.gagaframe.client.speedfact.SpeedLib;
	import flash.display.DisplayObject;
	import flash.media.SoundChannel;
	import flash.utils.Dictionary;
	
	/**
	 * 设置方法
	 * 
	 * 设置信息		不同类型,设置不同时间
	 * 预设时间		timeCore
	 * 驱动方式		selfEngine
	 * 
	 * 无Sprite驱动Bitmap layer <-> bitmap <-> timer (只有偏移量)
	 * 有Sprite驱动Bitmap sprite <-> timer <-> u2layer <-> timer <-> bitmap <--> timer
	 * 有Sprite驱动Bitmap sprite <-> timer <-> u2layer <-> timer <-> bitmap 如果bitmap不是动画,无需timer
	 * 
	 * 叠加时间的算法
	 * 
	 * 100毫秒  -> 找到U2释放的时间 -> 找到U2时间  -> 找到U2    -> 找到path(传递形)
	 * 累加时间 -> (是否累加)累加到这个U2中 -> (是否累加)
	 *             FPS 12           FPS 2             静态
	 * 
	 * U2BitmapMovie -> U2Bitmap
	 * 
	 * 多层结构的解析方法
	 * 
	 * 
	 * 对象是否要有,那些对象可以控制,需要封闭空间控制么?
	 * 主对象不进行回收,封闭内容进行回收控制(参数控制回收情况)
	 * 
	 * U2Bitmap -> 类型(只可以添加图片,添加相对坐标)
	 * U2BitmapMovie -> 动画,可以添加图片,可以添加U2Bitmap对象,可以添加U2BitmapMovie
	 * 
	 * 
	 * U2Shape 取消 U2Shape 层,这个很难叠加,因为要画矢量图
	 * 
	 * 双层结构
	 * 
	 * U2Bitmap -> 一层走到黑   -> 需要有对应的数据列表来操作这个对象,并且每套数据都需要有坐标数据记录
	 * U2Sprite -> 多层存在嵌套
	 * 
	 * 传递时间是为了播放音乐(只有需要播放音乐才会叠加enter叠加时间)
	 * 
	 * @author GaGa
	 */
	public class U2Timer 
	{
		/** 对象池 **/
		private static var __f:SpeedLib = new SpeedLib(500);
		/** 对象池强引用的最大数量 **/
		static public function get __m():uint {return __f.length;}
		/** 对象池强引用的最大数量 **/
		static public function set __m(value:uint):void { __f.length = value; }
		/** 初始化 **/
		public function U2Timer() { }
		public static function instance():U2Timer
		{
			var o:U2Timer = __f.instance() as U2Timer;
			if (o)
			{
				o.isLive = true;
				return o;
			}
			return new U2Timer();
		}
		/** 移除,清理,并回收 **/
		public function dispose():void
		{
			if (isLive)
			{
				isLive = false;
				g.event.removeEnterFrame(enterFrame, this);
				if (u2Layer)
				{
					u2Layer.dispose();
					u2Layer = null;
				}
				if (display)
				{
					var d:* = display;
					display = null;
					if ("dispose" in d) d.dispose();
					d = null;
				}
				if (layer != null) layer = null;
				if (frame != null) frame = null;
				if (eventBase != null) eventBase = null;
				if (listLib != null) listLib = null;
				if (listLength != 0)
				{
					listLength = 0;
					for each (var item:U2Layer in listLayer) 
					{
						item.dispose();
					}
					listLayer.length = 0;
				}
				if (_speed != 1) _speed = 1;
				if (_playThis) _playThis = false;
				if (_playChild) _playChild = false;
				if (_currentFrame != -1) _currentFrame = -1;
				if (_playLabel != "") _playLabel = "";
				if (_playLabelFrame != null)
				{
					_playLabelFrame.length = 0;
					_playLabelFrame = null;
				}
				if (_playLabelFrameStart != 0) _playLabelFrameStart = 0;
				if (_playLabelTimeStart != 0) _playLabelTimeStart = 0;
				if (_playLabelTimeEnd != 0) _playLabelTimeEnd = 0;
				if (_loop != 0) _loop = 0;
				if (_complete != null) _complete = null;
				if (_overLabel != "") _overLabel = "";
				if (_stopBegin == false) _stopBegin = true;
				if (_round != 0) _round = 0;
				if (_selfEngine) _selfEngine = false;
				if (time != -1) time = -1;
				if (_timeLoop != 0) _timeLoop = 0;
				if (timeStart != -1) timeStart = -1;
				if (_timeCore != -1) _timeCore = -1;
				if (_timeEvent != -1) _timeEvent = -1;
				if (_timeEventLoop != -1) _timeEventLoop = -1;
				if (soundLib)
				{
					var channel:SoundChannel;
					for (var c:* in soundLib) 
					{
						channel = c;
						channel.stop();
					}
					soundLib = null;
				}
				if (__o) __o = null;
				if (cache) cache = null;
				U2Timer.__f.recover(this);
			}
			else if (cache)
			{
				g.log.pushLog(this, LogType._ErrorLog, "严重BUG");
				//throw new Error();
			}
		}
		
		/** 是否存在 **/
		public var isLive:Boolean = true;
		/** [控制类型]容器子对象 **/
		public var u2Layer:U2Layer;
		/** layer 对应的显示对象 **/
		public var display:DisplayObject;
		/** [控制类型]动画画布使用的数据 **/
		public var layer:U2InfoBaseLayer;
		/** 这个画布所使用的帧数据 **/
		public var frame:U2InfoBaseFrame;
		/** 有声音的时候,对主对象进行应用 **/
		public var eventBase:U2InfoBaseInfo;
		
		/** [控制类型]对应的ListLib信息 **/
		public var listLib:U2InfoBaseLayerLib;
		/** List的数量 **/
		public var listLength:int = 0;
		/** U2Sprite使用的数据 **/
		public var listLayer:Vector.<U2Layer> = new Vector.<U2Layer>();
		
		/** 播放的速度 **/
		public var _speed:Number = 1;
		/** 本元件是否播放 **/
		public var _playThis:Boolean = false;
		/** 本原件的子元件是否播放 **/
		public var _playChild:Boolean = false;
		/** 现在播放那一幀,从0开始,-1标识没有任何数据 **/
		public var _currentFrame:int = -1;
		/** 现在要播放那个Label区间 **/
		private var _playLabel:String = "";
		/** 播放区域起始的ID **/
		private var _playLabelFrameStart:int;
		/** 现在要播放那个Label区间 **/
		private var _playLabelFrame:Vector.<U2InfoBaseFrame>;
		/** 现在要播放那个Label区间(开始毫秒数) **/
		internal var _playLabelTimeStart:Number = 0;
		/** 现在要播放那个Label区间(结束毫秒数) **/
		internal var _playLabelTimeEnd:Number = 0;
		/** 播放的时候循环几次 **/
		private var _loop:int = 0;
		/** 播放完毕后执行某特定函数 **/
		private var _complete:Function;
		/** 播放完毕后播放那个区间 **/
		private var _overLabel:String = "";
		/** 播放完毕后停留在开始还是结束位置 **/
		private var _stopBegin:Boolean = true;
		/** 本轮执行了几次循环 **/
		private var _round:uint = 0;
		
		/** 是否自己驱动时间 **/
		private var _selfEngine:Boolean = false;
		/** 内部的时间,根据这个时间来算出运行到那帧 **/
		public var time:Number = -1;
		/** 核心运行第几个循环,这个只影响内部的动画,内部是U2动画的时候,重新计算播放时间 **/
		private var _timeLoop:int = 0;
		/** 动画开始的时间 **/
		public var timeStart:Number = -1;
		/** 内核时间,每次外部出入新时间,就会叠加进内核, (-1是未初始化) **/
		private var _timeCore:Number = -1;
		/** 本循环中,从0开始算起的声音播放到什么位置的记录 **/
		private var _timeEvent:Number = -1;
		/** 现在声音在第几个循环上 **/
		private var _timeEventLoop:int = -1;
		/** 启动删除消除的时候,保存处于播放的声音 **/
		public var soundLib:Dictionary;
		/** 是否启用播放缓存控制 **/
		public var cache:Dictionary;
		
		/** 临时int变量 **/
		private var __i:int;
		/** 临时int变量 **/
		private var __i2:int;
		/** 临时Number **/
		private var __n:Number;
		/** 临时Number **/
		private var __n2:Number;
		/** 临时Boolean变量 **/
		private var __b:Boolean;
		/** 临时Boolean变量 **/
		private var __b2:Boolean;
		/** 缓存临时文件 **/
		private var __o:*;
		
		/** 设置元件平滑 **/
		public function set smoothing(value:Boolean):void
		{
			if (listLength)
			{
				for each (var item:U2Layer in listLayer) 
				{
					item.smoothing = value;
				}
			}
			else if (u2Layer && u2Layer.timer && u2Layer.timer != this)
			{
				u2Layer.smoothing = value;
			}
		}
		
		public function get speed():Number { return this._speed; }
		public function set speed(value:Number):void
		{
			if (this._speed != value)
			{
				this._speed = value;
			}
			if (listLength)
			{
				for each (var item:U2Layer in listLayer) 
				{
					item.speed = value;
				}
			}
			else if (u2Layer && u2Layer.timer && u2Layer.timer != this)
			{
				u2Layer.speed = value;
			}
		}
		
		/** 本对象和子集对象是否播放 **/
		public function setPlay(value:Boolean, core:int = -1):void
		{
			setPlayThis(value, core);
			setPlayChild(value, core);
		}
		
		/** 是否正在播放 **/
		public function getPlayThis():Boolean { return this._playThis; }
		/** 是否正在播放 **/
		public function setPlayThis(value:Boolean, core:int = -1):void
		{
			if(_playThis != value)
			{
				_playThis = value;
				if (_playThis)
				{
					if (eventBase && eventBase.eventLib.eventLength && time)
					{
						if (time == 0)
						{
							_timeEvent = -1;
						}
						else
						{
							if (_playLabel)
							{
								_timeEventLoop = Math.floor(time / (_playLabelTimeEnd - _playLabelTimeStart));
								_timeEvent = time - ((_playLabelTimeEnd - _playLabelTimeStart) * _timeEventLoop);
							}
							else
							{
								_timeEventLoop = Math.floor(time / eventBase.layer.timeLength);
								_timeEvent = time - (eventBase.layer.timeLength * _timeEventLoop);
							}
						}
					}
					timeCore(core, timeStart, true, true);
				}
				else
				{
					timeCore(core, timeStart, false, true);
				}
				if (listLib && listLib.isPlay)
				{
					for each (var item:U2Layer in listLayer)
					{
						if (item.timer)
						{
							item.timer.setPlayThis(value, _timeCore);
							if (_playThis)
							{
								item.timer.timeCore(core, timeStart, true, true);
							}
							else
							{
								item.timer.timeCore(core, timeStart, false, true);
							}
						}
					}
				}
			}
			else
			{
				timeCore(core, timeStart, false, true);
			}
		}
		
		/** 子对象是否正播放 **/
		public function setPlayChild(value:Boolean, core:int = -1):void
		{
			_playChild = value;
			if (listLib)
			{
				if (listLib.isPlay)
				{
					for each (var item:U2Layer in listLayer) 
					{
						if (item.timer && item.layer && item.layer.isPlayChild)
						{
							item.timer.setPlayChild(value, _timeCore);
						}
					}
				}
			}
			else if (u2Layer && u2Layer.layer && u2Layer.layer.isPlay && u2Layer.display)
			{
				var t:U2Timer = (u2Layer._display as Object).timer;
				if (t)
				{
					t.setPlayThis(value, _timeCore);
					t.setPlayChild(value, _timeCore);
				}
			}
			//layer 只可能是Bitmap , 所以肯定不能播放
		}
		
		public function get selfEngine():Boolean { return _selfEngine; }
		public function set selfEngine(value:Boolean):void 
		{
			if (_selfEngine != value)
			{
				_selfEngine = value
				if (_selfEngine)
				{
					g.event.addEnterFrame(enterFrame, this);
				}
				else
				{
					g.event.removeEnterFrame(enterFrame, this);
				}
			}
		}
		
		/** 对display和u2Layer操作 查找并运行到某一帧,没有跳转和切帧的时候继续运行,否则返回false **/
		private function playFrame(isChange:Boolean):void
		{
			//图层长度
			__i = 0;
			//层循环一次总时间
			__n = 0;
			//每一帧时间
			__n2 = 0;
			var id:int;
			if (u2Layer)
			{
				if (_playLabel)
				{
					__n = _playLabelTimeEnd - _playLabelTimeStart;
					__i = _playLabelFrame.length - 1;
				}
				else
				{
					__n = u2Layer.layer.timeLength;
					__i = u2Layer.layer.length - 1;
				}
				__n2 = u2Layer.layer.frequency;
			}
			else if (layer)
			{
				if (_playLabel)
				{
					__n = _playLabelTimeEnd - _playLabelTimeStart;
					__i = _playLabelFrame.length - 1;
				}
				else
				{
					__n = layer.timeLength;
					__i = layer.length - 1;
				}
				__n2 = layer.frequency;
			}
			else if (listLib)
			{
				__n = listLib.timeLength;
			}
			//查看是否有跳转产生, false 已经跳转循环了
			var line:Boolean = true;
			//计算钱的循环次数
			var startLoop:int = _timeLoop;
			_timeLoop = Math.floor(time / __n);
			var layerLoopTime:Number = _timeLoop * __n;
			if(listLib)
			{
				//要对u2Sprite
				if (listLib && _loop && startLoop != _timeLoop)
				{
					_loop--;
					if (_loop == 0)
					{
						if (_stopBegin)
						{
							time = Math.ceil(layerLoopTime);
							timeStart = _timeCore - time;
						}
						else
						{
							time = Math.floor(layerLoopTime) - 1;
							timeStart = _timeCore - time;
						}
						enterFrameOver();
						line = false;
					}
				}
			}
			else if(layer || u2Layer)
			{
				if (isChange == false)
				{
					if (_playLabel)
					{
						if (_loop && startLoop != _timeLoop)
						{
							_loop--;
							if (_loop == 0)
							{
								if (_stopBegin)
								{
									time = Math.ceil(layerLoopTime);
									timeStart = _timeCore - time;
									gotoFrameId(0, isChange);
								}
								else
								{
									time = Math.floor(layerLoopTime) - 1;
									timeStart = _timeCore - time;
									gotoFrameId(__i, isChange);
								}
								enterFrameOver();
								line = false;
							}
						}
					}
					else
					{
						if (_loop && startLoop != _timeLoop)
						{
							_loop--;
							if (_loop == 0)
							{
								if (_stopBegin)
								{
									time = Math.ceil(layerLoopTime);
									timeStart = _timeCore - time;
									gotoFrameId(0, isChange);
								}
								else
								{
									time = Math.floor(layerLoopTime) - 1;
									timeStart = _timeCore - time;
									id = layer.length;
									gotoFrameId(__i, isChange);
								}
								enterFrameOver();
								line = false;
							}
						}
					}
				}
				if (line)
				{
					id = Math.floor((time - layerLoopTime) / __n2);
					gotoFrameId(id, isChange);
				}
			}
			if(line)
			{
				sendCoreTime(isChange);
			}
			else
			{
				sendCoreTime(true);
			}
		}
		
		/**
		 * 通过修正时间运行动画,每个动画还是单独控制~~~
		 * 播放速度自己运算.
		 * 
		 * core		使用 getTimer() 或 使用其他内核时间
		 * start	可以使用开始时间来空控制动画播放
		 * useSpeed	当使用速度的时候,时间最后的叠加值就是新的值
		 * isChange	如果是修正,直接就是把开始时间和核心时间赋值进去,
		 * 			如果不是修正,就会使用核心时间,然后和内部核心时间进行运算,然后播放动画,这种是最常见的
		 * 
		 * 传递到子对象也使用 timeCore 来控制
		 * 
		 * @param	t			使用的核心时间
		 * @param	start		使用的开始核心时间,-1就是不改变开始时间, 当使用叠加时间的时候,一并使用本参数,将会?????,应该需要反向修正start
		 * @param	isChange	(只要goto全为change时间,内部的全需要修正)是直接修正开始和核心时间,还是通过本地开始时间和核心时间进行叠加
		 * @param	useSpeed	是否启用速度控制
		 * @param	runFrame	强制运行Frame
		 * @param	eventStart	事件是否从头开始(isChange为true才生效)
		 */
		public function timeCore(core:int = -1, start:int = -1, isChange:Boolean = true, useSpeed:Boolean = true, eventStart:Boolean = false):void
		{
			if (isLive)
			{
				//U2格式都必须要传递值
				if (core == -1)
				{
					if (_selfEngine)
					{
						
						core = g.time.frameTime.time;
					}
					else if(_timeCore != -1)
					{
						core = _timeCore;
					}
					else
					{
						throw new Error("被驱动对象,初始化需要核心时间");
					}
				}
				if (isChange)
				{
					//切换不会考虑_timePause 的情况
					if (_timeCore != core) _timeCore = core;
					if (start != -1) timeStart = start;
					if (timeStart == -1) timeStart = core;
					if (timeStart > core)
					{
						if (time == -1)
						{
							timeStart = core;
						}
						else
						{
							timeStart = core - time;
						}
					}
					if (_speed == 1 || useSpeed == false)
					{					
						__n = core - timeStart;
					}
					else
					{
						__n = (core - timeStart) * _speed;
						timeStart = core - time;
					}
					if (__n != time)
					{
						time = __n;
						playFrame(true);
						if (_playThis && eventBase && eventBase.eventLib.eventLength)
						{
							//控制声音 这里只播放等于区间的
							if (time == 0 || eventStart)
							{
								if (_timeEventLoop != 0)_timeEventLoop = 0;
								if (_timeEvent != -1)_timeEvent = -1;
							}
							else
							{
								if (_playLabel)
								{
									_timeEventLoop = Math.floor(time / (_playLabelTimeEnd - _playLabelTimeStart));
									_timeEvent = time - ((_playLabelTimeEnd - _playLabelTimeStart) * _timeEventLoop);
								}
								else
								{
									_timeEventLoop = Math.floor(time / eventBase.layer.timeLength);
									_timeEvent = time - (eventBase.layer.timeLength * _timeEventLoop);
								}
								_timeEvent--;
							}
							playEvent();
						}
					}
				}
				else
				{
					//未初始化先初始化
					if (_timeCore == -1 || core < _timeCore)
					{
						_timeCore = core;
					}
					else if (core != _timeCore)
					{
						if (timeStart > core)
						{
							timeStart = core - time;
						}
						__n = core - _timeCore;
						if (_speed == 1 || useSpeed == false)
						{
							if (_playThis)
							{
								time = time + __n;
							}
							else
							{
								timeStart = timeStart + __n;
							}
						}
						else
						{
							if (_playThis)
							{
								__n = __n * _speed;
								time = time + __n;
								timeStart = core - time;
							}
							else
							{
								timeStart = timeStart + __n;
							}
						}
						_timeCore = core;
					}
					if (_playThis)
					{
						playFrame(false);
						if (eventBase && eventBase.eventLib.eventLength)
						{
							playEvent();
						}
					}
					else
					{
						//传递时间到子对象和其他层
						sendCoreTime(false);
					}
				}
			}
		}
		
		/**
		 * 传递时间
		 * @param	isChange	(只要goto全为change时间,内部的全需要修正)是直接修正开始和核心时间,还是通过本地开始时间和核心时间进行叠加
		 */
		private function sendCoreTime(isChange:Boolean):void
		{
			if (listLength)
			{
				var u2Sprite:U2Sprite;
				__i = -1;
				//是否有鼠标事件
				__b = false;
				//是否已经添加
				__b2 = false;
				for each (var item:U2Layer in listLayer) 
				{
					if (item.timer && item.layer.isPlay)
					{
						//这里可能是图片,但是至少要设置一次, 在初始化的时候处理
						//if (item.layer.isPlay) { } else { }
						if (isChange)
						{
							item.timer.timeCore(_timeCore, timeStart, true, true);
						}
						else
						{
							item.timer.timeCore(_timeCore, -1, false, true);
						}
					}
					//设置层级
					if(item.display)
					{
						if((item._display as Object).isEmpty)
						{
							__b2 = false;
							item._display.dispose();
							item._display = null;
						}
						else
						{
							__b2 = true;
							if (u2Sprite == null)
							{
								u2Sprite = item.parent;
								if (u2Sprite.startMouse)
								{
									EngineSprite.handleMouseClear(u2Sprite);
								}
							}
							__i++;
							if((item._display as DisplayObject).parent != u2Sprite || item.parent.getChildIndex(item._display as DisplayObject) != __i)
							{
								if(u2Sprite.numChildren < __i)
								{
									u2Sprite.addChild(item._display as DisplayObject);
								}
								else
								{
									u2Sprite.addChildAt(item._display as DisplayObject, __i);
									if (listLib.autoRemove && EngineDisplay.displayInStage(item._display as DisplayObject) == false)
									{
										if (listLib.autoDispose)
										{
											__i--;
											item._display.dispose();
											item._display = null;
										}
										else if ((item._display as DisplayObject).parent)
										{
											__i--;
											(item._display as DisplayObject).parent.removeChild(item._display as DisplayObject);
										}
										__b2 = false;
									}
								}
							}
						}
						//添加鼠标事件内容
						if (item._display is U2Sprite)
						{
							if (__b2)
							{
								if ((item._display as U2Sprite).mouseLength)
								{
									__b = true;
									if (u2Sprite.startMouse == false) EngineSprite.handleOpenMouse(u2Sprite);
									EngineSprite.mergeMouseInfo(u2Sprite, item._display as U2Sprite);
								}
							}
							else if ((item._display as U2Sprite).mouseLength)
							{
								EngineSprite.handleMouseClear(item._display as U2Sprite);
							}
						}
						if (__b2 && item.layer.mouseLength)
						{
							__b = true;
							if (u2Sprite.startMouse == false)
							{
								EngineSprite.handleOpenMouse(u2Sprite);
							}
							EngineSprite.handleMousePush(u2Sprite, item._display as DisplayObject, item);
						}
					}
				}
				//开始添加鼠标事件
				if (u2Sprite)
				{
					if (__b)
					{
						EngineSprite.handleMouseInfo(u2Sprite);
					}
					else if(u2Sprite.startMouse && u2Sprite.mouseLength)
					{
						EngineSprite.handleMouseClear(u2Sprite);
					}
				}
			}
			else if (u2Layer && u2Layer.display)
			{
				var t:U2Timer = (u2Layer._display as Object).timer;
				if (t)
				{
					if (isChange)
					{
						t.timeCore(_timeCore, timeStart, true, true);
					}
					else
					{
						t.timeCore(_timeCore, -1, false, true);
					}
				}
			}
			//layer 只有本地的Bitmap使用,layer的U2Bitmap肯定和本地的Timer相符
			/*
			else if (layer)
			{
				if (display && (display as Object)._timer)
				{
					if ((display as Object)._timer != this)
					{
						trace("不同-----------------------------");
					}
				}
				if (display && (display as Object)._timer && (display as Object)._timer != this)
				{
					(display as Object)._timer.timeCore(_timeCore, timeStart, isChange, true);
				}
			}
			*/
		}
		
		/**
		 * (已经对跳转处理)控制声音的播放
		 * 
		 * 在Play状态下播放声音, 对比第几Loop,然后对比本Loop下经历了多少时间,然后修正这个最低值
		 * 标识已经播放了这个声音
		 * 在小于等于的时候,播放声音,播放前Loop和timeSound必须和前一个不同
		 * 在播放的时候对比,旧的Loop和timeSound,和现在的Loop和timeSound,计算出要播放的声音
		 */
		private function playEvent():void
		{
			if (eventBase)
			{
				//__i : loop 上一次是第几次循环
				__i = _timeEventLoop;
				var _stPrev:Number = _timeEvent;
				if (_playLabel)
				{
					_timeEventLoop = Math.floor(time / (_playLabelTimeEnd - _playLabelTimeStart));
					_timeEvent = time - ((_playLabelTimeEnd - _playLabelTimeStart) * _timeEventLoop);
				}
				else
				{
					_timeEventLoop = Math.floor(time / eventBase.layer.timeLength);
					_timeEvent = time - (eventBase.layer.timeLength * _timeEventLoop);
				}
				if (__i != _timeEventLoop || _stPrev != _timeEvent)
				{
					//__b : 是否可以播放
					//__i2 : timeLine 激活的时间点
					for each (var item:U2InfoBase in eventBase.eventLib.eventList) 
					{
						__i2 = (item as Object).timeLine;
						if (_playLabel)
						{
							__i2 = __i2 - _playLabelFrameStart;
						}
						if (__i2 > -1)
						{
							__b = false;
							if (__i != _timeEventLoop)
							{
								//从头开始播放
								if (__i2 <= _timeEvent)
								{
									__b = true;
								}
							}
							else
							{
								if (__i2 > _stPrev && __i2 <= _timeEvent)
								{
									__b = true;
								}
							}
							if (__b)
							{
								switch (item.type) 
								{
									case U2InfoType.sound:
										EngineEvent.playSound(eventBase.gfile, item as U2InfoSound, eventBase.disposeSound, this, cache);
										break;
									case U2InfoType.playEvent:
										EngineEvent.playPlayEvent(item as U2InfoPlayEvent, this);
										break;
									case U2InfoType.eventBridge:
										EngineEvent.playBridge(item as U2InfoEventBridge);
										break;
								}
							}
						}
					}
				}
			}
		}
		
		/** 如果有Label就在这个Label中播放 **/
		private function enterFrame():void
		{
			//救急算法
			if (display)
			{
				if (display.stage == null)
				{
					//if(time > 0) U2Timer.clear(this);
					return;
				}
			}
			else if (listLength)
			{
				var u2Sprite:U2Sprite = listLayer[0].parent;
				if (u2Sprite == null || u2Sprite.stage == null)
				{
					//if(time > 0) U2Timer.clear(this);
					return;
				}
			}
			else if (u2Layer)
			{
				if (u2Layer.display == null || u2Layer.display.stage == null)
				{
					//if(time > 0) U2Timer.clear(this);
					return;
				}
			}
			else
			{
				//if(time > 0) U2Timer.clear(this);
				return;
			}
			//autonomy 自律,保持每帧不能超越自己过多
			timeCore( -1, -1, false, true);
		}
		
		/** 运行里面的完成函数 **/
		private function enterFrameOver():void
		{
			if (_playLabel != "") _playLabel = "";
			if (_playLabelFrame != null)
			{
				_playLabelFrame.length = 0;
				_playLabelFrame = null;
			}
			if (_playLabelFrameStart != 0) _playLabelFrameStart = 0;
			if (_playLabelTimeStart != 0) _playLabelTimeStart = 0;
			if (_playLabelTimeEnd != 0) _playLabelTimeEnd = 0;
			setPlayThis(false, -1);
			setPlayChild(false, -1);
			if (_complete != null)
			{
				var f:Function = _complete;
				_complete = null;
				f();
			}
			if (_overLabel != "")
			{
				playLabel(_overLabel);
			}
		}
		
		/** [帧第一帧为0]跳转到特定幀 **/
		private function gotoFrameId(id:int, isChange:Boolean):void
		{
			if (_currentFrame != id)
			{
				if (_playLabel)
				{
					if (_playLabelFrame.length)
					{
						if (id > -1 && id < _playLabelFrame.length)
						{
							_currentFrame = id + _playLabelFrameStart;
							if (u2Layer)
							{
								u2Layer.frame = _playLabelFrame[id] as U2InfoBaseFrameDisplay;
								handleFrameU2Layer(isChange);
							}
							else if(layer)
							{
								frame = _playLabelFrame[id];
								handleFrameLayer(isChange);
							}
						}
						else
						{
							gotoFrameId(_playLabelFrameStart, isChange);
						}
					}
					else if (_currentFrame != -1)
					{
						_currentFrame = -1;
						sendCoreTime(isChange);
					}
				}
				else
				{
					if (u2Layer)
					{
						if(u2Layer.layer.length)
						{
							if (id > -1 && id < u2Layer.layer.length)
							{
								_currentFrame = id;
								u2Layer.frame = u2Layer.layer.lib[id] as U2InfoBaseFrameDisplay;
								handleFrameU2Layer(isChange);
							}
							else
							{
								gotoFrameId(0, isChange);
							}
						}
					}
					else if(layer)
					{
						if (layer.length > 0)
						{
							if (id > -1 && id < layer.length)
							{
								_currentFrame = id;
								frame = layer.lib[id];
								handleFrameLayer(isChange);
							}
							else
							{
								gotoFrameId(0, isChange);
							}
						}
					}
					else if (_currentFrame != -1)
					{
						_currentFrame = -1;
						sendCoreTime(isChange);
					}
				}
			}
			else
			{
				sendCoreTime(isChange);
			}
		}
		
		/** 切换帧的时候,具体的执行内容,针对Layer的内容 **/
		private function handleFrameLayer(isChange:Boolean):void
		{
			if (display && frame && frame.type == U2InfoType.baseFrameBitmap)
			{
				var d:U2Bitmap = display as U2Bitmap;
				//子内容因为切换帧,需要反推到正常过来的时间点
				var o:U2InfoBitmap = (frame as U2InfoBaseFrameBitmap).display;
				if (o.pathType != 0)
				{
					if (o.pathType == 1)
					{
						//播放的时候不会切换图片类型
						if (layer.pathLine)
						{
							//如果已经设置,直接走移动到位置操作
							if (d.path != o.path)
							{
								if (g.u2.u2UseDefGFile)
								{
									g.dfile.bitmapX(o.path, true, d, cache);
								}
								else
								{
									g.gfile.bitmapX(o.parent.gfile, o.path, true, d, cache);
								}
							}
						}
						else
						{
							//如果已经设置,直接走移动到位置操作
							if (d.path != o.path)
							{
								if (g.u2.u2UseDefGFile)
								{
									g.dfile.bitmapX(o.path, true, d, cache);
								}
								else
								{
									g.gfile.bitmapX(o.parent.gfile, o.path, true, d, cache);
								}
							}
						}
					}
					else if(d.path != o.path)
					{
						if (g.u2.u2UseDefGFile)
						{
							g.dfile.bitmapX(o.path, true, d, cache);
						}
						else
						{
							g.gfile.bitmapX(layer.parent.gfile, o.path, true, d, cache);
						}
					}
					d.setOffsetInfo(o.offsetX, o.offsetY, o.offsetAlpha, o.offsetRotation, o.offsetScaleX, o.offsetScaleY);
				}
				else
				{
					U2Bitmap.clear(d);
				}
			}
		}
		
		/** 执行选中的帧内容,只有layer与u2Layer可以执行 **/
		private function handleFrameU2Layer(isChange:Boolean):void
		{
			if (u2Layer.display && u2Layer.frame)
			{
				var d:* = u2Layer.display;
				//子内容因为切换帧,需要反推到正常过来的时间点
				var childUseTime:int;
				if (u2Layer.frame.type == U2InfoType.baseFrameBitmap)
				{
					var ob:U2InfoBitmap = (u2Layer.frame as U2InfoBaseFrameBitmap).display;
					if (ob.pathType != 0)
					{
						if (ob.pathType == 1)
						{
							//播放的时候不会切换图片类型
							if (u2Layer.layer.pathLine)
							{
								//如果已经设置,直接走移动到位置操作
								if (d.path != ob.path)
								{
									if (g.u2.u2UseDefGFile)
									{
										g.dfile.bitmapX(ob.path, true, d, cache);
									}
									else
									{
										g.gfile.bitmapX(ob.parent.gfile, ob.path, true, d, cache);
									}
									/*
									if (d._timer)
									{
										d._timer.setPlayThis(_playChild, _timeCore);
									}
									*/
								}
							}
							else
							{
								if (d.path != ob.path)
								{
									if (g.u2.u2UseDefGFile)
									{
										g.dfile.bitmapX(ob.path, true, d, cache);
									}
									else
									{
										g.gfile.bitmapX(ob.parent.gfile, ob.path, true, d, cache);
									}
									/*
									if (isChange)
									{
										//计算出上一次的时间
										childUseTime = EngineMovie.getFrameUseTime(u2Layer.layer, u2Layer.frame, time);
										d._timer.timeCore(_timeCore, (_timeCore - childUseTime), true, true);
									}
									else
									{
										//要到前面切帧的时间点
										d._timer.timeCore(_timeCore, -1, false, true);
									}
									*/
								}
							}
						}
						else if(d.path != ob.path)
						{
							if (g.u2.u2UseDefGFile)
							{
								g.dfile.bitmapX(ob.path, true, d, cache);
							}
							else
							{
								g.gfile.bitmapX(ob.parent.gfile, ob.path, true, d, cache);
							}
						}
						d.setOffsetInfo(ob.offsetX, ob.offsetY, ob.offsetAlpha, ob.offsetRotation, ob.offsetScaleX, ob.offsetScaleY);
					}
					else
					{
						U2Bitmap.clear(d);
					}
				}
				else if(u2Layer.frame.type == U2InfoType.baseFrameDisplay)
				{
					var od:U2InfoDisplay = (u2Layer.frame as U2InfoBaseFrameDisplay).display;
					if (d is U2Bitmap)
					{
						if (od.pathType != 0 && u2Layer.frame.parent.gfile)
						{
							if (od.pathType == 1)
							{
								if (u2Layer.layer.pathLine)
								{
									//如果已经设置,直接走移动到位置操作
									if (d.path != od.path)
									{
										EngineInfo.openForDisplay(d, u2Layer.frame.parent.gfile, od.path, false, _timeCore, timeStart, cache);
										if (d._timer)
										{
											d._timer.setPlayThis(_playChild, _timeCore);
										}
									}
									else if(d._timer)
									{
										d._timer.timeCore(_timeCore, timeStart, isChange, true);
									}
								}
								else
								{
									if (d.path != od.path)
									{
										//计算出上一次的时间
										childUseTime = EngineMovie.getFrameUseTime(u2Layer.layer, u2Layer.frame, time);
										EngineInfo.openForDisplay(d, u2Layer.frame.parent.gfile, od.path, false, _timeCore, (_timeCore - childUseTime), cache);
										if (d._timer)
										{
											d._timer.setPlayThis(_playChild, _timeCore);
										}
									}
									else if(d._timer)
									{
										if (isChange)
										{
											childUseTime = EngineMovie.getFrameUseTime(u2Layer.layer, u2Layer.frame, time);
											d._timer.timeCore(_timeCore, (_timeCore - childUseTime), true, true);
										}
										else
										{
											d._timer.timeCore(_timeCore, -1, false, true);
										}
									}
								}
							}
							else if(d.path != od.path)
							{
								if (g.u2.u2UseDefGFile)
								{
									g.dfile.bitmapX(od.path, true, d, cache);
								}
								else
								{
									g.gfile.bitmapX(u2Layer.frame.parent.gfile, od.path, true, d, cache);
								}
							}
							d.setSizeInfo(od.x, od.y, od.alpha, od.rotation, od.scaleX, od.scaleY);
						}
						else
						{
							U2Bitmap.clear(d);
						}
					}
					else if (d is U2Sprite)
					{
						if (od.pathType == 1 && u2Layer.frame.parent.gfile)
						{
							if (u2Layer.layer.pathLine)
							{
								if (d.path != od.path)
								{
									//od.path开始的时间
									EngineInfo.openForDisplay(d, u2Layer.frame.parent.gfile, od.path, false, _timeCore, timeStart, cache);
									if(d.timer)
									{
										d.timer.setPlayThis(_playChild, _timeCore);
										d.timer.setPlayChild(_playChild, _timeCore);
									}
								}
								else if(d.timer)
								{
									d.timer.timeCore(_timeCore, timeStart, isChange, true);
								}
							}
							else
							{
								if (d.path != od.path)
								{
									childUseTime = EngineMovie.getFrameUseTime(u2Layer.layer, u2Layer.frame, time);
									EngineInfo.openForDisplay(d, u2Layer.frame.parent.gfile, od.path, false, _timeCore, (_timeCore - childUseTime), cache);
									if(d.timer)
									{
										d.timer.setPlayThis(_playChild, _timeCore);
										d.timer.setPlayChild(_playChild, _timeCore);
									}
								}
								else if(d.timer)
								{
									if (isChange)
									{
										childUseTime = EngineMovie.getFrameUseTime(u2Layer.layer, u2Layer.frame, time);
										d.timer.timeCore(_timeCore, (_timeCore - childUseTime), true, true);
									}
									else
									{
										d.timer.timeCore(_timeCore, -1, false, true);
									}
								}
							}
							d.setSizeInfo(od.x, od.y, od.alpha, od.rotation, od.scaleX, od.scaleY);
							EngineSprite.autoEmpty(d);
						}
						else
						{
							U2Sprite.clear(d);
						}
					}
				}
			}
			else
			{
				sendCoreTime(isChange);
			}
		}
		
		/**
		 * 将播放头移到影片剪辑的指定帧并停在那里
		 * @param	scene			层名称或帧ID
		 * @param	playChild		子对象是否播放
		 * @param	core			是否修正下核心时间
		 */
		public function gotoStop(scene:* = null, playChild:Boolean = false, core:int = -1):void
		{
			var t:uint = 0;
			if(layer)
			{
				t = Math.ceil((EngineMovie.getFrameId(scene, _currentFrame + 1, layer) - 1) * layer.frequency);
			}
			else if(u2Layer)
			{
				t = Math.ceil((EngineMovie.getFrameId(scene, _currentFrame + 1, u2Layer.layer) - 1) * u2Layer.layer.frequency);
			}
			else if(listLib && listLib.isPlayThis)
			{
				var lt:uint;
				for each (var l:U2InfoBaseLayer in listLib.lib) 
				{
					if (l.isPlayThis)
					{
						lt = Math.ceil((EngineMovie.getFrameId(scene, _currentFrame + 1, l) - 1) * l.frequency);
						if (lt != 0 && (t == 0 || lt < t))
						{
							t = lt;
						}
					}
				}
			}
			if (core == -1) core = g.time.frameTime.time;
			if (_selfEngine && _timeCore != core)
			{
				_timeCore = core;
			}
			stopTime(t, playChild, core);
		}
		
		/**
		 * 播放那一帧,循环几次,播放完毕后执行函数
		 * @param scene			播放的标签或第几帧
		 * @param loop			循环的次数.
		 * @param method		播完触发函数
		 * @param overLabel		播完播放区间
		 * @param stopBegin		播完是停留在开始,还是停留在最后幀,如果设置overLabel就忽略这个参数
		 */
		public function gotoPlay(scene:*, loop:int = 0, method:Function = null, overLabel:String = "", stopBegin:Boolean = true, playChild:Boolean = true, core:int = -1):void
		{
			var t:uint = 0;
			if(layer)
			{
				t = Math.ceil((EngineMovie.getFrameId(scene, _currentFrame + 1, layer) - 1) * layer.frequency);
			}
			else if(u2Layer)
			{
				t = Math.ceil((EngineMovie.getFrameId(scene, _currentFrame + 1, u2Layer.layer) - 1) * u2Layer.layer.frequency);
			}
			else if(listLib && listLib.isPlayThis)
			{
				var lt:uint;
				for each (var l:U2InfoBaseLayer in listLib.lib) 
				{
					if (l.isPlayThis)
					{
						lt = Math.ceil((EngineMovie.getFrameId(scene, _currentFrame + 1, l) - 1) * l.frequency);
						if (lt != 0 && (t == 0 || lt < t))
						{
							t = lt;
						}
					}
				}
			}
			if (core == -1) core = g.time.frameTime.time;
			if (_selfEngine && _timeCore != core)
			{
				_timeCore = core;
			}
			if (String(int(Number(scene))) != String(scene))
			{
				_playLabel = String(scene);
			}
			else
			{
				_playLabel = "";
			}
			if (_playLabel)
			{
				playLabel(_playLabel, loop, method, overLabel, stopBegin, playChild, core);
			}
			else
			{
				if (_playLabelTimeStart != 0) _playLabelTimeStart = 0;
				if (_playLabelTimeEnd != 0) _playLabelTimeEnd = 0;
				if (listLength)
				{
					var tr:U2Timer;
					for each (var itemLayer:U2Layer in listLayer) 
					{
						tr = itemLayer.timer;
						if (tr)
						{
							if (tr._complete != null) tr._complete = null;
							if (tr._loop != 0) tr._loop = 0;
							if (tr._overLabel != "") tr._overLabel = "";
							if (tr._stopBegin != true) tr._stopBegin = true;
							if (tr._playLabel != "") tr._playLabel = "";
							if (tr._playLabelTimeStart != 0) tr._playLabelTimeStart = 0;
							if (tr._playLabelTimeEnd != 0) tr._playLabelTimeEnd = 0;
						}
					}
				}
				timeCore(core, core - t, true, false);
				if (_complete != method) _complete = method;
				if (_loop != loop) _loop = loop;
				if (_overLabel != overLabel) _overLabel = overLabel;
				if (_stopBegin != stopBegin) _stopBegin = stopBegin;
				setPlayThis(true, core);
				setPlayChild(playChild, core);
			}
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
			if (core == -1) core = g.time.frameTime.time;
			if (_selfEngine) _timeCore = core;
			if (_playLabel != "") _playLabel = "";
			if (_playLabelTimeStart != 0) _playLabelTimeStart = 0;
			if (_playLabelTimeEnd != 0) _playLabelTimeEnd = 0;
			if (listLength)
			{
				var tr:U2Timer;
				for each (var l:U2Layer in listLayer) 
				{
					tr = l.timer;
					if (tr)
					{
						if (tr._complete != null) tr._complete = null;
						if (tr._loop != 0) tr._loop = 0;
						if (tr._overLabel != "") tr._overLabel = "";
						if (tr._stopBegin != true) tr._stopBegin = true;
						if (tr._playLabel != "") tr._playLabel = "";
						if (tr._playLabelTimeStart != 0) tr._playLabelTimeStart = 0;
						if (tr._playLabelTimeEnd != 0) tr._playLabelTimeEnd = 0;
					}
				}
			}
			timeCore(core, core - time, true, false);
			if (_complete != method) _complete = method;
			if (_loop != loop) _loop = loop;
			if (_overLabel != overLabel) _overLabel = overLabel;
			if (_stopBegin != stopBegin) _stopBegin = stopBegin;
			setPlayThis(true, core);
			setPlayChild(playChild, core);
		}
		
		/**
		 * 播放那一帧,循环几次,播放完毕后执行函数
		 * @param	time		毫秒
		 * @param	playChild	是否播放子对象
		 * @param	core		内核时间
		 */
		public function stopTime(time:uint, playChild:Boolean = false, core:int = -1):void
		{
			if (_complete != null) _complete = null;
			if (_loop != 0) _loop = 0;
			if (_overLabel != "") _overLabel = "";
			if (_stopBegin != true) _stopBegin = true;
			if (_playLabel != "") _playLabel = "";
			if (_playLabelTimeStart != 0) _playLabelTimeStart = 0;
			if (_playLabelTimeEnd != 0) _playLabelTimeEnd = 0;
			if (listLength)
			{
				var t:U2Timer;
				for each (var l:U2Layer in listLayer) 
				{
					t = l.timer;
					if (t)
					{
						if (t._complete != null) t._complete = null;
						if (t._loop != 0) t._loop = 0;
						if (t._overLabel != "") t._overLabel = "";
						if (t._stopBegin != true) t._stopBegin = true;
						if (t._playLabel != "") t._playLabel = "";
						if (t._playLabelTimeStart != 0) t._playLabelTimeStart = 0;
						if (t._playLabelTimeEnd != 0) t._playLabelTimeEnd = 0;
					}
				}
			}
			if (core == -1) core = g.time.frameTime.time;
			if (_selfEngine && _timeCore != core)
			{
				_timeCore = core;
			}
			timeCore(core, core - time, true, false);
			setPlayThis(false, core);
			setPlayChild(playChild, core);
		}
		
		/**
		 * [需要重写]播放名称为labelName的几个幀的序列
		 * @param	label		播放的区间
		 * @param	loop		循环次数,0无限循环,1循环一次停止
		 * @param	method		播放完毕后触发函数
		 * @param	overLabel	播放完毕后播放那个区间
		 * @param	stopBegin	播放完毕后是停留在开始,还是停留在最后幀,如果设置overPlayLabel就忽略这个参数
		 * @param	playChild	子对象是否播放
		 * @param	core		内核时间
		 */
		public function playLabel(label:String, loop:int = 0, method:Function = null, overLabel:String = "", stopBegin:Boolean = true, playChild:Boolean = true, core:int = -1):void
		{
			var l:U2InfoBaseLayer;
			if (layer)
			{
				l = layer;
			}
			else if (u2Layer)
			{
				l = u2Layer.layer;
			}
			if (l)
			{
				var i:int = 0;
				var labelStart:int = -1;
				for each (var item:U2InfoBaseFrame in l.lib) 
				{
					if (item.label == label)
					{
						if (labelStart == -1)
						{
							_playLabelFrameStart = i;
							labelStart = i;
							_playLabelTimeStart = l.frequency * i;
							_playLabelTimeEnd = _playLabelTimeStart + l.frequency;
							if (_playLabelFrame == null)
							{
								_playLabelFrame = new Vector.<U2InfoBaseFrame>();
							}
							else
							{
								_playLabelFrame.length = 0;
							}
							_playLabelFrame.push(item);
						}
						else
						{
							_playLabelTimeEnd = l.frequency * (i + 1);
							_playLabelFrame.push(item);
						}
					}
					else if(labelStart != -1)
					{
						break;
					}
					i++;
				}
				if (labelStart != -1)
				{
					if (_complete != method) _complete = method;
					if (_loop != loop) _loop = loop;
					if (_overLabel != overLabel)_overLabel = overLabel;
					if (_stopBegin != stopBegin)_stopBegin = stopBegin;
					if (_playLabel != label) _playLabel = label;
					gotoFrameId(labelStart, true);
				}
				else
				{
					if (_complete != null) _complete = null;
					if (_loop != 0) _loop = 0;
					if (_overLabel != "") _overLabel = "";
					if (_stopBegin != true) _stopBegin = true;
					if (_playLabel != "") _playLabel = "";
					if (_playLabelTimeStart != 0) _playLabelTimeStart = 0;
					if (_playLabelTimeEnd != 0) _playLabelTimeEnd = 0;
					g.log.pushLog(this, LogType._Warning, "无名为 " + label + "帧");
				}
				setPlayThis(true, core);
				setPlayChild(playChild, core);
			}
			else if (listLength)
			{
				if (_complete != null) _complete = null;
				if (_loop != 0) _loop = 0;
				if (_overLabel != "") _overLabel = "";
				if (_stopBegin != true) _stopBegin = true;
				if (_playLabel != "") _playLabel = "";
				if (_playLabelTimeStart != 0) _playLabelTimeStart = 0;
				if (_playLabelTimeEnd != 0) _playLabelTimeEnd = 0;
				var maxLayer:U2Layer;
				var maxTime:int = 0;
				var useTime:int = 0;
				for each (var itemLayer:U2Layer in listLayer) 
				{
					if (itemLayer.timer && itemLayer.layer.isPlay)
					{
						itemLayer.timer.playLabel(label, loop, null, overLabel, stopBegin, playChild, core);
						useTime = itemLayer.timer._playLabelTimeEnd - itemLayer.timer._playLabelTimeStart;
						if (maxTime < useTime)
						{
							maxLayer = itemLayer;
							maxTime = useTime;
						}
					}
				}
				if (itemLayer)
				{
					itemLayer.timer.playLabel(label, loop, method, overLabel, stopBegin, playChild, core);
				}
				else if (method != null)
				{
					method();
				}
			}
			
		}
	}
}