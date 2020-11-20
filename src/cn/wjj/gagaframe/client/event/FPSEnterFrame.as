package cn.wjj.gagaframe.client.event
{
	import cn.wjj.g;
	import flash.utils.getTimer;
	
	/**
	 * FPS 的监控如果是比较低的那种会导致FPS不准确,或者稍稍慢一些
	 */
	internal class FPSEnterFrame
	{
		/** FPS的库 **/
		private var lib:Object = new Object();
		/** 是否使用Super的检测方式,效率要低10倍 **/
		internal var _isSuper:Boolean = false;
		/** 临时的item **/
		private var item:FPSEnterFrameItem;
		/** 临时的fpsName **/
		private var fpsName:String;
		/** 临时时间 **/
		private var t:uint = 0;
		/** 运行的次数 **/
		private var libLength:int;
		/** 是否启动 **/
		private var isStart:Boolean = false;
		
		public function FPSEnterFrame():void { }
		
		/** 是否用addSuperEnterFrame **/
		internal function set isSuper(value:Boolean):void
		{
			if(_isSuper != value)
			{
				_isSuper = value;
				if(isStart)
				{
					if(_isSuper)
					{
						g.event.removeEnterFrame(doing, this);
						g.event.addSuperEnterFrame(doing, this);
					}
					else
					{
						g.event.addEnterFrame(doing, this);
						g.event.removeSuperEnterFrame(doing, this);
					}
				}
			}
		}
		
		private function doing():void
		{
			t = getTimer();
			libLength = 0;
			for each(item in lib)
			{
				libLength++;
				//这里这个算法会越算跑的越慢
				if(t >= item.nextTime)
				{
					item.runTime = t;
					item.nextTime = t + item.frameTime;
					if (item.doing() == 0)
					{
						//删除这个队列
						delete lib[String(item._fps)];
						libLength--;
					}
				}
			}
			if (libLength == 0)
			{
				//停下来
				t = 0;
				isStart = false;
				if(_isSuper)
				{
					g.event.removeSuperEnterFrame(doing, this);
				}
				else
				{
					g.event.removeEnterFrame(doing, this);
				}
			}
		}
		
		/**
		 * 添加事件
		 * @param fps				FPS
		 * @param method			方法
		 * @param link				对触发的函数和linkMethodObj绑定,产生弱引用
		 */
		internal function add(fps:Number, method:Function, link:* = null):void
		{
			fpsName = String(fps);
			if(lib.hasOwnProperty(fpsName))
			{
				item = lib[fpsName] as FPSEnterFrameItem;
				item.add(method, link);
			}
			else
			{
				item = new FPSEnterFrameItem(fps);
				if (item.frameTime != 0)
				{
					item.runTime = getTimer();
					//item.runTime = new Date().time;
					item.nextTime = item.runTime + item.frameTime;
					lib[fpsName] = item;
					item.add(method, link);
					if(isStart == false)
					{
						isStart = true;
						t = item.runTime;
						if(_isSuper)
						{
							g.event.addSuperEnterFrame(doing, this);
						}
						else
						{
							g.event.addEnterFrame(doing, this);
						}
					}
				}
			}
		}
		
		/** 删除事件 **/
		internal function remove(fps:Number, method:Function, link:* = null):void
		{
			fpsName = String(fps);
			if(lib.hasOwnProperty(fpsName))
			{
				item = lib[fpsName] as FPSEnterFrameItem;
				item.remove(method, link);
			}
		}
	}
}