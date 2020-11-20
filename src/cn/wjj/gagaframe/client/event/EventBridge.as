package cn.wjj.gagaframe.client.event
{
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	
	/**
	 * 事件驱动的对象的入口
	 * 
	 * 提供一个记录事件名称的地方，并且可以根据名称传递数据，激活特定方法，把一些内容和数据耦合起来
	 * 
	 * 例如：
	 * 
	 * function(info);    info数据是自由定义的需要对接
	 * 
	 * add(mc,"Event.Menu.AboutMe",function);
	 * run(Event.Menu.AboutMe,info);
	 * 
	 */
	internal class EventBridge
	{
		/** 记录所有事件桥的对象 **/
		internal var lib:Object = new Object();
		
		public function EventBridge() { }
		
		/**
		 * 添加一个监听事件
		 * @param target		添加的对象
		 * @param name			添加的名称
		 * @param method		添加的函数
		 */
		internal function add(target:*, name:String, method:Function):void
		{
			if(lib.hasOwnProperty(name))
			{
				lib[name].push(target, method);
			}
			else
			{
				var e:EventBridgeObj = new EventBridgeObj();
				e.name = name;
				e.push(target, method);
				lib[name] = e;
			}
		}
		
		/**触发一个事件类型**/
		internal function run(...args):Array
		{
			var n:String = args[0];
			if(lib.hasOwnProperty(n))
			{
				var e:EventBridgeObj = lib[n] as EventBridgeObj;
				var o:Array = g.speedFact.n_array();
				args.shift();
				args.push(o);
				e.dispatchEvent.apply(null, args);
				return o;
			}
			g.log.pushLog(this, LogType._Frame, "事件桥 " + n + " 无监听");
			return null;
		}
		
		/** 删除特定监听的冒一个事件 **/
		internal function removeListener(target:*, name:String, method:Function):void
		{
			if(lib.hasOwnProperty(name))
			{
				var e:EventBridgeObj = lib[name] as EventBridgeObj;
				e.delTargetAddMethod(target, method);
			}
		}
	}
}