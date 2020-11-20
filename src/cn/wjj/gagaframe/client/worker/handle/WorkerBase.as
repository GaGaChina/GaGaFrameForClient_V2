package cn.wjj.gagaframe.client.worker.handle 
{
	import cn.wjj.gagaframe.client.worker.WorkerInfo;
	
	/**
	 * 处理事务的基类
	 * @author GaGa
	 */
	public class WorkerBase implements IWorkerInfo 
	{
		
		/** 处理完毕的回调 **/
		protected var follow:Function;
		/** 处理中途的状态回调 **/
		protected var track:Function;
		/** 处理的对象 **/
		protected var info:WorkerInfo;
		
		public function WorkerBase() { }
		
		/**
		 * 任务处理模块
		 * @param	info		处理的信息
		 * @param	follow		处理完成的回调函数
		 * @param	track		处理过程中的进度
		 */
		public function run(info:WorkerInfo, follow:Function, track:Function = null):void 
		{
			this.follow = follow;
			this.track = track;
			if (this.info)
			{
				if (this.info != info)
				{
					throw new Error("逻辑错误");
				}
			}
			else
			{
				this.info = info;
			}
		}
		
		/** 结束掉 **/
		protected function over():void
		{
			if (follow != null)
			{
				follow();
				follow = null;
			}
		}
		
		/** 结束掉 **/
		protected function sendTrack():void
		{
			if (track != null)
			{
				track();
			}
		}
	}
}