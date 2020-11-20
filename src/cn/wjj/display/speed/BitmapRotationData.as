package cn.wjj.display.speed
{
	public class BitmapRotationData
	{
		/** 每一个旋转角度对应的Bitmap对象,这个对象从0 - 359之间 **/
		public var data:Vector.<BitmapRotationDataItem>;
		
		public function BitmapRotationData():void{}
		
		/**
		 * 获取特定幀的数据
		 * @param frameId
		 * @return 
		 */
		static public function getRotation(rotationData:BitmapRotationData , rotation:int):BitmapDataItem
		{
			var id:int = rotation % 360;
			return rotationData.data[id].data as BitmapDataItem;
		}
	}
}