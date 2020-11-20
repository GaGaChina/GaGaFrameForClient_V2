package cn.wjj.gagaframe.client.loader{
	
	/**
	 * 下载任务对象的状态
	 */
	public class ItemState
	{
		/** 写入数据中,这个时候不运行执行 **/
		public static const INIT:int = 1;
		/** 等待下载 **/
		public static const WAIT:int = 2;
		/** 取消下载 **/
		public static const CANCEL:int = 3;
		/** 下载完毕 : 不包含余载的内容 **/
		public static const FINISH:int = 4;
		/** 全部下载完毕 : 有一部分任务是预载的,是放在最后面的,完成后在后台驻扎的下载的,那部分任务是预载的,如果也完成,就触发这个事件 **/
		public static const COMPLETE:int = 5;
		/** 发生错误 **/
		public static const ERROR:int = 6;
		/** 开始下载 **/
		public static const START:int = 7;
		/** 正在下载 **/
		public static const PROGRESS:int = 8;
	}
}