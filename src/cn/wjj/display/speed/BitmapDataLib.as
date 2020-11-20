package cn.wjj.display.speed
{
	import cn.wjj.crypto.CRC32;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	/**
	 * 所有的BitmapData的集合,保证相同的BitmapData是不同的,一样的BitmapData
	 * @author GaGa
	 * BitmapDataLib.getID
	 */
	public class BitmapDataLib
	{
		/** 库 **/
		private static var lib:Dictionary = new Dictionary(true);
		/** 临时变量 **/
		private static var r:Rectangle = new Rectangle();
		
		/**
		 * 这里要比较二个二进制的数据,这个还在思考,好像很难哦~~~NND~~~
		 * @param bitmapData
		 * @return 
		 */
		static public function push(data:BitmapData):BitmapData
		{
			if (data)
			{
				r.width = data.width;
				r.height = data.height;
				var byte:ByteArray = data.getPixels(r);
				var id:uint = CRC32.getCRC32(byte);
				for(var temp:* in lib)
				{
					if(lib[temp] == id)
					{
						return temp as BitmapData;
					}
				}
				lib[data] = id;
			}
			return data;
		}
		
		static public function getID(data:BitmapData):uint
		{
			if(data && lib[data])
			{
				return lib[data];
			}
			return 0;
		}
	}
}