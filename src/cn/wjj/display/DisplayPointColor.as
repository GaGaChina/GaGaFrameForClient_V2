package cn.wjj.display
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	/**
	 * 获取BitmapData数据
	 * @author GaGa
	 * 
	 */
	public class DisplayPointColor
	{
		
		private static var p:Point = new Point();
		private static var b:BitmapData = new BitmapData(1, 1, true, 0);
		private static var m:Matrix = new Matrix(1, 0, 0, 1, 0, 0);
		private static var drawMathod:Function;
		
		public function DisplayPointColor():void { }
		
		/** 根据坐标点返回颜色 **/
		public static function getColor(display:DisplayObject, stageX:Number, stageY:Number):uint
		{
			p.x = stageX;
			p.y = stageY;
			p = display.globalToLocal(p);
			m.tx = -int(p.x);
			m.ty = -int(p.y);
			b.setPixel32(0, 0, 0);
			if (drawMathod != null)
			{
				drawMathod(display, m, null, null, null, false, "best");
			}
			else if("drawWithQuality" in b)
			{
				drawMathod = b["drawWithQuality"] as Function; 
				drawMathod(display, m, null, null, null, false, "best");
			}
			else
			{
				b.draw(display, m, null, null, null, false);
			}
			return b.getPixel32(0, 0);
		}
	}
}