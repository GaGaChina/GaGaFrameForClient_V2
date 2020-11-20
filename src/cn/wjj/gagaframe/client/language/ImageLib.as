package cn.wjj.gagaframe.client.language
{
	
	import cn.wjj.g;
	import flash.display.Bitmap;
	import flash.utils.Dictionary;
	
	/**
	 * 多语言包里的图形管理对象
	 * 
	 * @version 0.5.0
	 * @author GaGa wjjhappy@Gmail.com
	 * @copy 王加静 www.5ga.cn
	 * @date 2012-03-15
	 */
	public class ImageLib
	{
		/** 自动设置文本的对象 **/
		private var lib:Dictionary = new Dictionary(true);
		
		public function ImageLib() { }
		
		/**
		 * 设置一个Bitmap,让他自动和某一个language的ID对象绑定
		 * @param textObj
		 * @param languageId
		 * @param setOver
		 */
		public function setBitmap(img:Bitmap, id:String, setOver:Function = null):void
		{
			if(g.language.config_change)
			{
				var temp:ImgItem = new ImgItem();
				temp.run = setOver;
				temp.id = id;
				lib[img] = temp;
			}
			if(g.language.allDefaultInfo.img.hasOwnProperty(id))
			{
				LanguageApi.SetBitmap(img, g.language.allDefaultInfo.img[id], setOver);
			}
		}
		
		/** 将以前设置的文本从新在设置一下 **/
		public function reSetAllImg():void
		{
			for each(var img:* in lib)
			{
				setImgUseLib(img as Bitmap);
			}
		}
		
		/**
		 * 设置库里的一个特定文本的内容
		 * @param textObj
		 * 
		 */
		public function setImgUseLib(img:Bitmap):void
		{
			if(lib[img])
			{
				var o:ImgItem = lib[img] as ImgItem;
				if(g.language.allDefaultInfo.img.hasOwnProperty(o.id))
				{
					LanguageApi.SetBitmap(img, g.language.allDefaultInfo.img[o.id], o.run);
				}
			}
		}
	}
}