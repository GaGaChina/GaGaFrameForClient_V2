package cn.wjj.display.speed
{
	
	import cn.wjj.g;
	import flash.display.Bitmap;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.utils.getQualifiedClassName;

	public class GaGaSpeed
	{
		
		/**配置:是否开始播放里面的MovieClip等**/
		public static var config_Play:Boolean = true;
		/** 配置:移出场景是否显示(没实现) **/
		public static var config_MoveOutDispaly:Boolean = false;
		/**配置:是否剥离系统幀频率,强制刷新场景**/
		public static var config_RefreshDispaly:Boolean = true;
		
		/**
		 * 通过一个MovieClip的类或者是MovieClip实例获取一个BitmapMovie对象.
		 * @param movieDisplayOrClass
		 * @param fps
		 * @return 
		 */
		public static function getBitmapMovie(movieDisplayOrClass:*, fps:int = -1):BitmapMovie
		{
			return BitmapMovie.create(movieDisplayOrClass, fps);
		}
		
		/**
		 * 通过一个显示对象或者一个显示对象的类中,获取这个对象的BitmapSprite对象
		 * @param displayOrClass	
		 * @param saveThis			是否在内存里存储,以便下次可以快速抽取内容
		 * @param scale				缓存的比例
		 * @return
		 */
		public static function getDisplayBitmap(displayOrClass:*, saveThis:Boolean = true, scale:Number = 1):BitmapSprite
		{
			return BitmapSprite.create(displayOrClass, saveThis, scale);
		}
		
		/**
		 * 从一个Display对象或BitmapData数据或它的类中获取一个GridMovie对象
		 * @param bitmapDisplayOrClass		Display对象或者是它的类
		 * @param gridWidth					每一帧的宽度
		 * @param gridHeight				每一帧的高度
		 * @param fps						播放的速度
		 * @return 
		 * 
		 */
		public static function getBitmapGrid(bitmapDisplayOrClass:*, gridWidth:int, gridHeight:int, fps:int = -1):GridMovie
		{
			if(bitmapDisplayOrClass is Class || bitmapDisplayOrClass is DisplayObject || bitmapDisplayOrClass is BitmapData)
			{
				var bitmapData:BitmapGridData = BitmapGridLib.getBitmap(bitmapDisplayOrClass,gridWidth,gridHeight);
				if(bitmapData == null)
				{
					g.log.pushLog(GaGaSpeed, g.logType._Frame,"getBitmapGrid 未获取到任何 BitmapGridData !");
				}
				else
				{
					return new GridMovie(bitmapData, fps);
				}
				return null;
			}
			else
			{
				g.log.pushLog(GaGaSpeed, g.logType._Frame,"getBitmapGrid 参数必须是一个DisplayObject的类或者是DisplayObject实例!");
				return null;
			}
		}
		
		/**
		 * 从一个Display对象或BitmapData数据或它的类中获取一个GridMovie对象(通过横列的数量来获取)
		 * @param bitmapDisplayOrClass
		 * @param rowNumber
		 * @param columnNumber
		 * @param fps
		 * @return 
		 */
		public static function getBitmapGridUseNumber(bitmapDisplayOrClass:*, rowNumber:int, columnNumber:int, fps:int = -1):GridMovie
		{
			if(bitmapDisplayOrClass is Class || bitmapDisplayOrClass is DisplayObject || bitmapDisplayOrClass is BitmapData)
			{
				var bitmapData:BitmapGridData = BitmapGridLib.getBitmapUseNumber(bitmapDisplayOrClass,rowNumber,columnNumber);
				if(bitmapData == null)
				{
					g.log.pushLog(GaGaSpeed, g.logType._Frame,"getBitmapGrid 未获取到任何 BitmapGridData !");
				}
				else
				{
					return new GridMovie(bitmapData, fps);
				}
				return null;
			}
			else
			{
				g.log.pushLog(GaGaSpeed, g.logType._Frame,"getBitmapGrid 参数必须是一个DisplayObject的类或者是DisplayObject实例!");
				return null;
			}
		}
	}
}