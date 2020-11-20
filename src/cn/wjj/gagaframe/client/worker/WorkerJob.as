package cn.wjj.gagaframe.client.worker 
{
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	import cn.wjj.gagaframe.client.worker.handle.WorkerBase;
	import cn.wjj.gagaframe.client.worker.handle.WorkerType;
	/**
	 * 处理每一个WorkerInfo对象
	 * @author GaGa
	 */
	public class WorkerJob 
	{
		/** 要处理的队列内容 **/
		private var item:WorkerInfo;
		
		public function WorkerJob() { }
		
		/**
		 * 开始运行一个小队列
		 * @param	item
		 */
		public function run(item:WorkerInfo):void
		{
			this.item = item;
			try
			{
				if (item.type > 4000000000)
				{
					switch (item.type) 
					{
						case WorkerJobType.Frame_Log:
							g.log.workerLog("worker", item.send.info);
							complete();
							break;
						default:
							g.log.pushLog(this, LogType._Frame, "线程无处理类型 : " + item.type);
					}
				}
				else if (item.type > 3000000000)
				{
					try
					{
						var base:WorkerBase = WorkerType.getWorker(item.type);
						if (item.task.needTrack)
						{
							base.run(item, complete, track);
						}
						else
						{
							base.run(item, complete, null);
						}
					}
					catch (e:Error)
					{
						item.out._isError = true;
						item.out.info = null;
					}
				}
				else
				{
					//切到普通的处理流程
				}
			}
			catch (e:Error)
			{
				
			}
		}
		
		/** 中途有状态修正的时候推送信息 **/
		private function track():void
		{
			item.task.trackItem(item);
		}
		
		/** 完成的时候返回 **/
		private function complete():void
		{
			item.task.completeItem(item);
			g.worker.job.finish(this);
		}
	}
}