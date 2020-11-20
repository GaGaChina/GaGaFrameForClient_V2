package cn.wjj.gagaframe.client.log
{
	
	/**
	 * 日志的类型
	 * 
	 * @version 1.0.0
	 * @author GaGa wjjhappy@Gmail.com
	 * @copy 王加静 www.5ga.cn
	 * @date 2011-11-04
	 */
	public class LogType
	{
		/** GaGaFrame 框架的内部输出日志 **/
		public static const _No:uint = 0;
		/** GaGaFrame 框架的内部输出日志 **/
		public static const _Frame:uint = 1;
		/** 记录 **/
		public static const _Record:uint = 2;
		/** 警告 **/
		public static const _Warning:uint = 3;
		/** 系统 **/
		public static const _System:uint = 4;
		/** 操作记录 **/
		public static const _UserAction:uint = 5;
		/** 截图 **/
		public static const _Screens:uint = 6;
		/** 错误 **/
		public static const _ErrorLog:uint = 7;
		/** 用户提交 **/
		public static const _UserSubmissions:uint = 8;
		/** 普通模式 **/
		public static const _Ordinary:uint = 9;
		/** Socket数据层 **/
		public static const _SocketInfo:uint = 10;
		
		/** 框架 **/
		public function get _Frame():uint { return LogType._Frame; }
		/** 记录 **/
		public function get _Record():uint { return LogType._Record; }
		/** 警告 **/
		public function get _Warning():uint { return LogType._Warning; }
		/** 系统 **/
		public function get _System():uint { return LogType._System; }
		/** 操作记录 **/
		public function get _UserAction():uint { return LogType._UserAction; }
		/** 截图 **/
		public function get _Screens():uint { return LogType._Screens; }
		/** 错误 **/
		public function get _ErrorLog():uint { return LogType._ErrorLog; }
		/** 用户提交 **/
		public function get _UserSubmissions():uint { return LogType._UserSubmissions; }
		/** 普通模式 **/
		public function get _Ordinary():uint { return LogType._Ordinary; }
		/** Socket数据层 **/
		public function get _SocketInfo():uint { return LogType._SocketInfo; }
		
		/** 获取日志的类型 **/
		public function getTypeString(id:uint):String
		{
			switch (id) 
			{
				case 0:
					return "无";
					break;
				case 1:
					return "框架";
					break;
				case 2:
					return "记录";
					break;
				case 3:
					return "警告";
					break;
				case 4:
					return "系统";
					break;
				case 5:
					return "操作记录";
					break;
				case 6:
					return "截图";
					break;
				case 7:
					return "错误";
					break;
				case 8:
					return "用户提交";
					break;
				case 9:
					return "普通模式";
					break;
				case 10:
					return "Socket数据层";
					break;
			}
			return "";
		}
	}
}