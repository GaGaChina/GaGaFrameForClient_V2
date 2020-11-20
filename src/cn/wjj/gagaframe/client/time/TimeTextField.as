package cn.wjj.gagaframe.client.time
{
	import cn.wjj.g;
	import cn.wjj.time.TimeToString;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	
	/**
	 * 添加一个倒计时的时间
	 * 可以设置一个特定的UNIX时间点,然后倒计时过去,完成后自动调用complete事件,并且自动删除
	 */
	public class TimeTextField
	{
		/** 对文本框的弱引用 **/
		private var textLib:Dictionary = new Dictionary(true);
		
		private var tempTime:Number = 0;
		
		public function TimeTextField():void { }
		
		/**
		 * 自动添加一个text文本,使得倒计时到结束时间
		 * @param textField		(弱引用)引用的文本框
		 * @param endTime		结束时间
		 * @param textFormat	时间要用的格式化函数
		 * @param complete		完成倒计时的时候自动调用的函数
		 * @param languageId    作为 bitmaptext绑定的id
		 */
		public function addAutoTime(textField:TextField, endTime:Number, textFormat:Function = null, complete:Function = null,languageId:String=""):void
		{
			if (textFormat == null)
			{
				textFormat = TimeToString.NumberToBaseString;
			}
			var item:Object = new Object();
			item.endTime = endTime;
			item.complete = complete;
			item.format = textFormat;
			item.languageId = languageId;
			textLib[textField] = item;
			g.event.addEnterFrame(go);
		}
		
		/**
		 * 删除一个文本的自动倒计时
		 * @param	textField		文本的引用
		 * @param	runComplete		是否自动运行结束函数
		 */
		public function delAutoTime(textField:TextField, runComplete:Boolean = false):void
		{
			var info:Object = textLib[textField];
			if (info)
			{
				if (runComplete)
				{
					if (info.complete != null)
					{
						var method:Function = info.complete;
						method();
					}
				}
				delete textLib[textField];
			}
		}
		
		private function go():void
		{
			var time:Number = new Date().time;
			if ((time - tempTime) >= 1000 )
			{
				tempTime = time;
				var times:int = 0;
				for (var temp:Object in textLib)
				{
					changeTime((temp as TextField), (textLib[temp] as Object));
					times++;
				}
				if (times == 0)
				{
					g.event.removeEnterFrame(go);
				}
			}
		}
		
		private function changeTime(textField:TextField, info:Object):void
		{
			var temp:Number = info.endTime - tempTime;
			if (temp < 0)
			{
				temp = 0;
			}
			var tempFunction:Function = info.format;
			if (info.languageId)
			{
				g.language.setBitmapField(textField, info.languageId, String(tempFunction(temp)));
			}
			else
			{
				textField.text = String(tempFunction(temp));
			}
			if (temp == 0)
			{
				//自动删除这个倒计时
				delete textLib[textField];
				if (info.complete != null)
				{
					var method:Function = info.complete;
					method();
				}
			}
		}
	}
}