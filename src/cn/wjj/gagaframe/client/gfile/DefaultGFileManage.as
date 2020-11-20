package cn.wjj.gagaframe.client.gfile
{
	import cn.wjj.data.file.GFileBase;
	import cn.wjj.display.grid9.Grid9Engine;
	import cn.wjj.display.grid9.Grid9Info;
	import cn.wjj.display.ui2d.engine.EngineInfo;
	import cn.wjj.display.ui2d.info.U2InfoBaseInfo;
	import cn.wjj.display.ui2d.info.U2InfoBitmapX;
	import cn.wjj.display.ui2d.U2Bitmap;
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.loader.AssetItem;
	import cn.wjj.gagaframe.client.speedfact.SByte;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.media.SoundChannel;
	import flash.utils.Dictionary;

	public class DefaultGFileManage
	{
		private var lib:Array;
		/** 默认GFile **/
		private var gfile:*;
		
		public function DefaultGFileManage()
		{
			lib = new Array();
		}
		
		public function pushGFile(gfile:*):void
		{
			if(gfile != null && this.gfile != gfile && lib.indexOf(gfile) == -1)
			{
				if(lib.length)
				{
					lib.push(gfile);
				}
				else if(this.gfile == null)
				{
					this.gfile = gfile
				}
				else
				{
					if(lib.length == 0)
					{
						lib.push(this.gfile);
						this.gfile = null;
					}
					lib.push(gfile);
				}
			}
		}
		
		/** 从列表中删除一个GFile的引用 **/
		public function removeGFile(gfile:*):void
		{
			if(this.gfile == gfile)
			{
				this.gfile = null;
			}
			else
			{
				var index:int = lib.indexOf(gfile);
				if(index != -1)
				{
					lib.splice(index, 1);
					if(lib.length == 1)
					{
						this.gfile = lib[0];
						lib.length = 0;
					}
				}
			}
		}
		
		/** 移除全部的GFile列表 **/
		public function removeAll():void
		{
			this.gfile = null;
			lib.length = 0;
		}
		
		/** 从一个GFile中获取一个路径的对象 **/
		public function getPath(path:String):GFileBase
		{
			if(gfile)
			{
				return g.gfile.getPath(gfile, path);
			}
			else if(lib.length)
			{
				var o:*;
				for each (var f:* in lib)
				{
					o = g.gfile.getPath(f, path);
					if(o)
					{
						return o;
					}
				}
			}
			return null;
		}
		
		/** 获取GFile文件中的对象 **/
		public function getPathObj(path:String):*
		{
			if(gfile)
			{
				return g.gfile.getPathObj(gfile, path);
			}
			else if(lib.length)
			{
				var o:*;
				for each (var f:* in lib) 
				{
					o = g.gfile.getPathObj(f, path);
					if(o)
					{
						return o;
					}
				}
			}
			return null;
		}
		
		/** 获取GFile文件中位图 **/
		public function bitmapData(path:String):BitmapData
		{
			return getPathObj(path);
		}
		
		/**
		 * 设置或获取信息内容,可能返回BitmapData,或
		 * @param	path
		 * @param	showError
		 * @param	display
		 */
		public function bitmapX(path:String, showError:Boolean = true, display:U2Bitmap = null, cache:Dictionary = null):*
		{
			var o:* = getPathObj(path);
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
					if (display.bitmapData != x.bitmapData)
					{
						display.bitmapData = x.bitmapData;
					}
					display.setOffsetX(x.offsetX, x.offsetY, x.offsetScaleX, x.offsetScaleY);
					display.path = path;
				}
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
			return o;
		}
		
		/** 创建U2图形 **/
		public function u2PathDisplay(path:String, selfEngine:Boolean  = true, core:int = -1, start:int = -1, cache:Dictionary = null):DisplayObject
		{
			var o:U2InfoBaseInfo = u2PathInfo(path);
			if(o)
			{
				return EngineInfo.create(o, selfEngine, core, start, cache);
			}
			return null;
		}
		
		/** 打开GFile文件里二进制,并获取数据对象 **/
		public function u2PathInfo(path:String):U2InfoBaseInfo
		{
			if (path)
			{
				var f:* = getPath(path);
				if(f)
				{
					f = f.parent;
				}
				if (f)
				{
					var o:* = f.getPathObj(path);
					if (o is U2InfoBaseInfo)
					{
						if (o.gfile == null) o.gfile = f;
						return o;
					}
					else if(o is SByte)
					{
						var byte:SByte = o as SByte;
						byte.position = 0;
						var u2:U2InfoBaseInfo = new U2InfoBaseInfo(null);
						u2.gfile = f;
						u2.setByte(byte);
						return u2;
					}
				}
			}
			return null;
		}
		
		/**
		 * 创建九宫格
		 * @param	path		路径
		 * @param	width		宽度
		 * @param	height		高度
		 * @return
		 */
		public function grid9PathDisplay(path:String, width:uint, height:uint):DisplayObject
		{
			var o:Grid9Info = grid9PathInfo(path);
			if(o)
			{
				return Grid9Engine.create(o, width, height);
			}
			return null;
		}
		
		/** 打开GFile文件里二进制,并获取数据对象 **/
		public function grid9PathInfo(path:String):Grid9Info
		{
			if (path)
			{
				var f:* = getPath(path);
				if(f)
				{
					f = f.parent;
				}
				if (f)
				{
					var o:* = f.getPathObj(path);
					if (o is Grid9Info)
					{
						if (o.gfile == null) o.gfile = f;
						return o;
					}
					else if(o is SByte)
					{
						var byte:SByte = o as SByte;
						byte.position = 0;
						var grid9:Grid9Info = new Grid9Info();
						grid9.gfile = f;
						grid9.setByte(byte);
						return grid9;
					}
				}
			}
			return null;
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
		public function playSound(path:String, teamName:String = "", startTime:Number = 0, endTime:Number = -1, loops:int = 1, volume:Number = 1, onComplete:Function = null):SoundChannel
		{
			var o:AssetItem = getPathObj(path) as AssetItem;
			if (o)
			{
				return g.loader.asset.sound.playAsset(o, teamName, startTime, endTime, loops, volume, onComplete);
			}
			return null;
		}
		
		/**
		 * 停止播放音乐
		 * @param assetItem
		 */
		public function stopSound(path:String):void
		{
			var o:AssetItem = getPathObj(path) as AssetItem;
			if (o) g.loader.asset.sound.stopAsset(o);
		}
	}
}