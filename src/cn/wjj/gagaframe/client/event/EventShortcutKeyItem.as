package cn.wjj.gagaframe.client.event 
{
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	
	/**
	 * ...
	 * @author GaGa
	 */
	public class EventShortcutKeyItem 
	{
		/** 列表名称 **/
		public var id:String = "";
		public var list:Vector.<Function>;
		
		public function EventShortcutKeyItem() 
		{
			list = new Vector.<Function>();
		}
		
		public function run():void
		{
			
			try
			{
				for each (var method:Function in list) 
				{
					method();
				}
			}
			catch(e:Error)
			{
				g.log.pushLog(this, LogType._Frame, "键盘事件出错");
			}
		}
		
		/** 添加函数 **/
		public function push(method:Function):void
		{
			if (list.indexOf(method) == -1)
			{
				list.push(method);
			}
		}
		
		/** 查询并且删除函数 **/
		public function removeMethod(method:Function):void
		{
			var index:int = list.indexOf(method);
			if (index != -1)
			{
				list.splice(index, 1);
			}
		}
	}
}