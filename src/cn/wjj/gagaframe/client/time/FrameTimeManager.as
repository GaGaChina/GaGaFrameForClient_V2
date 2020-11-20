package cn.wjj.gagaframe.client.time
{
	import cn.wjj.g;
	
	public class FrameTimeManager
	{
		/** 时间 **/
		public var time:int = 0;
		/** 核心时间 **/
		private var core:Number = 0;
		/** 每一帧的时间 **/
		private var frameTime:Number;
		
		public function FrameTimeManager():void
		{
			g.event.addEnterFrame(frame, this);
		}
		
		private function frame():void
		{
			if (frameTime)
			{
				core += frameTime;
				time = int(core);
			}
			else if(g.bridge.stage)
			{
				frameTime = Math.round(1000 / g.bridge.stage.frameRate * 10000) / 10000;
			}
		}
	}
}

