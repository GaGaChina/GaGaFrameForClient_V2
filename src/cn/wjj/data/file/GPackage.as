package cn.wjj.data.file 
{
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	import cn.wjj.gagaframe.client.speedfact.SByte;
	
	/**
	 * 包中包结构
	 * 
	 * @version 1.0.0
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 * @date 2013-06-09
	 */
	public class GPackage extends GFileBase
	{
		
		public function GPackage():void
		{
			this.type = GFileType.packageBox;
		}
		
		/** 写入包体的内容,直接写入的是包内容二进制 **/
		override public function setBodyByte(b:SByte, disposeByte:Boolean = false):*
		{
			//已经错误了,多取了一个Package的内容,其实是要做映射
			b.position = 0;
			/** 包中包类型,比下面多一个值正常 **/
			var gfileType:int = b.readByte();
			var file:GFileBase;
			switch(gfileType)
			{
				case GFileType.byte:
					file = new GListBase();
					break;
				case GFileType.AMF:
					file = new AMFFile();
					break;
				case GFileType.AMFList:
					file = new AMFFileList();
					break;
				case GFileType.AMFListConfig:
					file = new AMFFileListConfig();
					break;
				case GFileType.bitmapData:
					file = new GBitmapData();
					break;
				case GFileType.listBase:
					file = new GListBase();
					break;
				case GFileType.language:
					file = new GLanguage();
					break;
				case GFileType.packageBox:
					file = new GPackage();
					break;
				default:
					g.log.pushLog(this, LogType._ErrorLog, "在CPackage中没有找到对应类型:" + gfileType);
			}
			file.parent = this.parent;
			file.parentPackage = this;
			this.obj = file;
			var out:* = file.setByte(b);
			if (isBuilder)
			{
				sourceByte = b;
			}
			else if (disposeByte)
			{
				b.dispose();
			}
			return out;
		}
		
		/** 数据是否准备完毕,image 类是需要异步解压的 **/
		override public function get isComplete():Boolean
		{
			if (obj != null)
			{
				if (obj is GFileBase)
				{
					return (obj as GFileBase).isComplete;
				}
				else
				{
					return true;
				}
			}
			return false;
		}
		
		/** 把包体的内容输出 **/
		override public function getBodyByte():SByte
		{
			if (isBuilder && sourceByte)
			{
				sourceByte.position = 0;
				return sourceByte;
			}
			var b:SByte = (obj as GFileBase).getByte();
			return b;
		}
	}
}