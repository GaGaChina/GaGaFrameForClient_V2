package cn.wjj.gagaframe.client.worker 
{
	import cn.wjj.gagaframe.client.speedfact.SpeedLib;
	/**
	 * 任务列表的每条任务
	 * @author GaGa
	 */
	public class WorkerInfo
	{
		/** 对象池 **/
		private static var __f:SpeedLib = new SpeedLib(300);
		
		/** 对象池强引用的最大数量 **/
		static public function get __m():uint { return __f.length; }
		/** 对象池强引用的最大数量 **/
		static public function set __m(value:uint):void { __f.length = value; }
		
		/**
		 * 初始化 Bitmap 对象以引用指定的 BitmapData 对象。
		 */
		public static function instance():WorkerInfo
		{
			var o:WorkerInfo = __f.instance() as WorkerInfo;
			if (o) return o;
			return new WorkerInfo();
		}
		
		/** 移除,清理,并回收 **/
		public function dispose():void
		{
			if (type != 0) type = 0;
			if (task != null) task = null;
			if (_index != 0) _index = 0;
			if (init != null) init = null;
			WorkerInfoOut.clear(out);
			WorkerInfoSend.clear(send);
			WorkerInfoTrack.clear(track);
			if (timeStart != 0) timeStart = 0;
			if (timeOver != 1) timeOver = 1;
			WorkerInfo.__f.recover(this);
		}
		
		/** 任务类型 **/
		public var type:uint = 0;
		/** 任务父级 **/
		public var task:WorkerTask;
		/** 任务的子对象id **/
		internal var _index:int = 0;
		
		/** 任务发起者记录数据(不在线程中互相发送) **/
		public var init:Object;
		/** 任务需要返回的内容(只在执行放进行赋值,并且完成后返回执行方) **/
		public var out:WorkerInfoOut = new WorkerInfoOut();
		/** 任务需要在各个子线程中传递的内容 **/
		public var send:WorkerInfoSend = new WorkerInfoSend();
		/** 任务的状态处理程度 **/
		public var track:WorkerInfoTrack = new WorkerInfoTrack();
		
		/** 单个任务开始时间 **/
		public var timeStart:Number = 0;
		/** 单个任务结束时间 **/
		public var timeOver:Number = 0;
		
		public function WorkerInfo() { }
		
		public function get index():int 
		{
			return _index;
		}
	}
}