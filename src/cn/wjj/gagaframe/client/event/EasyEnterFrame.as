package cn.wjj.gagaframe.client.event
{
	import cn.wjj.g;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	/**
	 * (弱引用)
	 * 
	 * @version 2.5.0
	 * @author GaGa wjjhappy@Gmail.com
	 * @copy 王加静 www.5ga.cn
	 * @date 2011-11-04
	 */
	internal class EasyEnterFrame
	{
		/** 一个MovieClip用来触发EnterFrame的 **/
		private var m:MovieClip = new MovieClip();
		/** 是否已经开始跑了 **/
		private var isStart:Boolean = false;
		/** 弱引用记录 **/
		private var dict:Dictionary = new Dictionary(true);
		/** 记录全部函数的列表 **/
		private var methodLib:Dictionary = new Dictionary(true);
		/** 临时变量 **/
		private var i:uint = 0;
		
		public function EasyEnterFrame() { }
		
		/** 开始运行 **/
		private function start():void
		{
			if (isStart == false)
			{
				isStart = true;
				m.addEventListener(Event.ENTER_FRAME, run);
			}
		}
		
		/**
		 * 检查是否还有ENTER_FRAME里的函数,如果没有就停止TempFrame
		 */
		private function stop():void
		{
			if (isStart)
			{
				isStart = false;
				m.removeEventListener(Event.ENTER_FRAME, run);
			}
		}
		
		/**
		 * 不断的循环
		 * @param e
		 */
		private function run(e:Event):void
		{
			for (var _method:* in methodLib) 
			{
				_method();
			}
		}
		
		/**
		 * 添加事件
		 * @param method			方法
		 */
		internal function add(method:Function, link:* = null):void
		{	
			if(!methodLib[method])
			{
				if (link == null) link = this;
				if (dict[link])
				{
					var v:Vector.<Function>;
					if (dict[link] is Function)
					{
						var temp:Function = dict[link];
						v = g.speedFact.n_vector(Function);
						if (v == null)
						{
							v = new Vector.<Function>();
						}
						v.push(temp);
						v.push(method);
						dict[link] = v;
					}
					else
					{
						v = dict[link];
						v.push(method);
					}
				}
				else
				{
					dict[link] = method;
				}
				methodLib[method] = true;
				if(isStart == false)
				{
					isStart = true;
					m.addEventListener(Event.ENTER_FRAME, run);
				}
			}
		}
		
		/** 删除事件 **/
		internal function remove(method:Function, link:* = null):void
		{
			if(methodLib[method] == true)
			{
				if (link == null) link = this;
				if (dict[link])
				{
					if (dict[link] is Function)
					{
						if (dict[link] == method)
						{
							dict[link] = null;
							delete dict[link];
						}
					}
					else
					{
						var v:Vector.<Function> = dict[link];
						i = v.indexOf(method);
						if(i != -1)
						{
							v.splice(i, 1);
							if (v.length == 1)
							{
								dict[link] = v[0];
								g.speedFact.d_vector(Function, v);
							}
						}
					}
				}
			}
			delete methodLib[method];
		}
	}
}