package cn.wjj.display.speed
{
	
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.utils.Dictionary;

	/**
	 * 所有的Moive,或者Movie的Class对象都存这里
	 * @author GaGa
	 */
	public class BitmapMovieLib
	{
		
		/** 弱引用的对象引用 **/
		static private var lib:Dictionary = new Dictionary(true);
		/** 带记忆功能的对象引用 **/
		static private var libLink:Dictionary = new Dictionary();
		
		/**
		 * 通过一个对象获取到这个BitmapMovieData对象
		 * @param obj					要抽取的object对象,可以是Display对象的Class或者实例
		 * @param saveThis				是否在内存里存储,以便下次可以快速抽取内容
		 * @param	directBitData		如果本幀只有一个Bitmap就取出BitmapData信息
		 * @return 
		 */
		static public function getBitmap(obj:*, saveThis:Boolean = true, directBitData:Boolean = false):BitmapMovieData
		{
			if (lib[obj] != null)
			{
				return lib[obj] as BitmapMovieData;
			}
			else if (libLink[obj] != null)
			{
				return libLink[obj] as BitmapMovieData;
			}
			var tempData:BitmapMovieData;
			var isClass:Boolean = false;
			var mc:MovieClip;
			if (obj is MovieClip)
			{
				mc = obj;
			}
			else
			{
				isClass = true;
				mc = new obj();
			}
			if (mc is MovieClip)
			{
				//dispaly.scaleX = scale;
				//dispaly.scaleY = scale;
				tempData = GetBitmapData.display(mc, true, 0x00000000, mc.scaleX, directBitData);
				if(tempData){
					if (isClass)
					{
						//是类的话,就自动记录起来
						libLink[obj] = tempData;
						return tempData;
					}
					if (saveThis)
					{
						//这里用的强引用,不自动是怎么考虑的
						libLink[obj] = tempData;
					}
					return tempData;
				}
			}
			return null;
		}
	}
}