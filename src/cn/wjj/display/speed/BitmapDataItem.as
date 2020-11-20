package cn.wjj.display.speed
{
	import cn.wjj.data.file.GBitmapData;
	import flash.display.BitmapData;
	
	/**
	 * 一个被截获的显示对象的BitmapData以及相对于原始的偏离坐标
	 * 
	 * @version 1.0.0
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 * @date 2011-12-12
	 */
	public class BitmapDataItem
	{
		/** x轴偏移 **/
		public var x:Number = 0;
		/** y轴偏移 **/
		public var y:Number = 0;
		/** 位图数据 **/
		private var data:BitmapData;
		/** 保存GBitmapData对象 **/
		public var gBitmapData:GBitmapData;
		
		public function BitmapDataItem():void { }
		
		/** 初始化 BitmapDataItem **/
		public static function instance():BitmapDataItem
		{
			return new BitmapDataItem();
		}
		
		/** 移除,清理,并回收 **/
		public function dispose():void
		{
			if (x != 0) x = 0;
			if (y != 0) y = 0;
			if (data != null) data = null;
			if (gBitmapData != null) gBitmapData = null;
		}
		
		public function get bitmapData():BitmapData 
		{
			if(data == null && gBitmapData)
			{
				var list:Object = gBitmapData.parent;
				if(list)
				{
					data = list.getPathObjRun(gBitmapData);
				}
				gBitmapData = null;
			}
			return data;
		}
		
		public function set bitmapData(value:BitmapData):void 
		{
			data = value;
		}
	}
}