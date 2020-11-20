package cn.wjj.gagaframe.client.loader
{
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	
	public class JobLoader
	{
		/** 这个对象所属的农民 **/
		private var farmer:Farmer;
		/** 下载的对象 **/
		private var loader:Loader;
		/** 发出的连接 **/
		private var urlRequest:URLRequest;
		/** 是不是就检查一下文件的整体大小 **/
		private var isGetBytesTotal:Boolean;
		/** 处理assetList的序号,做CPU负载均衡 **/
		private var assetId:int;
		
		public function JobLoader(farmer:Farmer):void
		{
			this.farmer = farmer;
		}
		
		internal function run(isGetBytesTotal:Boolean = false):void
		{
			var context:LoaderContext;
			if (farmer.item.fileType == AssetType.SWFCLASS || farmer.item.fileType == AssetType.SWFCLASSLIB || farmer.item.fileType == AssetType.FONT)
			{
				context = new LoaderContext();
				if(g.status.os == "Android" || g.status.os == "IOS" || g.status.os == "AIR")
				{
					context.allowCodeImport = true;//给手机和桌面AIR用
					context.applicationDomain = ApplicationDomain.currentDomain; //加载到同域(共享库)
				}
				else
				{
					context.applicationDomain = ApplicationDomain.currentDomain; //加载到同域(共享库)
				}
			}
			if(farmer.item.fileData)
			{
				loader = new Loader();
				configureListeners(loader.contentLoaderInfo);
				if (farmer.item.fileType == AssetType.SWFCLASS || farmer.item.fileType == AssetType.SWFCLASSLIB || farmer.item.fileType == AssetType.FONT)
				{
					loader.loadBytes(farmer.item.fileData, context);
				}
				else
				{
					loader.loadBytes(farmer.item.fileData);
				}
			}
			else
			{
				this.isGetBytesTotal = isGetBytesTotal;
				urlRequest = new URLRequest(farmer.item.url);
				loader = new Loader();
				configureListeners(loader.contentLoaderInfo);
				if (farmer.item.fileType == AssetType.SWFCLASS || farmer.item.fileType == AssetType.SWFCLASSLIB || farmer.item.fileType == AssetType.FONT)
				{
					loader.load(urlRequest, context);
				}
				else
				{
					loader.load(urlRequest);
				}
			}
		}
		
		/** 重置这个对象 **/
		internal function resetting():void
		{
			if(loader)
			{
				removeListeners(loader.contentLoaderInfo);
				loader = null;
			}
			close();
		}
		
		internal function close():void
		{
			try
			{
				if(loader)
				{
					loader.close();
				}
			}
			catch (e:Error){}
		}
		
		/**
		 * 摧毁这个对象
		 */
		internal function destroy():void
		{
			resetting();
			farmer = null;
		}
		
		//添加监听事件
		private function configureListeners(dispatcher:IEventDispatcher):void
		{
			g.event.addListener(dispatcher, Event.COMPLETE, completeHandler);
			//f.event.addListener(dispatcher, HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			//f.event.addListener(dispatcher, Event.INIT, initHandler);
			g.event.addListener(dispatcher, SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			g.event.addListener(dispatcher, IOErrorEvent.IO_ERROR, ioErrorHandler);
			g.event.addListener(dispatcher, Event.OPEN, openHandler);
			g.event.addListener(dispatcher, ProgressEvent.PROGRESS, progressHandler);
			g.event.addListener(dispatcher, Event.UNLOAD, unLoadHandler);
		}
		
		//删除监听事件
		private function removeListeners(dispatcher:IEventDispatcher):void
		{
			g.event.removeListener(dispatcher, Event.COMPLETE, completeHandler);
			//f.event.removeListener(dispatcher, HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			//f.event.removeListener(dispatcher, Event.INIT, initHandler);
			g.event.removeListener(dispatcher, SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			g.event.removeListener(dispatcher, IOErrorEvent.IO_ERROR, ioErrorHandler);
			g.event.removeListener(dispatcher, Event.OPEN, openHandler);
			g.event.removeListener(dispatcher, ProgressEvent.PROGRESS, progressHandler);
			g.event.removeListener(dispatcher, Event.UNLOAD, unLoadHandler);
		}
		
		/** 下载成功的回调 **/
		private var ce:Event;
		
		/** 数据下载成功 **/
		private function completeHandler(e:Event):void
		{
			this.ce = e;
			g.status.process.pushMethod(runCompleteInfo);
		}
		
		private function runCompleteInfo():void
		{
			switch(farmer.item.fileType)
			{
				case AssetType.SWFCLASS:
				case AssetType.FONT:
					if (farmer.item.assetList.length)
					{
						assetId = 0;
						g.status.process.pushMethod(openAssetClass);
						return;
					}
					break;
				case AssetType.SWFCLASSLIB:
					try
					{
						farmer.item.firstAsset.data = (ce.currentTarget.loader as Loader).contentLoaderInfo.applicationDomain;
					}
					catch (e:Error)
					{
						if (g.loader.isLog || g.loader.isLogError)
						{
							g.log.pushLog(this, LogType._Frame, "抽取文件错误 URL:" + farmer.item.url + " : " + farmer.item.firstAsset.name + " SMG : " + e.toString());
						}
					}
					break;
				case AssetType.IMAGE:
					try
					{
						farmer.item.firstAsset.data = (ce.currentTarget.content as Bitmap).bitmapData;
					}
					catch (e:Error)
					{
						if (g.loader.isLog || g.loader.isLogError)
						{
							g.log.pushLog(this, LogType._Frame, "抽取图片错误 URL:" + farmer.item.url + " : " + farmer.item.firstAsset.name + " SMG : " + e.toString());
						}
					}
					break;
				default:
					try
					{
						farmer.item.firstAsset.data = (ce.currentTarget as Loader).content;
					}
					catch (e:Error)
					{
						if (g.loader.isLog || g.loader.isLogError)
						{
							g.log.pushLog(this, LogType._Frame, "抽取错误 URL:" + farmer.item.url + " : " + farmer.item.firstAsset.name + " SMG : " + e.toString());
						}
					}
			}
			ce = null;
			farmer.resetting(true);
		}
		
		/** 抽类 **/
		private function openAssetClass():void
		{
			if (assetId < farmer.item.assetList.length)
			{
				var c:AssetItem = farmer.item.assetList[assetId];
				assetId++;
				try
				{
					if(c.config_className)
					{
						c.data = (ce.currentTarget.loader as Loader).contentLoaderInfo.applicationDomain.getDefinition(c.config_className) as Class;
					}
					else
					{
						c.data = (ce.currentTarget.loader as Loader).contentLoaderInfo.applicationDomain;
					}
				}
				catch (e:Error)
				{
					if (g.loader.isLog || g.loader.isLogError)
					{
						g.log.pushLog(this, LogType._Frame, "抽取文件错误 URL:" + farmer.item.url + " : " + c.name + " config_className:" + c.config_className + " SMG : " + e.toString());
					}
				}
				g.status.process.pushMethod(openAssetClass);
			}
			else
			{
				ce = null;
				farmer.resetting(true);
			}
		}
		
		private function ioErrorHandler(e:IOErrorEvent):void
		{
			if (farmer.item.numTries <= g.loader.farm.maxTries)
			{
				farmer.item.numTries = farmer.item.numTries + 1;
				resetting();
				run();
			}
			else
			{
				if (g.loader.isLog || g.loader.isLogError)
				{
					g.log.pushLog(this, LogType._ErrorLog, "IO错误 URL:" + farmer.item.url + " MSG : " + e.toString());
				}
				farmer.item.state = ItemState.ERROR;
			}
		}
		
		private function openHandler(e:Event):void
		{
			//这里没有下载的大小
			//frame.log.pushLog(this, frame.log.logType._ErrorLog, "被打开 Event.OPEN : " + e);
			farmer.item.state = ItemState.START;
		}
		
		private function progressHandler(e:ProgressEvent):void
		{
			//trace("progressHandler: " + e.bytesTotal , e.bytesLoaded);
			//frame.log.pushLog(this, frame.log.logType._ErrorLog, "下载中 ProgressEvent.PROGRESS : " + e);
			if(farmer.item.fileData == null)
			{
				farmer.item.bytesTotal = e.bytesTotal;
				farmer.item.bytesLoaded  = e.bytesLoaded;
				farmer.item.state = ItemState.PROGRESS;
				g.loader.farm.doTeam.changeState(farmer.item, ItemState.PROGRESS);
				g.loader.speed.pushProgress(loader, e.bytesLoaded);
			}
		}
		
		/** 被卸载 **/
		private function unLoadHandler(e:Event):void
		{
			if(g.loader.isLog)
			{
				g.log.pushLog(this, LogType._Frame, "被卸载 unLoadHandler : " + e);
			}
		}
		
		/** 沙箱错误 **/
		private function securityErrorHandler(e:SecurityErrorEvent):void
		{
			if(g.loader.isLog || g.loader.isLogError)
			{
				g.log.pushLog(this, LogType._ErrorLog, "沙箱错误 URL : " + farmer.item.url + " " + e.toString());
			}
		}
	}
}