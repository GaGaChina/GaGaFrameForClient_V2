package cn.wjj.gagaframe.client.language
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.InterpolationMethod;
	import flash.display.Shape;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import cn.wjj.g;
	import cn.wjj.display.filter.EasyFilter;
	import cn.wjj.display.speed.BitmapDataItem;
	import cn.wjj.display.speed.BitmapTextField;
	import cn.wjj.display.speed.GetBitmapData;
	import cn.wjj.gagaframe.client.log.LogType;
	import cn.wjj.tool.StringReplace;
	
	/**
	 * Language语言处理对象的工具类
	 * 
	 * @version 0.5.2
	 * @author GaGa wjjhappy@Gmail.com
	 * @copy 王加静 www.5ga.cn
	 * @date 2012-08-02
	 */
	public class LanguageApi
	{
		/** 临时字符串 **/
		private static var s:String;
		private static var b:Boolean;
		private static var t:TextField = new TextField();
		/** BitmapTextField 创建文本的时候所用的容器 **/
		private static var bitmapFieldSprite:Sprite = new Sprite();
		/** 文本有投影时候所用的容器 **/
		private static var shadowBitmapFieldSprite:Sprite = new Sprite();
		/** 文本有投影时候所用的零时位图 **/
		private static var shadowBitmap:Bitmap = new Bitmap();
		
		/** BitmapTextField 创建文本的时候所用的遮罩 **/
		private static var bitmapFieldShape:Shape = new Shape();
		/** 文本渐变色 **/
		private static var matr:Matrix = new Matrix();
		/** 没有内容的渐变色 **/
		private static var getRatios0:Array = new Array();
		private static var getRatios1:Array = [0];
		private static var getRatios2:Array = [0,255];
		
		public static function GetLanguageSet(xml:XML):void
		{
			var ver:String = "";
			if(xml.config.@ver && xml.config.@ver != "")
			{
				ver = xml.config.@ver;
			}
			var cacheMemory:Boolean = false;
			if(xml.config.@cacheMemory == "1")
			{
				cacheMemory = true;
			}
			var cacheSO:Boolean = false;
			if(xml.config.@cacheSO == "1")
			{
				cacheSO = true;
			}
		}
		
		/**
		 * 通过一个语言包XML的配置文件,获取到里面的全部数据,并以Object输出
		 * @param xml
		 * @return 
		 */
		public static function GetInfo(xml:XML):Object
		{
			//转换文本信息
			var o:Object = new Object();
			o.font = new Object();
			o.format = new Object();
			o.str = new Object();
			o.img = new Object();
			o.arr = new Array();
			o.amf = new Array();
			GetXMLFont(o.font, xml);
			GetXMLFontFormat(o.format, xml);
			GetXMLString(o.str, xml);
			GetXMLImage(o.img, xml);
			GetXMLAMF(o.amf, xml);
			return o;
		}
		
		/**
		 * 通过一个语言包XML的配置文件,获取到里面的字体相关的数据,并设置到info对象中
		 * @param info	语言包转换到那个对象里
		 * @param xml	语言包配置文件
		 * @return 
		 */
		public static function GetXMLFont(info:Object, xml:XML):void
		{
			
			var l:int = xml.font.children().length();
			var id:String;
			var o:Object;
			for (var i:int = 0; i < l; i++)
			{
				id = xml.font.item[i].@id;
				if(!id)
				{
					g.log.pushLog(LanguageApi, LogType._ErrorLog, "缺少ID")
				}
				else if(id && info.hasOwnProperty(id))
				{
					g.log.pushLog(LanguageApi, LogType._ErrorLog, "ID冲突 : ", id);
				}
				else
				{
					o = new Object();
					o.url = String(xml.font.item[i].@url);
					o.classAllName = String(xml.font.item[i].@classAllName);
					if(xml.font.item[i].hasOwnProperty("@isRegister"))
					{
						if (String(xml.font.item[i].@isRegister) == "1")
						{
							o.register = true;
						}
						else
						{
							o.register = false;
						}
					}
					if(xml.font.item[i].hasOwnProperty("@embedFonts"))
					{
						if (String(xml.font.item[i].@embedFonts) == "1")
						{
							o.embed = true;
						}
						else
						{
							o.embed = false;
						}
					}
					info[id] = o;
				}
			}
		}
		
		/**
		 * 通过一个语言包XML的配置文件,获取到里面的字体相关的数据,并设置到info对象中
		 * @param info	语言包转换到那个对象里
		 * @param xml	语言包配置文件
		 * @return 
		 */
		public static function GetXMLFontFormat(o:Object, xml:XML):void
		{
			var l:int = xml.fontFormat.children().length();
			for (var i:int = 0; i < l; i++)
			{
				GetXMLFontBase(o, xml.fontFormat.item[i], false);
			}
		}
		
		/**
		 * 通过一个语言包XML的配置内容,获取到里面的字体相关的数据,并设置到info对象中
		 * @param o		语言包转换到那个对象里
		 * @param xml	语言包配置文件
		 * @return 
		 */
		public static function GetXMLString(o:Object, xml:XML):void
		{
			var l:int = xml.text.children().length();
			for (var i:int = 0; i < l; i++)
			{
				if(xml.text.item[i])
				{
					GetXMLFontBase(o, xml.text.item[i], true);
				}
				else
				{
					g.log.pushLog(LanguageApi, LogType._Warning, "获取XML有空行 : " + i + " 内容 : " + String(xml.text.item[i]));
				}
			}
		}
		
		/**
		 * 通过一个语言包XML的配置内容,获取图形相关的数据,并合并的Object对象里
		 * @param info
		 * @param xml
		 */
		public static function GetXMLImage(info:Object, xml:XML):void
		{
			var l:int = xml.img.children().length();
			var o:Object;
			for (var i:int = 0; i < l; i++)
			{
				s = xml.img.item[i].@id;
				if(!s)
				{
					g.log.pushLog(LanguageApi, LogType._ErrorLog, "缺少ID")
				}
				else if(s && info.hasOwnProperty(s))
				{
					g.log.pushLog(LanguageApi, LogType._ErrorLog, "ID冲突 : " + s);
				}
				else
				{
					o = new Object();
					o.url = String(xml.img.item[i].@url);
					if(xml.img.item[i].hasOwnProperty("@x"))
					{
						o.x = Number(String(xml.img.item[i].@x));
					}
					if(xml.img.item[i].hasOwnProperty("@y"))
					{
						o.y = Number(String(xml.img.item[i].@y));
					}
					info[s] = o;
				}
			}
		}
		
		/**
		 * 通过一个语言包XML的配置内容,获取图形相关的数据,并合并的Object对象里
		 * @param info
		 * @param xml
		 */
		public static function GetXMLAMF(info:Array, xml:XML):void
		{
			var l:int = xml.amf.children().length();
			var o:Object;
			for (var i:int = 0; i < l; i++)
			{
				s = String(xml.amf.item[i].@url);
				info.push(s);
			}
		}
		
		/**
		 * 从XML获取最基础的信息
		 * @param info		整个数据
		 * @param xml		传入的XML配置
		 * @param isString	是否是文本配置
		 * @return 
		 */
		private static function GetXMLFontBase(info:Object, xml:XML, isText:Boolean):void
		{
			var id:String = String(xml.@id);
			if(!id)
			{
				g.log.pushLog(LanguageApi, LogType._ErrorLog, "缺少ID值")
			}
			else if(id && info.hasOwnProperty(id))
			{
				g.log.pushLog(LanguageApi, LogType._ErrorLog, "有ID冲突 : ", id);
			}
			else
			{
				var o:Object = new Object();
				//是否单独是str内容
				var d:Boolean = true;
				if(isText)
				{
					if(xml.hasOwnProperty("@str"))
					{
						o.str = String(xml.@str);
					}
					else
					{
						o.str = String(xml);
					}
				}
				if(xml.hasOwnProperty("@fontFormatId") && xml.@fontFormatId)
				{
					o.format = String(xml.@fontFormatId);
					d = false;
				}
				if(xml.hasOwnProperty("@isHtml"))
				{
					if (String(xml.@isHtml) == "1")
					{
						o.html =  true;
					}
					else
					{
						o.html =  false;
					}
					d = false;
				}
				var tempArr:Array;
				var tempOut:Array;
				var tempItem:*;
				if(xml.hasOwnProperty("@color"))
				{
					s = String(xml.@color);
					if(s != "")
					{
						tempArr = s.split(",");
						tempOut = new Array();
						for each (tempItem in tempArr) 
						{
							tempOut.push(uint(tempItem));
						}
						o.color = tempOut;
						d = false;
					}
				}
				if(xml.hasOwnProperty("@alpha"))
				{
					if(String(xml.@alpha) != "")
					{
						tempArr = String(xml.@alpha).split(",");
						tempOut = new Array();
						for each (tempItem in tempArr)
						{
							tempOut.push(Number(tempItem));
						}
						o.alpha = tempOut;
						d = false;
					}
				}
				if (xml.hasOwnProperty("@colorRotation"))
				{
					s = String(xml.@colorRotation);
					if(s != "" && s != "90")
					{
						o.colorRotation = Number(s);
						d = false;
					}
				}
				if(xml.hasOwnProperty("@size"))
				{
					o.size = Number(xml.@size);
					d = false;
				}
				if(xml.hasOwnProperty("@leading"))
				{
					o.leading = Number(xml.@leading);
					d = false;
				}
				if(xml.hasOwnProperty("@align"))
				{
					o.align = String(xml.@align);
					d = false;
				}
				if(xml.hasOwnProperty("@shadowSize"))
				{
					o.shadowSize = Number(xml.@shadowSize);
					d = false;
				}
				if(xml.hasOwnProperty("@bold"))
				{
					if(String(xml.@bold) == "1")
					{
						o.bold = true;
					}
					else
					{
						o.bold = false;
					}
					d = false;
				}
				if(xml.hasOwnProperty("@fontId"))
				{
					o.fontId = String(xml.@fontId);
					d = false;
				}
				if(xml.hasOwnProperty("@fontName"))
				{
					o.fontName = String(xml.@fontName);
					d = false;
				}
				if(xml.hasOwnProperty("@embedFonts"))
				{
					if(String(xml.@embedFonts) == "1")
					{
						o.embed = true;
					}
					else
					{
						o.embed = false;
					}
					d = false;
				}
				if(xml.hasOwnProperty("@mbColor"))
				{
					o.mbColor = uint(xml.@mbColor);
					d = false;
				}
				if(xml.hasOwnProperty("@mbSize"))
				{
					o.mbSize = Number(xml.@mbSize);
					d = false;
				}
				if(xml.hasOwnProperty("@x"))
				{
					o.x = Number(String(xml.@x));
					d = false;
				}
				if(xml.hasOwnProperty("@y"))
				{
					o.y = Number(String(xml.@y));
					d = false;
				}
				if(xml.hasOwnProperty("@width"))
				{
					o.width = Number(String(xml.@width));
					d = false;
				}
				if(xml.hasOwnProperty("@multiline"))
				{
					s = String(xml.@multiline);
					if(s == "1")
					{
						o.multiline =  1;
					}
					else if(s == "-1")
					{
						o.multiline =  -1;
					}
					else if(s == "2")
					{
						o.multiline = 2;
					}
					else
					{
						o.multiline =  0;
					}
					d = false;
				}
				if(xml.hasOwnProperty("@autoReSizeWidth"))
				{
					if(String(xml.@autoReSizeWidth) == "1")
					{
						o.autoX =  true;
					}
					else
					{
						o.autoX = false;
					}
					d = false;
				}
				if(xml.hasOwnProperty("@autoReSizeHeight"))
				{
					if(String(xml.@autoReSizeHeight) == "1"){
						o.autoY =  true;
					}
					else
					{
						o.autoY = false;
					}
					d = false;
				}
				if(xml.hasOwnProperty("@canSelete"))
				{
					if(String(xml.@canSelete) == "1")
					{
						o.selete =  true;
					}
					else
					{
						o.selete = false;
					}
					d = false;
				}
				if(xml.hasOwnProperty("@canMouse"))
				{
					if(String(xml.@canMouse) == "1")
					{
						o.mouse =  true;
					}
					else
					{
						o.mouse = false;
					}
					d = false;
				}
				if (d)
				{
					if(isText)
					{
						info[id] = o.str;
					}
				}
				else
				{
					info[id] = o;
				}
			}
		}
		
		/**
		 * 根据fontId与fontFormatID获取这个字体最终的Object,这个Object是一个全新的Object是新复制出来的
		 * @param info			全部的语言数据
		 * @param id			需要引用的text的引用
		 * @param formatId		另外要预先附加的fontFormatID
		 * @return 
		 */
		public static function CopyIdToSetText(info:Object, id:String = "", formatId:String = ""):Object
		{
			var tempText:Object = new Object();
			if(formatId)
			{
				AddInfoInSetText(info, formatId, tempText, true);
			}
			if(id)
			{
				AddInfoInSetText(info, id, tempText, false);
			}
			return tempText;
		}
		
		/**
		 * 将一个textInfo的数据信息,添加到一个tempText对象上
		 * @param info		语言包的全部数据
		 * @param skinId	套用的语言包ID
		 * @param tempText	在一个基础上调整
		 * @param runNumber	递归次数
		 */
		private static function AddInfoInSetText(info:Object, id:String, c:Object, isFormat:Boolean):void
		{
			var o:*;
			if(isFormat)
			{
				if(info.format.hasOwnProperty(id) && info.format[id] != null)
				{
					o = info.format[id];
				}
			}
			else
			{
				if(info.str.hasOwnProperty(id) && info.str[id] != null)
				{
					o = info.str[id];
				}
				if(!o && info.arr.length)
				{
					for each(o in info.arr)
					{
						if(o.hasOwnProperty(id))
						{
							o = o[id];
							break;
						}
					}
				}
			}
			if(o)
			{
				if (o is String)
				{
					c.str = o;
				}
				else
				{
					if(o.hasOwnProperty("format"))
					{
						if(id != o.format)
						{
							AddInfoInSetText(info, o.format, c, true);
						}
						else
						{
							g.log.pushLog(LanguageApi, LogType._ErrorLog, "语言包编号 : " +　id + " 里,有引用编号为 : " + o.format + " 的样式引用,很容易死循环!");
						}
					}
					if (o.hasOwnProperty("str")) c.str = o.str;
					if (o.hasOwnProperty("html")) c.html =  o.html;
					if (o.hasOwnProperty("color")) c.color =  o.color;
					if (o.hasOwnProperty("alpha")) c.alpha =  o.alpha;
					if (o.hasOwnProperty("colorRotation")) c.colorRotation = o.colorRotation;
					if (o.hasOwnProperty("size")) c.size = o.size;
					if (o.hasOwnProperty("leading")) c.leading = o.leading;
					if (o.hasOwnProperty("align")) c.align = o.align;
					if (o.hasOwnProperty("shadowSize")) c.shadowSize = o.shadowSize;
					if (o.hasOwnProperty("bold")) c.bold = o.bold;
					if (o.hasOwnProperty("fontId"))
					{
						if(info.font.hasOwnProperty(o.fontId))
						{
							c.fontId = o.fontId;
						}
						else
						{
							g.log.pushLog(LanguageApi, LogType._ErrorLog, "语言包中未找到编号为 : " +　o.fontId + " 的字体");
						}
					}
					if (o.hasOwnProperty("fontName")) c.fontName = o.fontName;
					if (o.hasOwnProperty("embed")) c.embed = o.embed;
					if (o.hasOwnProperty("mbColor")) c.mbColor = o.mbColor;
					if (o.hasOwnProperty("mbSize")) c.mbSize = o.mbSize;
					if (o.hasOwnProperty("x")) c.x = o.x;
					if (o.hasOwnProperty("y")) c.y = o.y;
					if (o.hasOwnProperty("multiline")) c.multiline = o.multiline;
					if (o.hasOwnProperty("autoX")) c.autoX = o.autoX;
					if (o.hasOwnProperty("autoY")) c.autoY = o.autoY;
					if (o.hasOwnProperty("selete")) c.selete = o.selete;
					if (o.hasOwnProperty("mouse")) c.mouse = o.mouse;
					if (o.hasOwnProperty("width")) c.width = o.width;
				}
			}
			else
			{
				g.log.pushLog(LanguageApi, LogType._ErrorLog, "语言包中未获取到ID: " + id);
			}
		}
		
		/**
		 * 设置一个Bitmap对象的多语言数据
		 * @param imgObj
		 * @param info
		 * @param temp
		 * 
		 */
		public static function SetBitmap(img:Bitmap, info:Object, run:Function = null):void
		{
			if(info)
			{
				if (info.hasOwnProperty("x") && img.x != info.x)
				{
					img.x = info.x;
				}
				if (info.hasOwnProperty("y") && img.y != info.y)
				{
					img.y = info.y;
				}
				if (info.hasOwnProperty("data") && info.data)
				{
					img.bitmapData = info.data;
				}
				else if (info.hasOwnProperty("url") && info.url)
				{
					var a:Array = g.language.config_img_gfile;
					var b:*;
					for each(var gfile:* in a)
					{
						b = gfile.getPathObj(info.url);
						if(b)
						{
							img.bitmapData = b;
							break;
						}
					}
				}
				if(run != null)
				{
					run();
				}
			}
		}
		
		/**
		 * 冲所有的数据中获取某个特殊字体的字体总共的String类型,没有排除重复字
		 * 如果使用了fontName将无法获取到
		 * 
		 * @param fontId
		 * @param info
		 */
		public static function getFontIdAllText(fontId:String, xml:XML):String
		{
			var out:String = "";
			//转换文本信息
			var o:Object = new Object();
			o.font = new Object();
			o.format = new Object();
			o.str = new Object();
			o.img = new Object();
			o.arr = new Array();
			o.amf = new Array();
			GetXMLFont(o.font, xml);
			GetXMLFontFormat(o.format, xml);
			GetXMLString(o.str, xml);
			var info:*;
			var fontInfo:Object;
			/** 是否使用所带字体 **/
			var embed:Boolean;
			for(var id:String in o.str) 
			{
				embed = false;
				info = o.str[id];
				//找到字体样式
				//最终找到字体
				if(info is Object)
				{
					if(info.hasOwnProperty("format") && o.format.hasOwnProperty(info.format) && o.format[info.format].hasOwnProperty("fontId") && o.format[info.format].fontId == fontId)
					{
						//这里强制抓取了~太忙,没顾得写详细了
						embed = true;
					}
					if(info.hasOwnProperty("fontId") && info.fontId == fontId && o.font.hasOwnProperty(info.fontId))
					{
						fontInfo = o.font[info.fontId];
						if(fontInfo.hasOwnProperty("embed"))
						{
							if(fontInfo.embed)
							{
								embed = true;
							}
							else
							{
								embed = false;
							}
						}
					}
					if(info.hasOwnProperty("embed"))
					{
						if(info.embed)
						{
							embed = true;
						}
						else
						{
							embed = false;
						}
					}
					if(embed && info.hasOwnProperty("str"))
					{
						out += String(info.str);
					}
				}
			}
			return out;
		}
		
		/**
		 * 通过多语言的ID来获取这个图片资源的唯一key值
		 * @param	id
		 * @param	args
		 */
		public static function getBitmapTextKey(id:String, args:Array = null):String
		{
			var key:String = "";
			var info:* = g.language.getObject(id);
			if(info)
			{
				if(info is String)
				{
					key = info;
				}
				else
				{
					if(info.hasOwnProperty("bold"))
					{
						if (info.bold)
						{
							key += "01";
						}
						else
						{
							key += "10";
						}
					}
					else
					{
						key += "00";
					}
					//多行,是否为多行,1多行,-1单行
					if(info.hasOwnProperty("multiline"))
					{
						if(info.multiline == 1)
						{
							key += "01";
						}
						else if(info.multiline == -1)
						{
							key += "10";
						}
						else if(info.multiline == 2)
						{
							key += "11";
						}
					}
					else
					{
						key += "00";
					}
					if(info.hasOwnProperty("autoX") && info.autoX)
					{
						key += "1";
					}
					else
					{
						key += "0";
					}
					if(info.hasOwnProperty("autoY") && info.autoY)
					{
						key += "1";
					}
					else
					{
						key += "0";
					}
					if(info.hasOwnProperty("selete") && info.selete)
					{
						key += "1";
					}
					else
					{
						key += "0";
					}
					if(info.hasOwnProperty("mouse") && info.mouse)
					{
						key += "1";
					}
					else
					{
						key += "0";
					}
					if(info.hasOwnProperty("embed"))
					{
						if(info.embed)
						{
							key += "01";
						}
						else
						{
							key += "10";
						}
					}
					else
					{
						key += "00";
					}
					if(info.hasOwnProperty("html") && info.html)
					{
						key += "1";
					}
					else
					{
						key += "0";
					}
					key = uint(parseInt(key, 2)).toString(36);
					if(key == "0")
					{
						key = "";
					}
					if(info.hasOwnProperty("size") && info.size > 0)
					{
						key += Number(info.size).toString(36);
					}
					else
					{
						key += "0";
					}
					if(info.hasOwnProperty("leading") && info.leading > 0)
					{
						key += Number(info.leading).toString(36);
					}
					else
					{
						key += "0";
					}
					if(info.hasOwnProperty("align") && info.align)
					{
						key += info.align;
					}
					else
					{
						key += "0";
					}
					if(info.hasOwnProperty("shadowSize") && info.shadowSize)
					{
						key += info.shadowSize;
					}
					else
					{
						key += "0";
					}
					if(info.hasOwnProperty("format") && info.format)
					{
						key += info.format;
					}
					else
					{
						key += "0";
					}
					if(info.hasOwnProperty("fontId") && info.fontId)
					{
						key += info.fontId;
					}
					else if(info.hasOwnProperty("fontName") && info.fontName)
					{
						key += info.fontName;
					}
					else
					{
						key += "0";
					}
					if(info.hasOwnProperty("mbColor") && info.mbColor >= 0)
					{
						var mbSize:int = 2;
						if(info.hasOwnProperty("mbSize") && info.mbSize) mbSize = info.mbSize;
						key += mbSize.toString(36);
						key += uint(info.mbColor).toString(36);
					}
					else
					{
						key += "0";
					}
					var colors:Array;
					var u:uint;
					if(info.hasOwnProperty("color") && info.color is Array)
					{
						colors = info.color as Array;
						for each(u in colors) 
						{
							key += u.toString(36);
						}
					}
					else
					{
						key += "0";
					}
					/** 透明度数组 **/
					var alphas:Array;
					if(info.hasOwnProperty("alpha") && info.alpha is Array)
					{
						alphas = info.alpha as Array;
						for each (u in alphas)
						{
							key += u.toString(36);
						}
					}
					else
					{
						key += "0";
					}
					/** 设定宽度 **/
					if(info.hasOwnProperty("width") && info.width)
					{
						key += info.width.toString(36);
					}
					else
					{
						key += "0";
					}
					//这是新属性
					var s:String;
					if(info.hasOwnProperty("str"))
					{
						s = info.str;
						if(args)
						{
							s = StringReplace.mateUseArr(s, "%s", args);
						}
					}
					key += s;
				}
			}
			return key;
		}
		
		/**
		 * 设置文本框使用多语言中的某一个字体的内容
		 * @param	text	文本框
		 * @param	id		多语言字体id
		 * @param	format	基础文本格式,如果要用新的TextFormat,必须new TextFormat(),传入null会保留原始样式
		 */
		public static function setFieldFont(text:TextField, id:String = "", format:TextFormat = null):void
		{
			if (format == null)
			{
				if(text.defaultTextFormat)
				{
					format = text.defaultTextFormat;
				}
				else
				{
					format = new TextFormat();
				}
			}
			if (g.language.allDefaultInfo.font.hasOwnProperty(id))
			{
				var info:Object = g.language.allDefaultInfo.font[id];
				format.font = info.item.font.fontName;
				if(info.hasOwnProperty("embed"))
				{
					text.embedFonts = info.embed;
				}
				text.defaultTextFormat = format;
				text.setTextFormat(format);
			}
			else
			{
				g.log.pushLog(LanguageApi, LogType._Frame, "语言包中没有获取到名称为 " + id + " 的字体");
			}
		}
		
		/**
		 * 设置一个字体
		 * @param textObj	要设置的文本框
		 * @param info		要设置的属性的对象,如果多个属性要先合并
		 * @param temp		设置完毕的时候要执行的一些函数的载体
		 * @param isBitmap	是否是BitmapText的对象里的内容
		 */
		public static function SetTextField(text:TextField, info:Object, args:Array = null, isBitmap:Boolean = false):void
		{
			var format:TextFormat = new TextFormat();
//			if (info.hasOwnProperty("size") && info.size > 0) format.size = info.size;
			
			
			if (info.hasOwnProperty("size") && info.size > 0)
			{
				if(info.hasOwnProperty("shadowSize") && info.shadowSize > 0)
				{
					format.size = 50;
				}
				else
				{
					format.size = info.size;
				}
			}
			
			
			
			if (info.hasOwnProperty("leading") && info.leading > 0) format.leading = info.leading;
			if (info.hasOwnProperty("align")) format.align = info.align;
			if (info.hasOwnProperty("bold")) format.bold = info.bold;
			/** 颜色数组 **/
			var colors:Array;
			if(info.hasOwnProperty("color") && info.color is Array)
			{
				colors = info.color as Array;
				if(colors.length == 1)
				{
					format.color = colors[0];
				}
			}
			/** 透明度数组 **/
			var alphas:Array;
			if(info.hasOwnProperty("alpha") && info.alpha is Array)
			{
				alphas = info.alpha as Array;
				if(alphas.length == 1)
				{
					text.alpha = alphas[0];
				}
			}
			if(info.hasOwnProperty("fontId") && info.fontId)
			{
				if (g.language.allDefaultInfo.font.hasOwnProperty(info.fontId))
				{
					var fontInfo:Object = g.language.allDefaultInfo.font[info.fontId];
					format.font = fontInfo.item.font.fontName;
					if(fontInfo.hasOwnProperty("embed"))
					{
						text.embedFonts = fontInfo.embed;
					}
				}
				else
				{
					g.log.pushLog(LanguageApi, LogType._Frame, "语言包无名 " + info.fontId + " 字体");
				}
				if(info.hasOwnProperty("embed"))
				{
					if(info.embed)
					{
						text.embedFonts = true;
					}
					else
					{
						text.embedFonts = false;
					}
				}
			}
			else if(info.hasOwnProperty("fontName") && info.fontName)
			{
				format.font = info.fontName;
				if(info.hasOwnProperty("embed"))
				{
					if(info.embed)
					{
						text.embedFonts = true;
					}
					else
					{
						text.embedFonts = false;
					}
				}
			}
			//多行,是否为多行,1多行,-1单行
			if(info.hasOwnProperty("multiline"))
			{
				if(info.multiline == 1)
				{
					text.multiline = true;
					text.wordWrap = false;
				}
				else if(info.multiline == -1)
				{
					text.multiline = false;
				}
				else if(info.multiline == 2)
				{
					text.multiline = true;
					text.wordWrap = true;
				}
			}
			text.defaultTextFormat = format;
			//这是新属性
			s = "";
			if(info.hasOwnProperty("str"))
			{
				s = info.str;
				if(args)
				{
					s = StringReplace.mateUseArr(s, "%s", args);
				}
				if(info.hasOwnProperty("html") && info.html)
				{
					text.htmlText = s;
				}
				else
				{
					text.text = s;
				}
			}
			text.setTextFormat(format);
			//位置
			if(info.hasOwnProperty("x") && text.x != info.x)
			{
				text.x = info.x;
			}
			if(info.hasOwnProperty("y") && text.y != info.y)
			{
				text.y = info.y;
			}
			if(info.hasOwnProperty("autoX") && info.autoX)
			{
				var newWidth:Number = text.width;
				text.width = text.textWidth + 8;
				if(text.defaultTextFormat.align == TextFieldAutoSize.CENTER)
				{
					text.x = text.x - (text.width - newWidth) / 2;
				}
				else if(text.defaultTextFormat.align == TextFieldAutoSize.RIGHT)
				{
					text.x = text.x - text.width + newWidth;
				}
				else
				{
					//TextFieldAutoSize.LEFT
					//TextFieldAutoSize.NONE
				}
			}
			if(info.hasOwnProperty("width") && info.width)
			{
				text.width = info.width;
			}
			if(info.hasOwnProperty("autoY") && info.autoY)
			{
				text.height = text.textHeight + 6;
			}
			//是否能被选中
			b = false;
			if(info.hasOwnProperty("selete") && info.selete)
			{
				b = true;
			}
			if (text.type != TextFieldType.INPUT && text.selectable != b)
			{
				text.selectable = b;
			}
			//是否有鼠标事件
			b = false;
			if(info.hasOwnProperty("mouse") && info.mouse)
			{
				b = true;
			}
			if (text.type != TextFieldType.INPUT && text.mouseEnabled != b)
			{
				text.mouseEnabled = b;
			}
			/** 遮罩对象 **/
			var c:Shape;
			//是否是渐变色
			if(isBitmap == false && text.text.length > 0 && (colors && colors.length > 1) || (alphas && alphas.length > 1) && text.textWidth > 0 && text.textHeight > 0)
			{
				var cRotation:Number = 90;
				if (info.hasOwnProperty("colorRotation") && info.colorRotation >= 0)
				{
					cRotation = Number(info.colorRotation);
				}
				matr.createGradientBox(Math.ceil(text.width), Math.ceil(text.height), cRotation * (Math.PI / 180), Math.floor(text.x), Math.floor(text.y));
				c = g.language.textLib.fieldMask[text] as Shape;
				if (c == null)
				{
					c = new Shape();
					g.language.textLib.fieldMask[text] = c;
				}
				if(alphas == null)
				{
					alphas = new Array();
				}
				while (colors.length > alphas.length)
				{
					alphas.push(1);
				}
				c.graphics.clear();
				c.graphics.lineStyle(0, 0, 0);
				c.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, getRatios(colors.length), matr, SpreadMethod.PAD, InterpolationMethod.RGB, 0);
				c.graphics.drawRect(Math.floor(text.x), Math.floor(text.y), Math.ceil(text.width), Math.ceil(text.height));
				c.graphics.endFill();
				if(text.parent)
				{
					text.parent.addChildAt(c, (text.parent.getChildIndex(text) + 1));
					c.cacheAsBitmap = true;
					c.mask = text;
				}
				else
				{
					g.event.addListener(text, Event.ADDED, fontMaskAdded);
				}
			}
			else
			{
				if(g.language.textLib.fieldMask[text])
				{
					c = g.language.textLib.fieldMask[text] as Shape;
					if(c)
					{
						c.graphics.clear();
						if (c.parent) c.parent.removeChild(c);
					}
					delete g.language.textLib.fieldMask[text];
				}
			}
			//对全部的文本全部进行位图缓存
			text.cacheAsBitmap = true;
			//描边
			text.filters = null;
			if(isBitmap == false)
			{
				if(info.hasOwnProperty("mbColor") && info.mbColor >= 0)
				{
					var mbSize:int = 2;
					if (info.hasOwnProperty("mbSize") && info.mbSize) mbSize = info.mbSize;
					if (info.hasOwnProperty("shadowSize") && info.shadowSize > 0)
					{
						if(c)
						{
							EasyFilter.ShadowCOC(c, info.mbColor, info.shadowSize, mbSize);
						}
						else
						{
							EasyFilter.ShadowCOC(text, info.mbColor, info.shadowSize, mbSize);
						}
					}
					else
					{
						if(c)
						{
							EasyFilter.MiaoBian(c, info.mbColor, mbSize);
						}
						else
						{
							EasyFilter.MiaoBian(text, info.mbColor, mbSize);
						}
					}
				}
				else if (c)
				{
					c.filters = null;
				}
			}
		}
		
		/**
		 * 获取一个渐变的区间
		 * @return 
		 */
		private static function getRatios(arrLength:uint):Array
		{
			if(arrLength == 0)
			{
				return getRatios0;
			}
			else if(arrLength == 1)
			{
				return getRatios1;
			}
			else if(arrLength == 2)
			{
				return getRatios2;
			}
			var out:Array = new Array();
			arrLength = arrLength - 1;
			var add:uint = uint(255/arrLength);
			out.push(0);
			var push:uint = 0;
			for(var i:int = 1;i<arrLength;i++)
			{
				push += add;
				out.push(push);
			}
			out.push(255);
			return out;
		}
		
		/** 当没有获取到内容的时候,就使用这个文本替换 **/
		private static var noInfoData:BitmapData = new BitmapData(1, 1, true, 0x00000000);
		
		/**
		 * 通过多语言的info和args生成BitmapData
		 * @param	info
		 * @param	args
		 * @return
		 */
		public static function getTextBitmap(info:Object, args:Array = null):BitmapData
		{
			var o:BitmapData;
			LanguageApi.SetTextField(t, info, args, true);
			if(t.text != "")
			{
				var b:BitmapDataItem = mackBitmapItem(t, info);
				o = b.bitmapData;
				b.dispose();
			}
			else
			{
				o = noInfoData;
			}
			//清理下Text
			if (t.text != "") t.text = "";
			if (t.htmlText != "") t.htmlText = "";
			if (t.x != 0) t.x = 0;
			if (t.y != 0) t.y = 0;
			if (t.width != 100) t.width = 100;
			if (t.height != 100) t.height = 100;
			if (t.alpha != 1) t.alpha = 1;
			if (t.cacheAsBitmap != false) t.cacheAsBitmap = false;
			if (t.autoSize != "none") t.autoSize = "none";
			if (t.embedFonts != false) t.embedFonts = false;
			if (t.multiline != false) t.multiline = false;
			if (t.selectable != true) t.selectable = true;
			if (t.textColor != 0x000000) t.textColor = 0x000000;
			if (t.type != "dynamic") t.type = "dynamic";
			if (t.wordWrap != false) t.wordWrap = false;
			if (t.filters != null) t.filters = null;
			if (t.mask != null) t.mask = null;
			t.defaultTextFormat = new TextFormat();
			return o;
		}
		
		/**
		 * 设置一个字体
		 * @param textObj	要设置的文本框
		 * @param info		要设置的属性的对象,如果多个属性要先合并
		 * @param temp		设置完毕的时候要执行的一些函数的载体
		 * 
		 */
		public static function SetBitmapField(txt:BitmapTextField, info:Object, args:Array = null):void
		{
			var t:TextField = txt.textField;
			txt.setThisInfo(t);
			LanguageApi.SetTextField(t, info, args, true);
			//txt.setThisInfo(t);
			var b:BitmapDataItem = mackBitmapItem(t, info);
			b.x -= t.x;
			b.y -= t.y;
			txt.refresh(b);
		}
		
		private static function mackBitmapItem(t:TextField, info:Object):BitmapDataItem
		{
			/** 颜色数组 **/
			var colors:Array = new Array();
			var l:uint = 0;
			if(info.hasOwnProperty("color") && info.color is Array)
			{
				colors = info.color as Array;
				l = colors.length;
			}
			/** 透明度数组 **/
			var alphas:Array = new Array();
			if(info.hasOwnProperty("alpha") && info.alpha is Array)
			{
				alphas = info.alpha as Array;
				if(alphas.length == 1)
				{
					t.alpha = alphas[0];
				}
				else
				{
					t.alpha = 1;
				}
			}
			var mbSize:int;
			var b:BitmapDataItem;
			//加渐变色
			bitmapFieldSprite.filters = null;
			if(colors.length > 1 || alphas.length > 1)
			{
				while (colors.length > alphas.length)
				{
					alphas.push(1);
				}
				//有内容
				if(t.text.length > 0 && t.textWidth > 0 && t.textHeight > 0)
				{
					var btemp:BitmapData = new BitmapData(Math.ceil(t.width), Math.ceil(t.height), true, 0x00000000);
					var cRotation:Number = 90;
					if (info.hasOwnProperty("colorRotation") && info.colorRotation >= 0)
					{
						cRotation = Number(info.colorRotation);
					}
					matr.createGradientBox(Math.ceil(t.width), Math.ceil(t.height), cRotation * (Math.PI / 180), Math.floor(t.x), Math.floor(t.y));
					bitmapFieldShape.graphics.clear();
					bitmapFieldShape.graphics.lineStyle(0, 0, 0);
					bitmapFieldShape.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, getRatios(colors.length), matr, SpreadMethod.PAD, InterpolationMethod.RGB, 0);
					bitmapFieldShape.graphics.drawRect(Math.floor(t.x), Math.floor(t.y), Math.ceil(t.width), Math.ceil(t.height));
					bitmapFieldShape.graphics.endFill();
					bitmapFieldSprite.addChild(t);
					bitmapFieldSprite.addChild(bitmapFieldShape);
					if (t.cacheAsBitmap != true) t.cacheAsBitmap = true;
					bitmapFieldShape.cacheAsBitmap = true;
					bitmapFieldSprite.cacheAsBitmap = true;
					bitmapFieldShape.mask = t;
					//描边
					if(info.hasOwnProperty("mbColor") && info.mbColor >= 0)
					{
						if(info.hasOwnProperty("mbSize") && info.mbSize)
						{
							mbSize = info.mbSize;
						}
						else
						{
							mbSize = 2;
						}
						if(info.hasOwnProperty("shadowSize") && info.shadowSize > 0)
						{
							EasyFilter.ShadowCOC(bitmapFieldSprite, info.mbColor, info.shadowSize, mbSize);
						}
						else
						{
							EasyFilter.MiaoBian(bitmapFieldSprite, info.mbColor, mbSize);
						}
					}
					//处理有投影的情况
					if(info.hasOwnProperty("shadowSize") && info.shadowSize > 0 && info.hasOwnProperty("size") && info.size > 0)
					{
						b = GetBitmapData.cacheBitmap(bitmapFieldSprite, true, 0x00000000, 1, true, "best", false);
						shadowBitmap.bitmapData = b.bitmapData;
						if(shadowBitmap.smoothing == false) shadowBitmap.smoothing = true;
						b = GetBitmapData.cacheBitmap(shadowBitmap, true, 0x00000000, info.size / 50, false, "best", false);
						shadowBitmap.bitmapData.dispose();
						shadowBitmap.bitmapData = null;
					}
					else
					{
						b = GetBitmapData.cacheBitmap(bitmapFieldSprite, true, 0x00000000, 1, true, "best", false);
					}
					
					if (t.cacheAsBitmap) t.cacheAsBitmap = false;
					bitmapFieldShape.cacheAsBitmap = false;
					bitmapFieldSprite.cacheAsBitmap = false;
					bitmapFieldShape.mask = null;
					bitmapFieldSprite.removeChildren();
				}
				else
				{
					b = BitmapDataItem.instance();
					b.bitmapData = new BitmapData(1, 1, true, 0x00000000);
				}
			}
			else
			{
				//走普通流程
				//描边
				if(info.hasOwnProperty("mbColor") && info.mbColor >= 0)
				{
					if(info.hasOwnProperty("mbSize") && info.mbSize)
					{
						mbSize = info.mbSize;
					}
					else
					{
						mbSize = 2;
					}
					if(info.hasOwnProperty("shadowSize") && info.shadowSize > 0)
					{
						EasyFilter.ShadowCOC(t, info.mbColor, info.shadowSize, mbSize);
					}
					else
					{
						EasyFilter.MiaoBian(t, info.mbColor, mbSize);
					}
				}
				else
				{
					t.filters = null;
				}
				bitmapFieldSprite.addChild(t);
				
				//处理有投影的情况
				if(info.hasOwnProperty("shadowSize") && info.shadowSize > 0 && info.hasOwnProperty("size") && info.size > 0)
				{
					b = GetBitmapData.cacheBitmap(bitmapFieldSprite, true, 0x00000000, 1, true, "best", false);
					shadowBitmap.bitmapData = b.bitmapData;
					if(shadowBitmap.smoothing == false) shadowBitmap.smoothing = true;
					b = GetBitmapData.cacheBitmap(shadowBitmap, true, 0x00000000, info.size / 50, false, "best", false);
					shadowBitmap.bitmapData.dispose();
					shadowBitmap.bitmapData = null;
				}
				else
				{
					b = GetBitmapData.cacheBitmap(bitmapFieldSprite, true, 0x00000000, 1, true, "best", false);
				}
				bitmapFieldSprite.removeChild(t);
			}
			return b;
		}
		
		/** 设置遮罩 **/
		private static function fontMaskAdded(e:Event):void
		{
			g.event.removeListener(e.currentTarget, Event.ADDED, fontMaskAdded);
			g.language.textLib.setFieldUseLib(e.currentTarget as TextField);
		}
	}
}