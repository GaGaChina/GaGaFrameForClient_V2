package cn.wjj.display.ui2d 
{
	import cn.wjj.display.ui2d.info.U2InfoMouseEvent;
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.events.Event;
	//import flash.events.MouseEvent;
	
	/**
	 * 提供U2的鼠标事件
	 * 
	 * @author GaGa
	 */
	public class U2MouseEvent extends Event
	{
		/*
		public static const CLICK:String = "click";
		public static const DOUBLE_CLICK:String = "doubleClick";
		public static const MIDDLE_CLICK:String = "middleClick";
		public static const MIDDLE_MOUSE_DOWN:String = "middleMouseDown";
		public static const MIDDLE_MOUSE_UP:String = "middleMouseUp";
		public static const MOUSE_DOWN:String = "mouseDown";
		public static const MOUSE_MOVE:String = "mouseMove";
		public static const MOUSE_OUT:String = "mouseOut";
		public static const MOUSE_OVER:String = "mouseOver";
		public static const MOUSE_UP:String = "mouseUp";
		public static const MOUSE_WHEEL:String = "mouseWheel";
		public static const RIGHT_CLICK:String = "rightClick";
		public static const RIGHT_MOUSE_DOWN:String = "rightMouseDown";
		public static const RIGHT_MOUSE_UP:String = "rightMouseUp";
		public static const ROLL_OUT:String = "rollOut";
		public static const ROLL_OVER:String = "rollOver";
		*/
		/** 触发的显示对象 **/
		public var display:DisplayObject;
		/** 点击的那个U2Sprite对象触发的事件 **/
		public var mouseTarget:U2Sprite;
		/** 触发所使用的信息 **/
		public var info:U2InfoMouseEvent;
		
		//public function U2MouseEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false):void
		//{
		//	super(type, bubbles, cancelable);
		//}
		
				/**
		 * 创建一个 Event 对象，其中包含有关鼠标事件的信息。将 Event 对象作为参数传递给事件侦听器。
		 * @param	type	事件的类型。可能的值包括：MouseEvent.CLICK、MouseEvent.DOUBLE_CLICK、MouseEvent.MOUSE_DOWN、MouseEvent.MOUSE_MOVE、MouseEvent.MOUSE_OUT、MouseEvent.MOUSE_OVER、MouseEvent.MOUSE_UP、MouseEvent.MIDDLE_CLICK、MouseEvent.MIDDLE_MOUSE_DOWN、MouseEvent.MIDDLE_MOUSE_UP、MouseEvent.RIGHT_CLICK、MouseEvent.RIGHT_MOUSE_DOWN、MouseEvent.RIGHT_MOUSE_UP、MouseEvent.MOUSE_WHEEL、MouseEvent.ROLL_OUT 和 MouseEvent.ROLL_OVER。
		 * @param	bubbles	确定 Event 对象是否参与事件流的冒泡阶段。
		 * @param	cancelable	确定是否可以取消 Event 对象。
		 * @param	localX	事件发生点相对于所属 Sprite 的水平坐标。
		 * @param	localY	事件发生点相对于所属 Sprite 的垂直坐标。
		 * @param	relatedObject	受事件影响的补充 InteractiveObject 实例。例如，发生 mouseOut 事件时，relatedObject 表示指针设备当前所指向的显示列表对象。
		 * @param	ctrlKey	在 Windows 或 Linux 中，表示是否已激活 Ctrl 键。在 Mac 中，表示是否已激活 Ctrl 键或 Command 键。
		 * @param	altKey	表示是否已激活 Alt 键（仅限 Windows 或 Linux）。
		 * @param	shiftKey	表示是否已激活 Shift 键。
		 * @param	buttonDown	表示是否按下了鼠标主按键。
		 * @param	delta	表示用户将鼠标滚轮每滚动一个单位应滚动多少行。正 delta 值表示向上滚动；负值表示向下滚动。通常所设的值为 1 到 3；值越大，滚动得越快。此参数仅用于 MouseEvent.mouseWheel 事件。
		 * @param	commandKey	（仅 AIR）表示 Command 键是否已激活（仅限 Mac）。此参数仅用于 MouseEvent.click、MouseEvent.mouseDown、MouseEvent.mouseUp、MouseEvent.middleClick、MouseEvent.middleMouseDown、MouseEvent.middleMouseUp、MouseEvent.rightClick、MouseEvent.rightMouseDown、MouseEvent.rightMouseUp 和 MouseEvent.doubleClick 事件。此参数仅适用于 Adobe AIR；请勿对 Flash Player 内容设置此参数。
		 * @param	controlKey	（仅 AIR）表示 Control 或 Ctrl 键是否已激活。此参数仅用于 MouseEvent.click、MouseEvent.mouseDown、MouseEvent.mouseUp、MouseEvent.middleClick、MouseEvent.middleMouseDown、MouseEvent.middleMouseUp、MouseEvent.rightClick、MouseEvent.rightMouseDown、MouseEvent.rightMouseUp 和 MouseEvent.doubleClick 事件。此参数仅适用于 Adobe AIR；请勿对 Flash Player 内容设置此参数。
		 * @param	clickCount	（仅 AIR）表示鼠标事件是否为多击序列的一部分。对于除 MouseEvent.mouseDown、MouseEvent.mouseUp、MouseEvent.middleMouseDown、MouseEvent.middleMouseUp、MouseEvent.rightMouseDown 和 MouseEvent.rightMouseUp 以外的所有鼠标事件，此参数将为零。使用 clickCount 参数可以侦听单击、双击或任何多击序列。此参数仅适用于 Adobe AIR；请勿对 Flash Player 内容设置此参数。
		 * @langversion	3.0
		 * 
		 * , localX:Number = 0, localY:Number = 0, relatedObject:InteractiveObject = null, ctrlKey:Boolean = false, altKey:Boolean = false, shiftKey:Boolean = false, buttonDown:Boolean = false, delta:int = 0, commandKey:Boolean = false, controlKey:Boolean = false, clickCount:int = 0
		 */
		public function U2MouseEvent(type:String, bubbles:Boolean = true, cancelable:Boolean = false):void
		{
			//, localX, localY, relatedObject, ctrlKey, altKey, shiftKey, buttonDown, delta, commandKey, controlKey, clickCount
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event 
		{
			//, localX, localY, relatedObject, ctrlKey, altKey, shiftKey, buttonDown, delta, commandKey, controlKey, clickCount
			var o:U2MouseEvent = new U2MouseEvent(type, bubbles, cancelable);
			o.display = display;
			o.mouseTarget = mouseTarget;
			o.info = info;
			return o;
		}
	}
}