package cn.wjj.gagaframe.client.system
{
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	import flash.external.ExternalInterface;
	
	/**
	 * 方便Flash调用JavaScript的一些功能
	 * 正对HTTP
	 * 
	 * @version 1.0.0
	 * @author GaGa wjjhappy@Gmail.com
	 * @copy 王加静 www.5ga.cn
	 * 
	 */
	public class JavaScriptManage
	{
		public function JavaScriptManage() { }
		
		/**
		 * 执行一段JavaScript代码,推送到客户端的浏览器
		 * @param js		JavaScript 内容
		 * @param method	执行的函数名称
		 */
		public function runJS(js:String, method:String = ""):void
		{
			if (ExternalInterface.available)
			{
				ExternalInterface.call("eval", js);
				if(method != "")
				{
					ExternalInterface.call(method);
				}
			}
			else
			{
				//指示此播放器是否位于提供外部接口的容器中。如果外部接口可用，则此属性为 true；否则，为 false。 
				g.log.pushLog(this, LogType._System, "播放器没有位于提供外部接口的容器中!外部接口不可用!ExternalInterface.available == false");
			}
		}
		
		/**
		 * 弹出一个JavaScript的window.alert警告窗
		 * @param info
		 */
		public function openAlert(info:String):void
		{
			if (ExternalInterface.available)
			{
				ExternalInterface.call("window.alert", info);
			}
			else
			{ 
				g.log.pushLog(this, LogType._System, "播放器没有位于提供外部接口的容器中!外部接口不可用!ExternalInterface.available == false");
			}
		}
			
		/**
		 * 使用JavaScript屏蔽keyCode按键
		 * @param keyCode
		 */
		public function killKeyCode(keyCode:int):void
		{
			var s:String = "function document.onkeydown(){if(event.keyCode==" + String( keyCode ) + "){event.keyCode=0;event.cancelBubble=true;return false;}}";
			runJS(s);
		}
		
		/**
		 * 使用JavaScript屏蔽所有的按键
		 * @param keyCode
		 */
		public function killAllKey():void
		{
			var s:String = "function document.onkeydown(){event.keyCode=0;event.cancelBubble=true;return false;}";
			runJS(s);
		}
	}
}