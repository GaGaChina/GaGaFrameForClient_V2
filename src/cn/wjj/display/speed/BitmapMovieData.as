package cn.wjj.display.speed
{
	
	/**
	 * MovieClip的数据保存的地方,一个MovieClip的Class或者一个MovieClip对象存放的地方
	 * 由一堆BitmapMovieDataItem组成
	 * 
	 * new Vector.<Object>(10,true)
	 * 例如 : data[1].label = "这个东西";
	 *        data[1].labelStart = true;
	 *        data[1].info = BitmapMovieDataItem
	 * 
	 * @version 1.0.0
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 */
	public class BitmapMovieData
	{
		/** 每一幀对应的Bitmap对象,这个对象从0开始 **/
		public var data:Vector.<BitmapMovieDataFrameItem>;
		/** 偏移缩放X,要放大一倍变正常就是 2 **/
		public var scaleX:Number = 1;
		/** 偏移缩放Y **/
		public var scaleY:Number = 1;
		
		public function BitmapMovieData():void { }
		
		/** 初始化 BitmapDataItem **/
		public static function instance():BitmapMovieData
		{
			return new BitmapMovieData();
		}
		
		/** 移除,清理,并回收 **/
		public function dispose():void
		{
			if (this.data != null)
			{
				for each (var item:BitmapMovieDataFrameItem in this.data) 
				{
					item.dispose();
				}
				this.data = null;
			}
		}
	}
}