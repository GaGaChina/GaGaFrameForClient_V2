package cn.wjj.gagaframe.client.system
{
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	
	public class Status
	{
		/** 运行在什么平台上,SWF,AIR,IOS,Android **/
		public var os:String = "";
		/** 运行的FPS速率,如果要获取场景FPS,请用stageFPS **/
		public var runFPS:FPS;
		/** 方便Flash调用JavaScript的一些功能 **/
		public var js:JavaScriptManage;
		/** 文件地址 **/
		public var rootURL:String = "";
		/** 进程管理 **/
		public var process:ProcessManage;
		/** 错误监控 **/
		public var error:ErrorManage;
		
		/** 查看是否是网络环境 **/
		public var networkMode:Boolean = false;
		/** 是否已经获取了网络环境 **/
		private var isGetNetMode:Boolean = false;
		
		public function Status()
		{
			runFPS = new FPS();
			js = new JavaScriptManage();
			process = new ProcessManage();
			error = new ErrorManage();
		}

		/**
		 * 当前的SWF里设定的FPS值
		 * @return 
		 */
		public function get stageFPS():int
		{
			if(g.bridge.stage)
			{
				return g.bridge.stage.frameRate;
			}
			else
			{
				g.log.pushLog(this, LogType._Frame, "无 g.bridge.stage");
				throw new Error();
			}
			return 0;
		}
	}
}