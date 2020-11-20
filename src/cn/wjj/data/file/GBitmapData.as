package cn.wjj.data.file 
{
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	import cn.wjj.gagaframe.client.speedfact.SByte;
	import com.adobe.crypto.MD5;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.JPEGEncoderOptions;
	import flash.display.Loader;
	import flash.display.PNGEncoderOptions;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	/**
	 * BitmapData的二进制转换类
	 * 
	 * 异步编译图形信息,可以添加回调函数GFileEvent.BITMAPCOMPLETE
	 * 
	 * @version 1.0.0
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 * @date 2013-06-09
	 */
	public class GBitmapData extends GFileBase implements IEventDispatcher
	{
		/** 如果是压缩的格式是否记录二进制 **/
		public static var zipSaveByte:Boolean = false;
		/** 全局设置区域使用的Rectangle **/
		private static var rect:Rectangle = new Rectangle();
		/** 添加事件调度 **/
		private var dispatcher:EventDispatcher;
		/** 图片的宽度 **/
		public var width:uint = 0;
		/** 图片的高度 **/
		public var height:uint = 0;
		/** 图片是否透明 **/
		public var transparent:Boolean = true;
		/** 图片所选择的压缩方式 **/
		public var imageCompress:int = 0;
		/** 图片下载器 **/
		private var imageLoader:Loader;
		
		public function GBitmapData():void
		{
			this.type = GFileType.bitmapData;
		}
		
		/** [先设包头->在设包体]获取包头部分,不包含属性部分 **/
		override public function getHeadByte():SByte
		{
			var b:SByte = SByte.instance();
			b.writeUTF(name);
			b.writeUTF(assets);
			b.writeUTF(ver);
			b.writeUTF(path);
			b.writeUTF(md5);
			b.writeByte(compress);
			b.writeUnsignedInt(sourceLength);
			b.writeBoolean(autoLoader);
			b.writeBoolean(isRecover);
			//-------------外加属性
			b.writeByte(imageCompress);
			b.writeShort(width);
			b.writeShort(height);
			b.writeBoolean(transparent);
			return b;
		}
		
		/** [先设包头->在设包体]通过二进制设置文件头,不包含内容的其他部分 **/
		override public function setHeadByte(b:SByte, disposeByte:Boolean = false):void
		{
			name = b.readUTF();
			assets = b.readUTF();
			ver = b.readUTF();
			path = b.readUTF();
			md5 = b.readUTF();
			compress = b.readUnsignedByte();
			sourceLength = b.readUnsignedInt();
			autoLoader = b.readBoolean();
			if (GFileBase.globalAutoLoader == 1)
			{
				autoLoader = true;
			}
			else if (GFileBase.globalAutoLoader == -1)
			{
				autoLoader = false;
			}
			isRecover = b.readBoolean();
			if (GFileBase.globalRecover == 1)
			{
				isRecover = true;
			}
			else if (GFileBase.globalRecover == -1)
			{
				isRecover = false;
			}
			//-------------外加属性
			imageCompress = b.readUnsignedByte();
			width = b.readUnsignedShort();
			height = b.readUnsignedShort();
			transparent = b.readBoolean();
			if (disposeByte)
			{
				b.dispose();
			}
		}
		
		/**
		 * 写入包体的内容,特指JPG,PNG的二进制
		 * @param	b
		 * @param	transparent
		 */
		override public function setBodyByte(b:SByte, disposeByte:Boolean = false):*
		{
			var o:BitmapData;
			if (isBuilder)
			{
				sourceByte = b;
			}
			o = byteToBimapData(b);
			this.obj = o;
			return o;
		}
		
		/** 通过一个二进制获取这个Bitmap **/
		private function byteToBimapData(b:SByte):BitmapData
		{
			var bmd:BitmapData = new BitmapData(this.width, this.height, this.transparent, 0);
			switch (this.imageCompress) 
			{
				case GBitmapDataType.compressBitmapZip:
					b.uncompress();
					b.position = 0;
					rect.width = this.width;
					rect.height = this.height;
					bmd.setPixels(rect, b);
					break;
				case GBitmapDataType.compressBitmap7z:
					b.uncompress("lzma");
					b.position = 0;
					rect.width = this.width;
					rect.height = this.height;
					bmd.setPixels(rect, b);
					break;
				case GBitmapDataType.compressByte:
					b.position = 0;
					rect.width = this.width;
					rect.height = this.height;
					bmd.setPixels(rect, b);
					break;
				case GBitmapDataType.compressBytePNG:
				case GBitmapDataType.compressBytePNGSpeed:
				case GBitmapDataType.compressByteJPG100:
				case GBitmapDataType.compressByteJPG95:
				case GBitmapDataType.compressByteJPG90:
				case GBitmapDataType.compressByteJPG85:
				case GBitmapDataType.compressByteJPG80:
				case GBitmapDataType.compressByteJPG75:
				case GBitmapDataType.compressByteJPG70:
				case GBitmapDataType.compressByteJPG60:
				case GBitmapDataType.compressByteJPG50:
				case GBitmapDataType.compressByteJPG40:
				case GBitmapDataType.compressByteJPG30:
				case GBitmapDataType.compressByteJPG20:
				case GBitmapDataType.compressByteJPG10:
					imageLoader = new Loader();
					imageLoader.loadBytes(b);
					imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderToDraw);
					break;
				default:
					b.position = 0;
					setBodyUseFile(b);
			}
			return bmd;
		}
		
		/** 获取文件 **/
		override public function get obj():* 
		{
			var out:* = super.obj;
			if (out)
			{
				return out;
			}
			if(sourceByte && GBitmapData.zipSaveByte)
			{
				try
				{
					out = byteToBimapData(sourceByte);
				}
				catch(e:Error)
				{
					g.log.pushLog(this, LogType._ErrorLog, e);
				}
				obj = out;
				sourceByte = null;
				return out;
			}
			return null;
		}
		
		/** 使用JPG,PNG等图片来设置本对象 **/
		public function setBodyUseFile(b:SByte):void
		{
			b.position = 0;
			imageLoader = new Loader();
			imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderComplete);
			imageLoader.loadBytes(b);
		}
		
		private function loaderToDraw(e:Event):void
		{
			if(obj is BitmapData)
			{
				obj.draw(imageLoader);
			}
			if(imageLoader)
			{
				if(imageLoader.contentLoaderInfo && imageLoader.contentLoaderInfo.hasEventListener(Event.COMPLETE))
				{
					imageLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loaderComplete);
				}
				imageLoader = null;
			}
		}
		
		/** 异步加载完毕 **/
		private function loaderComplete(e:Event):void 
		{
			var info:BitmapData = (e.currentTarget.content as Bitmap).bitmapData;
			this.width = info.width;
			this.height = info.height;
			this.transparent = info.transparent;
			obj = info;
			//保存数据
			if (isBuilder && sourceByte == null)
			{
				var b:SByte = SByte.instance();
				var bytes:ByteArray;
				switch (this.imageCompress) 
				{
					case GBitmapDataType.compressBitmapZip:
						bytes = obj.getPixels(obj.rect);
						bytes.position = 0;
						b.writeBytes(bytes);
						b.compress();
						break;
					case GBitmapDataType.compressBitmap7z:
						bytes = obj.getPixels(obj.rect);
						bytes.position = 0;
						b.writeBytes(bytes);
						b.compress("lzma");
						break;
					case GBitmapDataType.compressByte:
						bytes = obj.getPixels(obj.rect);
						bytes.position = 0;
						b.writeBytes(bytes);
						break;
					/*
					Flash Builder 4.6 要屏蔽的内容
					*/
					case GBitmapDataType.compressBytePNG:
						obj.encode(obj.rect, new PNGEncoderOptions(false), b);
						break;
					case GBitmapDataType.compressBytePNGSpeed:
						obj.encode(obj.rect, new PNGEncoderOptions(true), b);
						break;
					case GBitmapDataType.compressByteJPG100:
						obj.encode(obj.rect, new JPEGEncoderOptions(100), b);
						break;
					case GBitmapDataType.compressByteJPG95:
						obj.encode(obj.rect, new JPEGEncoderOptions(95), b);
						break;
					case GBitmapDataType.compressByteJPG90:
						obj.encode(obj.rect, new JPEGEncoderOptions(90), b);
						break;
					case GBitmapDataType.compressByteJPG85:
						obj.encode(obj.rect, new JPEGEncoderOptions(85), b);
						break;
					case GBitmapDataType.compressByteJPG80:
						obj.encode(obj.rect, new JPEGEncoderOptions(80), b);
						break;
					case GBitmapDataType.compressByteJPG75:
						obj.encode(obj.rect, new JPEGEncoderOptions(75), b);
						break;
					case GBitmapDataType.compressByteJPG70:
						obj.encode(obj.rect, new JPEGEncoderOptions(70), b);
						break;
					case GBitmapDataType.compressByteJPG60:
						obj.encode(obj.rect, new JPEGEncoderOptions(60), b);
						break;
					case GBitmapDataType.compressByteJPG50:
						obj.encode(obj.rect, new JPEGEncoderOptions(50), b);
						break;
					case GBitmapDataType.compressByteJPG40:
						obj.encode(obj.rect, new JPEGEncoderOptions(40), b);
						break;
					case GBitmapDataType.compressByteJPG30:
						obj.encode(obj.rect, new JPEGEncoderOptions(30), b);
						break;
					case GBitmapDataType.compressByteJPG20:
						obj.encode(obj.rect, new JPEGEncoderOptions(20), b);
						break;
					case GBitmapDataType.compressByteJPG10:
						obj.encode(obj.rect, new JPEGEncoderOptions(10), b);
						break;
				}
				if (b)
				{
					b.position = 0;
					sourceByte = b;
				}
			}
			if (dispatcher)
			{
				var eg:GFileEvent = new GFileEvent(GFileEvent.BITMAPCOMPLETE);
				eg.file = this;
				dispatchEvent(eg);
			}
			if(imageLoader)
			{
				if(imageLoader.contentLoaderInfo && imageLoader.contentLoaderInfo.hasEventListener(Event.COMPLETE))
				{
					imageLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loaderComplete);
				}
				imageLoader = null;
			}
		}
		
		/** 把包体的内容输出 **/
		override public function getBodyByte():SByte
		{
			if (isBuilder && sourceByte)
			{
				return sourceByte;
			}
			var b:SByte = SByte.instance();
			var bytes:ByteArray;
			switch (this.imageCompress) 
			{
				case GBitmapDataType.compressBitmapZip:
					bytes = obj.getPixels(obj.rect);
					bytes.position = 0;
					b.writeBytes(bytes);
					b.compress();
					break;
				case GBitmapDataType.compressBitmap7z:
					bytes = obj.getPixels(obj.rect);
					bytes.position = 0;
					b.writeBytes(bytes);
					b.compress("lzma");
					break;
				case GBitmapDataType.compressByte:
					bytes = obj.getPixels(obj.rect);
					bytes.position = 0;
					b.writeBytes(bytes);
					break;
				/*
				Flash Builder 4.6 要屏蔽的内容
				
				*/
				case GBitmapDataType.compressBytePNG:
					obj.encode(obj.rect, new PNGEncoderOptions(false), b);
					break;
				case GBitmapDataType.compressBytePNGSpeed:
					obj.encode(obj.rect, new PNGEncoderOptions(true), b);
					break;
				case GBitmapDataType.compressByteJPG100:
					obj.encode(obj.rect, new JPEGEncoderOptions(100), b);
					break;
				case GBitmapDataType.compressByteJPG95:
					obj.encode(obj.rect, new JPEGEncoderOptions(95), b);
					break;
				case GBitmapDataType.compressByteJPG90:
					obj.encode(obj.rect, new JPEGEncoderOptions(90), b);
					break;
				case GBitmapDataType.compressByteJPG85:
					obj.encode(obj.rect, new JPEGEncoderOptions(85), b);
					break;
				case GBitmapDataType.compressByteJPG80:
					obj.encode(obj.rect, new JPEGEncoderOptions(80), b);
					break;
				case GBitmapDataType.compressByteJPG75:
					obj.encode(obj.rect, new JPEGEncoderOptions(75), b);
					break;
				case GBitmapDataType.compressByteJPG70:
					obj.encode(obj.rect, new JPEGEncoderOptions(70), b);
					break;
				case GBitmapDataType.compressByteJPG60:
					obj.encode(obj.rect, new JPEGEncoderOptions(60), b);
					break;
				case GBitmapDataType.compressByteJPG50:
					obj.encode(obj.rect, new JPEGEncoderOptions(50), b);
					break;
				case GBitmapDataType.compressByteJPG40:
					obj.encode(obj.rect, new JPEGEncoderOptions(40), b);
					break;
				case GBitmapDataType.compressByteJPG30:
					obj.encode(obj.rect, new JPEGEncoderOptions(30), b);
					break;
				case GBitmapDataType.compressByteJPG20:
					obj.encode(obj.rect, new JPEGEncoderOptions(20), b);
					break;
				case GBitmapDataType.compressByteJPG10:
					obj.encode(obj.rect, new JPEGEncoderOptions(10), b);
					break;
				
			}
			b.position = 0;
			return b;
		}
		   
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			if (dispatcher == null) dispatcher = new EventDispatcher(this);
			dispatcher.addEventListener(type, listener, useCapture, priority);
		}
		
		public function dispatchEvent(e:Event):Boolean
		{
			if (dispatcher) return dispatcher.dispatchEvent(e);
			return false;
		}
		
		public function hasEventListener(type:String):Boolean
		{
			if (dispatcher) return dispatcher.hasEventListener(type);
			return false;
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			if (dispatcher) dispatcher.removeEventListener(type, listener, useCapture);
		}
		
		public function willTrigger(type:String):Boolean
		{
			if (dispatcher) return dispatcher.willTrigger(type);
			return false;
		}
		
		/** 把一个BitmapMovieDataFrameItem写入到这个文件里 **/
		public function setBitmapData(o:BitmapData):void
		{
			this.width = o.width;
			this.height = o.height;
			this.transparent = o.transparent;
			this.obj = o;
			sourceByte = SByte.instance();
			var bytes:ByteArray;
			var byteList:Array;
			switch (this.imageCompress) 
			{
				case GBitmapDataType.compressBitmapZip:
					bytes = o.getPixels(o.rect);
					bytes.position = 0;
					sourceByte.writeBytes(bytes);
					sourceByte.compress();
					break;
				case GBitmapDataType.compressBitmap7z:
					bytes = o.getPixels(o.rect);
					bytes.position = 0;
					sourceByte.writeBytes(bytes);
					sourceByte.compress("lzma");
					break;
				case GBitmapDataType.compressByte:
					bytes = obj.getPixels(obj.rect);
					bytes.position = 0;
					sourceByte.writeBytes(bytes);
					sourceByte.position = 0;
					break;
				/*
				Flash Builder 4.6 要屏蔽的内容
				
				*/
				
				case GBitmapDataType.compressBytePNG:
					o.encode(o.rect, new PNGEncoderOptions(false), sourceByte);
					break;
				case GBitmapDataType.compressBytePNGSpeed:
					o.encode(o.rect, new PNGEncoderOptions(true), sourceByte);
					break;
				case GBitmapDataType.compressByteJPG100:
					o.encode(o.rect, new JPEGEncoderOptions(100), sourceByte);
					break;
				case GBitmapDataType.compressByteJPG95:
					o.encode(o.rect, new JPEGEncoderOptions(95), sourceByte);
					break;
				case GBitmapDataType.compressByteJPG90:
					o.encode(o.rect, new JPEGEncoderOptions(90), sourceByte);
					break;
				case GBitmapDataType.compressByteJPG85:
					o.encode(o.rect, new JPEGEncoderOptions(85), sourceByte);
					break;
				case GBitmapDataType.compressByteJPG80:
					o.encode(o.rect, new JPEGEncoderOptions(80), sourceByte);
					break;
				case GBitmapDataType.compressByteJPG75:
					o.encode(o.rect, new JPEGEncoderOptions(75), sourceByte);
					break;
				case GBitmapDataType.compressByteJPG70:
					o.encode(o.rect, new JPEGEncoderOptions(70), sourceByte);
					break;
				case GBitmapDataType.compressByteJPG60:
					o.encode(o.rect, new JPEGEncoderOptions(60), sourceByte);
					break;
				case GBitmapDataType.compressByteJPG50:
					o.encode(o.rect, new JPEGEncoderOptions(50), sourceByte);
					break;
				case GBitmapDataType.compressByteJPG40:
					o.encode(o.rect, new JPEGEncoderOptions(40), sourceByte);
					break;
				case GBitmapDataType.compressByteJPG30:
					o.encode(o.rect, new JPEGEncoderOptions(30), sourceByte);
					break;
				case GBitmapDataType.compressByteJPG20:
					o.encode(o.rect, new JPEGEncoderOptions(20), sourceByte);
					break;
				case GBitmapDataType.compressByteJPG10:
					o.encode(o.rect, new JPEGEncoderOptions(10), sourceByte);
					break;
				
			}
			if (sourceByte)
			{
				this.md5 = MD5.hashBinary(sourceByte);
				sourceByte.position = 0;
			}
		}
		
		/** 摧毁obj的内容 **/
		override public function disposeObj():void
		{
			if (this.obj)
			{
				var o:BitmapData = this.obj as BitmapData;
				if (o) o.dispose();
				if(Robj)
				{
					for (_temp_o in Robj) 
					{
						delete Robj[_temp_o];
					}
					g.speedFact.d_dictWeak(Robj);
					Robj = null;
				}
				if (Qobj) Qobj = null;
				this.sourceByte = null;
			}
		}
	}
}