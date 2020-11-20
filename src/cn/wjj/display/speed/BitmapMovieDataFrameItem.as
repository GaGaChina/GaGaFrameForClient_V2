package cn.wjj.display.speed
{
	/**
	 * 每一针的数据
	 * @author GaGa
	 */
	public class BitmapMovieDataFrameItem
	{
		/** MovieClip 的 currentLabel **/
		public var label:String;
		/** MovieClip 的 currentFrameLabel **/
		public var frameLabel:String;
		/** 显示对象的BitmapDataItem参数 **/
		public var data:BitmapDataItem;
		
		public function BitmapMovieDataFrameItem():void { }
		
		/** 初始化 BitmapDataItem **/
		public static function instance():BitmapMovieDataFrameItem
		{
			return new BitmapMovieDataFrameItem();
		}
		
		/** 移除,清理,并回收 **/
		public function dispose():void
		{
			if (this.data != null)
			{
				this.data.dispose();
				this.data = null;
			}
		}
	}
}