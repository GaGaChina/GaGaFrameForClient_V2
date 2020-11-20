package cn.wjj.display.ui2d.engine 
{
	import cn.wjj.display.ui2d.IU2Base;
	import flash.display.DisplayObject;
	
	
	/**
	 * 主动式设置偏移量
	 * 
	 * @author GaGa
	 */
	public class EnginePositionCount 
	{
		
		public function EnginePositionCount() { }
		
		/** 是否需要重算偏移信息 **/
		public static var isChange:Boolean = false;
		/** 是否需要重算最终值 **/
		public static var isChangeS:Boolean = false;
		/** 偏离中心点的角度(弧度),添加缩放比例的 **/
		private static var offsetAngle:Number = 0;
		/** 偏离中心点的长度,添加缩放比例的 **/
		private static var offsetLength:Number = 0;
		
		/** 需要去设置的对象 **/
		public static var display:DisplayObject;
		/** 偏移x **/
		public static var ox:Number;
		/** 偏移y **/
		public static var oy:Number;
		/** 偏移角度 **/
		public static var or:Number;
		/** 偏移透明度 **/
		public static var oa:Number;
		/** 偏移比例x **/
		public static var osx:Number;
		/** 偏移比例y **/
		public static var osy:Number;
		
		/** 临时变量 **/
		private static var a:Number;
		private static var b:Number;
		
		/**
		 * 设置初始信息
		 * @param	display
		 * @param	x
		 * @param	y
		 * @param	a
		 * @param	r
		 * @param	sx
		 * @param	sy
		 */
		public static function setDefault(display:DisplayObject, x:Number = 0, y:Number = 0, a:Number = 1, r:Number = 0, sx:Number = 1, sy:Number = 1):void
		{
			EnginePositionCount.display = display;
			//计算出偏移变化量
			if (EnginePositionCount.offsetAngle != 0) EnginePositionCount.offsetAngle = 0;
			if (EnginePositionCount.offsetLength != 0) EnginePositionCount.offsetLength = 0;
			EnginePositionCount.a = 0;
			EnginePositionCount.b = 0;
			EnginePositionCount.offsetAngle = 0;
			EnginePositionCount.offsetLength = 0;
			if (x != 0)
			{
				EnginePositionCount.a = -x * sx;
				EnginePositionCount.b = -y * sy;
				EnginePositionCount.offsetAngle = Math.atan2(EnginePositionCount.b, EnginePositionCount.a);
				EnginePositionCount.offsetLength = Math.sqrt(EnginePositionCount.a * EnginePositionCount.a + EnginePositionCount.b * EnginePositionCount.b);
			}
			else if (x == 0 && y == 0) { }
			else if (x == 0)
			{
				EnginePositionCount.offsetAngle = 2 * Math.PI;
				EnginePositionCount.offsetLength = y * sy;
			}
			else if (y == 0)
			{
				EnginePositionCount.offsetAngle = 0;
				EnginePositionCount.offsetLength = x * sx;
			}
			//计算出偏移翻转绝对量
			r = r % 360;
			if (r < 0) r += 360;
			if (EnginePositionCount.ox != -x) EnginePositionCount.ox = -x;
			if (EnginePositionCount.oy != -y) EnginePositionCount.oy = -y;
			if (EnginePositionCount.or != r) EnginePositionCount.or = r;
			if (EnginePositionCount.oa != a) EnginePositionCount.oa = a;
			if (EnginePositionCount.osx != sx) EnginePositionCount.osx = sx;
			if (EnginePositionCount.osy != sy) EnginePositionCount.osy = sy;
			if (r == 0)
			{
				if (x != 0) EnginePositionCount.ox = x * sx;
				if (y != 0) EnginePositionCount.oy = y * sy;
			}
			else if (r == 90)
			{
				//X轴的便宜将变为Y轴偏移,Y轴便宜转换为X轴便宜
				if (x != 0) EnginePositionCount.oy = x * sx;
				if (y != 0) EnginePositionCount.ox = -y * sy;
			}
			else if (r == 270)
			{
				if (x != 0) EnginePositionCount.oy = -x * sx;
				if (y != 0) EnginePositionCount.ox = y * sy;
			}
			else
			{
				if (x != 0 && y != 0)
				{
					EnginePositionCount.tempAngle = r / 180 * Math.PI + EnginePositionCount.offsetAngle;
					EnginePositionCount.ox = -Math.cos(EnginePositionCount.tempAngle) * EnginePositionCount.offsetLength;
					EnginePositionCount.oy = -Math.sin(EnginePositionCount.tempAngle) * EnginePositionCount.offsetLength;
				}
			}
		}
		
		/**
		 * 叠加设置这个对象的偏移属性
		 * @param	x
		 * @param	y
		 * @param	alpha
		 * @param	rotation
		 * @param	scaleX
		 * @param	scaleY
		 */
		public static function addOffset(x:int = 0, y:int = 0, alpha:Number = 1, rotation:Number = 0, scaleX:Number = 1, scaleY:Number = 1):void
		{
			EnginePositionCount.a = -x * scaleX - (EnginePositionCount.ox * EnginePositionCount.osx);
			EnginePositionCount.b = -y * scaleY - (EnginePositionCount.oy * EnginePositionCount.osy);
			EnginePositionCount.a = -x * scaleX;
			EnginePositionCount.b = -y * scaleY;
			EnginePositionCount.offsetAngle = Math.atan2(EnginePositionCount.b, EnginePositionCount.a);
			EnginePositionCount.offsetLength = Math.sqrt(EnginePositionCount.a * EnginePositionCount.a + EnginePositionCount.b * EnginePositionCount.b);
			
			/*
			if (x != 0)
			{
				EnginePositionCount.a = -x * scaleX + EnginePositionCount.a;
				EnginePositionCount.b = -y * scaleY + EnginePositionCount.b;
				EnginePositionCount.offsetAngle = Math.atan2(EnginePositionCount.b, EnginePositionCount.a);
				EnginePositionCount.offsetLength = Math.sqrt(EnginePositionCount.a * EnginePositionCount.a + EnginePositionCount.b * EnginePositionCount.b);
			}
			else if (x == 0 && y == 0) { }
			else if (x == 0)
			{
				EnginePositionCount.offsetAngle = 2 * Math.PI;
				EnginePositionCount.offsetLength = y * scaleY + EnginePositionCount.offsetLength;
			}
			else if (y == 0)
			{
				EnginePositionCount.offsetAngle = 0;
				EnginePositionCount.offsetLength = x * scaleX + EnginePositionCount.offsetLength;
			}
			*/
			EnginePositionCount.or = (rotation + EnginePositionCount.or) % 360;
			if (EnginePositionCount.or < 0) EnginePositionCount.or += 360;
			if (alpha != 1) EnginePositionCount.oa = EnginePositionCount.oa * alpha;
			if (scaleX != 1) EnginePositionCount.osx = scaleX * EnginePositionCount.osx;
			if (scaleY != 1) EnginePositionCount.osy = scaleY * EnginePositionCount.osy;
			/*
			if (EnginePositionCount.or == 0)
			{
				if (x != 0) EnginePositionCount.ox += x * EnginePositionCount.osx;
				if (y != 0) EnginePositionCount.oy += y * EnginePositionCount.osy;
			}
			else if (EnginePositionCount.or == 90)
			{
				//X轴的便宜将变为Y轴偏移,Y轴便宜转换为X轴便宜
				if (x != 0) EnginePositionCount.oy += x * EnginePositionCount.osx;
				if (y != 0) EnginePositionCount.ox -= y * EnginePositionCount.osy;
			}
			else if (EnginePositionCount.or == 270)
			{
				if (x != 0) EnginePositionCount.oy -= x * EnginePositionCount.osx;
				if (y != 0) EnginePositionCount.ox += y * EnginePositionCount.osy;
				
			}
			else
			{
				if (x != 0 && y != 0)
				{
					tempAngle = EnginePositionCount.or / 180 * Math.PI + offsetAngle;
					EnginePositionCount.ox -= Math.cos(tempAngle) * offsetLength;
					EnginePositionCount.oy -= Math.sin(tempAngle) * offsetLength;
				}
			}
			*/
					tempAngle = EnginePositionCount.or / 180 * Math.PI + offsetAngle;
					EnginePositionCount.ox -= Math.cos(tempAngle) * offsetLength;
					EnginePositionCount.oy -= Math.sin(tempAngle) * offsetLength;
		}
		
		/** 根据偏移量算出角度
		private static function angleCount():void
		{
			if (offsetAngle != 0) offsetAngle = 0;
			if (offsetLength != 0) offsetLength = 0;
			if (ox != 0 && y != 0)
			{
				a = -ox * osx;
				b = -oy * osy;
				offsetLength = Math.sqrt(a * a + b * b);
				offsetAngle = Math.atan2(b, a);
			}
			else if (ox == 0 && oy == 0) { }
			else if (ox == 0)
			{
				offsetAngle = 2 * Math.PI;
				offsetLength = oy * osy;
			}
			else if (oy == 0)
			{
				offsetAngle = 0;
				offsetLength = ox * osx;
			}
			count();
		}
		 **/
		public function countOffset():void
		{
			/*
			EnginePositionCount.or = EnginePositionCount.or % 360;
			if (EnginePositionCount.or < 0) EnginePositionCount.or += 360;
			tempX = _x;
			tempY = _y;
			tempSX = _scaleX * _offsetScaleX;
			tempSY = _scaleY * _offsetScaleY;
			if (EnginePositionCount.or == 0)
			{
				if (_offsetX != 0) EnginePositionCount.ox += _offsetX * tempSX;
				if (_offsetY != 0) tempY += _offsetY * tempSY;
			}
			else if (EnginePositionCount.or == 90)
			{
				//X轴的便宜将变为Y轴偏移,Y轴便宜转换为X轴便宜
				if (_offsetX != 0) tempY += _offsetX * tempSX;
				if (_offsetY != 0) tempX -= _offsetY * tempSY;
				
			}
			//容器和Shape可以去掉180的参数
			else if (EnginePositionCount.or == 180)
			{
				if (_offsetX != 0) tempX -= (_width + _offsetX) * tempSX;
				if (_offsetY != 0) tempY -= (_height + _offsetY) * tempSY;
			}
			else if (EnginePositionCount.or == 270)
			{
				if (_offsetX != 0) tempY -= _offsetX * tempSX;
				if (_offsetY != 0) tempX += _offsetY * tempSY;
				
			}
			else
			{
				if (offsetX != 0 && offsetY != 0)
				{
					tempAngle = tempR / 180 * Math.PI + offsetAngle;
					tempX -= Math.cos(tempAngle) * offsetLength;
					tempY -= Math.sin(tempAngle) * offsetLength;
				}
			}
			var alpha:Number = _alpha * this._offsetAlpha;
			if (super.alpha != alpha) super.alpha = alpha;
			if (super.rotation != tempR) super.rotation = tempR;
			if (super.scaleX != tempSX) super.scaleX = tempSX;
			if (super.scaleY != tempSY) super.scaleY = tempSY;
			if (super.x != tempX) super.x = tempX;
			if (super.y != tempY) super.y = tempY;
			*/
		}
		
		
		/** 存放弧度变量 **/
		private static var tempAngle:Number;
		
		/** 现实的角度,对角度进行360度转换 **/
		private static var tempR:Number;
		private static var tempX:Number;
		private static var tempY:Number;
		private static var tempSX:Number;
		private static var tempSY:Number;
		
		public function count():void
		{
			/*
			tempR = (_rotation + _offsetRotation) % 360;
			if (tempR < 0) tempR += 360;
			tempX = _x;
			tempY = _y;
			tempSX = _scaleX * _offsetScaleX;
			tempSY = _scaleY * _offsetScaleY;
			if (tempR == 0)
			{
				if (_offsetX != 0) tempX += _offsetX * tempSX;
				if (_offsetY != 0) tempY += _offsetY * tempSY;
			}
			else if (tempR == 90)
			{
				//X轴的便宜将变为Y轴偏移,Y轴便宜转换为X轴便宜
				if (_offsetX != 0) tempY += _offsetX * tempSX;
				if (_offsetY != 0) tempX -= _offsetY * tempSY;
				
			}
			//容器和Shape可以去掉180的参数
			else if (tempR == 180)
			{
				if (_offsetX != 0) tempX -= (_width + _offsetX) * tempSX;
				if (_offsetY != 0) tempY -= (_height + _offsetY) * tempSY;
			}
			else if (tempR == 270)
			{
				if (_offsetX != 0) tempY -= _offsetX * tempSX;
				if (_offsetY != 0) tempX += _offsetY * tempSY;
				
			}
			else
			{
				if (offsetX != 0 && offsetY != 0)
				{
					tempAngle = tempR / 180 * Math.PI + offsetAngle;
					tempX -= Math.cos(tempAngle) * offsetLength;
					tempY -= Math.sin(tempAngle) * offsetLength;
				}
			}
			var alpha:Number = _alpha * this._offsetAlpha;
			if (super.alpha != alpha) super.alpha = alpha;
			if (super.rotation != tempR) super.rotation = tempR;
			if (super.scaleX != tempSX) super.scaleX = tempSX;
			if (super.scaleY != tempSY) super.scaleY = tempSY;
			if (super.x != tempX) super.x = tempX;
			if (super.y != tempY) super.y = tempY;
			*/
		}
	}

}