package cn.wjj.display.ui2d
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	/**
	 * U2事件分发
	 * @author GaGa
	 */
	public class U2Event extends Event implements IEventDispatcher
	{
		
		private static const instanceUse:String = "instanceUse";
		
		/** 创建图层完成 **/
		public static const CREATE:String = "CREATE";
		/** 场景尺寸比例发生变化 **/
		public static const StageScaleReSize:String = "StageScaleReSize";
		/** 选中了其他图层 **/
		public static const SelectLayer:String = "SelectLayer";
		/** 选中的图层的帧 **/
		public static const SelectFrame:String = "SelectFrame";
		/** 修改了选中的图层 **/
		public static const ChangeLayer:String = "ChangeLayer";
		/** 修改了选中的帧 **/
		public static const ChangeFrame:String = "ChangeFrame";
		/** 添加或删除图层,导致图层高度发生变化 **/
		public static const ChangeLayerLength:String = "ChangeLayerLength";
		/** 添加或删除帧,导致帧数量发生变化 **/
		public static const ChangeFrameLength:String = "ChangeLayerLength";
		/** 帧的最大宽度发生变化 **/
		public static const MaxFrameWidthChange:String = "MaxFrameWidthChange";
		
		/** 主时间轴的时间发生变化 **/
		public static const LineTimeChange:String = "LineTimeChange";
		
		/** 场景绘制完毕 **/
		public static const DragOver:String = "DragOver";
		
		private static var instance:U2Event;
		
		/** 帧的最大宽度 **/
		public var maxFrameWidth:uint = 0;
		
		private static var dispatcher:EventDispatcher;
		
		public function U2Event(type:String, bubbles:Boolean = false, cancelable:Boolean = false):void
		{
			super(type, bubbles, cancelable);
		}
		
		public static function get getInstance():U2Event
		{
			if (instance)
			{
				return instance;
			}
			else
			{
				instance = new U2Event(U2Event.instanceUse);
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
			var e:U2Event = new U2Event(type, bubbles, cancelable);
			return e;
		}
	}
}
class Enforcer{}