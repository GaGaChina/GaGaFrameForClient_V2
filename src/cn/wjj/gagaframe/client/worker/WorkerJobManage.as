package cn.wjj.gagaframe.client.worker 
{
	
	/**
	 * 内部线程管理
	 * @author GaGa
	 */
	public class WorkerJobManage 
	{
		/** 最大空闲的列表 **/
		private var _config_IdleMax:int = 100;
		/** 空闲的任务处理单元 **/
		private var _idle:Vector.<WorkerJob> = new Vector.<WorkerJob>();
		/** 空闲的数量 **/
		private var _idleLength:int = 0;
		/** 工作中的队列列表 **/
		private var _job:Vector.<WorkerJob> = new Vector.<WorkerJob>();
		/** 工作中的队列列表 **/
		private var _jobLength:int = 0;
		
		public function WorkerJobManage() { }
		
		/**
		 * 运行一个队列
		 * @param	item
		 */
		public function run(item:WorkerInfo):void
		{
			var j:WorkerJob;
			if (_idleLength)
			{
				j = _idle.shift();
				_idleLength--;
			}
			else
			{
				j = new WorkerJob();
			}
			_job.push(j);
			_jobLength++;
			j.run(item);
		}
		
		/** 回收工作子集,方便其他的使用 **/
		internal function finish(j:WorkerJob):void
		{
			var index:int = _job.indexOf(j);
			_job.splice(index, 1);
			_jobLength--;
			if (_config_IdleMax < _idleLength)
			{
				_idle.push(j);
				_idleLength++;
			}
		}
		
		/** 最大空闲的列表 **/
		public function get config_IdleMax():int 
		{
			return _config_IdleMax;
		}
		/** 最大空闲的列表,设置0,将清除全部的空闲队列 **/
		public function set idleMax(value:int):void 
		{
			_config_IdleMax = value;
			if (_config_IdleMax < _idleLength)
			{
				var l:int = _idleLength - _config_IdleMax;
				_idle.splice(0, l);
				_idleLength = _config_IdleMax;
			}
		}
	}
}