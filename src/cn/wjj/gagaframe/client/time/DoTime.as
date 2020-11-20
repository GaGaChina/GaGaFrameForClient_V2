package cn.wjj.gagaframe.client.time {
	
	import cn.wjj.time.TimeToString;
	
	public class DoTime{
		
		/**
		 * 将用 Date().getTime() 获取的时间输出为 2011年11月31日 下午 12:32 星期一 毫秒:300
		 * 2011年11月31日 下午 12:32 星期一 毫秒:300
		 * @param	time	Date().getTime(),单位毫秒
		 * @return			2011年11月31日 下午 12:32 星期一 毫秒:300
		 */
		public static function NumberToChinaTime(time:Number):String
		{
			return TimeToString.getString(time, "2000年01月01日 下午 11:59 星期一 毫秒:999");
		}
		
		/**
		 * 将用 Date().getTime() 获取的时间输出为:2011/11/31 AM 12:32:30
		 * 2011/11/31 AM12:32:30
		 * @param	time	Date().getTime(),单位毫秒
		 * @return			2011/11/31 AM 12:32:30
		 */
		public static function NumberToMinTime(time:Number):String{
			return TimeToString.getString(time, "2000/01/01 PM 11:59:59");
		}
		
		/**
		 * 将用 Date().getTime() 获取的时间输出为:2011/11/31 23:32:30
		 * @param	time	Date().getTime(),单位毫秒
		 * @return			2011/11/31 23:32:30
		 */
		public static function NumberToOtherMinTime(time:Number):String
		{
			return TimeToString.getString(time, "2000/01/01 23:59:59");
		}
		
		/**
		 * 将一个毫秒时间转换为中文的时间
		 * @param	time	一个历时的毫秒数
		 * @return			转换为 1Day 12:32:20.395
		 */
		public static function UseTimeToString(time:Number):String
		{
			return TimeToString.getString(time, "1Day 23:59:59.999");
		}
		
		/**
		 * 将一个毫秒时间转换为中文的时间
		 * @param	time	一个历时的毫秒数
		 * @return			转换为 12:32:20或者是324234:00:30
		 */
		public static function NumberToBaseString(time:Number):String {
			return TimeToString.getString(time, "99:59:59");
		}
	}
}