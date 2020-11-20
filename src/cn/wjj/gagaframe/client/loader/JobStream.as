package cn.wjj.gagaframe.client.loader
{
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLStream;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	
	public class JobStream
	{
		/** 这个对象所属的农民 **/
		private var farmer:Farmer;
		/** 发出的连接 **/
		private var request:URLRequest;
		/** 二进制内容 **/
		private var stream:URLStream;
		/** 是不是就检查一下文件的整体大小 **/
		private var isGetBytesTotal:Boolean;
		
		public function JobStream(farmer:Farmer):void
		{
			this.farmer = farmer;
		}
		
		/**
		 * 运行这个下载
		 * @param isGetBytesTotal	是不是就检查一下文件的整体大小
		 */
		internal function run(isGetBytesTotal:Boolean = false):void
		{
			this.isGetBytesTotal = isGetBytesTotal;
			request = new URLRequest(farmer.item.url);
			request.contentType = "multipart/form-data";
			request.contentType = "application/octet-stream";
			//添加版本号
			if(farmer.item.fileVer || this.isGetBytesTotal || farmer.item.autoReChange)
			{
				var v:URLVariables = new URLVariables();
				if (farmer.item.fileVer)
				{
					v.ver = farmer.item.fileVer;
					if(this.isGetBytesTotal || farmer.item.autoReChange)
					{
						v.tempRandom = String(g.time.getTime()) + String(Math.random()*100000);
					}
					request.data = v;
					if(g.status.networkMode)
					{
						request.method = URLRequestMethod.GET;
					}
					else
					{
						request.method = URLRequestMethod.POST;
					}
				}
				else if(this.isGetBytesTotal || farmer.item.autoReChange)
				{
					v.tempRandom = String(g.time.getTime()) + String(Math.random()*100000);
					request.data = v;
					if(g.status.networkMode)
					{
						request.method = URLRequestMethod.GET;
					}
					else
					{
						request.method = URLRequestMethod.POST;
					}
				}
			}
			//建立URLLoader对象
			stream = new URLStream();
			stream.addEventListener(Event.COMPLETE, completeHandler);
			stream.addEventListener(Event.INIT, initHandler);
			stream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			stream.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			stream.addEventListener(Event.OPEN, openHandler);
			stream.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			stream.addEventListener(Event.UNLOAD, unLoadHandler);
			stream.load(request);
		}
		
		/** 重置这个对象 **/
		internal function resetting():void
		{
			if(stream)
			{
				stream.removeEventListener(Event.COMPLETE, completeHandler);
				stream.removeEventListener(Event.INIT, initHandler);
				stream.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
				stream.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				stream.removeEventListener(Event.OPEN, openHandler);
				stream.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
				stream.removeEventListener(Event.UNLOAD, unLoadHandler);
				try
				{
					stream.close();
				} catch (e:Error) { }
				stream = null;
			}
			if (request) request = null;
		}
		
		internal function close():void
		{
			try
			{
				if(stream)
				{
					stream.close();
				}
			} catch (e:Error) { }
		}
		
		/** 摧毁这个对象 **/
		internal function destroy():void
		{
			resetting();
			if (farmer) farmer = null;
			if (request) request = null;
		}
		
		/** 下载成功的回调 **/
		private var completeInfo:Event;
		
		private function completeHandler(e:Event):void
		{
			completeInfo = e;
			g.status.process.pushMethod(runCompleteInfo);
		}
		
		private function runCompleteInfo():void
		{
			var e:Event = completeInfo;
			completeInfo = null;
			if (this.isGetBytesTotal)
			{
				resetting();
			}
			else
			{
				var byte:ByteArray = new ByteArray();
				farmer.item.loadApiID = g.id;
				stream.readBytes(byte);
				farmer.item.fileData = byte;
				close();
				farmer.loadObject();
			}
		}
		
		private function initHandler(e:Event):void
		{
			if (g.loader.isLog)
			{
				g.log.pushLog(this, LogType._Frame, "initHandler: " + e);
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
			if (this.isGetBytesTotal)
			{
				return;
			}
			//这里没有下载的大小
			//frame.log.pushLog(this, frame.log.logType._ErrorLog, "被打开 Event.OPEN : " + e);
			farmer.item.state = ItemState.START;
		}
		
		private function progressHandler(e:ProgressEvent):void
		{
			if (this.isGetBytesTotal)
			{
				farmer.item.bytesTotal = e.bytesTotal;
				farmer.getFileSizeOver();
				resetting();
				return;
			}
			//trace("progressHandler: " + e.bytesTotal , e.bytesLoaded);
			//frame.log.pushLog(this, frame.log.logType._ErrorLog, "下载中 ProgressEvent.PROGRESS : " + e);
			farmer.item.bytesTotal = e.bytesTotal;
			farmer.item.bytesLoaded  = e.bytesLoaded;
			farmer.item.state = ItemState.PROGRESS;
			g.loader.farm.doTeam.changeState(farmer.item, ItemState.PROGRESS);
			g.loader.speed.pushProgress(stream, e.bytesLoaded);
		}
		
		/** 被卸载 **/
		private function unLoadHandler(e:Event):void
		{
			if (g.loader.isLog)
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
			farmer.item.state = ItemState.ERROR;
		}
	}
}