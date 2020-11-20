package cn.wjj.gagaframe.client.event
{
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	internal class OtherEventListener
	{
		/** 所有监听存放的地方,使用Obj对象进行连接 **/
		private var lib:Dictionary = new Dictionary(true);
		/** 是否开启记录Event **/
		private var start:Boolean = true;
		
		/** 临时变量 **/
		private var _o1:Object;
		/** 临时变量 **/
		private var _o2:Object;
		/** 临时变量 **/
		private var _d1:Dictionary;
		/** 布尔值 **/
		private var _b1:Boolean;
		/** 文本 **/
		private var _s1:String;
		/** 文本 **/
		private var _s2:String;
		
		public function OtherEventListener() { }
		
		/**
		 * 替换系统的事件监听
		 * @param o						添加监听的对象
		 * @param type					
		 * @param method
		 * @param useCapture
		 * @param priority
		 * @param useWeakReference		确定对侦听器的引用是强引用，还是弱引用
		 */
		internal function addListener(o:Object, type:String, method:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			if(o as IEventDispatcher == null)
			{
				g.log.pushLog(this, LogType._Warning, "addListener,对象不可添加事件");
			}
			else if(type == "")
			{
				g.log.pushLog(this, LogType._Warning, "addListener,监听类型为空");
			}
			else if(method as Function == null)
			{
				g.log.pushLog(this, LogType._Warning, "addListener,无监听函数");
			}
			else if(start)
			{
				if (hasListener(o, type, method) == false)
				{
					o.addEventListener(type, method, useCapture, priority, useWeakReference);
					_o1 = lib[o];
					if(_o1)
					{
						_o2 = _o1[type];
						if (_o2)
						{
							if (useCapture)
							{
								_d1 = _o2["1"];
								if(_d1 == null)
								{
									_d1 = g.speedFact.n_dictWeak();
									_o2["1"] = _d1;
								}
							}
							else
							{
								_d1 = _o2["0"];
								if(_d1 == null)
								{
									_d1 = g.speedFact.n_dictWeak();
									_o2["0"] = _d1;
								}
							}
						}
						else
						{
							_o2 = g.speedFact.n_object();
							_o1[type] = _o2;
							_d1 = g.speedFact.n_dictWeak();
							if (useCapture)
							{
								_o2["1"] = _d1;
							}
							else
							{
								_o2["0"] = _d1;
							}
						}
					}
					else
					{
						_o1 = g.speedFact.n_object();
						lib[o] = _o1;
						_o2 = g.speedFact.n_object();
						_o1[type] = _o2;
						_d1 = g.speedFact.n_dictWeak();
						if (useCapture)
						{
							_o2["1"] = _d1;
						}
						else
						{
							_o2["0"] = _d1;
						}
					}
					_d1[method] = true;
					_o1 = null;
					_o2 = null;
					_d1 = null;
				}
			}
			else
			{
				o.addEventListener(type, method, useCapture, priority, useWeakReference);
			}
		}
		
		/**
		 * 检查是否有某一项监听
		 * @param	o
		 * @param	type
		 * @param	method
		 * @param	useCapture	冒泡行为
		 */
		internal function hasListener(o:Object, type:String, method:Function, useCapture:Boolean = false):Boolean
		{
			if(start)
			{
				_o1 = lib[o];
				if (_o1)
				{
					_o1 = _o1[type];
					if (_o1)
					{
						if (useCapture)
						{
							_d1 = _o1["1"];
							if (_d1 && _d1[method])
							{
								_o1 = null;
								_d1 = null;
								return true;
							}
						}
						else
						{
							_d1 = _o1["0"];
							if (_d1 && _d1[method])
							{
								_o1 = null;
								_d1 = null;
								return true;
							}
						}
					}
				}
			}
			if (_o1)_o1 = null;
			if (_d1)_d1 = null;
			return false;
		}
		
		/**
		 * 删除一个监听事件
		 * @param	obj			事件的对象
		 * @param	type		事件的类型
		 * @param	method		事件的方法
		 * @param	useCapture	冒泡行为
		 */
		internal function removeListener(o:*, type:String, method:Function, useCapture:Boolean = false):void
		{
			if(o == null)
			{
				g.log.pushLog(this, LogType._Frame, "removeListener 移除对象不存在");
			}
			else if (method as Function == null)
			{
				g.log.pushLog(this,LogType._Warning,"removeListener 函数为空");
			}
			else if (type == "")
			{
				g.log.pushLog(this, LogType._Warning, "removeListener 类型为空");
			}
			else if(o is IEventDispatcher == false)
			{
				g.log.pushLog(this, LogType._ErrorLog, "removeListener 对象无法添加监听");
			}
			else if(start)
			{
				if(hasListener(o, type, method, useCapture))
				{
					//removeEventListener效率比addEventListener更高 大概是hasEventListener的二倍
					//这里不用hasEventListener,因为一般能查到就说明是有的
					o.removeEventListener(type, method, useCapture);
					if (useCapture)
					{
						if (_s1 != "1")_s1 = "1";
						if (_s2 != "0")_s2 = "0";
					}
					else
					{
						if (_s1 != "0")_s1 = "0";
						if (_s2 != "1")_s2 = "1";
					}
					_d1 = lib[o][type][_s1];
					delete _d1[method];
					if (_b1)_b1 = false;
					for (_o1 in _d1)
					{
						_b1 = true;
						break;
					}
					if (_b1 == false)
					{
						g.speedFact.d_dictWeak(_d1);
						_o2 = lib[o][type];
						delete _o2[_s1];
						if (_o2.hasOwnProperty(_s2))
						{
							//检查0里是否还有函数(多重检查)
							_d1 = lib[o][type][_s2];
							for (_o1 in _d1)
							{
								_b1 = true;
								break;
							}
							if (_b1 == false)
							{
								//0,1都没有内容
								delete _d1[_s2];
								g.speedFact.d_dictWeak(_d1);
								g.speedFact.d_object(_o2);
								delete lib[o][type];
								_o1 = lib[o];
								for (_o2 in _o1)
								{
									_b1 = true;
									break;
								}
								if (_b1 == false)
								{
									g.speedFact.d_object(_o2);
									delete lib[o];
								}
							}
						}
						else
						{
							g.speedFact.d_object(_o2);
							delete lib[o][type];
							_o1 = lib[o];
							for (_o2 in _o1)
							{
								_b1 = true;
								break;
							}
							if (_b1 == false)
							{
								g.speedFact.d_object(_o1);
								delete lib[o];
							}
						}
					}
					if (_d1)_d1 = null;
					if (_o1)_o1 = null;
					if (_o2)_o2 = null;
				}
			}
			else
			{
				o.removeEventListener(type, method, useCapture);
			}
		}
		
		/**
		 * 删除一个特定对象的监听
		 * @param obj			一个监听对象
		 */
		internal function removeListenerObj(obj:Object):void
		{
			throw new Error();
			if(obj == null)
			{
				g.log.pushLog(this, LogType._Frame, "removeListener 移除对象不存在");
			}
			else if(obj is IEventDispatcher)
			{
				if(start)
				{
					
				}
				else
				{
					g.log.pushLog(this, LogType._Warning, "未开启事件功能");
				}
			}
			else
			{
				g.log.pushLog(this, LogType._ErrorLog, "对象不能添加监听");
			}
		}
		
		/**
		 * 遍历所有的事件对象,并且删除特定的函数
		 * @param theMethod
		 */
		internal function removeListenerMethod(method:Function):void
		{
			throw new Error();
			if(method == null)
			{
				g.log.pushLog(this, LogType._UserAction, "监听函数为空");
			}
			else
			{
				if(start)
				{
					
				}
				else
				{
					g.log.pushLog(this, LogType._ErrorLog, "未开启事件功能");
				}
			}
		}
		
		/** 删除全部的监听 **/
		internal function removeListenerAll():void
		{
			throw new Error();
			if(start)
			{
				
			}
			else
			{
				g.log.pushLog(this, LogType._ErrorLog, "未开启事件功能");
			}
		}
	}
}