package cn.wjj.data.file 
{
	import cn.wjj.gagaframe.client.speedfact.SByte;
	
	/**
	 * 一个被删除后,留下来的空白区域
	 * 
	 * @version 1.0.0
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 */
	public class GAssist extends GFileBase
	{
		/**文件的修改时间 **/
		public var time:Number = 0;
		/**文件的长度 **/
		public var size:uint = 0;
		/** BitmapX 文件的修改时间 **/
		public var bxTime:Number = 0;
		/** BitmapX 文件的长度 **/
		public var bxSize:uint = 0;
		/** BitmapX 的MD5 **/
		public var bxMD5:String = "";
		
		public function GAssist():void
		{
			type = GFileType.assist;
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
			b.writeDouble(time);
			b.writeUnsignedInt(size);
			//-------------图片外加属性
			b.writeDouble(bxTime);
			b.writeUnsignedInt(bxSize);
			b.writeUTF(bxMD5);
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
			time = b.readDouble();
			size = b.readUnsignedInt();
			//-------------图片外加属性
			if (b.position < b.length)
			{
				bxTime = b.readDouble();
				bxSize = b.readUnsignedInt();
				bxMD5 = b.readUTF();
			}
			if (disposeByte)
			{
				b.dispose();
			}
		}
	}
}