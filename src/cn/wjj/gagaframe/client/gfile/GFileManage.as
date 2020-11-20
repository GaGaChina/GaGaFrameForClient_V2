package cn.wjj.gagaframe.client.gfile
{
	import cn.wjj.data.file.GBitmapData;
	import cn.wjj.data.file.GFileBase;
	import cn.wjj.display.grid9.Grid9Engine;
	import cn.wjj.display.grid9.Grid9Info;
	import cn.wjj.display.ui2d.engine.EngineInfo;
	import cn.wjj.display.ui2d.info.U2InfoBaseInfo;
	import cn.wjj.display.ui2d.info.U2InfoBitmapX;
	import cn.wjj.display.ui2d.U2Bitmap;
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.loader.AssetItem;
	import cn.wjj.gagaframe.client.log.LogType;
	import cn.wjj.gagaframe.client.speedfact.SByte;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.utils.Dictionary;

	public class GFileManage
	{
		/** 对每个GFile进行命名 [Game] = gfile **/
		private var gfileLib:Object = new Object();
		/** 每个GFile命名可以对应几个GFile对象 [GFile] = [gfile, gfile, gfile] **/
		private var gfileList:Object = new Object();
		/** 是否输出错误的LOG **/
		public var pushLog:Boolean = true;
		
		public function GFileManage() { }
		
		public function namePushGFile(name:String, gfile:*):void
		{
			if (gfileLib.hasOwnProperty(name))
			{
				g.log.pushLog(this, LogType._ErrorLog, "已经添加过这个名称的GFile,这里做了替换处理!");
			}
			gfileLib[name] = gfile;
		}
		
		/**
		 * 通过名称获取GFile文件引用
		 * @param	name
		 * @return
		 */
		public function nameGetGFile(name:String):*
		{
			if (gfileLib.hasOwnProperty(name))
			{
				return gfileLib[name];
			}
			return null;
		}
		
		/** 添加名称为name的gfile列表,后加的先被查询到 **/
		public function listPushGFile(name:String, gfile:*):void
		{
			if (!gfileList.hasOwnProperty(name))
			{
				gfileList[name] = new Array();
			}
			gfileList[name].push(gfile);
		}
		
		/** 通过别名GFile中获取一个路径的对象 **/
		public function listPath(name:String, path:String):GFileBase
		{
			if (path && gfileList.hasOwnProperty(name))
			{
				var a:Array = gfileList[name];
				var o:GFileBase;
				for each (var item:* in a) 
				{
					o = item.getPath(path);
					if (o) return o;
				}
			}
			return null;
		}
		/** 通过别名GFile通过MD5值来获取GFile里的对象 **/
		public function listMD5(name:String, md5:String):GFileBase
		{
			if (md5 && gfileList.hasOwnProperty(name))
			{
				var a:Array = gfileList[name];
				var o:GFileBase;
				for each (var item:* in a) 
				{
					o = item.getMD5(md5);
					if (o) return o;
				}
			}
			return null;
		}
		/** 获取地址前一段包含path的一个对象列表 **/
		public function listPathFuzzy(name:String, path:String):Vector.<GFileBase>
		{
			if (path && gfileList.hasOwnProperty(name))
			{
				var olist:Vector.<GFileBase>;
				var glist:Vector.<GFileBase>;
				var a:Array = gfileList[name];
				var o:GFileBase;
				for each (var item:* in a) 
				{
					glist = item.getPathFuzzy(path);
					if (glist && glist.length)
					{
						if (olist == null) olist = new Vector.<GFileBase>();
						olist = olist.concat(glist);
					}
				}
				return olist;
			}
			return null;
		}
		/** 获取GFile文件中的对象,找二进制并实例化对象 **/
		public function listPathObj(name:String, path:String, showError:Boolean = true):*
		{
			if (path && gfileList.hasOwnProperty(name))
			{
				var a:Array = gfileList[name];
				var o:*;
				for each (var item:* in a) 
				{
					o = item.getPathObj(path);
					if (o) return o;
				}
				if(showError && pushLog) g.log.pushLog(this, LogType._ErrorLog, "GFile Error : " + path);
			}
			return null;
		}
		/** 获取GFile文件中位图 **/
		public function listBitmapData(name:String, path:String, showError:Boolean = true):BitmapData { return listPathObj(name, path, showError); }
		/** 获取GFile文件中的信息,如果有对象引入,直接设置 **/
		public function listBitmapX(name:String, path:String, showError:Boolean = true, display:U2Bitmap = null, cache:Dictionary = null):*
		{
			var o:* = listPathObj(name, path, showError);
			if (cache)
			{
				cache[o] = g.time.frameTime.time;
			}
			if (o is BitmapData)
			{
				if (display)
				{
					display.bitmapData = o;
					display.path = path;
				}
			}
			else if (o is U2InfoBitmapX)
			{
				if (display)
				{
					var x:U2InfoBitmapX = o;
					display.bitmapData = x.bitmapData;
					display.setOffsetX(x.offsetX, x.offsetY, x.offsetScaleX, x.offsetScaleY);
					display.path = path;
				}
			}
			return o;
		}
		
		/**
		 * 播放声音
		 * @param name			列表名称
		 * @param path			路径
		 * @param teamName		队列名称
		 * @param startTime		开始时间
		 * @param endTime		结束时间
		 * @param loops			播放默认是1次,0次是无线循环播放
		 * @param volume		声音大小
		 * @param onComplete	完成播放后运行函数
		 * @return 是否成功播放
		 */
		public function listPlaySound(name:String, path:String, teamName:String = "", startTime:Number = 0, endTime:Number = -1, loops:int = 1, volume:Number = 1, onComplete:Function = null):SoundChannel
		{
			var o:AssetItem = listPathObj(name, path) as AssetItem;
			if (o)
			{
				return g.loader.asset.sound.playAsset(o, teamName, startTime, endTime, loops, volume, onComplete);
			}
			return null;
		}
		/** 停止播放音乐 **/
		public function listStopSound(name:String, path:String, showError:Boolean = true):void
		{
			var o:AssetItem = listPathObj(name, path, showError) as AssetItem;
			if (o) g.loader.asset.sound.stopAsset(o);
		}
		/** 获取声音 **/
		public function listGetSound(name:String, path:String, showError:Boolean = true):Sound
		{
			var o:AssetItem = listPathObj(name, path, showError) as AssetItem;
			if (o && o.data is Sound) return o.data as Sound;
			return null;
		}
		/** 创建U2图形 **/
		public function listU2PathDisplay(name:String, path:String, selfEngine:Boolean = true, core:int = -1, start:int = -1, showError:Boolean = true, cache:Dictionary = null):DisplayObject
		{
			var o:U2InfoBaseInfo = listU2PathInfo(name, path, showError);
			if (o) return EngineInfo.create(o, selfEngine, core, start, cache);
			return null;
		}
		/** 打开GFile文件里二进制,并获取数据对象 **/
		public function listU2PathInfo(name:String, path:String, showError:Boolean = true):U2InfoBaseInfo
		{
			if (name && path && gfileList.hasOwnProperty(name))
			{
				var a:Array = gfileList[name];
				var o:*;
				for each (var item:* in a) 
				{
					o = item.getPathObj(path);
					if (o)
					{
						if (o is U2InfoBaseInfo)
						{
							if (o.gfile == null) o.gfile = item;
							return o;
						}
						else if(o is SByte)
						{
							var byte:SByte = o as SByte;
							byte.position = 0;
							var u2:U2InfoBaseInfo = new U2InfoBaseInfo(null);
							u2.gfile = item;
							u2.setByte(byte);
							return u2;
						}
						return o;
					}
				}
				if(showError && pushLog) g.log.pushLog(this, LogType._ErrorLog, "GFile Error : " + path);
			}
			return null;
		}
		
		/** 通过别名GFile中获取一个路径的对象 **/
		public function namePath(name:String, path:String):GFileBase { return getPath(nameGetGFile(name), path); }
		/** 通过别名GFile通过MD5值来获取GFile里的对象 **/
		public function nameMD5(name:String, md5:String):GFileBase { return getMD5(nameGetGFile(name), md5); }
		/** 获取地址前一段包含path的一个对象列表 **/
		public function namePathFuzzy(name:String, path:String):Vector.<GFileBase> { return getPathFuzzy(nameGetGFile(name), path); }
		/** 获取GFile文件中的对象,找二进制并实例化对象 **/
		public function namePathObj(name:String, path:String, showError:Boolean = true):* { return getPathObj(nameGetGFile(name), path, showError); }
		/** 从GFile中获取到一个文件的对象 **/
		public function nameFileBaseObj(name:String, file:GFileBase):* { return getFileBaseObj(nameGetGFile(name), file); }
		/** 获取GFile文件中位图 **/
		public function nameBitmapData(name:String, path:String, showError:Boolean = true):BitmapData { return bitmapData(nameGetGFile(name), path, showError); }
		/** 获取GFile文件中的信息,如果有对象引入,直接设置 **/
		public function nameBitmapX(name:String, path:String, showError:Boolean = true, display:U2Bitmap = null, cache:Dictionary = null):* { return bitmapX(nameGetGFile(name), path, showError, display, cache); }
		/**
		 * 播放声音
		 * @param url			媒体文件的长度
		 * @param teamName		队列名称
		 * @param startTime		开始时间
		 * @param endTime		结束时间
		 * @param loops			播放默认是1次,0次是无线循环播放
		 * @param volume		声音大小
		 * @param onComplete	完成播放后运行函数
		 * @return 是否成功播放
		 */
		public function namePlaySound(name:String, path:String, teamName:String = "", startTime:Number = 0, endTime:Number = -1, loops:int = 1, volume:Number = 1, onComplete:Function = null):SoundChannel { return playSound(nameGetGFile(name), path, teamName, startTime, endTime, loops, volume, onComplete); }
		/** 停止播放音乐 **/
		public function nameStopSound(name:String, path:String):void { stopSound(nameGetGFile(name), path); }
		/** 获取声音 **/
		public function nameGetSound(name:String, path:String):Sound { return getSound(nameGetGFile(name), path); }
		
		/**
		 * 把一个文件记录到本地临时目录
		 * @param	path
		 * @param	bitmapData
		 */
		public function nameAddBitmapData(name:String, path:String, bitmapData:BitmapData):void { addBitmapData(nameGetGFile(name), path, bitmapData); }
		/** 通过别名GFile中获取一个路径的对象 **/
		public function nameDelPath(name:String, path:String):void { delPath(nameGetGFile(name), path); }
		/** 创建U2图形 **/
		public function nameU2PathDisplay(name:String, path:String, selfEngine:Boolean = true, core:int = -1, start:int = -1, showError:Boolean = true):DisplayObject { return u2PathDisplay(nameGetGFile(name), path, selfEngine, core, start, showError); }
		/** 打开GFile文件里二进制,并获取数据对象 **/
		public function nameU2PathInfo(name:String, path:String, showError:Boolean = true):U2InfoBaseInfo { return u2PathInfo(nameGetGFile(name), path, showError); }
		
		/** 从一个GFile中获取一个路径的对象 **/
		public function getPath(gfile:*, path:String):GFileBase
		{
			if(gfile && path) return gfile.getPath(path);
			return null;
		}
		
		/** 通过MD5值来获取GFile里的对象 **/
		public function getMD5(gfile:*, md5:String):GFileBase
		{
			if(gfile && md5) return gfile.getMD5(md5);
			return null;
		}
		
		/** 获取地址前一段包含path的一个对象列表 **/
		public function getPathFuzzy(gfile:*, path:String):Vector.<GFileBase>
		{
			if(gfile) return gfile.getPathFuzzy(path);
			return null;
		}
		
		/** 获取GFile文件中的对象,找二进制并实例化对象 **/
		public function getPathObj(gfile:*, path:String, showError:Boolean = true):*
		{
			if(gfile && path)
			{
				var o:* = gfile.getPathObj(path);
				if (o) return o;
				if(showError && pushLog) g.log.pushLog(this, LogType._ErrorLog, "GFile Error : " + path);
			}
			return null;
		}
		
		/** 从GFile中获取到一个文件的对象 **/
		public function getFileBaseObj(gfile:*, file:GFileBase):*
		{
			if(gfile && file) return gfile.getPathObjRun(file);
			return null;
		}
		
		/**
		 * 设置或获取信息内容,可能返回BitmapData,或
		 * @param	gfile
		 * @param	path
		 * @param	showError
		 * @param	display
		 * @param	cache			
		 * @return
		 */
		public function bitmapX(gfile:*, path:String, showError:Boolean = true, display:U2Bitmap = null, cache:Dictionary = null):*
		{
			var o:* = getPathObj(gfile, path, showError);
			if (cache)
			{
				cache[o] = g.time.frameTime.time;
			}
			if (display)
			{
				if (o is BitmapData)
				{
					display.bitmapData = o;
					display.path = path;
					display.setOffsetX(0, 0, 1, 1);
				}
				else if (o is U2InfoBitmapX)
				{
					//var x:U2InfoBitmapX = o;
					if (display.bitmapData != o.bitmapData)
					{
						display.bitmapData = o.bitmapData;
					}
					display.setOffsetX(o.offsetX, o.offsetY, o.offsetScaleX, o.offsetScaleY);
					display.path = path;
				}
				if (display.bitmapData)
				{
					if (display.isEmpty)
					{
						display.isEmpty = false;
					}
				}
				else if (display.isEmpty == false)
				{
					display.isEmpty = true;
				}
			}
			return o;
		}
		
		/** 获取GFile文件中位图 **/
		public function bitmapData(gfile:*, path:String, showError:Boolean = true):BitmapData
		{
			return getPathObj(gfile, path, showError);
		}
		
		/**
		 * 播放声音
		 * @param url			媒体文件的长度
		 * @param teamName		队列名称
		 * @param startTime		开始时间
		 * @param endTime		结束时间
		 * @param loops			播放默认是1次,0次是无线循环播放
		 * @param volume		声音大小
		 * @param onComplete	完成播放后运行函数
		 * @return 是否成功播放
		 */
		public function playSound(gfile:*, path:String, teamName:String = "", startTime:Number = 0, endTime:Number = -1, loops:int = 1, volume:Number = 1, onComplete:Function = null):SoundChannel
		{
			var o:AssetItem = getPathObj(gfile, path) as AssetItem;
			if (o)
			{
				return g.loader.asset.sound.playAsset(o, teamName, startTime, endTime, loops, volume, onComplete);
			}
			return null;
		}
		
		/** 停止播放音乐 **/
		public function stopSound(gfile:*, path:String, showError:Boolean = true):void
		{
			var o:AssetItem = getPathObj(gfile, path, showError) as AssetItem;
			if (o) g.loader.asset.sound.stopAsset(o);
		}
		
		/** 获取声音 **/
		public function getSound(gfile:*, path:String, showError:Boolean = true):Sound
		{
			var o:AssetItem = getPathObj(gfile, path, showError) as AssetItem;
			if (o && o.data is Sound) return o.data as Sound;
			return null;
		}
		
		/**
		 * 把一个文件记录到本地临时目录
		 * @param	path
		 * @param	bitmapData
		 */
		public function addBitmapData(gfile:*, path:String, bitmapData:BitmapData):void
		{
			delPath(gfile, path);
			var file:GBitmapData = new GBitmapData();
			file.path = path;
			file.name = path;
			file.isBuilder = true;
			file.obj = bitmapData;
			file.setBitmapData(bitmapData);
			gfile.isBuilder = true;
			gfile.push(file);
			gfile.getWritePosition(file);
			//写入包头
			gfile.writeBlank();
			gfile.writeHeadFile();
			gfile.isBuilder = false;
			file.isBuilder = false;
			file.sourceByte = null;
		}
		
		/**
		 * 从临时目录删除一个文件
		 * @param	path
		 * @param	bitmapData
		 */
		public function delPath(gfile:*, path:String):void
		{
			var o:* = this.getPath(gfile, path);
			if (o)
			{
				gfile.clear(o);
				gfile.writeBlank();
				gfile.writeHeadFile();
			}
		}
		
		/**
		 * 通过path获取U2图形
		 * @param	gfile		GFile
		 * @param	path		路径
		 * @param	selfEngine	是否自己驱动
		 * @param	core		核心时间
		 * @param	start		开始运行时间
		 * @param	showError	获取不到内容是否报错
		 * @return
		 */
		public function u2PathDisplay(gfile:*, path:String, selfEngine:Boolean = true, core:int = -1, start:int = -1, showError:Boolean = true, cache:Dictionary = null):DisplayObject
		{
			var o:U2InfoBaseInfo = u2PathInfo(gfile, path, showError);
			if (o) return EngineInfo.create(o, selfEngine, core, start, cache);
			return null;
		}
		
		/** 打开GFile文件里二进制,并获取数据对象 **/
		public function u2PathInfo(gfile:*, path:String, showError:Boolean = true):U2InfoBaseInfo
		{
			if (gfile && path)
			{
				var o:* = getPathObj(gfile, path, showError);
				if (o)
				{
					if (o is U2InfoBaseInfo)
					{
						if (o.gfile == null) o.gfile = gfile;
						return o;
					}
					else if(o is SByte)
					{
						var byte:SByte = o as SByte;
						byte.position = 0;
						var u2:U2InfoBaseInfo = new U2InfoBaseInfo(null);
						u2.gfile = gfile;
						u2.setByte(byte);
						return u2;
					}
				}
			}
			return null;
		}
		
		/**
		 * 通过path获取九宫格图形
		 * @param	gfile		GFile引用
		 * @param	path		路径
		 * @param	width
		 * @param	height
		 * @return
		 */
		public function grid9PathDisplay(gfile:*, path:String, width:uint, height:uint, showError:Boolean = true):DisplayObject
		{
			var o:Grid9Info = grid9PathInfo(gfile, path, showError);
			if (o) return Grid9Engine.create(o, width, height);
			return null;
		}
		
		/** 打开GFile文件里二进制,并获取数据对象 **/
		public function grid9PathInfo(gfile:*, path:String, showError:Boolean = true):Grid9Info
		{
			if (gfile && path)
			{
				var o:* = getPathObj(gfile, path, showError);
				if (o)
				{
					if (o is Grid9Info)
					{
						if (o.gfile == null) o.gfile = gfile;
						return o;
					}
					else if(o is SByte)
					{
						var byte:SByte = o as SByte;
						byte.position = 0;
						var grid9:Grid9Info = new Grid9Info();
						grid9.gfile = gfile;
						grid9.setByte(byte);
						return grid9;
					}
				}
			}
			return null;
		}
	}
}