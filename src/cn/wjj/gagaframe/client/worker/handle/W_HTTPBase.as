package cn.wjj.gagaframe.client.worker.handle 
{
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	import cn.wjj.gagaframe.client.speedfact.SByte;
	import cn.wjj.gagaframe.client.worker.WorkerInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.getTimer;
	
	/**
	 * 处理HTTP的功能
	 * 
	 * out.info 内容
	 * 		state		[int]		状态,0成功, 1:IO错误, 2:沙箱错误, 3:自定义超时
	 * 		data		[*]			获取到的内容(可能是字符串或二进制)
	 * 								SByte
	 * 								String
	 * 
	 * track.info 状态内容
	 * 		bytesTotal	[Number]	内容的总容量
	 * 		bytesLoaded	[Number]	已经下载的内容量
	 * 
	 * @author GaGa
	 */
	public class W_HTTPBase extends WorkerBase 
	{
		/** 任务类型 **/
		public static const ID:uint = 3000000001;
		/** 本任务是否有返回值 **/
		public static const hasReturn:Boolean = true;
		
		public function W_HTTPBase() { }
		
		/**
		 * 创建一个异步任务
		 * @param	url			地址
		 * @param	vars		发送参数
		 * @param	isPost		是否使用POST
		 * @param	timeOut		是否添加额外的超时
		 * @param	addTime		是否添加一个时间戳防止缓存
		 * @param	isByte		是否是二进制下载
		 * @return	这个任务信息
		 */
		public static function init(url:String, vars:Object = null, isPost:Boolean = true, timeOut:uint = 0, addTime:Boolean = false, isByte:Boolean = false):WorkerInfo
		{
			var info:WorkerInfo = WorkerInfo.instance();
			info.type = ID;
			var o:Object = new Object();
			o.url = url;
			o.vars = vars;
			o.isPost = isPost;
			o.timeOut = timeOut;
			o.addTime = addTime;
			o.isByte = isByte;
			info.send.info = o;
			return info;
		}
		
		/** 下载 **/
		private var loader:URLLoader;
		/** 开始时间 **/
		private var timeStart:int = -1;
		private var timeEnd:int = -1;
		
		override public function run(info:WorkerInfo, follow:Function, track:Function = null):void 
		{
			super.run(info, follow, track);
			if (info.send.hasInfo)
			{
				var o:Object = info.send.info;
				loader = new URLLoader();
				loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityError);
				loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				loader.addEventListener(Event.COMPLETE, completeHandler);
				loader.addEventListener(ProgressEvent.PROGRESS, progress);
				var request:URLRequest = new URLRequest(o.url);
				if (o.isByte)
				{
					request.contentType = "multipart/form-data";
					request.contentType = "application/octet-stream";
				}
				var variables:URLVariables;
				if (o.addTime)
				{
					if (variables == null)
					{
						variables = new URLVariables();
						request.data = variables;
					}
					variables.exampleSessionId = new Date().time;
				}
				if (o.vars)
				{
					if (variables == null)
					{
						variables = new URLVariables();
						request.data = variables;
					}
					for (var name:String in o.vars) 
					{
						variables[name] = o.vars[name];
					}
				}
				if(o.isPost)
				{
					request.method = URLRequestMethod.POST;
				}
				else
				{
					request.method = URLRequestMethod.GET;
				}
				if (o.timeOut)
				{
					timeStart = getTimer();
					timeEnd = timeStart + o.timeOut;
					g.event.addEnterFrame(enterFrame);
				}
				else
				{
					timeStart = -1;
					timeEnd = -1;
				}
				loader.load(request);
			}
			else
			{
				throw new Error("缺数据");
			}
		}
		
		/** 加载完毕 **/
		private function completeHandler(e:Event):void
		{
			g.log.pushLog(this, LogType._Record, "完成:" + info.send.info.url);
			info.out.info = new Object();
			info.out.info.state = 0;
			if (info.send.info.isByte)
			{
				var byte:SByte = SByte.instance();
				e.currentTarget.readBytes(byte);
				info.out.info.data = byte;
			}
			else
			{
				info.out.info.data = e.currentTarget.data;
			}
			close();
			over();
		}
		
		/** URL不可用或不可访问 **/
		private function ioErrorHandler(e:IOErrorEvent):void
		{
			g.log.pushLog(this, LogType._ErrorLog, "IO错误 : " + info.send.info.url + " : " + e.toString());
			close();
			var o:Object = new Object();
			info.out.info = o;
			info.out.info.state = 1;
			over();
		}
		
		/** 沙箱错误 **/
		private function securityError(e:SecurityErrorEvent):void
		{
			g.log.pushLog(this, LogType._ErrorLog, "沙箱错误 : " + info.send.info.url + " : " + e.toString());
			close();
			var o:Object = new Object();
			info.out.info = o;
			info.out.info.state = 2;
			over();
		}
		
		/** 处理遗留内容 **/
		private function close():void
		{
			if (timeStart != -1)
			{
				g.event.removeEnterFrame(enterFrame);
				timeStart = -1;
				timeEnd = -1;
			}
			if (loader)
			{
				loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityError);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				loader.removeEventListener(Event.COMPLETE, completeHandler);
				loader.removeEventListener(ProgressEvent.PROGRESS, progress);
				try
				{
					loader.close();
				}
				catch (e:Error) { }
				loader = null;
			}
		}
		
		/** 记录下载数量的数量 **/
		private function progress(e:ProgressEvent):void
		{
			if (timeStart != -1)
			{
				g.event.removeEnterFrame(enterFrame);
				timeStart = -1;
				timeEnd = -1;
			}
			var o:Object;
			if (info.track.hasInfo == false)
			{
				o = new Object();
				info.track.info = o;
			}
			else
			{
				o = info.track.info;
			}
			o.bytesTotal = e.bytesTotal;
			o.bytesLoaded = e.bytesLoaded;
			sendTrack();
		}
		
		private function enterFrame():void
		{
			if (timeEnd < getTimer())
			{
				g.log.pushLog(this, LogType._ErrorLog, "连接超时:" + info.send.info.url);
				close();
				var o:Object = new Object();
				info.out.info = o;
				info.out.info.state = 3;
				over();
			}
		}
	}
}