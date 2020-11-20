package cn.wjj.display.ui2d.engine
{
	import cn.wjj.display.DisplayPointColor;
	import cn.wjj.display.ui2d.info.U2InfoBase;
	import cn.wjj.display.ui2d.info.U2InfoBaseFrame;
	import cn.wjj.display.ui2d.info.U2InfoBaseFrameBitmap;
	import cn.wjj.display.ui2d.info.U2InfoBaseFrameDisplay;
	import cn.wjj.display.ui2d.info.U2InfoBaseInfo;
	import cn.wjj.display.ui2d.info.U2InfoBaseLayer;
	import cn.wjj.display.ui2d.info.U2InfoDisplay;
	import cn.wjj.display.ui2d.info.U2InfoMouseEvent;
	import cn.wjj.display.ui2d.info.U2InfoType;
	import cn.wjj.display.ui2d.U2Bitmap;
	import cn.wjj.display.ui2d.U2Layer;
	import cn.wjj.display.ui2d.U2MouseEvent;
	import cn.wjj.display.ui2d.U2Sprite;
	import cn.wjj.display.ui2d.U2Timer;
	import cn.wjj.g;
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	/**
	 * 对Sprite进行操作
	 * @author GaGa
	 */
	public class EngineSprite 
	{
		
		/** 临时字符串 **/
		private static var __s:String;
		/** 临时字符串 **/
		private static var __s2:String;
		/** 临时int **/
		private static var __i:int;
		/** 临时Boolean **/
		private static var __b:Boolean;
		/** 临时Boolean **/
		private static var __b2:Boolean;
		
		public function EngineSprite() { }
		
		/**
		 * 将list的鼠标内容添加到列表中
		 * @param	s
		 * @param	list
		 */
		public static function handleMousePush(s:U2Sprite, d:DisplayObject, u2Layer:U2Layer):void
		{
			if (u2Layer.timer && u2Layer.layer.mouseLength && u2Layer.timer._currentFrame > -1)
			{
				var frameId:int = u2Layer.timer._currentFrame + 1;
				var list:Vector.<U2InfoMouseEvent> = u2Layer.layer.mouseList;
				var o:Object;
				var od:Vector.<DisplayObject>;
				var oa:Array;
				var oaa:Array;
				var index:int;
				for each (var item:U2InfoMouseEvent in list) 
				{
					if (item.frameLength && item.frameLib.indexOf(frameId) != -1)
					{
						if (s.mouseInfo.hasOwnProperty(item.mouseType))
						{
							o = s.mouseInfo[item.mouseType];
							od = o.display;
							oa = o.info;
							index = od.indexOf(d);
							if (index == -1)
							{
								od.push(d);
								oa.push(item);
								o.length++;
							}
							else
							{
								if (oa[index] is U2InfoMouseEvent)
								{
									oaa = new Array();
									oaa.push(oa[index]);
									oaa.push(item);
									oa[index] = oaa;
								}
								else
								{
									oa[index].push(item);
								}
							}
						}
						else
						{
							o = new Object();
							s.mouseInfo[item.mouseType] = o;
							s.mouseLength++;
							od = new Vector.<DisplayObject>();
							o.display = od;
							oa = new Array();
							o.info = oa;
							od.push(d);
							oa.push(item);
							o.length = 1;
						}
					}
				}
			}
		}
		
		/**
		 * 把b里面的数据取出来,然后丢到a内
		 * 
		 * frame 切换的时候才用重置并重新添加这个内容
		 * 
		 * mouseInfo   容器中的鼠标信息集合
		 * mouseLength 鼠标类型的数量
		 * 
		 * mouseInfo[鼠标事件类型] = Object[单鼠标类型数据]
		 * Object[单鼠标类型数据].length  显示对象数量 : int
		 * Object[单鼠标类型数据].display 显示对象数组 : DisplayObject
		 * Object[单鼠标类型数据].info    显示对象信息 : U2InfoMouseEvent || Array
		 * 
		 * @param	a
		 * @param	b	把b的内容转移到a中,并清理b
		 */
		public static function mergeMouseInfo(a:U2Sprite, b:U2Sprite):void
		{
			if (b.mouseLength)
			{
				var oa:Object, ob:Object;
				var obd:Vector.<DisplayObject>;
				var oba:Array, obaa:Array;
				var oai:int;
				var oad:Vector.<DisplayObject>;
				var oaa:Array, oaaa:Array;
				var i:int;
				var d:DisplayObject;
				for (var s:String in b.mouseInfo) 
				{
					ob = b.mouseInfo[s];
					if(ob.length > 0)
					{
						if (a.mouseInfo.hasOwnProperty(s))
						{
							oa = a.mouseInfo[s];
							oad = oa.display;
							oaa = oa.info;
							obd = ob.display;
							oba = ob.info;
							for (i = 0; i < ob.length; i++) 
							{
								d = obd[i];
								oai = oad.indexOf(d);
								if (oai == -1)
								{
									oa.length++;
									oad.push(d);
									oaa.push(oba[i]);
								}
								else
								{
									if (oba[i] is U2InfoMouseEvent)
									{
										if (oaa[oai] is U2InfoMouseEvent)
										{
											oaaa = new Array();
											oaaa.push(oaa[oai]);
											oaaa.push(oba[i]);
											oaa[oai] = oaaa;
										}
										else
										{
											oaaa = oaa[oai];
											oaaa.push(oba[i]);
										}
									}
									else
									{
										obaa = oba[i];
										if (oaa[oai] is U2InfoMouseEvent)
										{
											obaa.unshift(oaa[oai]);
											oaa[oai] = obaa;
										}
										else
										{
											oaaa = oaaa.concat(obaa);
											oaa[oai] = oaaa;
										}
									}
								}
							}
							ob.length = 0;
							obd.length = 0;
							oba.length = 0;
						}
						else
						{
							a.mouseLength++;
							a.mouseInfo[s] = ob;
						}
						delete b.mouseInfo[s];
					}
				}
				b.mouseLength = 0;
				handleMouseClear(b);
			}
		}
		
		/** 开始处理某一个显示对象的信息 **/
		public static function handleMouseInfo(s:U2Sprite):void
		{
			if (s.mouseLength)
			{
				if (s.mouseOpenLength == 0 && s.mouseEnabled == false && s.mouseSprite == null)
				{
					s.mouseEnabled = true;
				}
				var removeType:Vector.<String> = s.mouseOpenType.concat();
				for (__s in s.mouseInfo) 
				{
					__i = removeType.indexOf(__s);
					if (__i == -1)
					{
						if (__s == "U2.stageMouseUp")
						{
							g.event.addListener(g.bridge.stage, MouseEvent.MOUSE_UP, s.stageMouseEvent);
						}
						else
						{
							if (s.mouseSprite)
							{
								g.event.addListener(s.mouseSprite, __s.substr(3), s.mouseEvent);
							}
							else
							{
								g.event.addListener(s, __s.substr(3), s.mouseEvent);
							}
						}
						s.mouseOpenType.push(__s);
						s.mouseOpenLength++;
					}
					else
					{
						removeType.splice(__i, 1);
					}
				}
				for each (__s in removeType) 
				{
					__i = s.mouseOpenType.indexOf(__s);
					s.mouseOpenLength--;
					s.mouseOpenType.splice(__i, 1);
				}
				removeType.length = 0;
			}
			else if (s.mouseOpenLength)
			{
				s.mouseEnabled = false;
				for each (__s in s.mouseOpenType) 
				{
					if (__s == "U2.stageMouseUp")
					{
						g.event.removeListener(g.bridge.stage, MouseEvent.MOUSE_UP, s.stageMouseEvent);
					}
					else
					{
						if (s.mouseSprite)
						{
							g.event.removeListener(s.mouseSprite, __s.substr(3), s.mouseEvent);
						}
						else
						{
							g.event.removeListener(s, __s.substr(3), s.mouseEvent);
						}
					}
				}
				s.mouseOpenType.length = 0;
				s.mouseOpenLength = 0;
			}
		}
		
		/**
		 * mouseInfo[鼠标事件类型] = Object[单鼠标类型数据]
		 * Object[单鼠标类型数据].length  显示对象数量 : int
		 * Object[单鼠标类型数据].display 显示对象数组 : DisplayObject
		 * Object[单鼠标类型数据].info    显示对象信息 : U2InfoMouseEvent || Array
		 * @param	s
		 * @param	type
		 */
		public static function handleMouseEvent(s:U2Sprite, type:String, isStage:Boolean):void
		{
			if (isStage)
			{
				type = "U2.stageMouseUp";
			}
			else
			{
				type = "U2." + type;
			}
			var index:int = s.mouseOpenType.indexOf(type);
			if (index != -1)
			{
				var o:Object = s.mouseInfo[type];
				if (o.length)
				{
					var d:DisplayObject;
					var dtimer:U2Timer;
					var cache:Dictionary;
					var a:Array;
					var info:U2InfoMouseEvent;
					var alpah:int;
					var x:Number = g.bridge.stage.mouseX;
					var y:Number = g.bridge.stage.mouseY;
					var event:U2MouseEvent;
					var eventInfo:U2InfoBase
					for (var i:int = 0; i < o.length; i++) 
					{
						d = o.display[i];
						if (d is U2Bitmap)
						{
							dtimer = (d as U2Bitmap)._timer;
						}
						else if (d is U2Sprite)
						{
							dtimer = (d as U2Sprite).timer;
						}
						else
						{
							dtimer = null;
						}
						if (dtimer)
						{
							cache = dtimer.cache;
						}
						if (isStage)
						{
							if (o.info[i] is Array)
							{
								a = o.info[i];
								for each (info in a) 
								{
									if (info.eventLib.eventLength)
									{
										for each (eventInfo in info.eventLib.eventList) 
										{
											EngineEvent.runItem(eventInfo.parent.gfile, eventInfo, dtimer, cache);
										}
									}
									event = new U2MouseEvent(type);
									event.info = info;
									event.display = d;
									event.mouseTarget = s;
									s.dispatchEvent(event);
								}
							}
							else
							{
								info = o.info[i];
								if (info.eventLib.eventLength)
								{
									for each (eventInfo in info.eventLib.eventList) 
									{
										EngineEvent.runItem(eventInfo.parent.gfile, eventInfo, dtimer, cache);
									}
								}
								event = new U2MouseEvent(type);
								event.info = info;
								event.display = d;
								event.mouseTarget = s;
								s.dispatchEvent(event);
							}
						}
						else if (d.hitTestPoint(x, y))
						{
							alpah = -1;
							if (o.info[i] is Array)
							{
								a = o.info[i];
								for each (info in a) 
								{
									if (info.alpha)
									{
										if (alpah == -1)
										{
											if (DisplayPointColor.getColor(d, x, y) > 0)
											{
												alpah = 1;
											}
											else
											{
												alpah = 0;
											}
										}
										if (alpah == 1)
										{
											if (info.eventLib.eventLength)
											{
												for each (eventInfo in info.eventLib.eventList) 
												{
													EngineEvent.runItem(eventInfo.parent.gfile, eventInfo, dtimer, cache);
												}
											}
											event = new U2MouseEvent(type);
											event.info = info;
											event.display = d;
											event.mouseTarget = s;
											s.dispatchEvent(event);
										}
									}
									else
									{
										if (info.eventLib.eventLength)
										{
											for each (eventInfo in info.eventLib.eventList) 
											{
												EngineEvent.runItem(eventInfo.parent.gfile, eventInfo, dtimer, cache);
											}
										}
										event = new U2MouseEvent(type);
										event.info = info;
										event.display = d;
										event.mouseTarget = s;
										s.dispatchEvent(event);
									}
								}
							}
							else
							{
								info = o.info[i];
								if (info.alpha)
								{
									if (alpah == -1)
									{
										if (DisplayPointColor.getColor(d, x, y) > 0)
										{
											alpah = 1;
										}
										else
										{
											alpah = 0;
										}
									}
									if (alpah == 1)
									{
										if (info.eventLib.eventLength)
										{
											for each (eventInfo in info.eventLib.eventList) 
											{
												EngineEvent.runItem(eventInfo.parent.gfile, eventInfo, dtimer, cache);
											}
										}
										event = new U2MouseEvent(type);
										event.info = info;
										event.display = d;
										event.mouseTarget = s;
										s.dispatchEvent(event);
									}
								}
								else
								{
									if (info.eventLib.eventLength)
									{
										for each (eventInfo in info.eventLib.eventList) 
										{
											EngineEvent.runItem(eventInfo.parent.gfile, eventInfo, dtimer, cache);
										}
									}
									event = new U2MouseEvent(type);
									event.info = info;
									event.display = d;
									event.mouseTarget = s;
									s.dispatchEvent(event);
								}
							}
						}
					}
				}
			}
		}
		
		/** 清理一个U2Sprite内容 **/
		public static function handleMouseClear(s:U2Sprite):void
		{
			if (s.mouseOpenLength)
			{
				s.mouseEnabled = false;
				for each (var str:String in s.mouseOpenType) 
				{
					if (s.mouseSprite)
					{
						g.event.removeListener(s.mouseSprite, str.substr(3), s.mouseEvent);
					}
					else
					{
						g.event.removeListener(s, str.substr(3), s.mouseEvent);
					}
				}
				s.mouseOpenType.length = 0;
				s.mouseOpenLength = 0;
			}
			if (s.mouseLength)
			{
				for (var type:String in s.mouseInfo) 
				{
					delete s.mouseInfo[type];
				}
			}
		}
		
		/** 关闭鼠标事件 **/
		public static function handleCloseMouse(s:U2Sprite):void
		{
			if (s.startMouse)
			{
				handleMouseClear(s);
				s.startMouse = false;
				if (s.mouseOpenType != null) s.mouseOpenType = null;
				if (s.mouseInfo != null) s.mouseInfo = null;
			}
		}
		
		/** 打开鼠标事件 **/
		public static function handleOpenMouse(s:U2Sprite):void
		{
			if (s.startMouse == false)
			{
				s.startMouse = true;
				if (s.mouseOpenType == null) s.mouseOpenType = new Vector.<String>();
				if (s.mouseInfo == null) s.mouseInfo = new Object();
			}
		}
		
		/**
		 * 对本对象及子对象数据进行设置
		 * @param	display		显示对象
		 * @param	o			信息
		 * @param	cache		是否启用播放缓存控制
		 */
		public static function init(display:U2Sprite, o:U2InfoBaseInfo, cache:Dictionary = null):void
		{
			var lib:Vector.<U2InfoBaseLayer> = o.layer.lib;
			//删除全部的图形
			if (display.timer)
			{
				__b = display.timer._playThis;
				__b2 = display.timer._playChild;
				display.timer.display = null;
				display.timer.dispose();
				display.timer = null;
			}
			else
			{
				__b = false;
				__b2 = false;
			}
			U2Sprite.clear(display);
			//回收到内容
			var layer:U2InfoBaseLayer;
			var di:U2InfoDisplay;
			var u2Layer:U2Layer;
			var u2Bitmap:U2Bitmap;
			display.data = o;
			if (o.layer.isPlay)
			{
				var timer:U2Timer = U2Timer.instance();
				if (__b)
				{
					timer._playThis = true;
				}
				if (__b2)
				{
					timer._playChild = true;
				}
				display.timer = timer;
				if (cache)
				{
					timer.cache = cache;
				}
				timer.listLib = o.layer;
				timer.listLength = o.layer.length;
				//timer.listLength = lib.length;
				for (__i = 0; __i < timer.listLength; __i++) 
				{
					layer = lib[__i];
					u2Layer = U2Layer.instance();
					u2Layer.layer = layer;
					u2Layer.parent = display;
					u2Layer.timer = U2Timer.instance();
					if (__b2)
					{
						u2Layer.timer._playThis = true;
						u2Layer.timer._playChild = true;
					}
					u2Layer.timer.u2Layer = u2Layer;
					u2Layer.timer.selfEngine = false;
					if (cache)
					{
						u2Layer.timer.cache = cache;
					}
					timer.listLayer.push(u2Layer);
					if (layer.isPlay == false && layer.length)
					{
						u2Bitmap = u2Layer.display as U2Bitmap;
						if (u2Bitmap && u2Layer.frame)
						{
							di = u2Layer.frame.display;
							EngineBitmap.useFrameDisplay(u2Bitmap, u2Layer.frame, cache);
							u2Bitmap.setSizeInfo(di.x, di.y, di.alpha, di.rotation, di.scaleX, di.scaleY);
							EngineBitmap.autoEmpty(u2Bitmap);
							u2Bitmap.name = layer.name;
						}
					}
				}
				if (o.eventLib.eventLength)
				{
					timer.eventBase = o;
				}
			}
			else
			{
				//子对象全是位图,没有任何声音和显示对象
				if (o.layer.length)
				{
					for (__i = 0; __i < o.layer.length; __i++)
					{
						layer = lib[__i];
						if (layer.length)
						{
							var frame:U2InfoBaseFrame = layer.lib[0];
							u2Bitmap = U2Bitmap.instance();
							if (frame.type == U2InfoType.baseFrameBitmap)
							{
								EngineBitmap.useFrameBitmap(u2Bitmap, frame as U2InfoBaseFrameBitmap, cache);
							}
							else if (frame.type == U2InfoType.baseFrameDisplay)
							{
								var frameDisplay:U2InfoBaseFrameDisplay = frame as U2InfoBaseFrameDisplay;
								di = frameDisplay.display;
								EngineBitmap.useFrameDisplay(u2Bitmap, frameDisplay, cache);
								u2Bitmap.setSizeInfo(di.x, di.y, di.alpha, di.rotation, di.scaleX, di.scaleY);
							}
							if (u2Bitmap.bitmapData)
							{
								display.addChild(u2Bitmap);
							}
							u2Bitmap.name = layer.name;
						}
					}
				}
			}
		}
		
		/** 根据BitmapData自动设置 Empty **/
		public static function autoEmpty(display:U2Sprite):void
		{
			__i = display.numChildren;
			if (__i == 0)
			{
				if (display.isEmpty == false)
				{
					display.isEmpty = true;
				}
			}
			else
			{
				var isEmpty:Boolean = true;
				var c:DisplayObject;
				while (--__i > -1)
				{
					c = display.getChildAt(__i);
					if (c is U2Sprite)
					{
						if ((c as U2Sprite).isEmpty == false)
						{
							isEmpty = false;
							break;
						}
					}
					else if (c is U2Bitmap)
					{
						if ((c as U2Bitmap).isEmpty == false)
						{
							isEmpty = false;
							break;
						}
					}
					else
					{
						isEmpty = false;
						break;
					}
				}
				if (isEmpty != display.isEmpty)
				{
					display.isEmpty = isEmpty;
				}
			}
		}
		
		/** 对容器进行滞空 **/
		public static function clear(display:U2Sprite):void
		{
			U2Sprite.clear(display);
		}
	}
}