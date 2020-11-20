package cn.wjj.time
{
	import cn.wjj.tool.StringReplace;
	
	/**
	 * 将时间模块转换为字符形式输出
	 * 
	 * @version 1.5.0
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 * @date 2012-08-04
	 */
	public class TimeToString
	{
		/** 临时一个时间 **/
		private static var date:Date = new Date();
		
		/** 86400000, 24小时60分钟60秒1000毫秒 24 * 60 * 60 * 1000 **/
		private static var dayTime:Number = 86400000;
		/** 3600000, 60分钟60秒1000毫秒 60*60*1000 **/
		private static var hourTime:Number = 3600000;
		/** 60000, 60秒1000毫秒 60 * 1000 **/
		private static var minuteTime:Number = 60000;
		
		
		/**
		 * 将一个
		 * @param time		Date().time,单位毫秒
		 * @param strType	输出的模式<br />
		 * 2000年01月01日 下午 11:59 星期一 毫秒:999<br />
		 * 2000/01/01 PM 11:59:59<br />
		 * 2000/01/01 23:59:59<br />
		 * 00/01/01 23:59:59<br />
		 * 2000-01-01 23:59:59<br />
		 * 1Day 23:59:59.999 (这段时间所消耗的时间)<br />
		 * 99:59:59 类似 00:00:05 (这段时间所消耗的时间)<br />
		 * 9:59 转换为 9:59 或者是 99:59:59
		 * 09:59 转换为 09:59 或者是 559:59
		 * @return 
		 * 
		 */
		public static function getString(time:Number, strType:String = ""):String
		{
			switch(strType)
			{
				case "2000年01月01日 下午 11:59 星期一 毫秒:999":
					return TimeToString.NumberToChinaTime(time);
					break;
				case "2000/01/01 PM 11:59:59":
					return TimeToString.NumberToMinTime(time, true, true, "/", ":");
					break;
				case "2000/01/01 23:59:59":
					return TimeToString.NumberToMinTime(time, true, false, "/", ":");
					break;
				case "00/01/01 23:59:59":
					return TimeToString.NumberToMinTime(time, true, false, "/", ":").substr(2);
					break;
				case "2000-01-01 23:59:59":
					return TimeToString.NumberToMinTime(time, true, false, "-", ":");
					break;
				case "1Day 23:59:59.999":
					return TimeToString.UseTimeToString(time);
					break;
				case "99:59:59":
					return TimeToString.NumberToBaseString(time);
					break;
				case "9:59":
					return TimeToString.NumberToBaseMinString(time);
					break;
				case "09:59":
					return TimeToString.NumberToBaseLengString(time);
					break;
			}
			return "";
		}
		
		/**
		 * 将用 Date().getTime() 获取的时间输出为 2011年11月31日 下午 12:32 星期一 毫秒:300
		 * 2011年11月31日 下午 12:32 星期一 毫秒:300
		 * @param	time	Date().getTime(),单位毫秒
		 * @return			2000年01月01日 下午 23:59 星期一 毫秒:999
		 */
		public static function NumberToChinaTime(time:Number):String
		{
			date.setTime(time);
			var s:String = date.getFullYear() + "年";
			var month:Number = date.getMonth() + 1;
			if (month < 10)
			{
				s += "0" + month + "月";
			}
			else
			{
				s += month + "月";
			}
			var day:Number = date.getDate();
			if (day < 10)
			{
				s += "0" + day + "日";
			}
			else
			{
				s += day + "日";
			}
			var hours:Number = date.getHours();
			if (hours < 12)
			{
				s += " 上午 ";
			}
			else
			{
				s += " 下午 ";
				hours = hours -12;
			}
			if (hours < 10)
			{
				s += "0" + hours;
			}
			else
			{
				s += hours;
			}
			var minutes:Number = date.getMinutes();
			if (minutes < 10)
			{
				s += ":0" + minutes;
			}
			else
			{
				s += ":" + minutes;
			}
			var second:Number = date.getSeconds();
			if (second < 10)
			{
				s += ":0" + second + " 星期";
			}
			else
			{
				s += ":" + second + " 星期";
			}
			switch(date.getDay())
			{
				case 0:
					s += "日";
					break;
				case 1:
					s += "一";
					break;
				case 2:
					s += "二";
					break;
				case 3:
					s += "三";
					break;
				case 4:
					s += "四";
					break;
				case 5:
					s += "五";
					break;
				case 6:
					s += "六";
					break;
			}
			var ms:Number = date.getMilliseconds();
			if (ms < 10)
			{
				s += " 毫秒:00" + ms;
			}
			else if (ms < 100)
			{
				s += " 毫秒:0" + ms;
			}
			else
			{
				s += " 毫秒:" + ms;
			}
			return s;
		}
		
		/**
		 * 将用 Date().getTime() 获取的时间输出为:2011/11/31 AM 12:32:30
		 * @param time		Date().time,单位毫秒
		 * @param hasTime	是否有时间
		 * @param hasPM		是否有AM和PM
		 * @param dataStr	日期中间使用什么分割,比如 "/", "-"
		 * @param timeStr	时间中间用时什么风格,比如 "/", ":"
		 * @return 
		 */
		public static function NumberToMinTime(time:Number, hasTime:Boolean, hasPM:Boolean, dataStr:String, timeStr:String):String
		{
			date.setTime(time);
			var s:String = "";
			s += date.getFullYear() + dataStr;
			var theMonth:Number = date.getMonth() + 1;
			if(theMonth < 10)
			{
				s += "0" + theMonth + dataStr;
			}
			else
			{
				s += theMonth + dataStr;
			}
			var day:Number = date.getDate();
			if(day < 10)
			{
				s += "0" + day;
			}
			else
			{
				s += day;
			}
			if(hasTime == false)
			{
				return s;
			}
			var h:Number = date.getHours();
			if(hasPM)
			{
				if(h < 12)
				{
					s += " AM ";
				}
				else
				{
					s += " PM ";
					h = h -12;
				}
			}
			else
			{
				s += " ";
			}
			if (h < 10)
			{
				s += "0" + h;
			}
			else
			{
				s += h;
			}
			var m:Number = date.getMinutes();
			if(m < 10)
			{
				s += timeStr + "0" + m;
			}
			else
			{
				s += timeStr + m;
			}
			var second:Number = date.getSeconds();
			if(second < 10)
			{
				s += timeStr + "0" + second;
			}
			else
			{
				s += timeStr + second;
			}
			return s;
		}
		
		/**
		 * 获取的时间输出为:2011/11/31 23:32:30
		 * @param	time	Date().getTime,单位毫秒
		 * @return			2000/01/01 23:59:59
		 */
		public static function NumberToOtherMinTime(time:Number):String
		{
			date.setTime(time);
			var s:String = date.getFullYear() + "/";
			time = date.getMonth() + 1;
			if (time < 10)
			{
				s += "0" + time + "/";
			}
			else
			{
				s += time + "/";
			}
			time = date.getDate();
			if (time < 10)
			{
				s += "0" + time;
			}
			else
			{
				s += time;
			}
			s += " ";
			time = date.getHours();
			if (time < 10)
			{
				s += "0" + time;
			}
			else
			{
				s += time;
			}
			time = date.getMinutes();
			if (time < 10)
			{
				s += ":0" + time;
			}
			else
			{
				s += ":" + time;
			}
			time = date.getSeconds();
			if (time < 10)
			{
				s += ":0" + time;
			}
			else
			{
				s += ":" + time;
			}
			return s;
		}
		
		/**
		 * 将用 Date().getTime 获取的时间输出为:2011/11/31 23:32:30
		 * @param	time	单位毫秒
		 * @return			2000-01-01 23:59:59
		 */
		public static function NumberToOtherMinTime2(time:Number):String
		{
			date.setTime(time);
			var s:String = date.getFullYear() + "-";
			time = date.getMonth() + 1;
			if (time < 10)
			{
				s += "0" + time + "-";
			}
			else
			{
				s += time + "-";
			}
			time = date.getDate();
			if (time < 10)
			{
				s += "0" + time + " ";
			}
			else
			{
				s += time + " ";
			}
			time = date.getHours();
			if (time < 10)
			{
				s += "0" + time;
			}
			else
			{
				s += time;
			}
			time = date.getMinutes();
			if (time < 10)
			{
				s += ":0" + time;
			}
			else
			{
				s += ":" + time;
			}
			time = date.getSeconds();
			if (time < 10)
			{
				s += ":0" + time;
			}
			else
			{
				s += ":" + time;
			}
			return s;
		}
		
		/**
		 * 将一个毫秒时间转换为中文的时间
		 * @param	time	一个历时的毫秒数
		 * @return			转换为 1Day 23:59:59.999
		 */
		public static function UseTimeToString(time:Number):String
		{
			var day:uint = int(time / dayTime);
			time = time % dayTime;
			var hour:int = int(time / hourTime);
			time = time % hourTime;
			var minute:int = int(time / minuteTime);
			time = time % minuteTime;
			var second:int = int(time / 1000);
			time = time % 1000;
			var s:String = "";
			if (day)
			{
				s = day + "Day ";
			}
			if (hour)
			{
				if (s != "" && hour < 10)
				{
					s += "0" + hour + ":";
				}
				else
				{
					s += hour + ":";
				}
			}
			if (minute)
			{
				if (s != "" && minute < 10)
				{
					s += "0" + minute + ":";
				}
				else
				{
					s += minute + ":";
				}
			}
			if (second)
			{
				if (s != "" && second < 10)
				{
					s += "0" + second + ".";
				}
				else
				{
					s += second + ".";
				}
			}
			if (s == "")
			{
				s = "0.";
			}
			if (time)
			{
				if (time < 10)
				{
					s += "00" + time;
				}
				else if (time < 100)
				{
					s += "0" + time;
				}
				else
				{
					s += time;
				}
			}
			else
			{
				s += "000";
			}
			return s;
		}
		
		/**
		 * 将一个毫秒时间转换为中文的时间
		 * @param	time	一个历时的毫秒数
		 * @return			转换为 23:59:59 或者是 99:59:59
		 */
		public static function NumberToBaseString(time:Number):String
		{
			var hour:uint = int(time / hourTime);
			time = time % hourTime;
			var minute:int = int(time / minuteTime);
			time = time % minuteTime;
			var second:int = int(time / 1000);
			time = time % 1000;
			var s:String = "";
			if (hour)
			{
				if (hour < 10)
				{
					s += "0" + hour + ":";
				}
				else
				{
					s += hour + ":";
				}
			}
			else
			{
				s += "00:";
			}
			if (minute)
			{
				if (s != "" && minute < 10)
				{
					s += "0" + minute + ":";
				}
				else
				{
					s += minute + ":";
				}
			}
			else
			{
				s += "00:";
			}
			if (second)
			{
				if (s != "" && second < 10)
				{
					s += "0" + second;
				}
				else
				{
					s += second;
				}
			}
			else
			{
				s += "00";
			}
			return s;
		}
		
		/**
		 * 将一个毫秒时间转换为中文的时间
		 * @param	time	一个历时的毫秒数
		 * @return			转换为 9:59 或者是 99:59:59
		 */
		public static function NumberToBaseMinString(time:Number):String
		{
			var hour:uint = int(time / hourTime);
			time = time % hourTime;
			var minute:int = int(time / minuteTime);
			time = time % minuteTime;
			var second:int = int(time / 1000);
			time = time % 1000;
			var s:String = "";
			if (hour)
			{
				if (s != "" && hour < 10)
				{
					s += "0" + hour + ":";
				}
				else
				{
					s += hour + ":";
				}
			}
			if (minute)
			{
				if (s != "" && minute < 10)
				{
					s += "0" + minute + ":";
				}
				else
				{
					s += minute + ":";
				}
			}
			if (second)
			{
				if (s != "" && second < 10)
				{
					s += "0" + second;
				}
				else
				{
					s += second;
				}
			}
			if (s == "")
			{
				s = "0";
			}
			return s;
		}
		
		/**
		 * 将一个毫秒时间转换为简单的分秒格式的形式
		 * @param	time	一个历时的毫秒数
		 * @return			转换为 09:59 或者是 59:59
		 */
		public static function NumberToBaseLengString(time:Number):String
		{
			var minute:Number = Math.floor(time / minuteTime);
			time = time % minuteTime;
			var second:Number = Math.floor(time / 1000);
			time = time % 1000;
			var s:String = "";
			if (minute)
			{
				if (minute < 10)
				{
					s += "0" + minute + ":";
				}
				else
				{
					s += minute + ":";
				}
			}
			else
			{
				s += "00:";
			}
			if (second)
			{
				if (second < 10)
				{
					s += "0" + second;
				}
				else
				{
					s += second;
				}
			}
			else
			{
				s += "00";
			}
			return s;
		}
		
		/**
		 * 获取一个毫秒时间标识已经用掉了几分钟,几小时或几天
		 * @param	time		毫秒时间
		 * @param	day			间距几天的文本,%s是数字,后面天是某一种语言
		 * @param	hours		间距小时的文本,%s是数字,后面天是某一种语言
		 * @param	minute		间距分钟的文本,%s是数字,后面天是某一种语言
		 * @return
		 */
		public static function NumberToFromNow(time:Number, day:String = "%s 天", hours:String = "%s 小时", minute:String = "%s 分钟"):String
		{
			var s:String;
			if (time > dayTime)
			{
				s = String(Math.floor(time / dayTime));
				return StringReplace.mateUseArr(day, "%s", [s]);
			}
			else if(time > hourTime)
			{
				s = String(Math.floor(time / hourTime));
				return StringReplace.mateUseArr(hours, "%s", [s]);
			}
			else if(time > minuteTime)
			{
				s = String(Math.floor(time / minuteTime));
				return  StringReplace.mateUseArr(minute, "%s", [s]);
			}
			else
			{
				return  StringReplace.mateUseArr(minute, "%s", ["1"]);
			}
			return "";
		}
		
		/**
		 * 获取一个毫秒时间的秒时间
		 * @param	time
		 * @return
		 */
		public static function NumberToSecond(time:Number):String
		{
			return String(Math.floor(time/1000));
		}
	}
}