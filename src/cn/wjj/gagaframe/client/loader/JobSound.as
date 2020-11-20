package cn.wjj.gagaframe.client.loader
{
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	/**
	 * 专门下载URL的sound声音
	 * @author Administrator
	 * 
	 */
	public class JobSound
	{
		/** 这个对象所属的农民 **/
		private var farmer:Farmer;
		/** 发出的连接 **/
		private var urlRequest:URLRequest;
		/** 声音的引用 **/
		private var sound:Sound;
		/** 是不是就检查一下文件的整体大小 **/
		private var isGetBytesTotal:Boolean;
		
		public function JobSound(farmer:Farmer):void
		{
			this.farmer = farmer;
		}
		
		/**
		 * 运行下载这个对象
		 * @param isGetBytesTotal	是否是检查尺寸,检查完毕就停止，返回以检查是否需要强制更新os缓存
		 */
		internal function run(isGetBytesTotal:Boolean = false):void
		{
			urlRequest = new URLRequest(farmer.item.url);
			this.isGetBytesTotal = isGetBytesTotal;
			//添加版本号
			if(farmer.item.fileVer || this.isGetBytesTotal || farmer.item.autoReChange)
			{
				var variables:URLVariables = new URLVariables();
				if (farmer.item.fileVer)
				{
					variables.ver = farmer.item.fileVer;
					if(this.isGetBytesTotal || farmer.item.autoReChange)
					{
						variables.tempRandom = String(g.time.getTime()) + String(Math.random()*100000);
					}
					urlRequest.data = variables;
					if(g.status.networkMode)
					{
						urlRequest.method = URLRequestMethod.GET;
					}
					else
					{
						urlRequest.method = URLRequestMethod.POST;
					}
				}
				else if(this.isGetBytesTotal || farmer.item.autoReChange)
				{
					variables.tempRandom = String(g.time.getTime()) + String(Math.random()*100000);
					urlRequest.data = variables;
					if(g.status.networkMode)
					{
						urlRequest.method = URLRequestMethod.GET;
					}
					else
					{
						urlRequest.method = URLRequestMethod.POST;
					}
				}
			}
			//准备下载声音
			sound = new Sound();
			farmer.item.fileData = sound;
			configureListeners(sound);
			sound.load(urlRequest);
		}
		
		/** 重置这个对象 **/
		internal function resetting():void
		{
			if(sound)removeListeners(sound);
			close();
			urlRequest = null;
		}
		
		internal function close():void
		{
			try
			{
				if(sound)
				{
					sound.close();
				}
			}
			catch(e:Error){}
		}
		
		/**
		 * 摧毁这个对象
		 */
		internal function destroy():void
		{
			sound = null;
			resetting();
			farmer = null;
			urlRequest = null;
		}
		
		//添加监听事件
		private function configureListeners(dispatcher:IEventDispatcher):void
		{
			g.event.addListener(dispatcher, Event.COMPLETE, completeHandler);
			g.event.addListener(dispatcher, HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			g.event.addListener(dispatcher, Event.INIT, initHandler);
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
			g.event.removeListener(dispatcher, HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			g.event.removeListener(dispatcher, Event.INIT, initHandler);
			g.event.removeListener(dispatcher, SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			g.event.removeListener(dispatcher, IOErrorEvent.IO_ERROR, ioErrorHandler);
			g.event.removeListener(dispatcher, Event.OPEN, openHandler);
			g.event.removeListener(dispatcher, ProgressEvent.PROGRESS, progressHandler);
			g.event.removeListener(dispatcher, Event.UNLOAD, unLoadHandler);
		}
		
		private function completeHandler(e:Event):void
		{
			farmer.item.loadApiID = g.id;
			farmer.resetting(true);
		}
		
		private function httpStatusHandler(e:HTTPStatusEvent):void
		{
			//trace("httpStatusHandler: " + e);
		}
		
		private function initHandler(e:Event):void
		{
			g.log.pushLog(this, LogType._Frame, "initHandler: " + e);
		}
		
		private function ioErrorHandler(e:IOErrorEvent):void
		{
			if (farmer.item.numTries <= g.loader.farm.maxTries)
			{
				farmer.item.numTries = farmer.item.numTries + 1;
				resetting();
				run();
				g.log.pushLog(this, LogType._Warning, "IO错误自动重试,重试次数 : " + String(farmer.item.numTries));
			}
			else
			{
				if(g.loader.isLog)
				{
					g.log.pushLog(this, LogType._ErrorLog, "ioErrorHandler: " + e);
				}
				farmer.item.state = ItemState.ERROR;
			}
		}
		
		private function openHandler(e:Event):void
		{
			//trace("openHandler: " + e);
			if(this.isGetBytesTotal)
			{
				return;
			}
			farmer.item.state = ItemState.START;
		}
		
		private function progressHandler(e:ProgressEvent):void
		{
			if(this.isGetBytesTotal)
			{
				farmer.item.bytesTotal = e.bytesTotal;
				farmer.getFileSizeOver();
				resetting();
				return;
			}
			//trace("progressHandler: " + e.bytesTotal , e.bytesLoaded);
			farmer.item.bytesTotal = e.bytesTotal;
			farmer.item.bytesLoaded  = e.bytesLoaded;
			farmer.item.state = ItemState.PROGRESS;
			g.loader.farm.doTeam.changeState(farmer.item, ItemState.PROGRESS);
			g.loader.speed.pushProgress(sound, e.bytesLoaded);
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
			if(g.loader.isLog)
			{
				g.log.pushLog(this, LogType._ErrorLog, "沙箱错误: " + e);
			}
		}
	}
}