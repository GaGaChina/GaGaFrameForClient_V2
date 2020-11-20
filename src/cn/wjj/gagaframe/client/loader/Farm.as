package cn.wjj.gagaframe.client.loader
{
	import cn.wjj.g;
	import flash.utils.Dictionary;
	
	/**
	 * 管理下载进程
	 * 农场总站
	 */
	internal class Farm
	{
		/** 农民对象集合 **/
		internal var farmerList:Vector.<Farmer> = new Vector.<Farmer>();
		/** 下载的队列列表 **/
		internal var teamList:Vector.<Team> = new Vector.<Team>();
		/** 未完成的任务列表,农民从这个里面取 **/
		internal var taskList:Vector.<Item> = new Vector.<Item>();
		/** 下载的资源列表 **/
		internal var itemList:Dictionary = new Dictionary(false);
		/** 最多多少个农民一起运行 **/
		private var _farmerMax:int = 1;
		/** 每个任务可以重复尝试的次数 **/
		public var maxTries:int = 10;
		/** 有多少个任务是在后台进行的 **/
		public var loadInBackMax:int = 1;
		/** 队伍辅助 **/
		internal var doTeam:TeamDo;
		
		public function Farm():void
		{
			doTeam = new TeamDo();
		}
		
		/** 通过字符串URL,或者Vars实例来获取文件的队列 **/
		internal function getItem(url:String):Item
		{
			if(url == "")return null;
			for (var item:* in itemList)
			{
				if ((item as Item).url == url)
				{
					return item as Item;
				}
			}
			return null;
		}
		
		/** 通过字符串URL,或者Vars实例来获取队列 **/
		internal function getTeam(name:String):Team
		{
			for each(var t:Team in teamList)
			{
				if (t.name == name)
				{
					return t;
				}
			}
			return null;
		}
		
		/**
		 * 添加一个任务列表
		 * @param vars
		 * @param forceStart	是否强行下载
		 * @return 
		 */
		internal function addItem(url:String, forceStart:Boolean = false):Item
		{
			if(url == "")return null;
			var item:Item = getItem(url);
			if(item == null)
			{
				item = new Item(url);
				itemList[item] = true;
				taskList.push(item);
			}
			if(forceStart)
			{
				//强行下载
				var farmer:Farmer = getIdleFarmer();
				farmer.run(item);
			}
			return item;
		}
		
		/**
		 * 如果有这个队列名称就返回,没有就添加一个这个队列
		 * 队列要重新启动,必须删除老队列,然后建立一个新的,才可以重新启动.
		 * @param	teamName	队列的名称
		 * @return
		 */
		internal function addTeam(name:String):Team
		{
			var t:Team = getTeam(name);
			if (t == null)
			{
				t = new Team();
				t.name = name;
				teamList.push(t);
			}
			return t;
		}
		
		/** 删除一个队列 **/
		internal function delTeam(name:String):void
		{
			for(var str:String in teamList)
			{
				if(name == (teamList[str] as Team).name)
				{
					taskList.splice(int(str),1);
				}
			}
		}
		
		/**
		 * 获取一个农民
		 * @param forceStart
		 * @return 
		 * 
		 */
		private function getIdleFarmer(forceStart:Boolean = false):Farmer
		{
			for each(var tempFarmer:Farmer in farmerList)
			{
				if(!tempFarmer.isWork)
				{
					return tempFarmer;
				}
			}
			if(forceStart || farmerList.length < _farmerMax)
			{
				var newFarmer:Farmer = new Farmer();
				farmerList.push(newFarmer);
				return newFarmer;
			}
			return null;
		}
		
		/** 获取一个农民,专门负责预载的 **/
		private function getIdleGetLoaderFarmer():Farmer
		{
			//loadInBackMax  最大的后台的任务农民数
			var theIdleFarmer:Farmer = getIdleFarmer();
			if(theIdleFarmer == null)
			{
				return null;
			}
			var loadInBackNow:int = 0;
			for each(var tempFarmer:Farmer in farmerList)
			{
				if(tempFarmer.item != null && tempFarmer.item.isGetToLoad && !tempFarmer.item.isComplete)
				{
					loadInBackNow++;
				}
			}
			if(loadInBackMax <= loadInBackNow)
			{
				return null;
			}
			else
			{
				return theIdleFarmer;
			}
			return null;
		}
		
		/** 是否在执行 **/
		internal function isRuning():Boolean
		{
			for each(var farmer:Farmer in farmerList)
			{
				if(farmer.isWork)
				{
					return true;
				}
			}
			return false;
		}
		
		/** 开始下载 **/
		internal function start():void
		{
			var i:Item;
			var farmer:Farmer;
			i = getSortWorkItem();
			if (i)
			{
				farmer = getIdleFarmer();
				if(farmer)
				{
					farmer.run(i);
				}
			}
			if(getSortWorkItem() && getIdleFarmer())
			{
				g.status.process.pushMethod(start);
				return;
			}
			//做一些预载的工作
			i = getSortGetLoadWorkItem();
			if (i)
			{
				farmer = getIdleGetLoaderFarmer();
				if(farmer)
				{
					farmer.run(i);
				}
			}
			if(getSortGetLoadWorkItem() && getIdleGetLoaderFarmer())
			{
				g.status.process.pushMethod(start);
			}
		}
		
		/** 获取将要进行的队列,最大优先级,这里获取的都是必须载入的对象 **/
		private function getSortWorkItem():Item
		{
			var o:Item;
			for each(var i:Item in taskList)
			{
				if(i.inFarmer == false && i.isGetToLoad == false)
				{
					if (o == null || o.priority < i.priority)
					{
						o = i;
					}
				}
			}
			//在比较队列
			return o;
		}
		
		/** 获取将要进行的队列,最大优先级,这里获取的都是后台预载的对象 **/
		private function getSortGetLoadWorkItem():Item
		{
			var o:Item;
			for each(var i:Item in taskList)
			{
				//是不是已经被下载了,如果支持调用在下载的情况下,有可以有内存的缓存和硬盘缓存就加入队列
				if(i.inFarmer == false && i.isGetToLoad == true && (i.cacheMemory || i.cacheSO))
				{
					if (o == null || o.priority < i.priority)
					{
						o = i;
					}
				}
			}
			return o;
		}
		
		/** 将一个Item从下载列表中删除 **/
		internal function delInFarmList(tempItem:Item):void
		{
			//var times:int = 0;
			var i:int = taskList.indexOf(tempItem);
			while(i != -1)
			{
				taskList.splice(i, 1);
				i = taskList.indexOf(tempItem);
				//times++;
			}
		}
		
		/**设置最大农民数**/
		internal function set farmerMax(num:int):void
		{
			_farmerMax = num;
		}
		
		/**
		 * 删除一个Item对象
		 * @param temp		要删除的Item对象
		 */
		internal function delItem(temp:Item):void
		{
			var str:String;
			delete itemList[temp];
			var i:int = taskList.indexOf(temp);
			while(i != -1)
			{
				taskList.splice(i, 1);
				i = taskList.indexOf(temp);
			}
		}
	}
}