package cn.wjj.gagaframe.client.loader
{
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	
	/**
	 * 下载的列表，队伍
	 * 
	 * 管理队列
	 */
	public class Team extends AbstractItemBase
	{
		/** 下载队列的名称 **/
		public var name:String = "";
		/** 队列中总共有多少任务进程 **/
		public var itemTotal:int = 0;
		/** 队列中已经完成的任务进程 **/
		public var itemLoaded:int = 0;
		/** 队列中必载总共有多少任务进程 **/
		public var itemFinishTotal:int = 0;
		/** 队列中已经完成的必载入任务进程 **/
		public var itemFinishLoaded:int = 0;
		/** 队列中必载内容全部下载字节数 **/
		public var bytesFinishTotal:int = 0;
		/** 队列中必载内容已经下载字节数 **/
		public var bytesFinishLoaded:int = 0;
		/** 是否重新被添加过,例如重新将函数加入,这样需要再次循环执行下 **/
		//public var isComplete:Boolean = false;
		/** 必载的是否下载完毕 **/
		public var isLoaded:Boolean = false;
		/** 必载和预载的是否下载完毕 **/
		public var isAllLoaded:Boolean = false;
		/** 这个队列中包含的Item **/
		public var itemList:Vector.<Item> = new Vector.<Item>;
		
		/**
		 * 新建一个队列,并设置名称
		 * @param teamName
		 */
		public function Team():void { }
		
		override internal function reSet(vars:*):void
		{
			super.reSet(vars);
			this.name = (vars.name != undefined && String(vars.name) != "") ? vars.name : "LoaderTeam" + String(AbstractItemBase.objID++);
		}
		
		/**
		 * 改变整个队列里的
		 * @param	method
		 */
		public function allIsGetToLoad(method:Function = null):void
		{
			this.itemTotal = 0;
			this.itemLoaded = 0;
			this.itemFinishTotal = 0;
			this.itemFinishLoaded = 0;
			for each (var item:Item in itemList)
			{
				item.isGetToLoad = false;
				this.itemTotal++;
				if (item.isComplete)
				{
					this.itemLoaded++;
				}
			}
			this.itemFinishTotal = this.itemTotal;
			this.itemFinishLoaded = this.itemLoaded;
			if (method != null)
			{
				this.onAllComplete(method);
			}
		}
		
		/**这个执行是从 TeamDo 中过来的,TeamDo 是辅助这个队列判断下载的程度的**/
		override internal function set state(value:int):void
		{
			super.state = value;
			if (state == ItemState.FINISH)
			{
				if(g.loader.isLog)
				{
					g.log.pushLog(this, LogType._Frame, "下载队列 Team 必载完成任务!");
				}
			}
			else if(state == ItemState.ERROR)
			{
				if(g.loader.isLog)
				{
					g.log.pushLog(this, LogType._Frame, "下载队列 Team 出现错误,自行删除中!");
				}
				dispose();
			}
			else if(state == ItemState.COMPLETE)
			{
				if(g.loader.isLog)
				{
					g.log.pushLog(this, LogType._Frame, "下载队列 Team 必载与预载都完成任务,自行删除中!");
				}
				dispose();
			}
		}
		
		/**
		 * 为队列添加一个子内容
		 * @param url
		 * 
		 */
		public function addItem(vars:Item):void
		{
			for each (var o:Item in itemList) 
			{
				if(o === vars)
				{
					return;
				}
			}
			itemList.push(vars);
			if(!vars.isComplete && g.loader.farm.taskList.indexOf(vars) == -1)
			{
				g.loader.farm.taskList.push(vars);
			}
		}
		
		/**
		 * 删除这个队列
		 */
		override public function dispose():void
		{
			g.loader.farm.delTeam(this.name);
			super.dispose();
			itemList.length = 0;
		}
		
		/** 数据添加完毕 **/
		public function start():void
		{
			state = ItemState.WAIT;
			if(itemList.length)
			{
				for each (var o:Item in itemList) 
				{
					if(o.state === ItemState.INIT)
					{
						o.state = ItemState.WAIT;
					}
				}
				g.loader.farm.start();
			}
			else
			{
				state = ItemState.FINISH;
				state = ItemState.COMPLETE;
				g.loader.farm.start();
			}
		}
	}
}