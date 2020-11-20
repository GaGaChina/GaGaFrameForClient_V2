package cn.wjj.display.speed
{
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.utils.Dictionary;

	/**
	 * 所有的Moive,或者Movie的Class对象都存这里
	 * @author GaGa
	 */
	public class BitmapGridLib
	{
		/** 弱引用的对象引用,对象的引用 **/
		static private var bitmapLib:Dictionary = new Dictionary(true);
		/** 带记忆功能的对象引用,类对象默认都记录在这里 **/
		static private var bitmapLibLink:Dictionary = new Dictionary();
		
		
		static public function getBitmapUseNumber(obj:* ,rowNumber:int, columnNumber:int, saveThis:Boolean = true):BitmapGridData
		{
			var gridWidth:int,gridHeight:int;
			var dispaly:DisplayObject;
			if(obj is Class)
			{
				var newObj:* = new obj();
				if(newObj is BitmapData)
				{
					dispaly = new Bitmap(newObj);
				}
				else
				{
					dispaly = newObj;
				}
			}
			else if(obj is DisplayObject)
			{
				dispaly = obj;
			}
			if(dispaly)
			{
				gridWidth = dispaly.width / rowNumber;
				gridHeight = dispaly.height / columnNumber;
				return getBitmap(obj,gridWidth,gridHeight,saveThis);
			}
			return null;
		}
		
		/**
		 * 通过一个对象获取到这个BitmapMovieData对象
		 * @param obj			要抽取的object对象,可以是Display对象的Class或者实例
		 * @param saveThis		是否在内存里存储,以便下次可以快速抽取内容
		 * @return 
		 */
		static public function getBitmap(obj:* ,gridWidth:int, gridHeight:int, saveThis:Boolean = true):BitmapGridData
		{
			if(bitmapLib[obj] != null)
			{
				return bitmapLib[obj] as BitmapGridData;
			}
			else if(bitmapLibLink[obj] != null)
			{
				return bitmapLibLink[obj] as BitmapGridData;
			}
			var tempData:BitmapGridData;
			var isSaveThis:Boolean = false;
			var dispaly:DisplayObject;
			if(obj is Class)
			{
				isSaveThis = true;
				var newObj:* = new obj();
				if(newObj is BitmapData)
				{
					dispaly = new Bitmap(newObj);
				}
				else
				{
					dispaly = newObj;
				}
			}
			else if(obj is DisplayObject)
			{
				dispaly = obj;
			}
			if(dispaly is DisplayObject)
			{
				tempData = GetBitmapData.gridBitmap(dispaly, gridWidth, gridHeight);
				if(tempData)
				{
					if(isSaveThis)
					{
						//是类的话,就自动记录起来
						bitmapLibLink[obj] = tempData;
						return tempData;
					}
					if(saveThis)
					{
						//这里用的强引用,不自动是怎么考虑的
						bitmapLibLink[obj] = tempData;
					}
					return tempData;
				}
			}
			return null;
		}
	}
}