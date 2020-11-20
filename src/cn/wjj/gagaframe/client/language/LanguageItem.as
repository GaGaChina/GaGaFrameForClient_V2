package cn.wjj.gagaframe.client.language
{
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.loader.AssetType;
	import cn.wjj.gagaframe.client.loader.Item;
	import cn.wjj.gagaframe.client.loader.Team;
	import cn.wjj.gagaframe.client.log.LogType;
	
	/**
	 * 语言包的XML内容
	 * 
	 * info[id] = 特定类型的Object
	 * 
	 * @author GaGa
	 */
	public class LanguageItem
	{
		/** 语言的名称 **/
		public var name:String;
		/** 语言包的连接地址 **/
		public var xmlURL:String;
		/** 语言包原始XML **/
		public var xml:XML;
		/** 语言包转对象 **/
		public var info:Object;
		/** 下载完毕的时候执行,执行一次删除 **/
		public var onComplete:Function;
		/** 每次下载成功的时候+1输出本次的进度,loadedItem:Number, totalItem:Number **/
		public var onLoading:Function;
		/** 是否下载完毕自动设置 **/
		public var autoSet:Boolean;
		
		public function LanguageItem():void { }
		
		/** 当这个语言包下载完毕的时候执行的操作 **/
		internal function loadOk():void
		{
			info = new Object();
			xml = g.loader.asset.asset.getAssetXML(xmlURL);
			g.loader.asset.file.removeFileUrl(xmlURL);
			g.loader.asset.asset.delAssetItem(xmlURL);
			if (xml)
			{
				g.log.pushLog(this, LogType._Frame, "载入多语言包配置成功!");
				info = LanguageApi.GetInfo(xml);
				//xmlToObject();
				var ver:String = "";
				if(xml.config.@ver && xml.config.@ver != "")
				{
					ver = xml.config.@ver;
				}
				var m:Boolean = false;
				if(xml.config.@cacheMemory == "1")
				{
					m = true;
				}
				var s:Boolean = false;
				if(xml.config.@cacheSO == "1")
				{
					s = true;
				}
				if(g.loader.config_getClassInRoot)
				{
					s = false;
				}
				loadLanguageObj(ver, m, s);
			}
			else
			{
				g.log.pushLog(this, LogType._Frame, "载入多语言包失败 : " + xmlURL);
			}
		}
		
		/** 当这个语言包下载完毕的时候执行的操作 **/
		internal function loadByteOk(info:Object, cacheMemory:Boolean = true, cacheSO:Boolean = false):void
		{
			this.info = info;
			var team:Team = g.loader.addTeam(xmlURL + "《Language全部内容》");
			if(team && team.isLoaded)
			{
				allComplete();
			}
			else
			{
				try
				{
					var item:Item;
					team.onComplete(allCompleteObj);
					if (onLoading != null)
					{
						onLoading(60, 100);
					}
					for each(var o:* in info.font)
					{
						if (g.loader.config_getClassInRoot == false || g.status.rootURL == "")
						{
							item = g.loader.addItem(o.url);
							item.cacheMemory = cacheMemory;
							item.cacheSO = cacheSO;
							item.fileType = AssetType.SWFCLASSLIB;
							item.addAsset(o.url, null, false, false);
							team.addItem(item);
						}
					}
					if (onLoading != null)
					{
						onLoading(65, 100);
					}
					team.start();
				}
				catch (e:Error)
				{
					g.log.pushLog(this, LogType._Frame, "载入《Language全部内容》出错:" + e.message);
					allCompleteObj();
				}
			}
		}
		
		/**
		 * 下载这个资源所需要的全部内容
		 */
		private function loadLanguageObj(ver:String, cacheMemory:Boolean = true, cacheSO:Boolean = false):void
		{
			var team:Team = g.loader.addTeam(xmlURL + "《Language全部内容》");
			if(team && team.isLoaded)
			{
				allComplete();
			}
			else
			{
				try
				{
					var item:Item;
					team.onComplete(allComplete);
					var o:*;
					for each(o in info.img)
					{
						item = g.loader.addItem(o.url);
						item.cacheMemory = cacheMemory;
						item.cacheSO = cacheSO;
						item.fileVer = ver;
						item.fileType = AssetType.IMAGE;
						item.addAsset(o.url, null, true, true);
						team.addItem(item);
					}
					for each(o in info.font)
					{
						if (g.loader.config_getClassInRoot == false || g.status.rootURL == "")
						{
							item = g.loader.addItem(o.url);
							item = g.loader.addItem(o.url);
							item.cacheMemory = cacheMemory;
							item.cacheSO = cacheSO;
							item.fileVer = ver;
							item.fileType = AssetType.SWFCLASSLIB;
							item.addAsset(o.url, null, false, false);
							team.addItem(item);
						}
					}
					team.start();
				}
				catch (e:Error)
				{
					g.log.pushLog(this, LogType._Frame, "载入《Language全部内容》出错:" + e.message);
					allComplete();
				}
			}
		}
		
		private function allComplete():void
		{
			if (onLoading != null)
			{
				onLoading(70, 100);
			}
			if (loadArr == null) loadArr = new Vector.<Object>();
			for each (var o:Object in info.img) 
			{
				loadArr.push(o);
			}
			loadId = 0;
			loadTotle = loadArr.length;
			g.status.process.pushMethod(loadingImg);
		}
		
		private var loadId:int = 0;
		private var loadTotle:int = 0;
		private var loadArr:Vector.<Object>;
		
		private function loadingImg():void
		{
			var o:Object;
			if (loadId < loadTotle)
			{
				o = loadArr[loadId];
				o.data = g.loader.asset.asset.getAssetBitmapData(o.url , false);
				g.loader.asset.file.removeFileUrl(o.url);
				g.loader.asset.asset.delAssetItem(o.url);
				if (onLoading != null)
				{
					onLoading(int(loadId / loadTotle * 10 + 70), 100);
				}
				loadId++;
				g.status.process.pushMethod(loadingImg);
			}
			else
			{
				if (loadArr == null)
				{
					loadArr = new Vector.<Object>();
				}
				else
				{
					loadArr.length = 0;
				}
				for each (o in info.font) 
				{
					loadArr.push(o);
				}
				if (onLoading != null)
				{
					onLoading(80, 100);
				}
				loadId = 0;
				loadTotle = loadArr.length;
				g.status.process.pushMethod(loadingFont);
			}
		}
		
		private function loadingFont():void
		{
			if (loadId < loadTotle)
			{
				var o:Object = loadArr[loadId];
				if(o.hasOwnProperty("url") && o.url)
				{
					var className:String = o.classAllName;
					var c:Class = null;
					if (g.loader.config_getClassInRoot)
					{
						c = g.loader.asset.asset.getLocalClassBase(className);
					}
					if(c == null)
					{
						c = g.loader.asset.asset.getAssetLibData(className, o.url, false);
					}
					if (c)
					{
						var item:FontItem = g.language.font.registerFontClass(className, c, o.register, o.embed);
						if (item)
						{
							o.item = item;
							item.embed = o.embed;
							item.url = o.url;
						}
					}
				}
				if (onLoading != null)
				{
					onLoading(int(loadId / loadTotle * 10 + 80), 100);
				}
				loadId++;
				g.status.process.pushMethod(loadingFont);
			}
			else
			{
				if (loadArr)
				{
					loadArr.length = 0;
					loadArr = null;
				}
				if (onLoading != null)
				{
					onLoading(90, 100);
				}
				loadId = 0;
				loadTotle = info.amf.length;
				g.status.process.pushMethod(loadingAMF);
			}
		}
		
		private function loadingAMF():void
		{
			if (loadId < loadTotle)
			{
				if (g.language.config_img_gfile)
				{
					var a:Array = g.language.config_img_gfile;
					if (a.length)
					{
						var add:*;
						var url:String = info.amf[loadId];
						for each(var gfile:* in a)
						{
							add = gfile.getPathObj(url);
							if(add)
							{
								info.arr.push(add);
								break;
							}
						}
					}
				}
				if (onLoading != null)
				{
					onLoading(int(loadId / loadTotle * 10 + 90), 100);
				}
				loadId++;
				g.status.process.pushMethod(loadingAMF);
			}
			else
			{
				completeOver();
			}
		}
		
		private function allCompleteObj():void
		{
			loadId = 0;
			if (loadArr == null)
			{
				loadArr = new Vector.<Object>();
			}
			else
			{
				loadArr.length = 0;
			}
			for each (var o:Object in info.font) 
			{
				loadArr.push(o);
			}
			loadTotle = loadArr.length;
			g.status.process.pushMethod(loadingFont);
		}
		
		private function completeOver():void
		{
			if(onLoading != null)
			{
				onLoading(100, 100);
				onLoading = null;
			}
			if(autoSet)
			{
				g.language.setConfig(name);
			}
			if(onComplete != null)
			{
				onComplete();
				onComplete = null;
			}
			var team:Team = g.loader.addTeam(xmlURL + "《Language全部内容》");
			if(team)team.dispose();
			g.log.pushLog(this, LogType._Frame, "完成Loader并实例化全部的资源!");
		}
		
		/** 将下载的资源全部覆盖上来 **/
		/**
		private function getFontInfo():void
		{
			var o:*;
			var c:Class;
			for each(o in info.font)
			{
				if(o.hasOwnProperty("url") && o.url)
				{
					if (f.loader.config_getClassInRoot)
					{
						c = f.loader.asset.asset.getLocalClassBase(o.classAllName);
					}
					if(c == null)
					{
						c = f.loader.asset.asset.getAssetLibData(o.classAllName, o.url, false);
					}
					o.fontClass = c;
					if (o.hasOwnProperty("register") && o.register)
					{
						Font.registerFont(c);
					}
					o.font = new c();
					c = null;
				}
			}
			var fontList:Array = Font.enumerateFonts(false);
			var repeat:Array = ArrayUtil.createRepeatItem(fontList);
			if(repeat.length)
			{
				f.log.pushLog(this, LogType._ErrorLog,"多语言包发现有重复字体,会造部分字体无法显示,重复字体 : " + repeat.join());
				f.log.pushLog(this, LogType._Frame, "已经载入的多语言字体包含 : " + fontList.join());
			}
			if (f.language.config_img_gfile)
			{
				var a:Array = f.language.config_img_gfile;
				var add:*;
				for each(var url:String in info.amf)
				{
					if (a.length)
					{
						for each(var gfile:* in a)
						{
							add = gfile.getPathObj(url);
							if(add)
							{
								info.arr.push(add);
								break;
							}
						}
					}
				}
			}
		}
		**/
	}
}