package cn.wjj.gagaframe.client.language 
{
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	import cn.wjj.tool.ArrayUtil;
	import flash.text.Font;
	import flash.utils.Dictionary;
	
	/**
	 * 统一的字体管理类
	 * 
	 * @author GaGa
	 */
	public class FontManage 
	{
		/** 所有的字体映射 **/
		private var list:Vector.<FontItem> = new Vector.<FontItem>();
		/** 字体映射 UIFont.CN.MSYH.DF3.Embed 对应一个字体  **/
		private var lib:Object = new Object();
		/** 类对应的映射 **/
		private var classLib:Dictionary = new Dictionary(true);
		/** 字体对应的映射 **/
		private var fontLib:Dictionary = new Dictionary(true);
		
		public function FontManage() {}
		
		/**
		 * 抽取URL的swf中的类,来注册字体,如果未找到,就从本地抽取类注册字体
		 * @param	url
		 * @param	className
		 * @param	register
		 */
		public function registerFontUrl(url:String, className:String, register:Boolean, embed:Boolean):FontItem
		{
			var c:Class = g.loader.asset.asset.getAssetLibData(className, url, false);
			if (c == null)
			{
				c = g.loader.asset.asset.getLocalClassBase(className);
			}
			return registerFontClass(className, c, register, embed);
		}
		
		/**
		 * 从本地抽取类,来注册字体
		 * @param	className	字体类名称
		 * @param	register	是否注册字体
		 * @param	embed		是否是嵌入字体
		 */
		public function registerFontName(className:String, register:Boolean, embed:Boolean):FontItem
		{
			var c:Class = g.loader.asset.asset.getLocalClassBase(className);
			return registerFontClass(className, c, register, embed);
		}
		
		/**
		 * 
		 * @param	className	字体类名称
		 * @param	classLink	字体类引用
		 * @param	register	是否注册字体
		 * @param	embed		是否是嵌入字体
		 */
		public function registerFontClass(className:String, classLink:Class, register:Boolean, embed:Boolean):FontItem
		{
			if (lib.hasOwnProperty(className) == false)
			{
				if (classLink && classLib[classLink] == null)
				{
					var font:Font = new classLink();
					if (font && fontLib[font] == null)
					{
						if (register) Font.registerFont(classLink);
						var item:FontItem = new FontItem();
						item.fontClass = classLink;
						item.className = className;
						item.register = register;
						item.font = font;
						item.embed = embed;
						//记录映射
						list.push(item);
						lib[className] = item;
						classLib[classLink] = item;
						fontLib[font] = item;
						//检测重复字体
						var fontList:Array = Font.enumerateFonts(false);
						var repeat:Array = ArrayUtil.createRepeatItem(fontList);
						if(repeat.length)
						{
							g.log.pushLog(this, LogType._ErrorLog,"发现重复注册字体,会造成部分字体无法显示,重复字体 : " + repeat.join());
							g.log.pushLog(this, LogType._Frame, "已经载入的多语言字体包含 : " + fontList.join());
						}
						return item;
					}
					else
					{
						g.log.pushLog(this, LogType._ErrorLog, "添加字体失败,不能实例化Font字体,或已经被添加");
					}
				}
				else
				{
					g.log.pushLog(this, LogType._ErrorLog, "添加字体失败,未找到对应字体Class,或已经添加");
				}
			}
			else
			{
				g.log.pushLog(this, LogType._ErrorLog, "添加字体失败,已经添加过本字体");
				return lib[className] as FontItem;
			}
			return null;
		}
	}
}