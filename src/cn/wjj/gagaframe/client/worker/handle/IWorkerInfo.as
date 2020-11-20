package cn.wjj.gagaframe.client.worker.handle 
{
	import cn.wjj.gagaframe.client.worker.WorkerInfo;
	
	/**
	 * 自动切换各个进程的任务接口
	 * 
	 * 任务ID
	 * 
	 * 任务发送的信息(处理)
	 * 任务接受的信息(处理)
	 * 
	 * @author GaGa
	 */
	public interface IWorkerInfo 
	{
		/**
		 * 任务处理模块
		 * @param	info		处理的信息
		 * @param	follow		处理完成的回调函数
		 * @param	track		处理过程中的进度
		 */
		function run(info:WorkerInfo, follow:Function, track:Function = null):void;
	}
}