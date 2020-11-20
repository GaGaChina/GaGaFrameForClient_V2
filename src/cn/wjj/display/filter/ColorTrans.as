package cn.wjj.display.filter 
{
	import cn.wjj.display.FColorTransform;
	import flash.display.DisplayObject;
	import flash.geom.ColorTransform;
	/**
	 * 颜色调整
	 * 
	 * @author GaGa
	 */
	public class ColorTrans 
	{
		
		public function ColorTrans() { }
		
		/** 克隆一个颜色 **/
		public static function clone(o:ColorTransform):FColorTransform
		{
			return FColorTransform.instance(o.redMultiplier, o.greenMultiplier, o.blueMultiplier, o.alphaMultiplier, o.redOffset, o.greenOffset, o.blueOffset, o.alphaOffset);
		}
		
		/**
		 * 查看2个对象是否相识
		 * @param	a
		 * @param	b
		 * @return	0:不同, 1:完全相同, 2:内容相同
		 */
		public static function same(a:ColorTransform, b:ColorTransform):int
		{
			if (a === b)
			{
				return 1;
			}
			else
			{
				if (a.redMultiplier != b.redMultiplier) return 0;
				if (a.greenMultiplier != b.greenMultiplier) return 0;
				if (a.blueMultiplier != b.blueMultiplier) return 0;
				if (a.alphaMultiplier != b.alphaMultiplier) return 0;
				if (a.redOffset != b.redOffset) return 0;
				if (a.greenOffset != b.greenOffset) return 0;
				if (a.blueOffset != b.blueOffset) return 0;
				if (a.alphaOffset != b.alphaOffset) return 0;
				return 2;
			}
			return 0;
		}
		
		/** 清理显示对象的颜色 **/
		public static function clear(display:DisplayObject):void
		{
			display.transform.colorTransform = ColorTransType.normal;
		}
		
		/** 设置显示对象颜色 **/
		public static function trans(display:DisplayObject, trans:ColorTransform):void
		{
			display.transform.colorTransform = trans;
		}
		
		/**
		 * 叠加颜色效果(把本身的颜色样式复制一份,然后叠加到trans里,在赋值)
		 * @param	display
		 * @param	trans
		 */
		public static function composition(display:DisplayObject, trans:ColorTransform):void
		{
			var o:FColorTransform = clone(display.transform.colorTransform);
			o.concat(trans);
			display.transform.colorTransform = o;
		}
		
		/**
		 * 修正颜色,并保持一段时间,结束后切换为end颜色
		 * @param	display		显示对象
		 * @param	time		(毫秒)保持时间
		 * @param	trans		保持的颜色
		 * @param	end			结束颜色还原
		 */
		public static function hold(display:DisplayObject, time:uint, trans:ColorTransform, end:ColorTransform):void
		{
			ColorTransHold.push(display, new Date().time + time, trans, end);
		}
		
		/**
		 * 移除保持的颜色
		 * @param	display		显示对象
		 * @param	useEnd		是否使用结束的颜色
		 */
		public static function holdRemove(display:DisplayObject, useEnd:Boolean = true):void
		{
			ColorTransHold.remove(display, useEnd);
		}
		
		/** 获取结束的时间 **/
		public static function holdEndTime(display:DisplayObject):Number
		{
			return ColorTransHold.endTime(display);
		}
		
		/**
		 * 颜色切换动画效果
		 * @param	display		显示对象
		 * @param	time		切换总时间
		 * @param	start		开始的颜色样式
		 * @param	end			结束的颜色样式
		 */
		public static function animation(display:DisplayObject, time:uint, start:ColorTransform, end:ColorTransform):void
		{
			
		}
		
		/**
		 * 移除动画颜色效果
		 * @param	display
		 * @param	useEnd
		 */
		public static function animationStop(display:DisplayObject, useEnd:Boolean = true):void
		{
			
		}
		
		/**
		 * 不停切换的闪烁动画
		 * @param	display		显示对象
		 * @param	time		切换总时间
		 * @param	rate		多长时间切换一次样式,从0秒开始第一个
		 * @param	list		循环切换的全部样式
		 * @param	over		当结束的时候停留在那个样式上
		 */
		public static function twinkle(display:DisplayObject, time:uint, rate:uint, list:Vector.<ColorTransform>, over:ColorTransform):void
		{
			
		}
		
		/**
		 * 移除不停闪烁的动画
		 * @param	display
		 * @param	useOver
		 */
		public static function twinkleRemove(display:DisplayObject, useOver:Boolean = true):void
		{
			
		}
	}
}