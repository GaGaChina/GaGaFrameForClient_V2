package cn.wjj.gagaframe.client.log 
{
	import cn.wjj.display.speed.BitmapDataItem;
	import cn.wjj.display.speed.GetBitmapData;
	import cn.wjj.g;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	/**
	 * 每一条日志的数据
	 * @author GaGa
	 */
	public class FloatShowBar extends Sprite 
	{
		/** 条的宽度 **/
		private var barWidth:int = 0;
		/** 字体大小 **/
		private var fontSize:int = 0;
		/** 时间文字 **/
		private var txTime:TextField;
		/** 类型文字 **/
		private var txType:TextField;
		/** 信息文字 **/
		private var txInfo:TextField;
		/** 类的文本 **/
		private var txClass:TextField;
		/** 时间的宽度 **/
		private var widthTime:int = 0;
		/** 时间的宽度 **/
		private var widthType:int = 0;
		/** 时间的宽度 **/
		private var widthInfo:int = 0;
		/** 背景起点 **/
		private var xTime:int = 0;
		/** 背景起点 **/
		private var xType:int = 0;
		/** 背景起点 **/
		private var xInfo:int = 0;
		/** 条的高度 **/
		private var heigthBar:int = 0;
		
		/** 24小时60分钟60秒1000毫秒 **/
		private const dayTime:Number = 86400000;
		/** 老的颜色 **/
		private var oldColor:uint = 0x000000;
		
		/** 显示的字体样式 **/
		private var format:TextFormat = new TextFormat(null, 14, 0x000000, null, null, null, null, null, null, 0, 0, null, null);
		
		/** Info是否自动设置高度 **/
		private var infoAuto:Boolean = false;
		/** Info是否自动设置高度 **/
		private var bgAlpha:Number = 1;
		/** 时间临时变量 **/
		private var date:Date;
		
		/**
		 * 初始化条
		 * @param	childAlpha		内容透明度
		 * @param	bgAlpha			背景条透明度
		 * @param	infoAuto		是否内容自动高度
		 */
		public function FloatShowBar(childAlpha:Number, bgAlpha:Number, infoAuto:Boolean) 
		{
			this.infoAuto = infoAuto;
			this.bgAlpha = bgAlpha;
			var filter:GlowFilter = new GlowFilter(0xFFFFFF, childAlpha, 2, 2, 10, 2, false, false);
			var a:Array = new Array();
			a.push(filter);
			txTime = new TextField();
			txTime.type = TextFieldType.DYNAMIC;
			txTime.selectable = false;
			txTime.mouseEnabled = false;
			txTime.filters = a;
			txTime.alpha = childAlpha;
			txType = new TextField();
			txType.type = TextFieldType.DYNAMIC;
			txType.selectable = false;
			txType.mouseEnabled = false;
			txType.filters = a;
			txType.alpha = childAlpha;
			txInfo = new TextField();
			txInfo.type = TextFieldType.DYNAMIC;
			txInfo.selectable = false;
			txInfo.mouseEnabled = false;
			txInfo.filters = a;
			txInfo.alpha = childAlpha;
			if (infoAuto)
			{
				txInfo.multiline = true;
				txInfo.wordWrap = true;
				
				txClass = new TextField();
				txClass.type = TextFieldType.DYNAMIC;
				txClass.selectable = false;
				txClass.mouseEnabled = false;
				txClass.filters = a;
				txClass.alpha = childAlpha;
				this.addChild(txClass);
			}
			this.addChild(txTime);
			this.addChild(txType);
			this.addChild(txInfo);
			date = new Date();
		}
		
		/**
		 * 设置文本
		 * @param	w		整个条宽度
		 * @param	size	字体大小
		 */
		internal function setSize(w:int, size:int):void
		{
			this.barWidth = w;
			this.fontSize = size;
			format.size = size;
			txTime.defaultTextFormat = format;
			txTime.setTextFormat(format);
			txTime.x = 0;
			txTime.y = 0;
			txTime.text = "8D 88:88:88.888";
			txTime.width = txTime.textWidth + 4;//1D 23:59:59.999
			txTime.height = txTime.textHeight + 4;
			xTime = 0;
			widthTime = txTime.width;
			
			txType.defaultTextFormat = format;
			txType.setTextFormat(format);
			txType.x = txTime.x + txTime.width + 1;
			txType.y = 0;
			txType.text = "Socket数据层";
			txType.width = txType.textWidth + 4;//Socket数据层 6 字
			txType.height = txType.textHeight + 4;
			xType = txType.x + 1;
			widthType = txType.width - 1;
			
			txInfo.defaultTextFormat = format;
			txInfo.setTextFormat(format);
			txInfo.x = txType.x + txType.width + 1;
			txInfo.y = 0;
			xInfo = txInfo.x + 1;
			if (txInfo.x < w)
			{
				txInfo.width = w - txInfo.x;
			}
			else
			{
				txInfo.width = 0;
			}
			txInfo.height = txType.height;
			if (infoAuto)
			{
				txClass.defaultTextFormat = format;
				txClass.setTextFormat(format);
				txClass.x = txInfo.x;
				txClass.y = 0;
				txClass.width = txInfo.width;
				txClass.height = txType.height;
				
				txInfo.y = txClass.height + 2;
			}
			heigthBar = fontSize + 4;
		}
		
		internal function getBitmap(o:Object):BitmapData
		{
			var color:uint = 0x000000;
			switch(o.type)
			{
				case LogType._ErrorLog:
					color = 0xFF0000;
					break;
				case LogType._Frame:
					color = 0x006600;
					break;
				case LogType._Record:
					color = 0x666666;
					break;
				case LogType._Screens:
					color = 0x006600;
					break;
				case LogType._SocketInfo:
					color = 0x9966FF;
					break;
				case LogType._System:
					color = 0x006600;
					break;
				case LogType._Warning:
					color = 0xFF6600;
					break;
				/*
				case LogType._Ordinary:
					break;
				case LogType._UserAction:
					break;
				*/
			}
			if (oldColor != color)
			{
				oldColor = color;
				format.color = color;
				txTime.defaultTextFormat = format;
				txTime.setTextFormat(format);
				txType.defaultTextFormat = format;
				txType.setTextFormat(format);
				txInfo.defaultTextFormat = format;
				txInfo.setTextFormat(format);
			}
			txTime.text = timeToString(o.time);
			txType.text = g.logType.getTypeString(o.type);
			txInfo.text = o.info;
			this.graphics.clear();
			var barWidth:int = txInfo.textWidth + 2;
			if (infoAuto)
			{
				var classText:String = "";
				if (o.targetName)
				{
					classText += "name : " + o.targetName;
				}
				if (o.targetType)
				{
					classText += " class : " + o.targetType;
				}
				txClass.text = classText;
				if (txInfo.textWidth < txClass.textWidth)
				{
					barWidth = txClass.textWidth + 2;
				}
				txInfo.height = txInfo.textHeight + 4;
				heigthBar = txInfo.y + txInfo.height;
				this.graphics.beginFill(0xFF3300, bgAlpha);
			}
			else
			{
				if (o.id % 2)
				{
					this.graphics.beginFill(0x0066FF, bgAlpha);
				}
				else
				{
					this.graphics.beginFill(0x0099FF, bgAlpha);
				}
			}
			this.graphics.drawRect(xTime, 0, widthTime, heigthBar);
			this.graphics.drawRect(xType, 0, widthType, heigthBar);
			this.graphics.drawRect(xInfo, 0, barWidth, heigthBar);
			this.graphics.endFill();
			var b:BitmapDataItem = GetBitmapData.cacheBitmap(this, true, 0x00000000, 1, true, "best", false);
			return b.bitmapData;
		}
		
		/**
		 * 将一个毫秒时间转换为中文的时间
		 * @param	time	一个历时的毫秒数
		 * @return			转换为 1D 23:59:59.999
		 */
		private function timeToString(time:Number):String
		{
			date.setTime(time);
			var _day:int = Math.floor((time - g.startTime) / dayTime);
			var _hour:Number = date.getHours();
			var _minute:Number = date.getMinutes();
			var _second:Number = date.getSeconds();
			var _m_second:Number = date.getMilliseconds();
			var s:String = String(_day) + "D ";
			if (_hour < 10)
			{
				s += "0" + String(_hour) + ":";
			}
			else
			{
				s += String(_hour) + ":";
			}
			if (_minute < 10)
			{
				s += "0" + String(_minute) + ":";
			}
			else
			{
				s += String(_minute) + ":";
			}
			if (_second < 10)
			{
				s += "0" + String(_second) + ".";
			}
			else
			{
				s += String(_second) + ".";
			}
			if (_m_second > 0)
			{
				if (_m_second < 10)
				{
					s += "00" + String(_m_second);
				}
				else if (_m_second < 100)
				{
					s += "0" + String(_m_second);
				}
				else
				{
					s += String(_m_second);
				}
			}
			else
			{
				s += "000";
			}
			return s;
		}
		
		/** 摧毁 **/
		internal function dispose():void
		{
			if (txTime) txTime = null;
			if (txType) txType = null;
			if (txInfo) txInfo = null;
			if (txClass) txClass = null;
			if (format) format = null;
			if (date) date = null;
			this.removeChildren();
		}
	}
}