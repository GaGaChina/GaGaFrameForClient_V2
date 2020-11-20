package cn.wjj.gagaframe.client.event
{
	import cn.wjj.data.ObjectUtil;
	import cn.wjj.display.DisplaySearch;
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	
	internal class EventData
	{
		/** 记录事件对应的执行函数 **/
		private var list:Vector.<EventDataItem> = new Vector.<EventDataItem>;	
		
		public function EventData():void { }
		
		/**
		 * 监听一个数据源,当里面的冒值发生变化的时候就触发,这个特定函数
		 * @param linkData			(弱引用)数据源
		 * @param groupName			可以为空,是当有数据变化时就执行
		 * @param method			(弱引用)对自动执行函数进行
		 * @param linkMethodObj		自动执行对象的弱引用的连接
		 * @param isPrimitive		[由多监听修改]监听对象是否是一个普通属性,比如String,int,Number等
		 * @param linkItem			是否自动赋值对象
		 */
		public function addEventData(linkData:Object, groupName:String, method:Function, linkMethodObj:* = null, isPrimitive:Boolean = true, linkItem:AutoLinkItem = null):void
		{
			if(ObjectUtil.isPrimitiveType(linkData))
			{
				g.log.pushLog(this, LogType._Frame, "linkData对象非对象,为原始类型不能形成引用!");
			}
			else if(DisplaySearch.objHasDisplay(linkData))
			{
				g.log.pushLog(this, LogType._Frame, "参数linkData对象中不允许出现显示对象!");
				throw new Error("参数linkData对象中不允许出现显示对象");
			}
			else
			{
				var isAdd:Boolean = false;
				var e:EventDataItem;
				for each(e in list)
				{
					if(e.linkData === linkData)
					{
						e.addItem(groupName, method, linkMethodObj, isPrimitive, linkItem);
						isAdd = true;
					}
				}
				if(isAdd == false)
				{
					e = new EventDataItem(linkData);
					e.addItem(groupName, method,linkMethodObj, isPrimitive, linkItem);
					list.push(e);
				}
			}
		}
		
		/**
		 * 移除特定数据源的监听
		 * @param linkData
		 * @param groupName
		 * @param method
		 */
		internal function removeEventData(linkData:Object, groupName:String, method:Function):void
		{
			var e:EventDataItem;
			var id:*;
			if(linkData == null && method == null && groupName == "")
			{
				while(list.length)
				{
					e = list.shift();
					e.dispose();
				}
			}
			else
			{
				for(id in list)
				{
					if(list[id].linkData === linkData)
					{
						list[id].delItem(groupName, method);
						if(list[id].libLength == 0)
						{
							e = list.splice(id,1) as EventDataItem;
							e.dispose();
						}
						return;
					}
				}
			}
		}
		
		/**
		 * 移除特定数据源的监听
		 * @param linkData
		 * @param method
		 */
		internal function removeEventDataForFrame(item:AutoLinkItem):void
		{
			for(var id:* in list)
			{
				list[id].delItemForFrame(item);
			}
		}
		
		/**
		 * 当数据源变化的时候,调用这个函数可以触发数据源里有变化的值
		 * @param	linkData
		 * @param	groupName
		 */
		internal function runEventData(linkData:Object, groupName:String = ""):void
		{
			for each(var e:EventDataItem in list)
			{
				if(e.linkData === linkData)
				{
					e.run(groupName);
				}
			}
		}
		
		/** 移除一个Item **/
		internal function removeEventItem(item:EventDataItem):void
		{
			var id:int = list.indexOf(item);
			if (id != -1)
			{
				list.splice(id, 1);
				item.dispose();
			}
		}
	}
}