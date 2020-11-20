package cn.wjj.gagaframe.client.loader
{
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	
	internal class TeamDo
	{
		public function TeamDo() { }
		
		/** 改变队列的状态 **/
		public function changeState(tempItem:Item, state:int):void
		{
			switch(state)
			{
				case ItemState.PROGRESS:
					stateProgress(tempItem);
					break;
				case ItemState.FINISH:
					stateFinish(tempItem);
					break;
				/*
				case ItemState.START:
					break;
				case ItemState.ERROR:
					break;
				*/
			}
		}
		
		private function stateState(item:Item):void
		{
			var i:Item;
			for each(var t:Team in g.loader.farm.teamList)
			{
				if (t.itemList.indexOf(item) != -1)
				{
					for each(i in t.itemList)
					{
						//如果有队列已经在农民里,表明正在下载么
						if (i.inFarmer)
						{
							t.state = ItemState.START;
						}
					}
				}
			}
		}
		
		private function stateProgress(item:Item):void
		{
			for each(var team:Team in g.loader.farm.teamList)
			{
				if(team.itemList.indexOf(item) != -1)
				{
					team.bytesTotal = 0;
					team.bytesLoaded = 0;
					team.bytesFinishTotal = 0;
					team.bytesFinishLoaded = 0;
					for each(var i:Item in team.itemList)
					{
						if(i.bytesTotal <= 0)
						{
							team.bytesTotal = team.bytesTotal + 102400;
						}
						else
						{
							team.bytesTotal = team.bytesTotal + i.bytesTotal;
						}
						team.bytesLoaded = team.bytesLoaded + i.bytesLoaded;
						if(!i.isGetToLoad)
						{
							if(i.bytesTotal <= 0)
							{
								team.bytesFinishTotal = team.bytesFinishTotal + 102400;
							}
							else
							{
								team.bytesFinishTotal = team.bytesFinishTotal + i.bytesTotal;
							}
							team.bytesFinishLoaded = team.bytesFinishLoaded + i.bytesLoaded;
						}
					}
					team.state = ItemState.PROGRESS;
				}
			}
		}
		
		/** 检查这个队列是不是一件完成了下载 **/
		private function stateFinish(tempItem:Item):void
		{
			var list:Vector.<Team> = g.loader.farm.teamList;
			var index:int = list.length;
			var t:Team;
			var item:Item;
			while (--index > -1)
			{
				t = list[index];
				if (t.itemList.indexOf(tempItem) != -1)
				{
					t.itemTotal = 0;
					t.itemLoaded = 0;
					t.itemFinishTotal = 0;
					t.itemFinishLoaded = 0;
					for each(item in t.itemList)
					{
						t.itemTotal++;
						if (item.isComplete)
						{
							t.itemLoaded++;
						}
						if(item.isGetToLoad == false)
						{
							t.itemFinishTotal++;
							if (item.isComplete)
							{
								t.itemFinishLoaded++;
							}
						}
					}
					if (t.itemFinishTotal == t.itemFinishLoaded)
					{
						t.isLoaded = true;
						t.state = ItemState.FINISH;
						if(g.loader.isLog)
						{
							g.log.pushLog(this, LogType._Frame, "Team 必载完毕:", t.name);
						}
					}
					else
					{
						t.isLoaded = false;
					}
					if (t.itemTotal == t.itemLoaded)
					{
						t.isAllLoaded = true;
						t.state = ItemState.COMPLETE;
						if(g.loader.isLog)
						{
							g.log.pushLog(this, LogType._Frame, "Team 必载+预载完毕:", t.name);
						}
						list.splice(index, 1);
					}
					else
					{
						t.isAllLoaded = false;
					}
				}
			}
		}
	}
}