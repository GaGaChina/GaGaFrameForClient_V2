package cn.wjj.display
{
	import cn.wjj.data.ObjectUtil;
	import cn.wjj.display.speed.BitmapText;
	import cn.wjj.display.speed.BitmapTextField;
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	
	public class DisplaySearch
	{
		/**
		 * 在容器display获取名称为name对象,没有返回null,有就返回对象
		 * @param	display	要搜索的容器
		 * @param	mc		容器内的名称
		 * @return
		 */
		public static function nameIn(display:DisplayObjectContainer, name:String):*
		{
			if(name)
			{
				var out:DisplayObject = display.getChildByName(name);
				if (out)
				{
					return out;
				}
				var l:int = display.numChildren;
				while (--l > -1)
				{
					if (display.getChildAt(l).name == name)
					{
						return display.getChildAt(l);
					}
				}
			}
			return null;
		}
		
		/**
		 * 在一个容器里通过名称检索对象,例:"display.menu.glod",在容器里找display对象,在display里找menu对象,在menu里在找glod对象
		 * @param groupName
		 * @param display
		 * @param isTrace		是否提示
		 * @return 
		 */
		public static function groupNameIn(display:DisplayObjectContainer, groupName:String, isTrace:Boolean = true):*
		{
			if(groupName == "")
			{
				return display;
			}
			var a:Array = groupName.split(".");
			var l:int = a.length;
			for (var i:int = 0 ; i < l; i++)
			{
				if(display is DisplayObjectContainer && nameIn(display as DisplayObjectContainer,a[i]))
				{
					display = nameIn(display as DisplayObjectContainer,a[i]);
				}
				else
				{
					if(isTrace && g.log.isLog)
					{
						g.log.pushLog(DisplaySearch, LogType._ErrorLog, getGroupName(display) + " 检索 " + groupName + " 失败,中断在:" + getGroupName(display));
					}
					return null;
				}
			}
			return display;
		}
		
		/**
		 * 获取一个显示对象到根的全面路径,display.menu.glod
		 * @param display
		 * @return 
		 * 
		 */
		public static function getGroupName(display:DisplayObject):String
		{
			var str:String = display.name;
			while(display && display is DisplayObjectContainer)
			{
				if(display.parent)
				{
					display = display.parent;
					if(display is flash.display.Stage)
					{
						str = "Stage." + str;
						return str;
					}
					str = display.name + "." + str;
				}
				else
				{
					return str;
				}
			}
			return str;
		}
		
		/**
		 * 搜索容器所有的显示对象,并且以数组返回
		 * @param container				搜索的容器
		 * @param searchInContainer		是否搜索到内部的容器,如果是false就是指搜索单层
		 * @return 
		 */
		public static function searchAllChild(container:DisplayObjectContainer, searchInContainer:Boolean = true):Array
		{
			var list:Array = g.speedFact.n_array();
			if (container)
			{
				var l:int = container.numChildren;
				var child:DisplayObject;
				while (--l > -1)
				{
					child = container.getChildAt(l);
					list.push(child);
					if (searchInContainer && child is DisplayObjectContainer)
					{
						var s:Array = searchAllChild(child as DisplayObjectContainer, searchInContainer);
						if (s.length)
						{
							list.push.apply(null, s);
						}
					}
					l++;
				}
			}
			return list;
		}
		
		/**
		 * 搜索容器中指定类型的对象并以数组方式返回
		 * @param container
		 * @param searchType
		 * @return 
		 */
		public static function searchChild(container:DisplayObjectContainer, searchType:Class):Array
		{
			var list:Array = new Array();
			var l:int = container.numChildren;
			var child:DisplayObject;
			while (--l > -1)
			{
				child = container.getChildAt(l);
				if (child is searchType)
				{
					list.push(child);
				}
				if (child is DisplayObjectContainer)
				{
					var s:Array = searchChild(child as DisplayObjectContainer, searchType);
					if (s.length)
					{
						list.push.apply(null, s);
					}
				}
			}
			return list;
		}
		
		/**
		 * 搜索容器中含有超过一幀的MovieClip的对象并以数组方式返回,递归所有的子对象
		 * @param container
		 * @return 
		 */
		public static function searchMcFrame(container:DisplayObjectContainer):Array
		{
			var list:Array = new Array();
			var l:int = container.numChildren;
			var child:DisplayObject;
			while (--l > -1)
			{
				child = container.getChildAt(l);
				if (child is MovieClip)
				{
					if ((child as MovieClip).totalFrames > 1)
					{
						list.push(child);
					}
				}
				if (child is DisplayObjectContainer)
				{
					var s:Array = searchMcFrame(child as DisplayObjectContainer);
					if (s.length)
					{
						list.push.apply(null, s);
					}
				}
			}
			return list;
		}
		
		/**
		 * 检测一个对象中是否含有显示对象.
		 * @param obj				任何对象
		 * @param maxDoing			已经遍历的次数
		 * @param maxDoingConfig	可以遍历的最高次数
		 * @return 
		 */
		public static function objHasDisplay(obj:*, maxDoing:int = 0, maxDoingConfig:int = 1000):Boolean
		{
			if(obj is DisplayObject)
			{
				return true;
			}
			var type:String;
			for(var temp:* in obj)
			{
				maxDoing++;
				if(temp is Boolean || temp is Number || temp is String)
				{
					break;
				}
				if (temp is DisplayObject)
				{
					return true;
				}
				if (maxDoingConfig < maxDoing)
				{
					//超出限制
					g.log.pushLog(null, LogType._Frame, "objHasDisplay查询超过次数限制,请检测检测对象有无相互引用,导致死循环!");
					return true;
				}
				return objHasDisplay(temp, maxDoing);
			}
			return false;
		}
		
		/** 清理全部的内容,并且清理里面全部的子元件 **/
		public static function searchDispose(container:DisplayObjectContainer, searchType:Class = null):void
		{
			var l:int = container.numChildren;
			if (l)
			{
				var d:Object;
				if (searchType)
				{
					while (--l > -1)
					{
						d = container.getChildAt(l);
						if (d is searchType)
						{
							if ("dispose" in d)
							{
								d.dispose();
							}
						}
					}
				}
				else
				{
					while (--l > -1)
					{
						d = container.getChildAt(l);
						if ("dispose" in d)
						{
							d.dispose();
						}
					}
				}
				container.removeChildren();
			}
		}
		
		/** 清理全部的内容,并且清理里面全部的子元件 **/
		public static function searchDisposeLanguage(container:DisplayObjectContainer):void
		{
			var l:int = container.numChildren;
			if (l)
			{
				var d:Object;
				while (--l > -1)
				{
					d = container.getChildAt(l);
					if (d is BitmapTextField)
					{
						d.dispose();
					}
				}
			}
		}
	}
}