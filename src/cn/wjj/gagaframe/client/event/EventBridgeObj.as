package cn.wjj.gagaframe.client.event
{
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	import flash.utils.Dictionary;
	
	/**
	 * 数据驱动类类型分支
	 */
	internal class EventBridgeObj
	{
		/** 事件桥名称 **/
		internal var name:String = "";
		/** 所有监听存放的地方,使用Obj对象进行连接 **/
		internal var lib:Dictionary = new Dictionary(true);
		
		public function EventBridgeObj():void { }
		
		/**
		 * 为一个对象添加一个事件桥连接
		 * @param	target
		 * @param	tempFunction
		 */
		internal function push(target:*, method:Function):void
		{
			if (hasEvent(target, method) == false)
			{
				if(lib[target] == null)
				{
					lib[target] = g.speedFact.n_array();
				}
				lib[target].push(method);
			}
		}
		
		/** 查看有没有添加了这个监听 **/
		internal function hasEvent(target:*, method:Function):Boolean
		{
			var a:Array = lib[target] as Array;
			if (a && a.indexOf(method) != -1)
			{
				return true;
			}
			return false;
		}
		
		/** 通过对象和函数双验证删除 **/
		internal function delTargetAddMethod(target:*, method:Function):void
		{
			var a:Array = lib[target] as Array;
			if(a)
			{
				var id:int = a.indexOf(method);
				if (id != -1)
				{
					a.splice(id, 1);
					if(a.length == 0)
					{
						g.speedFact.d_array(a);
						lib[target] = null;
						delete lib[target];
					}
					autoDel();
				}
			}
		}
		
		/**
		 * 执行这个事件
		 * @param args	参数
		 */
		internal function dispatchEvent(...args):Array
		{
			var a:Array = args.pop();
			var f:Function;
			var list:Array;
			var copy:Array = g.speedFact.n_array();
			for(var o:* in lib)
			{
				list = lib[o] as Array;
				if(list)
				{
					copy.length = 0;
					copy.push.apply(null, list);
					for each(f in copy)
					{
						if(args.length)
						{
							a.push(f.apply(null, args));
						}
						else
						{
							a.push(f());
						}
					}
				}
				else
				{
					delete lib[o];
				}
			}
			g.speedFact.d_array(copy);
			return a;
		}
		
		/**
		 * 返回这个对象里包含的对象数量
		 * @return 
		 */
		internal function eventLength():uint
		{
			var t:*;
			var l:uint = 0;
			for(t in lib)
			{
				if(lib[t])
				{
					l = l + (lib[t] as Array).length;
				}
			}
			return l;
		}
		
		internal function autoDel():void
		{
			for(var target:* in lib)
			{
				if(lib[target] && lib[target].length)
				{
					return;
				}
			}
			del();
		}
		
		/**
		 * 删除这个监听事件
		 */
		internal function del():void
		{
			if (lib)
			{
				for(var target:* in lib)
				{
					if(lib[target])
					{
						g.speedFact.d_array(lib[target]);
						lib[target] = null;
						delete lib[target];
					}
				}
				lib = null;
			}
			if(g.event.bridge.lib.hasOwnProperty(name))
			{
				delete g.event.bridge.lib[name];
			}
		}
	}
}