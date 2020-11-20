package cn.wjj.display 
{
	import flash.geom.ColorTransform;
	
	/**
	 * 带对象池的颜色
	 * @author GaGa
	 */
	public class FColorTransform extends ColorTransform
	{
		
		/** 初始化 U2Sprite **/
		public static function instance(redMultiplier:Number = 1, greenMultiplier:Number = 1, blueMultiplier:Number = 1, alphaMultiplier:Number = 1, redOffset:Number = 0, greenOffset:Number = 0, blueOffset:Number = 0, alphaOffset:Number = 0):FColorTransform
		{
			return new FColorTransform(redMultiplier, greenMultiplier, blueMultiplier, alphaMultiplier, redOffset, greenOffset, blueOffset, alphaOffset);
		}
		
		/** 移除,清理,并回收 **/
		public function dispose():void
		{
			if (redMultiplier != 1) redMultiplier = 1;
			if (greenMultiplier != 1) greenMultiplier = 1;
			if (blueMultiplier != 1) blueMultiplier = 1;
			if (alphaMultiplier != 1) alphaMultiplier = 1;
			if (redOffset != 0) redOffset = 0;
			if (greenOffset != 0) greenOffset = 0;
			if (blueOffset != 0) blueOffset = 0;
			if (alphaOffset != 0) alphaOffset = 0;
		}
		
		public function FColorTransform(redMultiplier:Number = 1, greenMultiplier:Number = 1, blueMultiplier:Number = 1, alphaMultiplier:Number = 1, redOffset:Number = 0, greenOffset:Number = 0, blueOffset:Number = 0, alphaOffset:Number = 0)
		{
			super(redMultiplier, greenMultiplier, blueMultiplier, alphaMultiplier, redOffset, greenOffset, blueOffset, alphaOffset);
		}
	}
}