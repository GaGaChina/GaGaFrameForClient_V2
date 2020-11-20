package cn.wjj.gagaframe.client.loader
{
	import cn.wjj.data.XMLToObject;
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	
	/**
	 * 将下载一个配置文件
	 * 
	 * @version 0.0.1
	 * @author GaGa wjjhappy@Gmail.com
	 * @copy 王加静 www.5ga.cn
	 * @time 2012-03-27
	 */
	internal class LoadXMLConfig
	{
		/** 这个Load的队列的队伍 **/
		public var team:Team;
		/** 如果有URL走这个下载 **/
		private var item:Item;
		
		public function LoadXMLConfig(teamName:String):void
		{
			team = g.loader.addTeam(teamName);
		}
		
		internal function loadXML(url:String):void
		{
			item = g.loader.addItem(url);
			item.onComplete(configComplete);
			item.fileType = AssetType.XML;
			item.cacheMemory = false;
			item.cacheSO = false;
			item.addAsset(url);
			item.autoReChange = true;
			item.start();
		}
		
		private function configComplete():void
		{
			var xml:XML = g.loader.asset.asset.getAssetXML(item.firstAsset.name);
			g.loader.asset.file.removeFileUrl(item.firstAsset.file.url);
			g.loader.asset.asset.delAssetItem(item.firstAsset.name);
			item.dispose();
			item = null;
			var info:Object = XMLToObject.to(xml);
			if(info && info.data.loader != "")
			{
				if(info.data.loader.file is Array)
				{
					var arr:Array = info.data.loader.file;
					for each (var file:Object in arr) 
					{
						addConfigList(file);
					}
				}
				else if(info.data.loader.file is Object)
				{
					addConfigList(info.data.loader.file);
				}
				
			}
			team.start();
		}
		
		private function addConfigList(file:Object):void
		{
			var itemInfo:Object;
			var fileItem:Item = g.loader.addItem(file.url);
			fileItem.fileType = file.type;
			fileItem.fileVer = file.ver;
			if(file.hasOwnProperty("cacheSO") && file.cacheSO == "1")
			{
				fileItem.cacheSO = true;
			}
			else
			{
				fileItem.cacheSO = false;
			}
			if(file.hasOwnProperty("cacheMemory") && file.cacheMemory == "1")
			{
				fileItem.cacheMemory = true;
			}
			else
			{
				fileItem.cacheMemory = false;
			}
			if(file.hasOwnProperty("getToLoad") && file.getToLoad == "1")
			{
				fileItem.isGetToLoad = true;
			}
			else
			{
				fileItem.isGetToLoad = false;
			}
			if(file.hasOwnProperty("size"))
			{
				fileItem.bytesTotal = int(Number(file.size));
			}
			if(file.item is Array)
			{
				var itemList:Array = file.item;
				for each (itemInfo in itemList) 
				{
					addAsset(fileItem, itemInfo);
				}
			}
			else if(file.item)
			{
				itemInfo = file.item;
				addAsset(fileItem, itemInfo);
			}
			team.addItem(fileItem);
		}
		
		/**
		 * 为Item添加信息
		 * @param item
		 * @param itemInfo
		 * 
		 */
		private function addAsset(item:Item, itemInfo:Object):void
		{
			var name:String = itemInfo.name;
			var isOnly:Boolean = false;
			var isOnlyLink:Boolean = false;
			var config_className:String = "";
			if(itemInfo.hasOwnProperty("isOnly") && itemInfo.isOnly == "1")
			{
				isOnly = true;
			}
			if(itemInfo.hasOwnProperty("isOnlyLink") && itemInfo.isOnlyLink == "1")
			{
				isOnlyLink = true;
			}
			if(itemInfo.hasOwnProperty("config_className"))
			{
				config_className = itemInfo.config_className;
				if(g.loader.isLog && config_className.length > 0)
				{
					g.log.pushLog(this, LogType._Frame, "Load Config Class Name : " + config_className);
				}
			}
			item.addAsset(name, null, isOnly, isOnlyLink, config_className);
		}
	}
}