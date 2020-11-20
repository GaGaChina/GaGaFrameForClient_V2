package cn.wjj.gagaframe.client.worker.handle 
{
	/**
	 * 处理列表阵列
	 * @author GaGa
	 */
	public class WorkerType 
	{
		
		public function WorkerType() { }
		
		public static function getWorker(type:uint):WorkerBase
		{
			switch (type) 
			{
				case 3000000001:
					return new W_HTTPBase();
				default:
			}
			return null;
		}
	}
}