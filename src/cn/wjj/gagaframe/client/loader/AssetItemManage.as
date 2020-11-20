package cn.wjj.gagaframe.client.loader
{
	import cn.wjj.data.CustomByteArray;
	import cn.wjj.data.file.AMFFile;
	import cn.wjj.data.file.AMFFileList;
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	import cn.wjj.gagaframe.client.speedfact.SByte;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.system.ApplicationDomain;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	
	/**
	 * 对象资源的总管理类
	 * 
	 * @version 0.0.5
	 * @author GaGa wjjhappy@Gmail.com
	 * @copy 王加静 www.5ga.cn
	 */
	public class AssetItemManage
	{
		/** [强引用]单例对象,不会被释放掉 **/
		private var onlyOneObject:Dictionary = new Dictionary();
		/** [弱引用]单例对象, 可以被释放放掉 **/
		private var onlyOneObjectLink:Dictionary = new Dictionary(true);
		/** 下载的资源集合,记录别名和对象的映射,因为这个不能存硬盘,所有必须要缓存到内存里 **/
		private var libAsset:Object = new Object();
		
		public function AssetItemManage():void { }
		
		/**
		 * 查询资源库,将对应的对象AssetItem输出出来.
		 * 
		 * @param info		查询的内容
		 * @param useName	true:使用Asset名称,false:使用url地址
		 * @return 
		 */
		public function getAssetItem(info:String, useName:Boolean = true):AssetItem
		{
			if(useName)
			{
				return libAsset[info];
			}
			else
			{
				for each(var temp:AssetItem in this.libAsset)
				{
					if(temp.file && temp.file.url == info)
					{
						return temp;
					}
				}
			}
			return null;
		}
		
		/**
		 * 通过一个item,当是only的时候,查询设置强弱引用,如果已经设置值就返回Dictionary引用的值
		 * @param item
		 * @return 
		 */
		private function assetGetOnlyDict(item:AssetItem):Dictionary
		{
			if(item.isOnly)
			{
				if(item.isOnlyLink)
				{
					if(onlyOneObjectLink[item])
					{
						onlyOneObject[item] = onlyOneObjectLink[item];
						delete onlyOneObjectLink[item];
					}
					return onlyOneObject;
				}
				else
				{
					if(onlyOneObject[item])
					{
						onlyOneObjectLink[item] = onlyOneObject[item];
						delete onlyOneObject[item];
					}
					return onlyOneObjectLink;
				}
			}
			return null;
		}
		
		/**
		 * 新建一个文件的Item,如果没有这个对象,就创建一个
		 * @param url
		 * @return 
		 */
		public function newAssetItem(name:String):AssetItem
		{
			if(name.length > 0)
			{
				var item:AssetItem = getAssetItem(name);
				if(item == null)
				{
					item = new AssetItem();
					item.name = name;
					libAsset[item.name] = item;
					return item;
				}
				return item;
			}
			return null;
		}
		
		/**
		 * 当一个资源载入完毕的时候运行
		 * @param	info		资源Asset的名称
		 * @param	useName		true:使用Asset名称,false:使用url地址
		 * @param	method		资源下载完毕时要执行的函数.
		 */
		public function assetFinishRun(info:String, useName:Boolean = true, method:Function = null):Item
		{
			var item:AssetItem = getAssetItem(info, useName);
			if(item)
			{
				if (item.data == null)
				{
					var loadItem:Item = g.loader.getItem(item.name);
					if (loadItem)
					{
						if (loadItem.isComplete)
						{
							method();
							return loadItem;
						}
						if (loadItem.isGetToLoad)
						{
							loadItem.isGetToLoad = false;
							if(g.loader.isLog)
							{
								g.log.pushLog(this, LogType._Frame, "一个余载的内容转换为必载内容URL:" + item.file.url);
							}
						}
						if(method != null)
						{
							loadItem.onComplete(method);
						}
						loadItem.start();
					}
					return loadItem;
				}
				else
				{
					method();
				}
			}
			else
			{
				g.log.pushLog(this, LogType._ErrorLog, "没有获取到对应的Asset资源:" + info);
			}
			return null;
		}
		
		/**
		 * 获取一个Asset的图片内容,得到一个BitmapData对象
		 * @param info
		 * @param useName	true:使用Asset名称,false:使用url地址
		 * @return 
		 */
		public function getAssetBitmapData(info:String, useName:Boolean = true):BitmapData
		{
			var item:AssetItem = getAssetItem(info, useName);
			if(item)
			{
				if(item.data is Class)
				{
					var c:Class = item.data as Class;
					item.data = new c();
				}
				if(item.data is BitmapData)
				{
					return item.data as BitmapData;
				}
				else if(item.data is Bitmap)
				{
					return (item.data as Bitmap).bitmapData;
				}
			}
			return null;
		}
		
		/**
		 * 获取一个Asset的图片内容,得到一个Bitmap对象
		 * @param info
		 * @param useName	true:使用Asset名称,false:使用url地址
		 * @return 
		 */
		public function getAssetImage(info:String, useName:Boolean = true):Bitmap
		{
			
			var item:AssetItem = getAssetItem(info, useName);
			if(item)
			{
				if(item.data is Class)
				{
					var c:Class = item.data as Class;
					item.data = new c();
				}
				var only:Dictionary = assetGetOnlyDict(item);
				if(only && only[item])
				{
					return only[item] as Bitmap;
				}
				else
				{
					var tempData:BitmapData = item.data as BitmapData;
					var bitmap:Bitmap = new Bitmap(tempData);
					if(only)
					{
						only[item] = bitmap;
					}
					return bitmap;
				}
			}
			return null;
		}
		
		/** 获取一个Asset的JSON转换Object后的对象 **/
		public function getAssetJSON(info:String, useName:Boolean = true):Object
		{
			var item:AssetItem = getAssetItem(info, useName);
			if(item)
			{
				var only:Dictionary = assetGetOnlyDict(item);
				if(only && only[item])
				{
					return only[item] as Object;
				}
				else
				{
					var obj:Object = g.jsonGetObj(item.data);
					if(only)
					{
						only[item] = obj;
					}
					return obj;
				}
			}
			return null;
		}
		
		/** 获取一个Asset的String转换XML后的对象 **/
		public function getAssetXML(info:String, useName:Boolean = true):XML
		{
			var item:AssetItem = getAssetItem(info, useName);
			if(item)
			{
				var only:Dictionary = assetGetOnlyDict(item);
				if(only && only[item])
				{
					return only[item] as XML;
				}
				else
				{
					var xml:XML = new XML(item.data);
					if(only)
					{
						only[item] = xml;
					}
					return xml;
				}
			}
			return null;
		}
		
		/** 获取一个Asset的AMFFile的对象 **/
		public function getAssetAMFFile(info:String, useName:Boolean = true):AMFFile
		{
			var item:AssetItem = getAssetItem(info, useName);
			if(item)
			{
				var only:Dictionary = assetGetOnlyDict(item);
				if(only && only[item])
				{
					return only[item] as AMFFile;
				}
				else
				{
					var temp:AMFFile = new AMFFile();
					var byte:SByte = SByte.instance();
					byte.writeBytes(item.data);
					byte.position = 0;
					temp.setByte(byte);
					if(only)
					{
						only[item] = temp;
					}
					return temp;
				}
			}
			return null;
		}
		
		/** 获取一个Asset的AMFFileList的对象 **/
		public function getAssetAMFFileList(info:String, useName:Boolean = true):AMFFileList
		{
			var item:AssetItem = getAssetItem(info, useName);
			if(item)
			{
				var only:Dictionary = assetGetOnlyDict(item);
				if(only && only[item])
				{
					return only[item] as AMFFileList;
				}
				else
				{
					var temp:AMFFileList = new AMFFileList();
					var byte:SByte = SByte.instance();
					byte.writeBytes(item.data);
					temp.setByte(byte);
					if(only)
					{
						only[item] = temp;
					}
					return temp;
				}
			}
			return null;
		}
		
		/** 获取一个Asset的一个二进制的对象 **/
		public function getAssetCustomByte(info:String, useName:Boolean = true):CustomByteArray
		{
			var item:AssetItem = getAssetItem(info, useName);
			if(item)
			{
				var only:Dictionary = assetGetOnlyDict(item);
				if(only && only[item])
				{
					return only[item] as CustomByteArray;
				}
				else
				{
					var byte:CustomByteArray = new CustomByteArray();
					byte.writeBytes(item.data);
					byte.position = 0;
					if(only)
					{
						only[item] = byte;
					}
					return byte;
				}
			}
			return null;
		}
		
		/** 获取一个Asset获取它的Font对象 **/
		public function getAssetFont(info:String, useName:Boolean = true):Font
		{
			var item:AssetItem = getAssetItem(info, useName);
			if(item)
			{
				var tempClass:Class;
				if(item.data is Font)
				{
					return item.data;
				}
				tempClass = item.data;
				Font.registerFont(tempClass);
				item.data = new tempClass() as Font;
				return item.data;
			}
			return null;
		}
		
		/**
		 * 
		 * @param textField
		 * @param info
		 * @param useName
		 */
		public function setTextFont(textField:TextField, info:String, useName:Boolean = true):void
		{
			var tempFont:Font = getAssetFont(info,useName);
			var textFormat:TextFormat = new TextFormat();
			textFormat.font = tempFont.fontName;
			textField.embedFonts = true;
			textField.defaultTextFormat = textFormat;
			textField.setTextFormat(textFormat);
		}
		
		/** 获取一个Asset的Class对象,已经被实例化后的 **/
		public function getAssetClassObj(info:String, useName:Boolean = true):*
		{
			var item:AssetItem = getAssetItem(info, useName);
			if(item)
			{
				var only:Dictionary = assetGetOnlyDict(item);
				if(only && only[item])
				{
					return only[item];
				}
				else
				{
					var obj:*;
					if(!(item.data is Class))
					{
						item.data = getLocalClassBase(item.config_className);
					}
					if(item.data is Class)
					{
						var tempClass:Class = item.data;
						obj = new tempClass();
						if(only)
						{
							only[item] = obj;
						}
						return obj;
					}
					else
					{
						if(g.loader.isLogError)
						{
							g.log.pushLog(this, LogType._ErrorLog, "getAssetClassObj " + info + " item.data 并不是Class");
						}
					}
				}
			}
			else
			{
				if(g.loader.isLogError)
				{
					g.log.pushLog(this, LogType._ErrorLog, "getAssetClassObj 并未获取到 : " + info);
				}
			}
			return null;
		}
		
		/** 获取一个Asset的Class **/
		public function getAssetClass(info:String, useName:Boolean = true):Class
		{
			var item:AssetItem = getAssetItem(info, useName);
			if(item)
			{
				if(item.data is Class)
				{
					return item.data;
				}
			}
			return null;
		}
		
		/** 获取一个AssetLib的Class转换完的对象 **/
		public function getAssetLibClassObj(classAllName:String, info:String, useName:Boolean = true):*
		{
			var temp:* = getAssetLibData(classAllName, info, useName);
			if(temp && temp is Class)
			{
				return new temp();
			}
			return null;
		}
		
		/** 获取一个AssetLib的对象不进行NEW操作,直接取出来 **/
		public function getAssetLibData(classAllName:String, info:String, useName:Boolean = true):*
		{
			var item:AssetItem = getAssetItem(info, useName);
			if(item)
			{
				var temp:*;
				if(item.data is Loader)
				{
					try
					{
						return (item.data as Loader).contentLoaderInfo.applicationDomain.getDefinition(classAllName);;
					}
					catch (e:Error)
					{
						if (g.loader.isLog || g.loader.isLogError)
						{
							g.log.pushLog(this, LogType._ErrorLog, "抽取文件错误 : " + item.name + " className:" + classAllName + " SMG : " + e.toString());
						}
					}
				}
				else if(item.data is ApplicationDomain)
				{
					try
					{
						return (item.data as ApplicationDomain).getDefinition(classAllName);
					}
					catch (e:Error)
					{
						if (g.loader.isLog || g.loader.isLogError)
						{
							g.log.pushLog(this, LogType._ErrorLog, "抽取文件错误 : " + item.name + " className:" + classAllName + " SMG : " + e.toString());
						}
					}
				}
				else if(item.data === g.bridge.root)
				{
					try
					{
						temp = getDefinitionByName(classAllName) as Class;
						if(temp == null)
						{
							temp = g.bridge.root.contentLoaderInfo.applicationDomain.getDefinition(classAllName) as Class;
						}
						if (g.loader.isLog)
						{
							g.log.pushLog(this, LogType._Frame, "g.bridge.root 抽取文件成功 : " + item.name + " className:" + classAllName);
						}
						return temp;
					}
					catch (e:Error)
					{
						if (g.loader.isLog || g.loader.isLogError)
						{
							g.log.pushLog(this, LogType._ErrorLog, "g.bridge.root 抽取文件错误 : " + item.name + " className:" + classAllName + " SMG : " + e.toString());
						}
					}
				}
			}
			return null;
		}
		
		/** 删除一个数据对象 **/
		public function delAssetItem(info:String, useName:Boolean = true):void
		{
			var temp:AssetItem = getAssetItem(info, useName);
			if(temp)
			{
				delete libAsset[temp.name];
				if(onlyOneObject[temp])
				{
					delete onlyOneObject[temp];
				}
				if(onlyOneObjectLink[temp])
				{
					delete onlyOneObjectLink[temp];
				}
			}
		}
		
		/**
		 * 从swf的根目录下获取类,基本的Class
		 * @param allClassName
		 * @return 
		 */
		public function getLocalClassBase(className:String):Class
		{
			try
			{
				var c:Class = getDefinitionByName(className) as Class;
				if (c == null)
				{
					c = g.bridge.root.contentLoaderInfo.applicationDomain.getDefinition(className) as Class;
				}
				return c;
			} 
			catch(e:Error)
			{
				if(g.loader.isLogError)
				{
					g.log.pushLog(this, LogType._Warning, "getLocalClassBase 失败 : " + className);
				}
			}
			return null;
		}
		
		/**
		 * 从swf的根目录下获取类
		 * @param allClassName	一个全部的类名
		 * @param isOnly		是否是唯一的
		 * @param isOnlyLink	是否是唯一的后,然后是否是弱引用
		 * @return 
		 */
		public function getLocalClass(allClassName:String, isOnly:Boolean = false, isOnlyLink:Boolean = true):*
		{
			try
			{
				var ClassReference:Class = getDefinitionByName(allClassName) as Class;
			} 
			catch(error:Error) {}
			if(ClassReference)
			{
				if(isOnly)
				{
					if(isOnlyLink)
					{
						if(onlyOneObjectLink[ClassReference])
						{
							onlyOneObject[ClassReference] = onlyOneObjectLink[ClassReference];
							delete onlyOneObjectLink[ClassReference];
						}
						else
						{
							if (onlyOneObject[ClassReference] == null)
							{
								onlyOneObject[ClassReference] = new ClassReference();
							}
						}
						return onlyOneObject[ClassReference];
					}
					else
					{
						if(onlyOneObject[ClassReference])
						{
							onlyOneObjectLink[ClassReference] = onlyOneObject[ClassReference];
							delete onlyOneObject[ClassReference];
						}
						else
						{
							if (onlyOneObjectLink[ClassReference] == null)
							{
								onlyOneObjectLink[ClassReference] = new ClassReference();
							}
						}
						return onlyOneObjectLink[ClassReference];
					}
				}
				else
				{
					return new ClassReference();
				}
			}
			if(g.loader.isLogError)
			{
				g.log.pushLog(this, LogType._Warning, "getLocalClass 获取的类未能在资源库中找到 !");
			}
			return null;
		}
	}
}