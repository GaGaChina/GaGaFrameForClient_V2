package cn.wjj.gagaframe.client.system
{
	import cn.wjj.g;
	import flash.utils.getTimer;
	
	/**
	 * 统计出每秒多少帧的帧频运行
	 */
	public class FPS
	{
		/** 获取一个FPS **/
		public var fps:int = 0;
		/** 临时时间记录 **/
		private var t:int;
		/** 下一秒时间 **/
		private var s:int;
		/** 已经运行了多少帧 **/
		private var frame:int = 0;
		/** 框架是否启动 **/
		private var run:Boolean = false;
		
		public function FPS() { }
		
		/** 开始统计实施帧频 **/
		public function start():void
		{
			if(run == false)
			{
				run = true;
				s = getTimer() + 1000;
				g.event.addEnterFrame(enterFrame, this);
			}
		}
		
		/** 暂停统计实施帧频 **/
		public function stop():void
		{
			if (run)
			{
				run = false;
				g.event.removeEnterFrame(enterFrame, this);
			}
		}
		
		/** 每次运行 **/
		private function enterFrame():void
		{
			t = getTimer();
			if(s > t)
			{
				frame++;
			}
			else
			{
				fps = frame;
				frame = 0;
				s = t + 1000;
			}
		}
	}
}