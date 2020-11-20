package cn.wjj.gagaframe.client.language
{
	import cn.wjj.display.speed.BitmapDataItem;
	import cn.wjj.display.speed.BitmapText;
	import cn.wjj.display.speed.BitmapTextField;
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.factory.FShape;
	import flash.display.Shape;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	
	/**
	 * 文本内容存放的仓库
	 */
	public class TextLib
	{
		/** 自动设置文本的对象 **/
		private var lib:Dictionary = new Dictionary(true);
		/** 自动设置BitmapText文本的对象 **/
		private var btlib:Dictionary = new Dictionary(true);
		/** 记录自动设置皮肤的对象,样式设置 **/
		private var fieldSkin:Dictionary = new Dictionary(true);
		/** 记录自动设置皮肤的有渐变色的遮罩对象,FShape,切回Shape **/
		internal var fieldMask:Dictionary = new Dictionary(true);
		/** 缓存文本字体的BitmapData,缓存用的BitmapDataItem, fieldCache[字体编号][文本内容] **/
		internal var fieldCache:Object = new Object();
		
		internal var bitmapLib:Dictionary = new Dictionary(true);
		
		/**
		 * 文本内容存放的仓库
		 * @param	frame	框架的引用
		 */
		public function TextLib() { }
		
		/**
		 * 设置一个文本,让他自动和某一个language的ID对象绑定
		 * @param textObj		TextField的文本引用(弱引用)
		 * @param languageId	语言的ID号
		 * @param setOver		[废弃]设置完毕后执行的函数
		 * @param args			语言ID下,如果有自动配置的%s替换参数
		 */
		public function setField(text:TextField, id:String, setOver:Function = null, ...args):void
		{
			if(g.language.config_change)
			{
				if(args.length)
				{
					var o:TextItem = new TextItem();
					o.id = id;
					o.info = args;
					lib[text] = o;
				}
				else
				{
					lib[text] = id;
				}
			}
			var i:Object = LanguageApi.CopyIdToSetText(g.language.allDefaultInfo, id);
			if(args.length)
			{
				LanguageApi.SetTextField(text, i, args);
			}
			else
			{
				LanguageApi.SetTextField(text, i);
			}
		}
		
		/**
		 * 设置一个BitmapTextField对象,让它和languageID绑定
		 * @param text
		 * @param id
		 * @param args
		 */
		public function setBitmapField(text:BitmapTextField , id:String , ...args):void
		{
			if(g.language.config_change)
			{
				var item:TextItem = new TextItem();
				item.id = id;
				item.info = args;
				lib[text] = item;
			}
			var info:Object = LanguageApi.CopyIdToSetText(g.language.allDefaultInfo, id);
			LanguageApi.SetBitmapField(text, info, args);
		}
		
		/**
		 * 获取一个文本的内容
		 * @param	id
		 * @param	...args
		 */
		public function getBitmapField(id:String, ...args):BitmapText
		{
			var key:String = LanguageApi.getBitmapTextKey(id, args);
			var b:*;
			var jl:BitmapText;
			if(key)
			{
				for(b in bitmapLib)
				{
					if(bitmapLib[b] == key)
					{
						jl = new BitmapText(b);
						break;
					}
				}
			}
			var info:Object = LanguageApi.CopyIdToSetText(g.language.allDefaultInfo, id);
			if (jl == null)
			{
				b = LanguageApi.getTextBitmap(info, args);
				bitmapLib[b] = key;
				jl = new BitmapText(b);
			}
			if(g.language.config_change)
			{
				var item:TextItem = new TextItem();
				item.id = id;
				item.info = args;
				this.btlib[jl] = item;
			}
			if(info.hasOwnProperty("x") && jl.x != info.x)
			{
				jl.x = info.x;
			}
			if(info.hasOwnProperty("y") && jl.y != info.y)
			{
				jl.y = info.y;
			}
			return jl;
		}
		
		/** 清理设置的Text内容 **/
		internal function removeField(text:TextField):void
		{
			text.filters = null;
			text.text = "";
			text.cacheAsBitmap = false;
			text.mask = null;
			var c:Shape = fieldMask[text] as Shape;
			if (c)
			{
				if (c.parent) c.parent.removeChild(c);
				c.graphics.clear();
				delete fieldMask[text];
			}
			if(g.language.config_change)
			{
				delete lib[text];
				delete fieldSkin[text];
			}
		}
		
		/**
		 * 设置一个文本框的皮肤,字体
		 * @param textObj			TextField的文本引用(弱引用)
		 * @param fontId			字体的ID号
		 * @param fontFormatId		字体fontFormat的ID号
		 */
		public function setFieldSkin(t:TextField , id:String = "" , formatId:String = ""):void
		{
			var o:Object;
			if(formatId != "")
			{
				o = LanguageApi.CopyIdToSetText(g.language.allDefaultInfo, "", formatId);
			}
			else
			{
				o = new Object();
			}
			if(id != "")
			{
				o.fontId = id;
			}
			if(g.language.config_change)
			{
				fieldSkin[t] = o;
			}
			LanguageApi.SetTextField(t, o);
		}
		
		/**
		 * 设置文本框使用多语言中的某一个字体的内容
		 * @param	text	文本框
		 * @param	id		多语言字体id
		 * @param	format	基础文本格式,如果要用新的TextFormat,必须new TextFormat(),传入null会保留原始样式
		 */
		public function setFieldFont(text:TextField, id:String = "", format:TextFormat = null):void
		{
			LanguageApi.setFieldFont(text, id, format);
		}
		
		/** 将以前设置的文本从新在设置一下 **/
		public function reSetAllText():void
		{
			if(g.language.config_change)
			{
				var temp:*;
				for(temp in lib)
				{
					if(temp is TextField)
					{
						setFieldUseLib(temp as TextField);
					}
					else if(temp is BitmapTextField)
					{
						setBitmapFieldUseLib(temp as BitmapTextField);
					}
				}
				for(temp in fieldSkin)
				{
					setFieldUseLib(temp as TextField);
				}
			}
		}
		
		/**
		 * 设置库里的一个特定文本的内容
		 * @param textObj
		 */
		public function setFieldUseLib(t:TextField):void
		{
			var temp:TextItem = lib[t] as TextItem;
			if(temp)
			{
				var info:Object = LanguageApi.CopyIdToSetText(g.language.allDefaultInfo, temp.id);
				LanguageApi.SetTextField(t, info, temp.info);
			}
		}
		
		/**
		 * 设置库里的一个特定文本的内容
		 * @param textObj
		 */
		public function setBitmapFieldUseLib(t:BitmapTextField):void
		{
			if(lib[t])
			{
				var temp:TextItem = lib[t] as TextItem;
				var info:Object = LanguageApi.CopyIdToSetText(g.language.allDefaultInfo, temp.id);
				LanguageApi.SetBitmapField(t, info, temp.info);
			}
		}
		
		/** 查看内容是不是单行 **/
		private function hasTheStr(str:String, theStr:String):Boolean
		{
			/** 原始文本长度 **/
			var l:int = str.length;
			for (var j:int = (theStr.length - 1); j < l; j++)
			{
				if (str.substr((j - 1), theStr.length) == theStr)
				{
					return true;
				}
			}
			return false;
		}
		/**
		 * 
		 * @param	str
		 * @param	languageId
		 * @return
		 */
		public function getCacheData(str:String, skinId:String, smoothing:Boolean = false):BitmapDataItem
		{
			if (fieldCache.hasOwnProperty(skinId) && fieldCache[skinId] is Object)
			{
				if (fieldCache[skinId].hasOwnProperty(str))
				{
					if (fieldCache[skinId][str] is BitmapDataItem)
					{
						return fieldCache[skinId][str];
					}
				}
			}
			else
			{
				fieldCache[skinId] = new Object();
			}
			fieldCache[skinId][str] = g.language.cacheCharData(str, skinId, smoothing);
			return fieldCache[skinId][str];
		}
		
		/**
		 * 清理全部的缓存内容,腾出内存
		 * @param	str
		 * @param	languageId
		 * @return
		 */
		public function delAllCacheData():void
		{
			var o:Object;
			var s:String;
			var b:BitmapDataItem;
			for(var id:String in fieldCache)
			{
				o = fieldCache[id];
				for(s in o)
				{
					b = o[s] as BitmapDataItem;
					b.bitmapData.dispose();
					b.dispose();
					delete o[s];
				}
				delete fieldCache[id];
			}
		}
	}
}