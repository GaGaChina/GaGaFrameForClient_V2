package cn.wjj.gagaframe.client.language
{
	import cn.wjj.display.speed.BitmapDataItem;
	import cn.wjj.display.speed.BitmapText;
	import cn.wjj.display.speed.BitmapTextField;
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.factory.FTextField;
	import cn.wjj.gagaframe.client.loader.AssetType;
	import cn.wjj.gagaframe.client.loader.Item;
	import cn.wjj.gagaframe.client.log.LogType;
	import cn.wjj.gagaframe.client.speedfact.SBitmap;
	import cn.wjj.tool.StringReplace;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	
	/**
	 * 动态字体外观
	 * 字体外观的ID号.
	 * 
	 * sound : 这个现在不制作
	 * 
	 * textField : str内容 color字体颜色 size字体大小 fontSystem字体类型,是个ID, mbColor描边颜色, mbSize描边尺寸
	 * 
	 * image(bitmap对象的引用) : _x X的偏移量,_y Y轴偏移量, url 图片的连接地址, bitmapdata对象
	 */
	public class LanguageManage
	{
		/** 现在已经载入的字体库 **/
		private var lib:Object = new Object();
		/** 默认使用的语言 **/
		private var _defaultName:String;
		/** 默认数据的引用 **/
		private var _defaultInfo:Object;
		internal var textLib:TextLib;
		private var imgLib:ImageLib;
		
		/** 自动设置文本的对象 **/
		private var bitmapTextLib:Dictionary = new Dictionary(true);
		private var recoverLength:uint = 0;
		
		/** 是否开启多语言功能 **/
		public var config_change:Boolean = true;
		/** 图片是否读取GFILE文件 **/
		public var config_img_gfile:Array = new Array();
		
		/** 字体管理模块 **/
		public var font:FontManage;
		
		public function LanguageManage()
		{
			font = new FontManage();
			textLib = new TextLib();
			imgLib = new ImageLib();
		}
		
		/** 获取现在正在执行的语言包的全部语言对象的引用 **/
		public function get allDefaultInfo():Object { return this._defaultInfo; }
		/** 现在选中的默认语言 **/
		public function get defaultName():String { return _defaultName; }
		
		/**
		 * 设置一个文本,让他自动和某一个language的ID对象绑定
		 * @param t
		 * @param id
		 * @param setOver
		 * @param args
		 */
		public function setField(t:TextField , id:String , setOver:Function = null , ...args):void
		{
			args.unshift(t, id, setOver);
			textLib.setField.apply(null, args);
		}
		
		/**
		 * 设置一个文本,让他自动和某一个language的ID对象绑定
		 * @param	t
		 * @param	id
		 * @param	...args
		 * @return
		 */
		public function setBitmapField(t:*, id:String , ...args):BitmapTextField
		{
			var b:BitmapTextField;
			if(t is TextField || t is FTextField)
			{
				if (bitmapTextLib[t])
				{
					b = bitmapTextLib[t] as BitmapTextField;
				}
				if (b == null)
				{
					b = new BitmapTextField(t);
					bitmapTextLib[t] = b;
				}
			}
			else
			{
				b = t as BitmapTextField;
			}
			args.unshift(b, id);
			textLib.setBitmapField.apply(null, args);
			return b;
		}
		
		/**
		 * 获取一个文本的内容
		 * @param	id
		 * @param	...args
		 */
		public function getBitmapField(id:String, ...args):BitmapText
		{
			args.unshift(id);
			return textLib.getBitmapField.apply(null, args);
		}
		
		/**
		 * 设置一个文本框的皮肤,字体
		 * @param text			TextField的文本引用(弱引用)
		 * @param id			字体的ID号
		 * @param formatId		字体fontFormat的ID号
		 */
		public function setFieldSkin(text:TextField , id:String = "" , formatId:String = ""):void
		{
			textLib.setFieldSkin(text, id, formatId);
		}
		
		/**
		 * 设置文本框使用多语言中的某一个字体的内容
		 * @param	text	文本框
		 * @param	id		多语言字体id
		 * @param	format	基础文本格式,如果要用新的TextFormat,必须new TextFormat(),传入null会保留原始样式
		 */
		public function setFieldFont(text:TextField, id:String = "", format:TextFormat = null):void
		{
			textLib.setFieldFont(text, id, format);
		}
		
		/**
		 * 清理一个多语言包的内容,包括设置的setField和setFieldSkin部分,还有bitmapField
		 * @param	text
		 */
		public function removeField(text:TextField):void
		{
			textLib.removeField(text);
			if (bitmapTextLib[text])
			{
				var b:BitmapTextField = bitmapTextLib[text] as BitmapTextField;
				if(b.textField && b.parent)
				{
					b.parent.addChildAt(text, (b.parent.getChildIndex(b) + 1));
				}
				b.dispose();
				delete bitmapTextLib[text];
			}
		}
		
		/**
		 * 清理一个多语言包的内容,包括设置的setField和setFieldSkin部分,还有bitmapField
		 * @param	textObj
		 */
		public function removeBitmapField(b:BitmapTextField):void
		{
			if (b.textField)
			{
				var t:TextField = b.textField;
				textLib.removeField(t);
				delete bitmapTextLib[t];
			}
			b.dispose();
		}
		
		/**
		 * 缓存字体,以备使用,不处理高度,最后合并处理高度
		 * @param	str
		 * @param	languageId
		 */
		public function cacheChar(str:String, skinId:String, smoothing:Boolean = false):void
		{
			var l:uint = str.length;
			var s:String;
			for (var i:int = 0; i < l; i++) 
			{
				s = str.substr(i, 1);
				textLib.getCacheData(s, skinId, smoothing);
			}
		}
		
		/** 清理全部的缓存字体 **/
		public function clearAllCacheChar():void
		{
			textLib.delAllCacheData();
		}
		
		/**
		 * 使用缓存取出文本
		 * @param	s			字符
		 * @param	skinId		多语言的样式
		 * @param	smoothing	是否平滑
		 * @return
		 */
		public function getCacheData(s:String, skinId:String, smoothing:Boolean = false):BitmapDataItem
		{
			return textLib.getCacheData(s, skinId, smoothing);
		}
		
		/**
		 * 用缓存字体把内容放入Sprite输出
		 * @param	str
		 * @param	skinId
		 * @param	align			1:剧中,2:0,0开始
		 * @param	spacing			间隔的偏移量
		 * @param	smoothing		是否平滑
		 * @return
		 */
		public function getCacheChar(str:String, skinId:String, align:int = 1, spacing:int = 2, smoothing:Boolean = false):Sprite
		{
			var s:Sprite = new Sprite();
			setDisplayCacheChar(str, skinId, s, align, spacing, smoothing);
			return s;
		}
		
		public function set recoverNumber(vars:uint):void
		{
			recoverLength = vars;
		}
		
		/**
		 * 把缓存的字体加入到特定位置
		 * @param	str
		 * @param	skinId
		 * @param	display
		 * @param	align			1:剧中,2:0,0开始
		 * @param	spacing			间隔的偏移量
		 * @param	smoothing		是否平滑
		 */
		public function setDisplayCacheChar(str:String, skinId:String, display:DisplayObjectContainer, align:int = 1, spacing:int = 2, smoothing:Boolean = false):void
		{
			var bit:SBitmap;
			var l:uint = str.length;
			var s:String;
			var info:BitmapDataItem;
			var arr:Array = g.speedFact.n_array();
			var maxHeight:uint = 0;
			var startX:uint = 0;
			for (var i:int = 0; i < l; i++) 
			{
				s = str.substr(i, 1);
				info = textLib.getCacheData(s, skinId, smoothing);
				bit = SBitmap.instance(info.bitmapData, "auto", smoothing);
				if (i == 0)
				{
					bit.x = Math.ceil(info.bitmapData.width / 2);
				}
				else
				{
					bit.x = Math.ceil(startX + info.bitmapData.width / 2);
				}
				bit.y = info.y;
				if (maxHeight < Math.ceil(info.bitmapData.height / 2))
				{
					maxHeight = Math.ceil(info.bitmapData.height / 2);
				}
				startX = startX + spacing + info.bitmapData.width;
				arr[i] = bit;
			}
			for each (var item:Bitmap in arr) 
			{
				if (align == 1)
				{
					item.x = item.x - Math.floor((bit.x + bit.width) / 2);
				}
				else if (align == 2)
				{
					item.y = item.y + maxHeight;
				}
				display.addChild(item);
			}
			g.speedFact.d_array(arr);
		}
		
		/** 临时变量 **/
		private var _m:Matrix = new Matrix();
		private var _s:Sprite = new Sprite();
		private var _p:Point = new Point();
		private var f:int = 0;
		/**
		 * 获取一个字体的缓存
		 * @param	str
		 * @param	skinId
		 * @return
		 */
		internal function cacheCharData(str:String, skinId:String, smoothing:Boolean = false):BitmapDataItem
		{
			//g.bridge.root.addChild(_s);
			var text:TextField = new TextField();
			text.autoSize = TextFieldAutoSize.CENTER;
			text.border = false;
			text.width = 400;
			text.height = 400;
			text.text = str;
			text.x = -200;
			_s.addChild(text);
			g.language.setFieldSkin(text, "", skinId);
			text.width = text.textWidth + 8;
			text.x = -text.width / 2;
			text.height = text.textHeight + 6;
			text.y = -text.height / 2;
			g.language.setFieldSkin(text, "", skinId);
			var r:Rectangle = _s.getBounds(_s);
			var x:int = Math.round(r.x);
			var y:int = Math.round(r.y);
			if (r.isEmpty())
			{
				r.width = 1;
				r.height = 1;
			}
			var b1:BitmapData = new BitmapData(Math.ceil(r.width), Math.ceil(r.height), true, 0x00000000);
			_m.tx = -x;
			_m.ty = -y;
			b1.drawWithQuality(_s, _m, null, null, null, smoothing, "best");
			g.language.removeField(text);
			_s.removeChildren();
			r = b1.getColorBoundsRect(0xFF000000, 0x00000000, false);
			if (r.isEmpty() == false && (b1.width != r.width || b1.height != r.height))
			{
				var b2:BitmapData = new BitmapData(r.width, r.height, true, 0x00000000);
				b2.copyPixels(b1, r, _p);
				b1.dispose();
				b1 = b2;
				x += r.x;
				y += r.y;
			}
			/*
			f++;
			var nb:Bitmap = new Bitmap();
			nb.bitmapData = b1;
			nb.x = int(f % 10) * 20 + 20;
			nb.y = int(f / 10) * 30 + 100;
			g.bridge.root.addChild(nb);
			*/
			
			var o:BitmapDataItem = BitmapDataItem.instance();
			var info:Object = LanguageApi.CopyIdToSetText(g.language.allDefaultInfo, "", skinId);
			//处理有投影的情况
			if(info.hasOwnProperty("shadowSize") && info.shadowSize > 0 && info.hasOwnProperty("size") && info.size > 0)
			{
				var shrink:BitmapData = new BitmapData(Math.ceil(b1.width * info.size / 50), Math.ceil(b1.height * info.size / 50), true, 0x00000000);
				_m.tx = 0;
				_m.ty = 0;
				var temp:SBitmap = SBitmap.instance(b1);
				var max:Number = shrink.width / b1.width;
				if (max < shrink.height / b1.height)
				{
					max = shrink.height / b1.height;
				}
				_m.a = max;
				_m.d = max;
				shrink.drawWithQuality(temp, _m, null, null, null, smoothing, "best");
				_m.a = 1;
				_m.d = 1;
				o.bitmapData = shrink;
				o.x = x * max;
				o.y = y * max;
			}
			else
			{
				o.bitmapData = b1;
				o.x = x;
				o.y = y;
			}
			return o;
		}
		
		/**
		 * 设置一个Bitmap,让他自动和某一个language的ID对象绑定
		 * @param textObj
		 * @param languageId
		 * @param setOver
		 */
		public function setBitmap(imgObj:Bitmap , id:String , setOver:Function = null):void
		{
			imgLib.setBitmap(imgObj, id, setOver);
		}
		
		/**
		 * [方法放弃了]获取记录某一个ID的数据全部对象
		 * @param 	id
		 * @return 
		 */
		public function getObject(id:String):Object
		{
			if(_defaultInfo.str.hasOwnProperty(id) && _defaultInfo.str[id] != null)
			{
				return _defaultInfo.str[id];
			}
			g.log.pushLog(this, LogType._Frame, "语言包中没有获取到名称为 " + id + " 的内容!");
			return null;
		}
		
		/**
		 * 获取一个language的ID对象的文本引用
		 * @param languageId	语言包的唯一ID
		 * @param args			如果文本由需要替换的地方,就使用这个参数
		 * @return 
		 */
		public function getString(id:String , ...args):String
		{
			if(_defaultInfo == null) 
			{
				g.log.pushLog(this, LogType._Frame, "语言包未配置");
				return "";
			}
			var o:*;
			var b:Boolean = true;
			var s:String = "";
			if (_defaultInfo.str.hasOwnProperty(id))
			{
				o = _defaultInfo.str[id];
				if (o is String)
				{
					return StringReplace.mateUseArr(o, "%s", args);
				}
				else if(o.hasOwnProperty("str"))
				{
					return StringReplace.mateUseArr(o.str, "%s", args);
				}
			}
			else
			{
				if(_defaultInfo.arr.length)
				{
					for each(o in _defaultInfo.arr)
					{
						if(o.hasOwnProperty(id))
						{
							return StringReplace.mateUseArr(o[id], "%s", args);
						}
					}
				}
			}
			g.log.pushLog(this, LogType._Frame, "语言包未获得:" + id);
			return "";
		}
		
		/**
		 * 获取一个language的ID对象的图像内容引用
		 * @param languageId
		 * @return 
		 * 
		 */
		public function getBitmapData(id:String):BitmapData
		{
			var o:Object;
			if(_defaultInfo.img.hasOwnProperty(id))
			{
				o = _defaultInfo.img[id];
				if(o.data)
				{
					return o.data;
				}
				else
				{
					var b:*;
					for each(var gfile:* in config_img_gfile)
					{
						b = gfile.getPathObj(o.url);
						if(b)
						{
							return b;
						}
					}
				}
			}
			else
			{
				g.log.pushLog(this, LogType._Frame, "语言包无 " + id + " 图形");
			}
			return null;
		}
		
		/**
		 * 获取一个language的ID对象的Font引用
		 * @param languageId
		 * @return 
		 */
		public function getFont(id:String):Font
		{
			if(_defaultInfo.font.hasOwnProperty(id))
			{
				var temp:FontItem = _defaultInfo.font[id];
				return temp.font;
			}
			else
			{
				g.log.pushLog(this, LogType._Frame, "语言包无 " + id + " 的字体");
			}
			return null;
		}
		
		/**
		 * 通过二进制文件来设置一个语言包
		 * @param	name
		 * @param	info
		 * @param	onComplete
		 * @param	autoSet
		 */
		public function loadConfigByte(name:String, info:Object, onComplete:Function, autoSet:Boolean = true, onLoading:Function = null):LanguageItem
		{
			var o:LanguageItem;
			if(name)
			{
				if(lib[name] == null)
				{
					o = new LanguageItem();
					o.xmlURL = "";
					o.onComplete = onComplete;
					o.onLoading = onLoading;
					o.name = name;
					o.autoSet = autoSet;
					lib[name] = o;
					//载入资源
					o.loadByteOk(info);
				}
				else
				{
					g.log.pushLog(this, LogType._Frame, "语言库中有现成语言包");
					onComplete();
				}
			}
			else
			{
				g.log.pushLog(this, LogType._Frame, "缺少名称");
			}
			return o;
		}
		
		/**
		 * 获取一个字体配置文件,并且保存下来
		 * @param name			语言名称
		 * @param xmlURL		连接地址
		 * @param onComplete	全部完成后触发的函数
		 * @param autoSet		是否自动设置为默认字体
		 */
		public function loadConfig(name:String, xmlURL:String , onComplete:Function , autoSet:Boolean = true):LanguageItem
		{
			var o:LanguageItem;
			if(name)
			{
				if(lib[name] == null)
				{
					o = new LanguageItem();
					o.xmlURL = xmlURL;
					o.onComplete = onComplete;
					o.name = name;
					o.autoSet = autoSet;
					lib[name] = o;
					//下载资源
					var item:Item = g.loader.addItem(xmlURL);
					item.fileType = AssetType.XML;
					if(g.status.os == "ISO" || g.status.os == "Android" || g.status.os == "AIR")
					{
						item.cacheSO = false;
						item.cacheMemory = false;
					}
					item.onComplete(o.loadOk);
					item.addAsset(xmlURL, null, false, false, AssetType.XML);
					item.start();
					g.log.pushLog(this, LogType._Frame, "语言包已经开始下载!");
				}
				else
				{
					g.log.pushLog(this, LogType._Frame, "语言库中有现成语言包");
					onComplete();
				}
			}
			else
			{
				g.log.pushLog(this, LogType._Frame, "缺少名称!");
			}
			return o;
		}
		
		/**
		 * 设置一个默认的语言包
		 * @param	name
		 */
		public function setConfig(name:String):void
		{
			if(defaultName != name)
			{
				if (lib[name])
				{
					_defaultName = name;
					this._defaultInfo = lib[name].info;
					textLib.reSetAllText();
					imgLib.reSetAllImg();
				}
				else
				{
					g.log.pushLog(this, LogType._Frame, "缺少语言包 : " + name);
				}
			}
		}
		
		/**
		 * 删除一个语言包配置
		 * @param	name
		 */
		public function delConfig(name:String):void
		{
			delete lib[name];
		}
		
		/** 删除现在默认语言包以外的其他语言包 **/
		public function delOtherConfig():void
		{
			for(var name:String in lib)
			{
				if(name != defaultName)
				{
					delete lib[name];
				}
			}
		}
		
		/**
		 * 把老的字体全部改成新字体,防止用户系统字体没有的情况
		 * @param	oldId
		 * @param	newId
		 */
		public function copyFontId(oldId:String, newId:String):void
		{
			var oldObj:FontItem;
			var newObj:FontItem;
			if (_defaultInfo.font.hasOwnProperty(oldId))
			{
				oldObj = _defaultInfo.font[oldId].item;
			}
			if (_defaultInfo.font.hasOwnProperty(newId))
			{
				newObj = _defaultInfo.font[newId].item;
			}
			if (oldObj && newObj)
			{
				oldObj.font = newObj.font;
				oldObj.fontClass = newObj.fontClass;
				oldObj.className = newObj.className;
				oldObj.register = newObj.register;
				oldObj.url = newObj.url;
				if(newObj.hasOwnProperty("embed"))
				{
					oldObj.embed = newObj.embed;
				}
				else if(oldObj.hasOwnProperty("embed"))
				{
					delete oldObj["embed"];
				}
			}
		}
	}
}