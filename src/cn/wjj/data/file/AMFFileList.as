package cn.wjj.data.file 
{
	
	/**
	 * AMF列表管理
	 * 自动获取MD5
	 * 
	 * @version 1.0.0
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 */
	public class AMFFileList extends GListBase
	{
		public function AMFFileList():void
		{
			type = GFileType.AMFList;
		}
		
		/**
		 * 通过子对象的name来获取到AMFFile
		 * @param	itemName
		 * @return
		 */
		public function getItem(path:String):AMFFile
		{
			var item:GFileBase = getPath(path);
			if (item && item is GFileBase)
			{
				return item as AMFFile;
			}
			return null;
		}
		
		/**
		 * 将里面的全部的对象数据用name的方式,添加到obj里
		 * @param	obj
		 */
		public function setAlltoObj(obj:Object):void
		{
			for each (var item:GFileBase in list) 
			{
				obj[item.name] = item.obj;
			}
		}
		
		/**
		 * 将这个对象以内容形式输出Object对象
		 * @return 
		 */
		public function getAllObj():Object
		{
			var o:Object = new Object();
			setAlltoObj(o);
			return o;
		}
	}
}