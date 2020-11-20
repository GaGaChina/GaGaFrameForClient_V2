package cn.wjj.display.filter
{
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.filters.BevelFilter;
	import flash.filters.BitmapFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BitmapFilterType;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.ConvolutionFilter;
	import flash.filters.DisplacementMapFilter;
	import flash.filters.DisplacementMapFilterMode;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * flash as3的图片特效静态类，只需要输入一个BitmapData和设定参数，就可以输出经过特效处理的一个BitmapData了。
	 * 目前该静态类支持底片效果(反色效果),黑白效果(灰度效果),浮雕效果,模糊效果，锐化效果，凸起效果，旧照片效果，
	 * 噪声效果，速描效果，油画效果，水彩效果，扩散效果（毛玻璃效果），球面效果（鱼眼效果），挤压效果，
	 * 光照效果（高光效果），马赛克效果,PS里的颜色阈值效果，色彩饱和度调整和色彩调整的特效。
	 */
	public class ImagesFilters
	{
		/** 底片效果(反色效果) **/
		public static function invert(source:BitmapData):BitmapData
		{
			var sourceBitmap:Bitmap = new Bitmap(source);
			var tempMovieClip:MovieClip = new MovieClip();
			tempMovieClip.addChild(sourceBitmap);
			var mytmpmc:Sprite = new Sprite();
			mytmpmc.graphics.lineStyle(0, 0x000000, 100);
			mytmpmc.graphics.moveTo(0, 0);
			mytmpmc.graphics.beginFill(0x000000);
			mytmpmc.graphics.lineTo(sourceBitmap.width, 0);
			mytmpmc.graphics.lineTo(sourceBitmap.width, sourceBitmap.height);
			mytmpmc.graphics.lineTo(0, sourceBitmap.height);
			mytmpmc.graphics.lineTo(0,0);
			mytmpmc.graphics.endFill();
			mytmpmc.blendMode = "invert";
			tempMovieClip.addChild(mytmpmc);
			var returnBitmapData:BitmapData = new BitmapData(tempMovieClip.width, tempMovieClip.height, true, 0x00FFFFFF);
			returnBitmapData.draw(tempMovieClip);
			tempMovieClip.removeChild(mytmpmc);
			tempMovieClip.removeChild(sourceBitmap);
			mytmpmc=null;
			return returnBitmapData;
		}
		
		/** 黑白效果(灰度效果) **/
		public static function grayFilter(source:BitmapData):BitmapData
		{
			var sourceBitmap:Bitmap = new Bitmap(source);
			sourceBitmap.filters = [getGrayFilter()];
			var returnBitmapData:BitmapData = new BitmapData(sourceBitmap.width, sourceBitmap.height, true, 0x00FFFFFF);
			returnBitmapData.draw(sourceBitmap);
			return returnBitmapData;
		}
		
		public static function getGrayFilter():ColorMatrixFilter
		{
			var myElements_array:Array = [0.3, 0.59, 0.11, 0, 0, 0.3, 0.59, 0.11, 0, 0, 0.3, 0.59, 0.11, 0, 0, 0, 0, 0, 1, 0];
			var myColorMatrix_filter:ColorMatrixFilter = new ColorMatrixFilter(myElements_array);
			return myColorMatrix_filter;
		}
		
		/** 浮雕效果 **/
		public static function embossFilter(source:BitmapData, angle:uint = 315):BitmapData
		{
			var radian:Number = angle * Math.PI / 180;
			var pi4:Number = Math.PI / 4;
			var clamp:Boolean = false;
			var clampColor:Number = 0xFF0000;
			var clampAlpha:Number = 256;
			var bias:Number = 128;
			var preserveAlpha:Boolean = false;
			var matrix:Array = [ Math.cos(radian + pi4) * 256, Math.cos(radian + 2 * pi4) * 256, Math.cos(radian + 3 * pi4) * 256,
			                     Math.cos(radian) * 256, 0, Math.cos(radian + 4 * pi4) * 256,
			                     Math.cos(radian - pi4) * 256, Math.cos(radian - 2 * pi4) * 256, Math.cos(radian - 3 * pi4) * 256 ];
			var matrixCols:Number = 3;
			var matrixRows:Number = 3;
			var filter:ConvolutionFilter = new ConvolutionFilter(matrixCols, matrixRows, matrix, matrix.length, bias, preserveAlpha, clamp, clampColor, clampAlpha);
			var myFilters:Array = new Array();
			myFilters.push(filter);
			myFilters.push(getGrayFilter());
			var sourceBitmap:Bitmap=new Bitmap(source);
			sourceBitmap.filters=myFilters;
			var returnBitmapData:BitmapData=new BitmapData(sourceBitmap.width,sourceBitmap.height,true, 0x00FFFFFF);
			returnBitmapData.draw(sourceBitmap);
			return returnBitmapData;
		}
		
		/** 模糊滤镜 **/
		public static function blurFilter(source:BitmapData, blurX:Number = 5, blurY:Number = 5):BitmapData
		{
			var filter:BlurFilter = new BlurFilter(blurX, blurY, BitmapFilterQuality.HIGH);
			var sourceBitmap:Bitmap = new Bitmap(source);
			sourceBitmap.filters = [filter];
			var o:BitmapData = new BitmapData(sourceBitmap.width, sourceBitmap.height, true, 0x00FFFFFF);
			o.draw(sourceBitmap);
			return o;
		}
		
		/** 锐化效果 **/
		public static function sharpenFilter(source:BitmapData, sharp:Number = 0.7):BitmapData
		{
			var matrix:Array = [ 0, 0, 0, 0, 0, 0, 0, 0, 0 ];
			matrix[1] = matrix[3] = matrix[5] = matrix[7] = -sharp;
			matrix[4] = 1 + sharp * 4;
			var filter: ConvolutionFilter = new ConvolutionFilter( 3, 3, matrix );
			var sourceBitmap:Bitmap = new Bitmap(source);
			sourceBitmap.filters = [filter];
			var o:BitmapData = new BitmapData(sourceBitmap.width, sourceBitmap.height, true, 0x00FFFFFF);
			o.draw(sourceBitmap);
			return o;
		}
		
		/** 凸起效果 **/
		public static function raiseFilter(source:BitmapData,distance:Number=5,angleInDegrees:Number=45):BitmapData {
			//var distance:Number       = 5;
			//var angleInDegrees:Number = 45;
			var highlightColor:Number = 0xCCCCCC;
			var highlightAlpha:Number = 0.8;
			var shadowColor:Number    = 0x808080;
			var shadowAlpha:Number    = 0.8;
			var blurX:Number          = 5;
			var blurY:Number          = 5;
			var strength:Number       = 5;
			var quality:Number        = BitmapFilterQuality.HIGH;
			var type:String           = BitmapFilterType.INNER;
			var knockout:Boolean      = false;
			var filter: BevelFilter =new BevelFilter(distance,
			                                   angleInDegrees,
			                                   highlightColor,
			                                   highlightAlpha,
			                                   shadowColor,
			                                   shadowAlpha,
			                                   blurX,
			                                   blurY,
			                                   strength,
			                                   quality,
			                                   type,
			                                   knockout);
			var sourceBitmap:Bitmap=new Bitmap(source);
			sourceBitmap.filters=[filter];
			var returnBitmapData:BitmapData=new BitmapData(sourceBitmap.width,sourceBitmap.height,true, 0x00FFFFFF);
			returnBitmapData.draw(sourceBitmap);
			return returnBitmapData;
		}
		
		/** 旧照片效果 **/
		public static function oldPictureFilter(source:BitmapData):BitmapData {
			var filter:ColorMatrixFilter = getGrayFilter();
			var sourceBitmap:Bitmap=new Bitmap(source);
			sourceBitmap.filters=[filter];
			source=new BitmapData(sourceBitmap.width,sourceBitmap.height,true, 0x00FFFFFF);
			source.draw(sourceBitmap);
			var matrix:Array = new Array();
			matrix = matrix.concat([0.94, 0, 0, 0, 0]);
			matrix = matrix.concat([0, 0.9, 0, 0, 0]);
			matrix = matrix.concat([0, 0, 0.8, 0, 0]);
			matrix = matrix.concat([0, 0, 0, 0.8, 0]);
			filter= new ColorMatrixFilter(matrix);
			sourceBitmap=new Bitmap(source);
			sourceBitmap.filters=[filter];
			var returnBitmapData:BitmapData=new BitmapData(sourceBitmap.width,sourceBitmap.height,true, 0x00FFFFFF);
			returnBitmapData.draw(sourceBitmap);
			return returnBitmapData;
		}
		
		/** 噪声效果 **/
		public static function noiseFilter(source:BitmapData, degree:Number = 128):BitmapData
		{
			//degree 0-255
			var noise:int,color:uint,r:uint,g:uint,b:uint;
			var returnBitmapData:BitmapData=source.clone();
			for (var i:int = 0; i < source.height; i++)
			{
				for (var j:int = 0; j < source.width; j++)
				{
					noise = int(Math.random() * degree * 2) - degree;
					color = source.getPixel(j, i);
					r = (color & 0xff0000) >> 16;
					g = (color & 0x00ff00) >> 8;
					b = color & 0x0000ff;
					r = r + noise<0?0:r+noise>255?255:r+noise;
					g = g + noise<0?0:g+noise>255?255:g+noise;
					b = b + noise<0?0:b+noise>255?255:b+noise;
					returnBitmapData.setPixel(j, i, r * 65536 + g * 256 + b);
				}
			}
			return returnBitmapData;
		}
		
		/** 素描滤镜 **/
		public static function sketchFilter(source:BitmapData,threshold:Number=30):BitmapData {
			//threshold 0-100
			var filter:ColorMatrixFilter = getGrayFilter();
			var sourceBitmap:Bitmap = new Bitmap(source);
			sourceBitmap.filters = [filter];
			var returnBitmapData:BitmapData = new BitmapData(sourceBitmap.width, sourceBitmap.height, true, 0x00FFFFFF);
			returnBitmapData.draw(sourceBitmap);
			var color:uint,gray1:int,gray2:int;
			for (var i:uint = 0; i < source.height - 1; i++) {
				for (var j:uint = 0; j < source.width - 1; j++) {
					color = source.getPixel(j, i);
					gray1 = (color & 0xff0000) >> 16;
					color = source.getPixel(j + 1, i + 1);
					gray2 = (color & 0xff0000) >> 16;
					if (Math.abs(gray1-gray2)>=threshold) {
						returnBitmapData.setPixel(j,i,0x222222);
					} else {
						returnBitmapData.setPixel(j,i,0xFFFFFF);
					}
				}
			}
			for (i=0; i<source.height; i++) {
				returnBitmapData.setPixel(source.width-1,i,0xFFFFFF);
			}
			for (i=0; i<source.width; i++) {
				returnBitmapData.setPixel(i,source.height-1,0xFFFFFF);
			}
			return returnBitmapData;
		}
		
		/** 油画效果 或 水彩效果 **/
		public static function waterColorFilter(source:BitmapData, scaleX:Number = 5, scaleY:Number = 5):BitmapData {
			var componentX:Number = 1;
			var componentY:Number = 1;
			var color:Number = 0x000000;
			var alpha:Number = 0x000000;
			var tempBitmap:BitmapData=new BitmapData(source.width,source.height,true,0x00FFFFFF);
			tempBitmap.perlinNoise(3, 3, 1, 1, false, true, 1, false);
			var sourceBitmap:Bitmap=new Bitmap(source);
			var filter:DisplacementMapFilter = new DisplacementMapFilter(tempBitmap, new Point(0, 0),componentX, componentY, scaleX, scaleY, DisplacementMapFilterMode.COLOR, color, alpha);
			sourceBitmap.filters=[filter];
			var returnBitmapData:BitmapData=new BitmapData(sourceBitmap.width,sourceBitmap.height,true, 0x00FFFFFF);
			returnBitmapData.draw(sourceBitmap);
			return returnBitmapData;
		}
		
		/** 扩散效果（毛玻璃效果） **/
		public static function diffuseFilter(source:BitmapData, scaleX:Number = 5, scaleY:Number = 5):BitmapData
		{
			var componentX:Number = 1;
			var componentY:Number = 1;
			var color:Number = 0x000000;
			var alpha:Number = 0x000000;
			var tempBitmap:BitmapData = new BitmapData(source.width, source.height, true, 0x00FFFFFF);
			tempBitmap.noise(888888);
			var sourceBitmap:Bitmap = new Bitmap(source);
			var filter:DisplacementMapFilter = new DisplacementMapFilter(tempBitmap, new Point(0, 0),componentX, componentY, scaleX, scaleY, DisplacementMapFilterMode.COLOR, color, alpha);
			sourceBitmap.filters = [filter];
			var returnBitmapData:BitmapData = new BitmapData(sourceBitmap.width, sourceBitmap.height, true, 0x00FFFFFF);
			returnBitmapData.draw(sourceBitmap);
			return returnBitmapData;
		}
		
		/** 球面效果（鱼眼效果） **/
		public static function spherizeFilter(source:BitmapData):BitmapData
		{
			var midx:int = int(source.width / 2);
			var midy:int = int(source.height / 2);
			var maxmidxy:int = midx > midy?midx:midy;
			var radian:uint, radius:uint, offsetX:uint, offsetY:uint, color:uint, r:int, g:int, b:int;
			var returnBitmapData:BitmapData = source.clone();
			for (var i:int = 0; i < source.height - 1; i++)
			{
				for (var j:int = 0; j < source.width - 1; j++)
				{
					offsetX = j - midx;
					offsetY = i - midy;
					radian = Math.atan2(offsetY, offsetX);
					radius = (offsetX * offsetX + offsetY * offsetY) / maxmidxy;
					var x:int = int(radius * Math.cos(radian)) + midx;
					var y:int = int(radius * Math.sin(radian)) + midy;
					if (x < 0)
					{
						x = 0;
					}
					if (x >= source.width)
					{
						x = source.width - 1;
					}
					if (y < 0)
					{
						y = 0;
					}
					if (y >= source.height)
					{
						y = source.height - 1;
					}
					color = source.getPixel(x, y);
					r = (color & 0xff0000) >> 16;
					g = (color & 0x00ff00) >> 8;
					b = color & 0x0000ff;
					returnBitmapData.setPixel(j, i, r * 65536 + g * 256 + b);
				}
			}
			return returnBitmapData;
		}
		
		/** 挤压效果 **/
		public static function pinchFilter(source:BitmapData, degree:Number = 16):BitmapData
		{
			var midx:int = int(source.width / 2);
			var midy:int = int(source.height / 2);
			var radian:uint, radius:uint, offsetX:uint, offsetY:uint, color:uint, r:int, g:int, b:int;
			var returnBitmapData:BitmapData = source.clone();
			for (var i:uint = 0; i < source.height - 1; i++)
			{
				for (var j:uint = 0; j < source.width - 1; j++)
				{
					offsetX = j - midx;
					offsetY = i - midy;
					radian = Math.atan2(offsetY, offsetX);
					radius = Math.sqrt(offsetX * offsetX + offsetY * offsetY);
					radius = Math.sqrt(radius) * degree;
					var x:int = int(radius * Math.cos(radian)) + midx;
					var y:int = int(radius * Math.sin(radian)) + midy;
					if (x<0) {
						x=0;
					}
					if (x >= source.width)
					{
						x = source.width - 1;
					}
					if (y < 0)
					{
						y=0;
					}
					if (y >= source.height)
					{
						y=source.height-1;
					}
					color = source.getPixel(x, y);
					r = (color & 0xff0000) >> 16;
					g = (color & 0x00ff00) >> 8;
					b = color & 0x0000ff;
					returnBitmapData.setPixel(j,i,r*65536+g*256+b);
				}
			}
			return returnBitmapData;
		}
		
		/** 光照效果（高光效果） **/
		public static function lightingFilter(source:BitmapData, power:Number = 128, posx:Number = 0.5, posy:Number = 0.5, r:Number = 0):BitmapData
		{
			//power 0-255
			var midx:int = int(source.width * posx);
			var midy:int = int(source.height * posy);
			if (r == 0)
			{
				r=Math.sqrt(midx*midx+midy*midy);
			}
			if (r == 0)
			{
				r = Math.sqrt(source.width * source.width / 4 + source.height * source.height / 4);
			}
			var radius:int = int(r);
			var sr:int = r * r;
			var returnBitmapData:BitmapData=source.clone();
			var sd:uint, color:uint, g:int, b:int, distance:uint, brightness:int;//r = 0
			for (var y:uint = 0; y < source.height; y++) {
				for (var x:uint = 0; x < source.width; x++) {
					sd = (x - midx) * (x - midx) + (y - midy) * (y - midy);
					if (sd<sr) {
						color=source.getPixel(x, y);
						r = (color & 0xff0000) >> 16;
						g = (color & 0x00ff00) >> 8;
						b = color & 0x0000ff;
						distance = Math.sqrt(sd);
						brightness = int(power * (radius - distance) / radius);
						r = r + brightness > 255?255:r + brightness;
						g = g + brightness > 255?255:g + brightness;
						b = b + brightness > 255?255:b + brightness;
						returnBitmapData.setPixel(x, y, r * 65536 + g * 256 + b);
					}
				}
			}
			return returnBitmapData;
		}
		
		/** 马赛克效果 **/
		public static function mosaicFilter(source:BitmapData, block:Number = 6):BitmapData {
			//block 1-32
			var returnBitmapData:BitmapData = source.clone();
			var sumr:int, sumg:int, sumb:int, product:int, color:uint, r:int, g:int, b:int, br:int, bg:int, bb:int;
			for (var y:uint = 0; y < source.height; y += block) {
				for (var x:uint = 0; x < source.width; x += block) {
					sumr = 0;
					sumg = 0;
					sumb = 0;
					product=0;
					for (var j:uint = 0; j < block; j++) {
						for (var i:uint = 0; i < block; i++) {
							if (x+i<source.width&&y+j<source.height) {
								color = source.getPixel(x + i, y + j);
								r = (color & 0xff0000) >> 16;
								g = (color & 0x00ff00) >> 8;
								b = color & 0x0000ff;
								sumr += r;
								sumg += g;
								sumb += b;
								product++;
							}
						}
					}
					br = int(sumr / product);
					bg = int(sumg / product);
					bb = int(sumb / product);
					for (j = 0; j < block; j++) {
						for (i = 0; i < block; i++) {
							if (x + i < source.width && y + j < source.height) {
								returnBitmapData.setPixel(x + i, y + j, br * 65536 + bg * 256 + bb);
							}
						}
					}
				}
			}
			return returnBitmapData;
		}
		
		/** 油画滤波器 **/
		public static function oilPaintingFilter(source:BitmapData, brushSize:Number = 1, coarseness:Number = 32):BitmapData {
			//brushSize 1-8
			//coarseness 1-255
			var color:uint, gray:uint, r:int, g:int, b:int, a:int;
			var arraylen:Number=coarseness+1;
			var CountIntensity:Array = new Array();
			var RedAverage:Array = new Array();
			var GreenAverage:Array = new Array();
			var BlueAverage:Array = new Array();
			var AlphaAverage:Array = new Array();

			var filter:ColorMatrixFilter = getGrayFilter();
			var sourceBitmap:Bitmap = new Bitmap(source);
			sourceBitmap.filters = [filter];
			var tempData:BitmapData = tempData = new BitmapData(sourceBitmap.width, sourceBitmap.height, true, 0x00FFFFFF);
			tempData.draw(sourceBitmap);
			var returnBitmapData:BitmapData = tempData.clone();
			var top:uint, bottom:uint, left:uint, right:uint;
			var x:uint, y:uint, i:uint;
			for (y = 0; y < source.height; y++) {
				top = y - brushSize;
				bottom = y + brushSize + 1;
				if (top < 0) {
					top = 0;
				}
				if (bottom>=source.height) {
					bottom=source.height-1;
				}
				for (x = 0; x < source.width; x++)
				{
					left = x - brushSize;
					right = x + brushSize + 1;
					if (left<0) {
						left=0;
					}
					if (right >= source.width)
					{
						right=source.width;
					}
					for (i = 0; i < arraylen; i++)
					{
						CountIntensity[i]=0;
						RedAverage[i]=0;
						GreenAverage[i]=0;
						BlueAverage[i]=0;
						AlphaAverage[i]=0;
					}
					for (var j:uint = top; j < bottom; j++)
					{
						for (i = left; i < right; i++)
						{
							color=tempData.getPixel(i, j);
							gray = (color & 0xff0000) >> 16;
							color=source.getPixel32(i, j);
							a = color >> 24 & 0xFF;
							r = color >> 16 & 0xFF;
							g = color >> 8 & 0xFF;
							b = color & 0xFF;
							var intensity:int=int(coarseness*gray/255);
							CountIntensity[intensity]++;
							RedAverage[intensity]+=r;
							GreenAverage[intensity]+=g;
							BlueAverage[intensity]+=b;
							AlphaAverage[intensity]+=a;
						}
					}
					var closenIntensity:Number=0;
					var maxInstance:Number=CountIntensity[0];
					for (i = 1; i < arraylen; i++)
					{
						if (CountIntensity[i] > maxInstance)
						{
							closenIntensity = i;
							maxInstance = CountIntensity[i];
						}
					}
					a = int(AlphaAverage[closenIntensity] / maxInstance);
					r = int(RedAverage[closenIntensity] / maxInstance);
					g = int(GreenAverage[closenIntensity] / maxInstance);
					b = int(BlueAverage[closenIntensity] / maxInstance);
					returnBitmapData.setPixel32(x, y, a * 16777216 + r * 65536 + g * 256 + b);
				}
			}
			return returnBitmapData;
		}
		
		/** PS里的颜色阈值效果 **/
		public static function thresholdFilter(source:BitmapData, threshold:uint = 128):BitmapData
		{
			var returnBitmapData:BitmapData = new BitmapData(source.width, source.height,true,0xFF000000);
			var pt:Point = new Point(0, 0);
			var rect:Rectangle = new Rectangle(0, 0,source.width,source.height);
			threshold=threshold<0?0:threshold>255?255:threshold;
			var thre:uint =  255 * 0xFFFFFF + threshold * 0xFFFF + threshold * 0xFF + threshold;
			var color:uint = 0x00FFFFFF;
			var maskColor:uint = 0xFFFFFFFF;
			returnBitmapData.threshold(source, rect, pt, ">", thre, color, maskColor, false);
			return returnBitmapData;
		}
		
		/**
		 * 饱和度,不过看起来像对比度,我日
		 * @param	source
		 * @param	rp
		 * @param	gp
		 * @param	bp
		 */
		public static function saturation(source:BitmapData, rp:Number = 1, gp:Number = 1, bp:Number = 1):BitmapData
		{
			var matrix:Array = new Array();
			matrix = matrix.concat([rp, 0, 0, 0, 0]);// red
			matrix = matrix.concat([0, gp, 0, 0, 0]);// green
			matrix = matrix.concat([0, 0, bp, 0, 0]);// blue
			matrix = matrix.concat([0, 0, 0, 1, 0]);// alpha
			var filter:BitmapFilter = new ColorMatrixFilter(matrix);
			var sourceBitmap:Bitmap = new Bitmap(source);
			sourceBitmap.filters = [filter];
			var o:BitmapData = new BitmapData(sourceBitmap.width, sourceBitmap.height, true, 0x00FFFFFF);
			o.draw(sourceBitmap);
			return o;
		}
		
		/** 色彩调整 **/
		public static function colorTrans(source:BitmapData, ro:Number = 0, go:Number = 0, bo:Number = 0):BitmapData
		{
			var resultColorTransform:ColorTransform = new ColorTransform();
			resultColorTransform.redOffset = ro;
			resultColorTransform.greenOffset = go;
			resultColorTransform.blueOffset = bo;
			var sourceBitmap:Bitmap = new Bitmap(source);
			var sp:Sprite = new Sprite();
			sp.addChild(sourceBitmap);
			var sp2:Sprite = new Sprite();
			sp2.addChild(sp);
			sp.transform.colorTransform = resultColorTransform;
			var o:BitmapData = new BitmapData(sourceBitmap.width, sourceBitmap.height, true, 0x00FFFFFF);
			o.draw(sp2);
			sp2 = null;
			sp = null;
			sourceBitmap = null;
			return o;
		}
		
		/**
		 * 发光滤镜 - 边框发光 
		 * @param source
		 * @param color
		 * @param isLighting 是否 会有一个高亮的 效果
		 * @param alpha
		 * @param blurX
		 * @param blurY
		 * @param strength
		 * @param inner
		 * @return 
		 * 
		 */		
		public static function glowFilter(source:BitmapData, color:uint = 0xFF0000, isLighting:Boolean = true, alpha:Number = 1, blurX:Number = 6.0, blurY:Number = 6.0, strength:Number = 2, inner:Boolean = false):BitmapData
		{
			var gf:GlowFilter = new GlowFilter(color, alpha, blurX, blurY, strength, 1, inner);
			var sb:Bitmap = new Bitmap(source);
			sb.filters = [gf];
			var bmd:BitmapData = new BitmapData(sb.width, sb.height, true, 0x00FFFFFF);
			bmd.draw(sb);
			if (isLighting)
			{
				bmd.colorTransform(new Rectangle(0, 0, bmd.width, bmd.height), new ColorTransform(.75, .75, .75, 1, 75, 75, 75));
			}
			return bmd;
		}
		
		/**
		 *  
		 * @param source
		 * @param distance
		 * @param angle
		 * @param color
		 * @param alpha
		 * @param blurX
		 * @param blurY
		 * @param strength
		 * @param quality
		 * @param inner
		 * @param knockout
		 * @param hideObject
		 * @return 
		 * 
		 */		
		public static function dropShadowFilter(source:BitmapData, distance:Number = 4.0, angle:Number = 45, color:uint = 0, alpha:Number = 1.0, blurX:Number = 4.0, blurY:Number = 4.0, strength:Number = 1.0, quality:int = 1, inner:Boolean = false, knockout:Boolean = false, hideObject:Boolean = false):BitmapData
		{
			var sb:Bitmap = new Bitmap(source);
			sb.filters = [new DropShadowFilter(
				distance,
				angle,
				color,
				alpha,
				blurX,
				blurY,
				strength,
				quality,
				inner,
				knockout
			)];
			var bmd:BitmapData = new BitmapData(sb.width, sb.height, true, 0x00FFFFFF);
			bmd.draw(sb);
			return bmd;
		}
	}
}