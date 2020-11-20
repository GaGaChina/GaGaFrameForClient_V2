package cn.wjj.gagaframe.client.system 
{
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.system.Capabilities;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	/**
	 * 对客户端的错误进行全面的监控
	 * 
	 * @version 1.5.0
	 * @author GaGa wjjhappy@Gmail.com
	 * @copy 王加静 www.5ga.cn
	 * @date 2011-11-04
	 */
	public class ErrorManage 
	{
		/** 错误ID **/
		private var id:String;
		/** 错误的时间 **/
		private var t:Number;
		/** 客户端时间 **/
		private var n:Number;
		/** 错误名称 **/
		private var name:String;
		/** 错误信息 **/
		private var msg:String;
		/** 提供debug的信息 **/
		private var info:String;
		/** 用户设备信息 **/
		private var dev:Object;
		/** 另加的内容 **/
		private var add:Array;
		/** 服务器的传送列表 **/
		private var serverList:Vector.<Object>;
		/** 已发送的记录 **/
		private var postLog:Vector.<String>;
		/** 发送列表 **/
		private var pushLib:Dictionary = new Dictionary();
		/** 是否通过HTTP发送出去 **/
		public var config_httpPost:Boolean = true;
		/** 是否推送重复的信息 **/
		public var config_postRepeat:Boolean = false;
		/** 当bug的时候调用某一个函数 **/
		private var bugMethod:Function;
		/** 是否显示蓝屏 **/
		public var showBlueDisplay:Boolean = false;
		
		public function ErrorManage() 
		{
			this.serverList = new Vector.<Object>();
			this.postLog = new Vector.<String>();
		}
		
		/** 开始监控 **/
		public function start():void
		{
			if (g.bridge.root == null)
			{
				if (g.log.isLog) g.log.pushLog(this, LogType._Frame, "开始错误监控出错, 必须先要设置 g.bridge.swfRoot");
			}
			else if(g.bridge.root.loaderInfo == null || g.bridge.root.loaderInfo.uncaughtErrorEvents == null)
			{
				if (g.log.isLog) g.log.pushLog(this, LogType._Frame, "开始错误监控出错, 必须先等Flash初始化完毕");
			}
			else
			{
				g.event.addListener(g.bridge.root.loaderInfo.uncaughtErrorEvents, UncaughtErrorEvent.UNCAUGHT_ERROR, loaderInfoUncaught);
				if (g.log.isLog) g.log.pushLog(this, LogType._Frame, "开始错误监控");
			}
		}
		
		/**
		 * 当bug的时候把bug的信息返回出来 function(o:Object){}
		 * @param	method
		 */
		public function setBugMethod(method:Function):void
		{
			bugMethod = method
		}
		
		/**
		 * 添加要发送给的服务器地址及要添加发送的内容
		 * @param	url				要用HTTP发送出去的地址
		 * @param	postName		这个地址里要POST的名称
		 * @param	addInfoMethod	函数,执行后返回String,Array,Object等, 发送的时候会把这些内容拼接给服务器传回
		 */
		public function addPushServer(url:String, postName:String, addInfoMethod:Vector.<Function> = null):void
		{
			var server:Object = new Object();
			server.url = url;
			server.postName = postName;
			if (addInfoMethod)
			{
				server.add = addInfoMethod;
			}
			else
			{
				server.add = new Vector.<Function>();
			}
			serverList.push(server);
		}
		
		/** 清理已经要发送错误日志的服务器 **/
		public function clearServer():void
		{
			serverList.length = 0;
		}
		
		/** 发送自定义的事件内容 **/
		public function sendInfo(info:String):void
		{
			t = getTimer();
			n = g.time.getTime();
			id = "8888";
			name = "自定义";
			msg = "自定义";
			this.info = info;
			getDev();
			showBlue();
			sendMethod();
			sendServer();
		}
		
		/** 触发了错误 **/
		private function loaderInfoUncaught(e:UncaughtErrorEvent):void
		{
			t = getTimer();
			n = g.time.getTime();
			try { if (e.error.errorID) id = String(e.error.errorID); } catch (e:Error) { id = ""; }
			try { if (e.error.name) name = String(e.error.name); } catch (e:Error) { name = ""; }
			try { if (e.error.message) msg = String(e.error.message); } catch (e:Error) { msg = ""; }
			try { info = e.error.getStackTrace(); } catch (e:Error) { info = ""; }
			getDev();
			showBlue();
			sendMethod();
			sendServer();
		}
		
		private function sendMethod():void
		{
			if (bugMethod != null)
			{
				var o:Object = getInfo();
				bugMethod(o);
			}
		}
		
		private function showBlue():void
		{
			if(showBlueDisplay && g.bridge.root)
			{
				var o:Object = getInfo();
				var blue:ErrorBlue = new ErrorBlue();
				blue.setInfo(o);
				g.bridge.root.addChild(blue);
			}
		}
		
		private function getInfo():Object
		{
			var o:Object = new Object();
			o.time = t;
			o.nt = n;
			o.id = id;
			o.name = name;
			o.msg = msg;
			o.info = info;
			o.dev = dev;
			return o;
		}
		
		private function sendServer():void
		{
			if (g.log.isLog) g.log.pushLog(this, LogType._ErrorLog, "框架 Error 模块 详细 : \n" + info);
			if (g.log.isLog) g.log.pushLog(this, LogType._ErrorLog, "框架 Error 模块 ID   : " + id + " Name : " + name + " 信息 : " + msg);
			if(config_httpPost)
			{
				//--------------发送给服务器
				var o:Object
				var request:URLRequest;
				var loader:URLLoader;
				var variables:URLVariables;
				var fl:Vector.<Function>;
				var m:Function;
				for each (var server:Object in serverList) 
				{
					//--------------------------组装数据
					o = getInfo();
					add = new Array();
					o.add = add;
					fl = server.add;
					if (fl.length)
					{
						for each (m in fl) 
						{
							try
							{
								add.push(m());
							}
							catch (e:Error)
							{
								if (g.log.isLog) g.log.pushLog(this, LogType._ErrorLog, "框架 Error 抓取错误 : " + e);
							}
						}
					}
					//--------------------------发送数据
					var s:String = g.jsonGetStr(o);
					if (!this.config_postRepeat)
					{
						if (this.postLog.indexOf(info) != -1)
						{
							return;
						}
						this.postLog.push(info);
					}
					loader = new URLLoader();
					request = new URLRequest(server.url);
					variables = new URLVariables();
					variables[server.postName] = s;
					variables.exampleSessionId = g.time.getTime();
					request.data = variables;
					request.method = URLRequestMethod.POST;
					addListeners(loader);
					loader.load(request);
					pushLib[loader] = request;
				}
			}
		}
		
		/** 添加监听事件 **/
		private function addListeners(dispatcher:IEventDispatcher):void
		{
			g.event.addListener(dispatcher, SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			g.event.addListener(dispatcher, IOErrorEvent.IO_ERROR, ioErrorHandler);
			g.event.addListener(dispatcher, HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			g.event.addListener(dispatcher, Event.OPEN, openHandler);
			g.event.addListener(dispatcher, ProgressEvent.PROGRESS, progressHandler);
			g.event.addListener(dispatcher, Event.COMPLETE, completeHandler);
			g.event.addListener(dispatcher, Event.INIT, initHandler);
			g.event.addListener(dispatcher, Event.UNLOAD, unLoadHandler);
		}
		
		/** 删除监听事件 **/
		private function removeListeners(dispatcher:IEventDispatcher):void
		{
			g.event.removeListener(dispatcher, SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			g.event.removeListener(dispatcher, IOErrorEvent.IO_ERROR, ioErrorHandler);
			g.event.removeListener(dispatcher, HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			g.event.removeListener(dispatcher, Event.OPEN, openHandler);
			g.event.removeListener(dispatcher, ProgressEvent.PROGRESS, progressHandler);
			g.event.removeListener(dispatcher, Event.COMPLETE, completeHandler);
			g.event.removeListener(dispatcher, Event.INIT, initHandler);
			g.event.removeListener(dispatcher, Event.UNLOAD, unLoadHandler);
		}
		
		/** 获取用户的设备信息 **/
		private function getDev():void
		{
			dev = new Object();
			dev.frameID = g.id;
			dev.stageWidth = g.bridge.stage.stageWidth;
			dev.stageHeight = g.bridge.stage.stageHeight;
			dev.frameRate = g.bridge.stage.frameRate;
			dev.OS = Capabilities.version;
			dev.DPI = Capabilities.screenDPI;
			dev.flashVer = Capabilities.version;
			dev.debug = Capabilities.isDebugger;
		}
		
		/** 加载完毕 **/
		private function completeHandler(e:Event):void
		{
			var loader:URLLoader = e.currentTarget as URLLoader;
			removeListeners(loader);
			delete pushLib[loader]
		}
		
		/** 沙箱错误 **/
		private function securityErrorHandler(e:SecurityErrorEvent):void
		{
			if (g.log.isLog) g.log.pushLog(this, LogType._ErrorLog, "框架 Error 沙箱错误 : " + e);
			var loader:URLLoader = e.currentTarget as URLLoader;
			removeListeners(loader);
			delete pushLib[loader]
		}
		
		/** URL不可用或不可访问 **/
		private function ioErrorHandler(e:IOErrorEvent):void
		{
			if (g.log.isLog) g.log.pushLog(this, LogType._ErrorLog, "框架 Error IO错误 : " + e);
			var loader:URLLoader = e.currentTarget as URLLoader;
			removeListeners(loader);
			delete pushLib[loader]
		}
		
		/** 非本地加载，并且只有在网络请求可用并可被 Flash Player 检测到的情况下，才会执行 httpStatusHandler() 方法 **/
		private function httpStatusHandler(e:HTTPStatusEvent):void{}
		
		/** initHandler() 方法在 completeHandler() 方法之前、progressHandler() 方法之后执行。 通常，init 事件在加载 SWF 文件时更有用 **/
		private function initHandler(e:Event):void{}
		
		/** 开打连接的时候 **/
		private function openHandler(e:Event):void{}
		
		/** 记录下载数量的数量 **/
		private function progressHandler(e:ProgressEvent):void{}
		
		/** 被卸载 **/
		private function unLoadHandler(e:Event):void{}
	}
}