package cn.wjj.gagaframe.client.log
{
	import cn.wjj.g;
	
	/**
	 * 提供记录日志记录.
	 * 
	 * @version 1.0.0
	 * @author GaGa wjjhappy@Gmail.com
	 * @copy 王加静 www.5ga.cn
	 * @date 2011-11-04
	 */
	public class Log
	{
		/** 日志的最大长度,如果是-1就不限制,注意:设置后日志会被截取 **/
		private var _maxItem:int = 3000;
		/** 是否开启日志功能,如果为false就自动绕过日志记录 **/
		public var isLog:Boolean = true;
		/** 是否将日志 trace 出来,true:输出 trace 内容,false:隐藏 trace 内容 **/
		public var isTrace:Boolean = true;
		/** 输出trace的时间标识方法,true:[2011年12月31日 下午 04:16:23 星期六 毫秒:040],false:[2011/11/31 AM12:32:30] **/
		public var config_ShowTimeType:Boolean = false;
		/** 日志是否显示出耗费时间, true显示, false 不显示 **/
		public var config_ShowUseTime:Boolean = true;
		/** 日志数据 **/
		internal var logInfo:LogInfo;
		/** 日志的数据类型 **/
		public var logType:LogType;
		/** 浮动日志界面 **/
		internal var float:FloatShow;
		
		/**
		 * 提供记录日志记录.
		 * @param	f	框架引入
		 */
		public function Log():void
		{
			logInfo = new LogInfo();
			logType = new LogType();
		}
		
		/** 日志的最大长度,如果是-1就不限制,注意:设置后日志会被截取 **/
		public function set maxItem(value:int):void
		{
			_maxItem = value;
			logInfo.c();
		}
		
		/** 日志的最大长度,如果是-1就不限制,注意:设置后日志会被截取 **/
		public function get maxItem():int
		{
			return _maxItem;
		}
		
		/**
		 * 获取相关日志.
		 * time		获取日志在那个时间后
		 */
		public function getLog(time:Number = 0):Vector.<Object>
		{
			return logInfo.getLog(time);
		}
		
		/**
		 * 获取从p日志以后的全部日志
		 * @param	p	一个锚点,指针,标识这条以后的全部日志
		 * @return
		 */
		public function getLogUsePosition(p:Object):Vector.<Object>
		{
			return logInfo.getLogUsePosition(p);
		}
		
		/**
		 * 添加一条日志,可以包含发出日志的对象,日志的类型,以及要输出的一系列参数
		 * @param	target	发出日志的对象
		 * @param	type	记录的日志类型:记录,错误,用户操作,截图,用户提交,警告,系统,框架
		 * @param	...args	内容
		 */
		public function pushLog(target:*= null, type:uint = 0, ...args):void
		{
			if (isLog)
			{
				logInfo.pushLog(target, type, args);
			}
		}
		
		/**
		 * 获取线程里的数据
		 * @param	name	线程的名称
		 * @param	o		线程数据
		 */
		public function workerLog(name:String, o:Object):void
		{
			if (isLog)
			{
				logInfo.workerLog(name, o);
			}
		}
		
		/** 添加一条简单的日志,只包含日志的内容 **/
		public function pushMinLog(...args):void
		{
			if (isLog)
			{
				logInfo.pushLog(null, 0, args);
			}
		}
		
		/** 输出全部的日志 **/
		public function toString():String
		{
			return logInfo.toString();
		}
		
		/** 打开浮动日志显示框,并且日志记录条数不允许少于3000行 **/
		public function floatOpen():void
		{
			if (isLog == false) isLog = true;
			if (maxItem < 3000) maxItem = 3000;
			if (float)
			{
				g.bridge.root.addChild(float);
			}
			else if(g.bridge.root)
			{
				float = new FloatShow();
				float.pushAll(logInfo.lib);
				g.bridge.root.addChild(float);
			}
			else
			{
				pushLog(this, LogType._Frame, "弹出浮动日志失败,缺少 f.bridge.root");
			}
		}
		
		/** 关闭浮动显示框 **/
		public function floatClose():void
		{
			if (float)
			{
				float.dispose();
				float = null;
			}
		}
	}
}