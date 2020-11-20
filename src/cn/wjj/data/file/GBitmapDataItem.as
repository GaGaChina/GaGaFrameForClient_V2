package cn.wjj.data.file 
{
	import cn.wjj.display.speed.BitmapDataItem;
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	import cn.wjj.gagaframe.client.speedfact.SByte;
	import com.adobe.crypto.MD5;
	import flash.display.BitmapData;
	
	/**
	 * 一个二进制的文件单元
	 * 
	 * 里面的BitmapData使用GBitmapData内容,使用MD5连接对象,obj记录的MD5的值
	 * 
	 * @version 1.0.0
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 * @date 2013-05-30
	 */
	public class GBitmapDataItem extends GFileBase
	{
		/** X轴的偏移量 **/
		public var x:int = 0;
		/** Y轴的偏移量 **/
		public var y:int = 0;
		/** BitmapData 的 MD5值 **/
		public var bitmapMD5:String;
		
		public function GBitmapDataItem():void
		{
			this.type = GFileType.bitmapDataItem;
		}
		
		/** 写入包体的内容 **/
		override public function setBodyByte(b:SByte, disposeByte:Boolean = false):*
		{
			x = b._r_Int16();
			y = b._r_Int16();
			bitmapMD5 = b._r_String();
			if (isBuilder)
			{
				sourceByte = b;
			}
			else if (disposeByte)
			{
				b.dispose();
				b = null;
			}
			if (this.parent)
			{
				var p:GListBase = this.parent;
				var bitmap:GBitmapData = p.getMD5(bitmapMD5) as GBitmapData;
				while (!bitmap && p.parent)
				{
					p = p.parent;
					bitmap = p.getMD5(bitmapMD5) as GBitmapData;
				}
				if (bitmap)
				{
					if(!bitmap.isComplete)
					{
						g.event.addListener(bitmap, GFileEvent.BITMAPCOMPLETE, c);
					}
					var item:BitmapDataItem = new BitmapDataItem();
					item.x = x;
					item.y = y;
					item.bitmapData = bitmap.obj as BitmapData;
					if(!item.bitmapData)
					{
						item.gBitmapData = bitmap;
					}
					this.obj = item;
					return item;
				}
				else if (g.log.isLog)
				{
					g.log.pushLog(this, LogType._ErrorLog, "没有获取到父级包含MD5的BitmapData对象,或者不属于GBitmapData");
				}
			}
			return null;
		}
		
		/** 把包体的内容输出,记得把BitmapData也要存起来 **/
		override public function getBodyByte():SByte
		{
			if (isBuilder && sourceByte)
			{
				return sourceByte;
			}
			var b:SByte = SByte.instance();
			b.writeShort(x);
			b.writeShort(y);
			b._w_String(bitmapMD5);
			b.position = 0;
			return b;
		}
		
		private function c(e:GFileEvent):void
		{
			g.event.removeListener(e.currentTarget, GFileEvent.BITMAPCOMPLETE, c);
			var item:BitmapDataItem = new BitmapDataItem();
			item.x = x;
			item.y = y;
			item.bitmapData = e.file.obj as BitmapData;
			this.obj = item;
			var event:GFileEvent = new GFileEvent(GFileEvent.BITMAPCOMPLETE);
			event.file = this;
		}
		
		/** 把一个BitmapMovieDataFrameItem写入到这个文件里 **/
		public function setThis(o:BitmapDataItem, imageCompress:int = 0):void
		{
			this.obj = o;
			this.x = o.x;
			this.y = o.y;
			var data:GBitmapData = new GBitmapData();
			data.isRecover = false;
			data.isBuilder = this.isBuilder;
			data.parent = this.parent;
			data.path = this.path + "_info";
			data.width = o.bitmapData.width;
			data.height = o.bitmapData.height;
			data.imageCompress = imageCompress;
			data.setBitmapData(o.bitmapData);
			this.bitmapMD5 = data.md5;
			if (this.parent.getMD5(data.md5))
			{
				g.log.pushLog(this, LogType._UserAction, "打包MovieData减少尺寸,绕开" + data.path);
			}
			else
			{
				this.parent.push(data);
			}
			var key:String = this.x + "_" + this.y + this.bitmapMD5;
			this.md5 = MD5.hash(key);
		}
	}
}