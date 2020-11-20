package cn.wjj.data.file 
{
	import cn.wjj.tool.ClassParameter;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;
	
	/**
	 * GFile相关的时间调度
	 * 
	 * @version 0.0.1
	 * @author GaGa wjjhappy@Gmail.com
	 * @copy 王加静 www.5ga.cn
	 * @date 2013-05-24
	 */
	public class GFileEvent extends Event 
	{
		/** 鼠标点击的时候的事件 **/
		public static const BITMAPCOMPLETE:String = "bitmapComplete";
		/** 完成的文件 **/
		public var file:GFileBase;
		
		/**
		 * 创建一个作为参数传递给事件侦听器的 Event 对象。
		 * @param	type	事件的类型，可以作为 Event.type 访问。
		 * @param	bubbles	确定 Event 对象是否参与事件流的冒泡阶段。默认值为 false。
		 * @param	cancelable	确定是否可以取消 Event 对象。默认值为 false。
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 */
		public function GFileEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			super(type, bubbles, cancelable);
		}
		
		public override function clone():Event
		{
			var e:GFileEvent = new GFileEvent(this.type);
			e.file = file;
			return e;
		}
		
		public override function toString():String
		{
			return formatToString("GFileEvent", "index", "type", "bubbles", "cancelable");
		}
	}

}