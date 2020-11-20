package cn.wjj.gagaframe.client.loader
{
	import cn.wjj.data.XMLToObject;
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	
	/**
	 * 将XML或者是Object转换为Array对象
	 * 
	 * @version 0.0.1
	 * @author GaGa wjjhappy@Gmail.com
	 * @copy 王加静 www.5ga.cn
	 * @time 2012-07-26
	 */
	public class LoadConfig
	{
		/** 配置文件的版本号 **/
		public var ver:String = "";
		
		
		/** 把一个XML的内容都获取到这个对象里 **/
		public function LoadConfig():void
		{
			
		}
		
		/** 从XML里获取资源的列表 **/
		public function getXML(xml:XML):void
		{
			var o:Object = XMLToObject.to(xml);
			getObj(o);
		}
		
		/** 从Object里获取内容 **/
		public function getObj(obj:Object):void
		{
			
		}
		
		
		/**
		 * 从一个Loader的XML配置里,把内容都解析出来,并且转换为数组备用,内容为Object
		 * @param loadXml	可以是XMLList和XML二种格式
		 * @return 
		 */
		public static function LoadXMLToArray(xml:*):Array
		{
			var list:Array = new Array();
			var xmlList:XMLList;
			if (xml is XMLList)
			{
				xmlList = xml as XMLList;
			}
			else
			{
				xmlList = xml.children();
			}
			xmlList = xmlList.item;
			var theLength:int = xmlList.length();
			var item:Object;
			for (var i:int = 0; i < theLength; i++)
			{
				item = new Object();
				if(String(xmlList[i]["@name"]))
				{
					item.name = String(xmlList[i]["@name"]);
				}
				if(String(xmlList[i]["@url"]))
				{
					item.url = String(xmlList[i]["@url"]);
				}
				item.type = String(xmlList[i]["@type"]);
				switch(item.type)
				{
					case AssetType.SWFCLASS:
						if(String(xmlList[i]["@config_className"]))
						{
							item.config_className = String(xmlList[i]["@config_className"]);
						}
						if(String(xmlList[i]["@classType"]))
						{
							item.classType = String(xmlList[i]["@classType"]);
						}
						break;
					case AssetType.IMAGE:
						break;
					case AssetType.JSON:
						break;
					case AssetType.SOUND:
						break;
					case AssetType.XML:
						break;
					case AssetType.ZIP:
						break;
					case AssetType.AMFFILE:
						break;
					case AssetType.AMFFILELIST:
						break;
					default:
						if(g.loader.isLogError)
						{
							g.log.pushLog(null, LogType._ErrorLog, "LoadConfig.LoadXMLToArray 中未找到配置的类型" + xmlList[i]["@type"]);
						}
						break;
				}
				if(String(xmlList[i]["@assetName"]))
				{
					item.assetName = String(xmlList[i]["@assetName"]);
				}
				if(String(xmlList[i]["@ver"]))
				{
					item.ver = String(xmlList[i]["@ver"]);
				}
				item.isOnly = false;
				if(String(xmlList[i]["@isOnly"]))
				{
					if(xmlList[i]["@isOnly"] == "1")
					{
						item.isOnly = true;
					}
				}
				if(String(xmlList[i]["@isOnlyLink"]))
				{
					if(xmlList[i]["@isOnlyLink"] == "1")
					{
						item.isOnlyLink = true;
					}
					else
					{
						item.isOnlyLink = false;
					}
				}
				item.getToLoad = false;
				if(String(xmlList[i]["@getToLoad"]))
				{
					if(xmlList[i]["@getToLoad"] == "1")
					{
						item.getToLoad = true;
					}
				}
				item.cacheMemory = false;
				if(String(xmlList[i]["@cacheMemory"]))
				{
					if(xmlList[i]["@cacheMemory"] == "1")
					{
						item.cacheMemory = true;
					}
				}
				item.cacheSO = false;
				if(String(xmlList[i]["@cacheSO"]))
				{
					if(xmlList[i]["@cacheSO"] == "1")
					{
						item.cacheSO = true;
					}
				}
				list.push(item);
			}
			return list;
		}
	}
}