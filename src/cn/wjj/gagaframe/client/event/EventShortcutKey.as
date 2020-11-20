package cn.wjj.gagaframe.client.event
{
	
	import cn.wjj.g;
	import flash.events.KeyboardEvent;
	
	/**
	 * 一个快捷键的管理类.
	 * 可以定义如果焦点在某对象上,就生效某些快捷键.
	 * 
	 * @version 1.0.0
	 * @author GaGa wjjhappy@Gmail.com
	 * @copy 王加静 www.5ga.cn
	 */
	public class EventShortcutKey
	{
		/** 是否已经开始监听 **/
		private var _isStart:Boolean = false;
		/**
		 * 初步检测下这个对象有没有监听
		 * keyLength[1287494] = ShortcutKeyItem -> DictValue
		 */
		private var lib:Object = new Object();
		
		public function EventShortcutKey() { }
		
		/** 是否已经开始监听 **/
		public function get isStart():Boolean 
		{
			return _isStart;
		}
		
		/** 开始所有的快捷键监听 **/
		public function start():void
		{
			if (_isStart == false && g.bridge.stage)
			{
				_isStart = true;
				g.bridge.stage.addEventListener(KeyboardEvent.KEY_UP, keyHandler);
				g.bridge.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
			}
		}
		
		/** 暂停所有快捷键监听 **/
		public function stop():void
		{
			if (g.bridge.stage && _isStart)
			{
				_isStart = false;
				g.bridge.stage.removeEventListener(KeyboardEvent.KEY_UP, keyHandler);
				g.bridge.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
			}
		}
		
		public function removeMothod(method:Function):void
		{
			var item:EventShortcutKeyItem
			for each (var id:String in lib) 
			{
				item = lib[id];
				if (item)
				{
					item.removeMethod(method);
					if (item.list.length == 0)
					{
						delete lib[id];
					}
				}
			}
		}
		
		/**
		 * 添加一个函数事件
		 * @param	method
		 * @param	type
		 * @param	ischarCode
		 * @param	charCode
		 * @param	keyCode
		 * @param	ctrl
		 * @param	alt
		 * @param	shift
		 */
		public function add(method:Function, type:String, ischarCode:Boolean, charCode:uint = 0, keyCode:uint = 0, ctrl:Boolean = false, alt:Boolean = false, shift:Boolean = false):void
		{
			var id:String = getId(type, ischarCode, charCode, keyCode, ctrl, alt, shift);
			var item:EventShortcutKeyItem = lib[id] as EventShortcutKeyItem;
			if (item == null )
			{
				item = new EventShortcutKeyItem();
				item.id = id;
				lib[id] = item;
			}
			item.push(method);
			start();
		}
		
		/**
		 * 移除键盘监听
		 * @param	method
		 * @param	type
		 * @param	ischarCode
		 * @param	charCode
		 * @param	keyCode
		 * @param	ctrl
		 * @param	alt
		 * @param	shift
		 */
		public function remove(method:Function, type:String, ischarCode:Boolean, charCode:uint = 0, keyCode:uint = 0, ctrl:Boolean = false, alt:Boolean = false, shift:Boolean = false):void
		{
			var id:String = getId(type, ischarCode, charCode, keyCode, ctrl, alt, shift);
			var item:EventShortcutKeyItem = lib[id] as EventShortcutKeyItem;
			if (item )
			{
				item.removeMethod(method);
				if (item.list.length == 0)
				{
					delete lib[id];
				}
			}
		}
		
		/** 
		 * 处理快捷键响应 
		 * @param   evt 
		 */  
		private function keyHandler(e:KeyboardEvent):void
		{
			var keyCode:String = getId(e.type, false, e.charCode, e.keyCode, e.ctrlKey, e.altKey, e.shiftKey);
			var charCode:String = getId(e.type, true, e.charCode, e.keyCode, e.ctrlKey, e.altKey, e.shiftKey);
			var item:EventShortcutKeyItem;
			if (lib[keyCode])
			{
				item = lib[keyCode] as EventShortcutKeyItem
				item.run();
			}
			if (lib[charCode])
			{
				item = lib[charCode] as EventShortcutKeyItem
				item.run();
			}
		}
		
		/**
		 * 设置这个对象包
		 * @param	type			鼠标类型
		 * @param	ischarCode		是否使用CharCode
		 * @param	charCode		包含按下或释放的键的字符代码值
		 * @param	keyCode			按下或释放的键的键控代码值
		 * @param	ctrlKey			Windows/Linux Ctrl 键活动状态；Mac OS Ctrl 或 Command 键活动状态
		 * @param	altKey			Windows Alt / Mac Os Option
		 * @param	shiftKey		是否按下 Shift 才触发
		 * @return
		 */
		public static function getId(type:String, ischarCode:Boolean, charCode:uint = 0, keyCode:uint = 0, ctrl:Boolean = false, alt:Boolean = false, shift:Boolean = false):String
		{
			var id:String = "1";
			
			if (type == KeyboardEvent.KEY_UP)
			{
				id += "1";
			}
			else
			{
				id += "0";
			}
			if (ischarCode)
			{
				id += "1";
			}
			else
			{
				id += "0";
			}
			if (ctrl)
			{
				id += "1";
			}
			else
			{
				id += "0";
			}
			if (alt)
			{
				id += "1";
			}
			else
			{
				id += "0";
			}
			if (shift)
			{
				id += "1";
			}
			else
			{
				id += "0";
			}
			id = uint(parseInt(id, 2)).toString(36);
			if (ischarCode)
			{
				id += charCode;
			}
			else
			{
				id += keyCode;
			}
			return id;
		}

	}
}