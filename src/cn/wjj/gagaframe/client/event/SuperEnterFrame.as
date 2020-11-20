package cn.wjj.gagaframe.client.event
{
	import cn.wjj.g;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	internal class SuperEnterFrame
	{
		/** Timer的对象 **/
		private var timer:Timer;
		/** 添加弱引用字典 **/
		private var dict:Dictionary = new Dictionary(true);
		/** 是否启动 **/
		private var isStart:Boolean = false;
		/** 临时引用 **/
		private var f:*;
		/** 临时变量 **/
		private var i:int = 0;
		/** 临时变量 **/
		private var v:Vector.<Function>;
		
		public function SuperEnterFrame() { }
		
		/** 开始运行 **/
		private function start():void
		{
			if(isStart == false)
			{
				isStart = true;
				if(timer == null)
				{
					timer = new Timer(1);
				}
				timer.addEventListener(TimerEvent.TIMER, run);
				timer.start();
			}
		}
		
		/** 停止SuperEnterFrame的运行 **/
		private function stop():void
		{
			if(isStart)
			{
				isStart = false;
				if(timer)
				{
					timer.removeEventListener(TimerEvent.TIMER, run);
					timer.stop();
					timer = null;
				}
			}
		}
		
		private function run(e:TimerEvent):void
		{
			for each (f in dict) 
			{
				if (f is Function)
				{
					f();
				}
				else
				{
					v = f;
					for each (f in v) 
					{
						f();
					}
				}
			}
			f = null;
		}
		
		/**
		 * 添加事件
		 * @param method		方法
		 * @param linkMethodObj		对触发的函数和linkMethodObj绑定,产生弱引用
		 */
		internal function add(method:Function, link:* = null):void
		{
			if (link == null) link = this;
			f = dict[link];
			if (f)
			{
				if (f is Function)
				{
					if (f != method)
					{
						v = g.speedFact.n_vector(Function);
						if (v == null)
						{
							v = new Vector.<Function>();
						}
						v.push(f);
						v.push(method);
						dict[link] = v;
					}
					f = null;
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
			if(isStart == false)
			{
				start();
			}
		}
		
		/** 删除事件 **/
		internal function remove(method:Function, link:* = null):void
		{
			if (link == null) link = this;
			f = dict[link];
			if (f)
			{
				if (f is Function)
				{
					if (f == method)
					{
						dict[link] = null;
						delete dict[link];
					}
					f = null;
				}
				else
				{
					v = f;
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
	}
}