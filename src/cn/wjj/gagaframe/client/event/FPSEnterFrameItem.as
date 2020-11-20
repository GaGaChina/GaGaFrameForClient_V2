package cn.wjj.gagaframe.client.event
{
	import flash.utils.Dictionary;
	
	internal class FPSEnterFrameItem
	{
		/** 每幀的时候执行的函数 **/
		private var lib:Vector.<Function> = new Vector.<Function>();
		/** 添加弱引用字典 **/
		private var dict:Dictionary = new Dictionary(true);
		/** 记录全部函数的列表 **/
		private var methodLib:Dictionary = new Dictionary(true);
		/** 播放的帧频 **/
		internal var _fps:Number;
		/** 每一幀所需要的时间,毫秒 **/
		internal var frameTime:uint;
		/** FPS中上一次播放的时间,毫秒 **/
		internal var runTime:uint = 0;
		/** 下一次运行的时间节点 **/
		internal var nextTime:uint = 0;
		/** 临时函数 **/
		private var _method:*;
		/** 临时变量 **/
		private var i:uint = 0;
		
		/**
		 * 特定的FPS对象,里面可以存放系列的函数.记得删除存在里面的函数.
		 * @param frame			框架的引用
		 * @param fps			这个FPS所执行的FPS频率
		 * @param autoUpdateUI	是否自动更新UI的显示
		 */
		public function FPSEnterFrameItem(fps:Number):void
		{
			_fps = fps;
			frameTime = uint(1000 / fps);
		}
		
		/**
		 * 为这个FPS添加一个运行函数
		 * @param method
		 * @param link		一个对象只能记录一个弱引用的监听函数
		 */
		internal function add(method:Function, link:* = null):void
		{
			if(methodLib[method] == true)
			{
				//已经包含了这个对象
			}
			else
			{
				if (link == null) link = this;
				if (dict[link])
				{
					var vector:Vector.<Function>;
					if (dict[link] is Function)
					{
						var temp:Function = dict[link];
						vector = new Vector.<Function>();
						vector.push(temp);
						vector.push(method);
						dict[link] = vector;
					}
					else
					{
						vector = dict[link];
						vector.push(method);
					}
				}
				else
				{
					dict[link] = method;
				}
				methodLib[method] = true;
			}
		}
		
		/** 运行里面的全部函数,并返回运行次数 **/
		internal function doing():int
		{
			var r:int = 0;
			for (_method in methodLib) 
			{
				_method();
				r++;
			}
			/*
			var vector:Vector.<Function>;
			for each (_method in dict) 
			{
				if (_method is Function)
				{
					_method();
					r++;
				}
				else
				{
					vector = _method;
					for each (_method in vector) 
					{
						_method();
						r++;
					}
				}
			}
			*/
			_method = null;
			return r;
		}
		
		/**
		 * 从这个FPS对象里删除某一个对象
		 * @param method
		 */
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
						var vector:Vector.<Function> = dict[link];
						i = vector.indexOf(method);
						if(i != -1)
						{
							vector.splice(i, 1);
							if (vector.length == 1)
							{
								dict[link] = vector[0];
								vector.length = 0;
							}
						}
					}
				}
			}
			delete methodLib[method];
		}
	}
}