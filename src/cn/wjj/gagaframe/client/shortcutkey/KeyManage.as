package cn.wjj.gagaframe.client.shortcutkey
{
	
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	import flash.events.KeyboardEvent;
	
	/**
	 * 一个快捷键的管理类.
	 * 可以定义如果焦点在某对象上,就生效某些快捷键.
	 * 
	 * 
	 * @version 1.0.0
	 * @author GaGa wjjhappy@Gmail.com
	 * @copy 王加静 www.5ga.cn
	 */
	public class KeyManage
	{
		/** 是否开始监听标记 (可以暂停全部监听, 改造成非静态类可以按需暂停/监听) **/
		private var _started:Boolean = false;
		
		public function KeyManage()
		{
			g.event.addListener(g.bridge.stage, KeyboardEvent.KEY_UP, keyHandler);
			g.event.addListener(g.bridge.stage, KeyboardEvent.KEY_DOWN, keyHandler);
		}
		
		/** 是否开始监听标记 (可以暂停全部监听, 改造成非静态类可以按需暂停/监听)  **/
		public function get started():Boolean { return _started; }
		public function set started(value:Boolean):void
		{
			_started = value;
		}

		/**
		 * 开始所有的快捷键监听
		 */
		public function start():void
		{
			started = true;
		}
		
		/**
		 * 暂停所有快捷键监听
		 */
		public function stop():void
		{
			started = false;
		}
		
		/**
		 * 添加一个快捷键
		 * @param keyCode
		 * @param func
		 * @param type
		 * 
		 */
		public function addShortcutKey(keyCode:int, method:Function, type:String = KeyboardEvent.KEY_UP):void
		{
			//焦点,事件类型,事件函数,Ctrl,alt,Shift
			//method
			//updateAfterEvent():void 如果已修改显示列表，则此事件处理完成后将指示 Flash Player 呈现结果。 
		}
		
		public function removeShortcutKey(keyCode:int, func:Function, type:String = KeyboardEvent.KEY_UP):void
		{
			
		}
		
		/** 
		 * 处理快捷键响应 
		 * @param   evt 
		 */  
		private function keyHandler(e:KeyboardEvent):void
		{
			g.log.pushLog(this, LogType._Frame, 'event type:', e.type, 'key code:', e.keyCode);
			if (_started == false)
			{
				return;
			}
			var keyName:String = getKeyName(e.type, e.keyCode);
			/*
			if (keyName in _keyMaps){
				var funcs:Array = _keyMaps[keyName].concat();  
				for (var i:int = 0, len:int = funcs.length; i < len; i++){
					funcs[i]();  
				}  
			}
			*/
		}
		
		/** 
		 * 获取映射名 
		 * @param   type    事件类型 
		 * @param   keyCode 按键键值 
		 * @return  形如 type_keyCode 的字符串 
		 */  
		private static function getKeyName(type:String, keyCode:int):String
		{  
			return [type, keyCode].join('_');
		}
	}
}