package cn.wjj.display.speed
{
	/**
	 * 一个矩阵的全部数据
	 */
	public class BitmapGridData
	{
		/** 行数 **/
		public var row:int;
		/** 列数 **/
		public var column:int;
		/** 有效区域宽 **/
		public var validWidth:int;
		/** 有效区域高 **/
		public var validHeight:int;
		/** 格子宽 **/
		public var gridWidth:int;
		/** 格子高 **/
		public var gridHeight:int;
		/** 分块位图数据二维数组，第一维是行，第二维是列 **/
		public var gridBitDataArray:Array;
		
		public function BitmapGridData():void{}
	}
}