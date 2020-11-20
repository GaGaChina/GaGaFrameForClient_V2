package cn.wjj.display.ui2d.engine
{
	import cn.wjj.display.ui2d.info.U2InfoDisplay;
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	
	/**
	 * 显示对象驱动
	 * @author GaGa
	 */
	public class EngineDisplay 
	{
		
		public function EngineDisplay() { }
		
		/**
		 * 设置BimtapMovie的每一幀
		 * @param	display
		 * @param	o
		 */
		public static function useDisplayInfo(display:DisplayObject, o:U2InfoDisplay):void
		{
			if (o)
			{
				(display as Object).setSizeInfo(o.x, o.y, o.alpha, o.rotation, o.scaleX, o.scaleY);
			}
		}
		
		public static function isImage(path:String):Boolean
		{
			var a:Array = path.split(".");
			var s:String = a.pop();
			switch (s) 
			{
				case "png":
				case "jpg":
				case "jpeg":
					return true;
					break;
			}
			return false;
		}
		
		/** 查看显示对象是否在场景区域以外 **/
		public static function displayInStage(display:DisplayObject):Boolean
		{
			if (display.stage)
			{
				var r:Rectangle = display.stage.getBounds(display);
				if (r.right < 0 || r.bottom < 0 || r.x > display.stage.stageWidth || r.y > display.stage.stageHeight)
				{
					return false;
				}
			}
			return true;
		}
	}

}