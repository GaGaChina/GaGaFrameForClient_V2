package cn.wjj.gagaframe.client.event
{
	import cn.wjj.data.DictValue;
	import cn.wjj.data.ObjectAction;
	import cn.wjj.data.ObjectUtil;
	import cn.wjj.display.DisplaySearch;
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	
	internal class AotoLinkVar
	{
		/** 全部的自动自动赋值对象列表 **/
		private var aotoLinkList:Vector.<AutoLinkItem> = new Vector.<AutoLinkItem>;
		
		public function AotoLinkVar() { }
		
		/**
		 * 自动绑定二个引用对象,当一个发生变化的时候,另一个也会改变(弱引用)
		 * @param setObj		需要设置的引用对象
		 * @param linkData		数据的引用对象
		 * @param group			设置对象里的某一个属性
		 * @param linkGropName	连接的数据对象的某一个属性
		 */
		public function addAotoLinkVar(setObj:Object , linkData:Object, group:String = "", linkGropName:String = ""):void
		{
			if(setObj is Boolean || setObj is Number || setObj is String)
			{
				g.log.pushLog(this, LogType._Frame, "setObj监听的对象非对象,为原始类型不能形成引用");
			}
			else if(linkData is Boolean || linkData is Number || linkData is String)
			{
				g.log.pushLog(this, LogType._Frame, "linkData对象非对象,不能形成引用!");
			}
			else if(DisplaySearch.objHasDisplay(linkData))
			{
				g.log.pushLog(this, LogType._Frame, "参数linkData对象中不允许出现显示对象");
				throw new Error("参数linkData对象中不允许出现显示对象!");
			}
			else
			{
				var _setObj:DictValue = DictValue.instance(setObj);
				var _linkData:DictValue = DictValue.instance(linkData);
				var temp:AutoLinkItem = hasAotoLinkVar(_setObj, _linkData, group, linkGropName);
				if(temp)
				{
					g.log.pushLog(this, LogType._Frame, "已经对这个对象进行了监听");
					eventDataDoing(temp);
				}
				else
				{
					temp = new AutoLinkItem();
					temp.setObj = _setObj;
					temp.linkData = _linkData;
					temp.setGroupName = group;
					temp.linkGropName = linkGropName;
					aotoLinkList.push(temp);
					g.event.addEventDataForFrame(linkData, linkGropName, eventDataDoing, this, temp, true);
					eventDataDoing(temp);
				}
			}
		}
		
		/**
		 * 删除自动赋值
		 * @param setObj
		 * @param linkData
		 * @param setGroupName
		 * @param linkGropName
		 */
		public function removeAotoLinkVar(setObj:Object , linkData:Object, setGroupName:String = "", linkGropName:String = ""):void
		{
			if(setObj is Boolean || setObj is Number || setObj is String)
			{
				g.log.pushLog(this, LogType._Frame, "setObj监听的对象非对象,为原始类型不能形成引用!");
			}
			else if(linkData is Boolean || linkData is Number || linkData is String)
			{
				g.log.pushLog(this, LogType._Frame, "linkData对象非对象,不能形成引用!");
			}
			else if(DisplaySearch.objHasDisplay(linkData))
			{
				g.log.pushLog(this, LogType._Frame, "参数linkData对象中不允许出现显示对象!");
				throw new Error("参数linkData对象中不允许出现显示对象!");
			}
			else
			{
				var _setObj:DictValue = DictValue.instance(setObj);
				var _linkData:DictValue = DictValue.instance(linkData);
				var temp:AutoLinkItem = hasAotoLinkVar(_setObj, _linkData, setGroupName, linkGropName);
				if(temp)
				{
					g.event.removeEventDataForFrame(temp);
				}
				else
				{
					g.log.pushLog(this, LogType._Frame, "未找到这个监听");
				}
			}
		}
		
		/** 从列表里删除特定的对象 **/
		private function removeList(temp:AutoLinkItem):void
		{
			for (var item:* in aotoLinkList) 
			{
				if(item === temp)
				{
					aotoLinkList.splice(item, 1);
					//delete aotoLinkList[item];
					return;
				}
			}
		}
		
		private function eventDataDoing(temp:AutoLinkItem):void
		{
			try
			{
				if(temp.linkData.value == null || temp.setObj.value == null)
				{
					g.event.removeEventDataForFrame(temp);
					g.log.pushLog(this, LogType._Frame, "检测到自动赋值对象或连接数据已经消失,自动删除这个自动赋值");
				}
				else
				{
					var vars:* = ObjectAction.getGroupVar(temp.linkData.value, temp.linkGropName, false);
					ObjectAction.setGroupVar(temp.setObj.value, temp.setGroupName, vars, false);
				}
			}
			catch(e:Error)
			{
				g.log.pushLog(this, LogType._Frame, "自动赋值执行失败!");
			}
		}
		
		/**
		 * 查询列表中是否已经添加了这个引用对象
		 * @param setObj
		 * @param linkData
		 * @param setGroupName
		 * @param linkGropName
		 * @return 
		 */
		private function hasAotoLinkVar(setObj:DictValue , linkData:DictValue, setGroupName:String = "", linkGropName:String = ""):AutoLinkItem
		{
			for each(var temp:AutoLinkItem in aotoLinkList)
			{
				if(temp.setObj.value == setObj.value && temp.linkData.value == linkData.value && temp.setGroupName == setGroupName && temp.linkGropName == linkGropName)
				{
					return temp;
				}
			}
			return null;
		}
	}
}