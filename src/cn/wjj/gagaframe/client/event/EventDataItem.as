package cn.wjj.gagaframe.client.event
{
	import cn.wjj.data.DictLink;
	import cn.wjj.data.DictValue;
	import cn.wjj.data.ObjectAction;
	import cn.wjj.data.ObjectClone;
	import cn.wjj.data.ObjectUtil;
	import cn.wjj.g;
	
	internal class EventDataItem
	{
		/** 原始值的引用 **/
		private var link:DictValue;
		/** 拷贝这个值,用于对照(当监听对象数据的时候才进行拷贝) **/
		private var copy:Object;
		/** 是否已经启用copy **/
		private var useCopy:Boolean = false;
		
		/**
		 * 监听的groupName列表
		 * 
		 * 
		 * lib[groupName] = o
		 * 
		 * o.primitive  			是否是一个值的属性(以Primitive为准,如果有Primitive就不能在修改为引用,可以节约内存)
		 * o.vars					旧的属性
		 * o.list (Array)			每个对象
		 * o.length int				list有多少个对象
		 * 
		 * item.list.linkMethodObj		对应函数的记录
		 * item.list.method				每个对象的函数
		 * item.list.AutoLinkItem		每个对象的附带对象
		 */
		internal var lib:Object;
		/** 监听的函数量 **/
		internal var libLength:int = 0;
		/** 空对象的监听 **/
		internal var libNull:Object;
		
		public function EventDataItem(linkData:Object):void
		{
			this.link = DictValue.instance(linkData);
			lib = new Object();
			libNull = new Object();
			libNull.primitive = true;
			libNull.length = 0;
		}
		
		/** 监听的数据源 **/
		public function get linkData():Object
		{
			return link.value;
		}

		/**
		 * 为这个数据源添加一个自动执行方法
		 * @param groupName			连接对象相对的位置
		 * @param method			自动执行的函数
		 * @param linkMethodObj		对自动执行函数进行弱引用
		 * @param isPrimitive		[由多监听修改]监听对象是否是一个普通属性,比如String,int,Number等
		 * @param autoItem			是否执行自动赋值
		 */
		internal function addItem(groupName:String, method:Function, linkMethodObj:* = null, isPrimitive:Boolean = true, autoItem:AutoLinkItem = null):void
		{
			if (!groupName) groupName = "";
			if(method != null && hasItem(groupName, method) == false)
			{
				if(linkMethodObj == null)
				{
					linkMethodObj = this;
				}
				//找出对应的 groupName 内容
				var o:Object;
				if (groupName)
				{
					if (lib.hasOwnProperty(groupName))
					{
						o = lib[groupName];
					}
					else
					{
						o = new Object();
						o.primitive = true;
						o.length = 0;
						lib[groupName] = o;
						libLength++;
					}
				}
				else
				{
					o = libNull;
				}
				if (o.primitive != isPrimitive)
				{
					//属性产生切换,单向只能向大替换
					if (isPrimitive == false)
					{
						o.primitive = isPrimitive;
						if (o.primitive == false && o.hasOwnProperty("vars"))
						{
							o.vars = null;
							delete o["vars"];
						}
						setCopyInfo();
					}
				}
				if(o.primitive && o.hasOwnProperty("vars") == false)
				{
					var vars:* = ObjectAction.getGroupVar(linkData, groupName, false);
					if (vars is Object || vars is Array || vars is Function || vars is Class)
					{
						o.vars = ObjectClone.deepClone(vars);
					}
					else
					{
						o["vars"] = vars;
					}
				}
				//每一个
				var list:Array;
				if (o.hasOwnProperty("list"))
				{
					list = o.list as Array;
				}
				else
				{
					list = g.speedFact.n_array();
					o.list = list;
				}
				//没个记录自动触发的函数
				var item:Object = new Object();
				item.primitive = isPrimitive;
				item.method = new DictLink(linkMethodObj, method);
				item.auto = autoItem;
				o.list.push(item);
				o.length++;
			}
		}
		
		/** 遍历查阅是否需要制作COPY对象 **/
		private function setCopyInfo():void
		{
			var isLink:Boolean = false;
			if (libNull.primitive == false)
			{
				isLink = true;
			}
			else
			{
				for (var name:String in lib) 
				{
					if (lib[name].primitive == false)
					{
						isLink = true;
						break;
					}
				}
			}
			if (isLink)
			{
				if (useCopy == false)
				{
					useCopy = true;
					this.copy = ObjectClone.deepClone(linkData);
				}
			}
			else
			{
				if (useCopy)
				{
					useCopy = false;
					this.copy = null;
				}
			}
		}
		
		/**
		 * 查看是否已经添加了自动执行函数
		 * @param groupName
		 * @param method
		 * @return 
		 */
		private function hasItem(groupName:String, method:Function):Boolean
		{
			var list:Array;
			var o:Object;
			if (groupName)
			{
				if (libLength)
				{
					if (lib.hasOwnProperty(groupName) && lib[groupName].length > 0)
					{
						list = lib[groupName].list as Array;
						for each (o in list) 
						{
							if (o.method.value == method)
							{
								return true;
							}
						}
					}
				}
			}
			else
			{
				if (libNull.length > 0)
				{
					list = libNull.list as Array;
					for each (o in list) 
					{
						if (o.method.value == method)
						{
							return true;
						}
					}
				}
			}
			return false;
		}
		
		/**
		 * 删除整个事件,或者是删除特定名称事件,或者是删除特定函数
		 * @param groupName
		 * @param method
		 * 
		 */
		internal function delItem(groupName:String, method:Function):void
		{
			if (method != null)
			{
				var i:int;
				var list:Array;
				var d:Object;
				if (!groupName) groupName = "";
				if (groupName)
				{
					if (libLength && lib.hasOwnProperty(groupName))
					{
						i = lib[groupName].length;
						list = lib[groupName].list as Array;
						while (--i > -1)
						{
							if (list[i].method.value == method)
							{
								d = list[i];
								list.splice(i, 1);
								d.method.dispose();
								delete d.method;
								delete d.auto;
								lib[groupName].length--;
								if (lib[groupName].length == 0)
								{
									g.speedFact.d_array(lib[groupName].list);
									delete lib[groupName].list;
									if(lib[groupName].primitive)
									{
										delete lib[groupName].vars;
									}
									lib[groupName] = null;
									delete lib[groupName];
									libLength--;
									if (libLength == 0 && libNull.length == 0)
									{
										//可以干掉了
										dispose();
									}
								}
								return;
							}
						}
					}
				}
				else
				{
					if (libNull.length)
					{
						i = libNull.length;
						list = libNull.list as Array;
						while (--i > -1)
						{
							if (list[i].method.value == method)
							{
								d = list[i];
								list.splice(i, 1);
								d.method.dispose();
								delete d.method;
								delete d.auto;
								libNull.length--;
								if (libLength == 0 && libNull.length == 0)
								{
									//可以干掉了
									dispose();
								}
								return;
							}
						}
					}
				}
			}
		}
		
		/**
		 * 删除本组全部的内容
		 * 
		 */
		internal function dispose():void
		{
			if (link)
			{
				link.dispose();
				link = null;
			}
			var i:int;
			var list:Array;
			var d:Object;
			if (lib)
			{
				if (libLength)
				{
					for (var name:String in lib) 
					{
						//有属性必定有长度
						i = lib[name].length;
						list = lib[name].list as Array;
						while (--i > -1)
						{
							d = list[i];
							d.method.dispose();
							delete d.method;
							delete d.auto;
						}
						lib[name].length = 0;
						g.speedFact.d_array(list);
						delete lib[name].list;
						if(lib[name].primitive)
						{
							delete lib[name].vars;
						}
						lib[name] = null;
						delete lib[name];
					}
					libLength = 0;
				}
				lib = null;
			}
			if (libNull)
			{
				if (libNull.length)
				{
					i = libNull.length;
					list = libNull.list as Array;
					while (--i > -1)
					{
						d = list[i];
						d.method.dispose();
						delete d.method;
						delete d.auto;
					}
					list.length = 0;
					libNull.length = 0;
					delete libNull.list;
				}
				libNull = null;
			}
			g.event.eventData.removeEventItem(this);
		}
		
		internal function delItemForFrame(auto:AutoLinkItem):void
		{
			var i:int;
			var list:Array;
			var d:Object;
			if (libLength)
			{
				for (var name:String in lib) 
				{
					i = lib[name].length;
					list = lib[name].list as Array;
					while (--i > -1)
					{
						if (list[i].auto == auto)
						{
							d = list[i];
							list.splice(i, 1);
							d.method.dispose();
							delete d.method;
							delete d.auto;
							lib[name].length--;
							if (lib[name].length == 0)
							{
								g.speedFact.d_array(lib[name].list);
								delete lib[name].list;
								if (lib[name].primitive)
								{
									delete lib[name].vars;
								}
								lib[name] = null;
								delete lib[name];
								libLength--;
								if (libLength == 0 && libNull.length == 0)
								{
									//可以干掉了
									dispose();
								}
							}
							return;
						}
					}
				}
			}
			if(libNull.length)
			{
				i = libNull.length;
				list = libNull.list as Array;
				while (--i > -1)
				{
					if (list[i].auto == auto)
					{
						d = list[i];
						list.splice(i, 1);
						d.method.dispose();
						delete d.method;
						delete d.auto;
						libNull.length--;
						if (libLength == 0 && libNull.length == 0)
						{
							//可以干掉了
							dispose();
						}
						return;
					}
				}
			}
		}
		
		/**
		 * 运行这个数据对象的groupName的事件桥
		 * @param	groupName	空是要检查全部,否则是检查指定内容
		 */
		public function run(changeName:String = ""):void
		{
			var copyChange:Boolean = false;
			if(useCopy && ObjectUtil.equals(copy, link.value))
			{
				copyChange = true;
			}
			if (libLength)
			{
				var length:int = changeName.length;
				for (var name:String in lib)
				{
					//当传入groupName的时候执行的方法
					if (length == 0 || name.substr(0, length) == changeName)
					{
						runObject(lib[name], name, copyChange);
					}
				}
			}
			if (changeName == "")
			{
				if (libNull.length > 0)
				{
					runObject(libNull, "", copyChange);
				}
			}
			if (copyChange)
			{
				this.copy = ObjectClone.deepClone(link.value);
			}
		}
		
		private function runObject(o:Object, name:String, copyChange:Boolean):void
		{
			var list:Array = o.list as Array;
			var item:Object;
			var copyList:Array;
			var vars:*;
			if (o.primitive)
			{
				var isPrimitive:Boolean = true;
				vars = ObjectAction.getGroupVar(link.value, name, false);
				if (vars is Object || vars is Array || vars is Function || vars is Class)
				{
					isPrimitive = false;
				}
				var isRun:Boolean = false;
				if (isPrimitive)
				{
					if (o.vars != vars)
					{
						isRun = true;
						o.vars = vars;
					}
				}
				else
				{
					if (ObjectUtil.equals(o.vars, vars) == false)
					{
						isRun = true;
						o.vars = ObjectClone.deepClone(vars);
					}
				}
				if (isRun)
				{
					copyList = g.speedFact.n_array();
					copyList.push.apply(null, list);
					for each (item in copyList) 
					{
						if (item.method.value)
						{
							if (item.auto)
							{
								item.method.value(item.auto);
							}
							else
							{
								item.method.value();
							}
						}
					}
				}
			}
			else if(copyChange)
			{
				if (name == "" || ObjectUtil.equals(ObjectAction.getGroupVar(copy, name, false), ObjectAction.getGroupVar(link.value, name, false)) == false)
				{
					//数据有变
					copyList = g.speedFact.n_array();
					copyList.push.apply(null, list);
					for each (item in copyList) 
					{
						if (item.method.value)
						{
							if (item.auto)
							{
								item.method.value(item.auto);
							}
							else
							{
								item.method.value();
							}
						}
					}
				}
			}
		}
	}
}