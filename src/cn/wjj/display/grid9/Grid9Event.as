package cn.wjj.display.grid9
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	/**
	 * Grid9事件分发
	 * @author GaGa
	 */
	public class Grid9Event extends Event implements IEventDispatcher
	{
		
		private static const instanceUse:String = "instanceUse";
		
		/** 创建图层完成 **/
		public static const CREATE:String = "CREATE";
		/** 场景尺寸比例发生变化 **/
		public static const StageScaleReSize:String = "StageScaleReSize";
		
		/** 场景绘制完毕 **/
		public static const DragOver:String = "DragOver";
		
		private static var instance:Grid9Event;
		
		private static var dispatcher:EventDispatcher;
		
		public function Grid9Event(type:String, bubbles:Boolean = false, cancelable:Boolean = false):void
		{
			super(type, bubbles, cancelable);
		}
		
		public static function get getInstance():Grid9Event
		{
			if (instance)
			{
				return instance;
			}
			else
			{
				instance = new Grid9Event(Grid9Event.instanceUse);
				dispatcher = new EventDispatcher(instance);
			}
			return instance;
		}
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			dispatcher.addEventListener(type, listener, useCapture, priority);
		}
		
		public function dispatchEvent(evt:Event):Boolean
		{
			return dispatcher.dispatchEvent(evt);
		}
		
		public function hasEventListener(type:String):Boolean
		{
			return dispatcher.hasEventListener(type);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			dispatcher.removeEventListener(type, listener, useCapture);
		}
		
		public function willTrigger(type:String):Boolean
		{
			return dispatcher.willTrigger(type);
		}
		
		override public function clone():Event 
		{
			var e:Grid9Event = new Grid9Event(type, bubbles, cancelable);
			return e;
		}
	}
}
class Enforcer{}