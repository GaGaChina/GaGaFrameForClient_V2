package cn.wjj.display.filter
{
	import flash.display.DisplayObject;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	
	/**
	 * 一些简单的滤镜效果
	 * 
	 * @version 1.0.0
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 * @date 2010-05-04
	 */
	public class EasyFilter
	{
		/**
		 * 清除滤镜
		 * @param	obj
		 */
		public static function cleanFiler(obj:*):void
		{
			//var objFilters:Array = new Array();
			//obj.filters = objFilters;
			obj.filters = null;
		}
		
		/**
		 * 描边
		 * @param	obj     要描边的对象
		 * @param	colour  描边颜色
		 * @param	thick   粗细
		 * @param	update	更新全部数据
		 */
		public static function MiaoBian(o:*, colour:uint = 0xFFFFFF, thick:uint = 2, update:Boolean = true):void
		{
			if (o == null) return;
			var filter:GlowFilter = new GlowFilter(colour, 1, thick, thick, 10, BitmapFilterQuality.HIGH, false, false);
			var a:Array;
			if (update)
			{
				a = new Array();
			}
			else
			{
				a = o.filters;
			}
			a.push(filter);
			o.filters = a;
		}
		
		/**
		 * 类似于COC的投影
		 * @param	o				被投影对象
		 * @param	colour			投影和描边颜色
		 * @param	shadowThick		投影的高度
		 * @param	thick			描边粗细
		 * @param	update
		 */
		public static function ShadowCOC(o:*, colour:uint = 0x000000, shadowThick:uint = 3, thick:uint = 2, update:Boolean = true):void
		{
			if (o == null) return;
			var glow:GlowFilter = new GlowFilter(colour, 1, thick, thick, 10, BitmapFilterQuality.HIGH, false, false);
			var filter:DropShadowFilter = new DropShadowFilter(shadowThick, 90, colour, 1, 0, 0, 10, BitmapFilterQuality.HIGH, false, false, false);
			var a:Array;
			if (update)
			{
				a = new Array();
			}
			else
			{
				a = o.filters;
			}
			a.push(glow);
			a.push(filter);
			o.filters = a;
		}
		
		/**
		 * 添加发光滤镜
		 * @param obj			要发光的对象
		 * @param distance		阴影的偏移距离，以像素为单位
		 * @param angle			阴影的角度，0 到 360 度（浮点）
		 * @param color			阴影颜色，采用十六进制格式 0xRRGGBB。 默认值为 0x000000
		 * @param alpha			阴影颜色的 Alpha 透明度值。 有效值为 0.0 到 1.0。 例如，.25 设置透明度值为 25%
		 * @param blurX			水平模糊量。 有效值为 0 到 255.0（浮点）
		 * @param blurY			垂直模糊量。 有效值为 0 到 255.0（浮点）
		 * @param strength		印记或跨页的强度。 该值越高，压印的颜色越深，而且阴影与背景之间的对比度也越强。 有效值为 0 到 255.0
		 * @param quality		应用滤镜的次数。 使用 BitmapFilterQuality 常数,BitmapFilterQuality.LOW,BitmapFilterQuality.MEDIUM,BitmapFilterQuality.HIGH
		 * @param inner			表示阴影是否为内侧阴影。 值 true 指定内侧阴影。 值 false 指定外侧阴影（对象外缘周围的阴影）
		 * @param knockout		应用挖空效果 (true)，这将有效地使对象的填色变为透明，并显示文档的背景颜色
		 * @param hideObject	表示是否隐藏对象。 如果值为 true，则表示没有绘制对象本身，只有阴影是可见的
		 * @param update		更新全部数据
		 */
		public static function FaGuang(o:*,
									   color:uint = 0x000000,
									   alpha:Number = 1,
									   blurX:Number = 4,
									   blurY:Number = 4,
									   strength:Number = 1,
									   quality:int = 1,
									   inner:Boolean = false,
									   knockout:Boolean = false,
									   update:Boolean = true ):void
		{
			if(o == null)return;
			//var filter:DropShadowFilter = new DropShadowFilter(distance, angle, color, alpha, blurX, blurY, strength, quality, inner, knockout, hideObject);
			var filter:GlowFilter = new GlowFilter(color, alpha, blurX, blurY, strength, quality, inner, knockout);
			var a:Array;
			if (update)
			{
				a = new Array();
			}
			else
			{
				a = o.filters;
			}
			a.push(filter);
			o.filters = a;
		}
		
		/** 缓存灰度的信息 **/
		private static var grayscaleInfo:Object = new Object();
		
		/**
		 * 调整灰度
		 * RGB转换为灰度的设置大约是将30%的红通道，59%的蓝通道，11%的绿通道值混合成为灰度图 
		 * @param	obj
		 * @param	num		0就成黑色了,100就是正常灰度
		 * @param	update
		 */
		public static function setGrayscale(o:*, num:Number = 0, update:Boolean = true):void
		{
			var filter:ColorMatrixFilter;
			if (grayscaleInfo.hasOwnProperty(num))
			{
				filter = grayscaleInfo[num];
			}
			else
			{
				var matrix:Array = new Array();
				var r:Number = 0.3 * num / 100;
				var g:Number = 0.59 * num / 100;
				var b:Number = 0.11 * num / 100;
				matrix = matrix.concat([r, g, b, 0, 0]); // red
				matrix = matrix.concat([r, g, b, 0, 0]); // green
				matrix = matrix.concat([r, g, b, 0, 0]); // blue
				matrix = matrix.concat([0, 0, 0, 1, 0]); // alpha
				filter = new ColorMatrixFilter(matrix);
				grayscaleInfo[num] = filter;
			}
			var a:Array;
			if (update)
			{
				a = new Array();
			}
			else
			{
				a = o.filters;
			}
            a.push(filter);
            o.filters = a;
		}
		
		/**
		 * 设置饱和度
		 * @param	o
		 * @param	num
		 * @param	update
		 */
		public static function setSaturation(o:*, num:Number = 0, update:Boolean = true):void
		{
            var matrix:Array = new Array();
            matrix = matrix.concat([1, 0, 0, 0, 0]); // red
            matrix = matrix.concat([0, 0, 0, 0, 0]); // green
            matrix = matrix.concat([0, 0, 0, 0, 0]); // blue
            matrix = matrix.concat([0, 0, 0, 1, 0]); // alpha
            var filter:ColorMatrixFilter = new ColorMatrixFilter(matrix);
			var a:Array;
			if (update)
			{
				a = new Array();
			}
			else
			{
				a = o.filters;
			}
            a.push(filter);
            o.filters = a;
		}
		
        public static function applyRed(o:*, update:Boolean = true):void
		{
            var matrix:Array = new Array();
            matrix = matrix.concat([1, 0, 0, 0, 0]); // red
            matrix = matrix.concat([0, 0, 0, 0, 0]); // green
            matrix = matrix.concat([0, 0, 0, 0, 0]); // blue
            matrix = matrix.concat([0, 0, 0, 1, 0]); // alpha
            var filter:ColorMatrixFilter = new ColorMatrixFilter(matrix);
			var a:Array;
			if (update)
			{
				a = new Array();
			}
			else
			{
				a = o.filters;
			}
            a.push(filter);
            o.filters = a;
        }
		
        public static function applyGreen(o:*, update:Boolean = true):void
		{
            var matrix:Array = new Array();
            matrix = matrix.concat([0, 0, 0, 0, 0]); // red
            matrix = matrix.concat([0, 1, 0, 0, 0]); // green
            matrix = matrix.concat([0, 0, 0, 0, 0]); // blue
            matrix = matrix.concat([0, 0, 0, 1, 0]); // alpha
            var filter:ColorMatrixFilter = new ColorMatrixFilter(matrix);
			var a:Array;
			if (update)
			{
				a = new Array();
			}
			else
			{
				a = o.filters;
			}
            a.push(filter);
            o.filters = a;
        }
		
        public static function applyBlue(o:*, update:Boolean = true):void
		{
            var matrix:Array = new Array();
            matrix = matrix.concat([0, 0, 0, 0, 0]); // red
            matrix = matrix.concat([0, 0, 0, 0, 0]); // green
            matrix = matrix.concat([0, 0, 1, 0, 0]); // blue
            matrix = matrix.concat([0, 0, 0, 1, 0]); // alpha
            var filter:ColorMatrixFilter = new ColorMatrixFilter(matrix);
			var a:Array;
			if (update)
			{
				a = new Array();
			}
			else
			{
				a = o.filters;
			}
            a.push(filter);
            o.filters = a;
        }
		
		/**
		 * 和Flash色彩效果中的样式高级对应的颜色分配对应的参数
		 * @param	display			要改变颜色的对象
		 * @param	red				(0% - 100%)红色保留量
		 * @param	redOffset		(-255至255)红色偏移量
		 * @param	green			(0% - 100%)绿色保留量
		 * @param	greenOffset		(-255至255)绿色偏移量
		 * @param	blue			(0% - 100%)蓝色保留量
		 * @param	blueOffset		(-255至255)蓝色偏移量
		 * @param	alpha			(0% - 100%)透明色保留量
		 * @param	alphaOffset		(-255至255)透明色偏移量
		 * @param	update
		 */
		public static function applyColor(o:DisplayObject, red:Number = 1, redOffset:Number = 0, green:Number = 1, greenOffset:Number = 0, blue:Number = 1, blueOffset:Number = 0, alpha:Number = 1, alphaOffset:Number = 0, update:Boolean = true):void
		{
			var matrix:Array = new Array();
			matrix = matrix.concat([red, 0, 0, 0, redOffset]); // red
			matrix = matrix.concat([0, green, 0, 0, greenOffset]); // green
			matrix = matrix.concat([0, 0, blue, 0, blueOffset]); // blue
			matrix = matrix.concat([0, 0, 0, alpha, alphaOffset]); // alpha
			var filter:ColorMatrixFilter = new ColorMatrixFilter(matrix);
			var a:Array;
			if (update)
			{
				a = new Array();
			}
			else
			{
				a = o.filters;
			}
			a.push(filter);
			o.filters = a;
		}
	}
}