package cn.wjj.display.speed
{
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.utils.Dictionary;

	/**
	 * 所有的Display或者Dispaly的Class对象都存这里
	 * @author GaGa
	 */
	public class BitmapDisplayLib
	{
		/** 缩放级别 **/
		static private var scaleLib:Object = new Object();
		
		/**
		 * 通过一个对象获取到这个BitmapDataItem对象
		 * @param obj			要抽取的object对象,可以是Display对象的Class或者实例
		 * @param saveThis		是否在内存里存储,以便下次可以快速抽取内容
		 * @param scale			缩放级别
		 * @param smoothing
		 * @param quality
		 * @param pushInLib
		 */
		static public function getBitmap(obj:* , saveThis:Boolean = true, scale:Number = 1, smoothing:Boolean = true, quality:String = "best", pushInLib:Boolean = true):BitmapDataItem
		{
			if (obj == null)
			{
				return null;
			}
			if(saveThis)
			{
				var s:String = String(scale);
				if (!scaleLib.hasOwnProperty(s))
				{
					scaleLib[s] = new Object();
					scaleLib[s].isLink = new Dictionary();
					scaleLib[s].noLink = new Dictionary(true);
				}
				if (scaleLib[s].noLink[obj] != null)
				{
					return scaleLib[s].noLink[obj] as BitmapDataItem;
				}
				else if (scaleLib[s].isLink[obj] != null)
				{
					return scaleLib[s].isLink[obj] as BitmapDataItem;
				}
			}
			var tempData:BitmapDataItem;
			var dispaly:DisplayObject;
			if (obj is DisplayObject)
			{
				dispaly = obj;
			}
			else if (obj is Class)
			{
				dispaly = new obj();
			}
			if (dispaly is DisplayObject)
			{
				tempData = GetBitmapData.cacheBitmap(dispaly, true, 0x00000000, scale, smoothing, quality, pushInLib);
				if (tempData && saveThis)
				{
					if (obj is Class)
					{
						//如果对象是类,强制记录起来
						scaleLib[s].isLink[obj] = tempData;
						return tempData;
					}
					if (saveThis)
					{
						//这里用的强引用,不自动是怎么考虑的
						scaleLib[s].isLink[obj] = tempData;
					}
					else
					{
						scaleLib[s].noLink[obj] = tempData;
					}
				}
				return tempData;
			}
			return null;
		}
	}
}