package cn.wjj.data.file 
{
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	import cn.wjj.gagaframe.client.speedfact.SByte;
	
	/**
	 * 一个可以记录模拟File或Byte的对象,以方便操作
	 * @author GaGa
	 */
	public class ByteLink 
	{
		/** 用于要在写入模式下打开的文件，并将所有写入的数据附加到文件末尾。打开文件时，会创建任何不存在的文件。 **/
		public static const APPEND:String = "append";
		/** 用于要在只读模式中打开的文件。文件必须存在（不创建缺少的文件）。 **/
		public static const READ : String = "read";
		/** 用于要在读/写模式中打开的文件。打开文件时，会创建任何不存在的文件。 **/
		public static const UPDATE : String = "update";
		/** 用于要在只写模式中打开的文件。打开文件时，会创建任何不存在的文件，并截断任何现有的文件（删除其数据）。 **/
		public static const WRITE : String = "write";
		
		/** 路径和文件之间形成关联,[path,文件路径] = ByteLink文件连接 **/
		public static var fileLink:Object = new Object();
		
		/** 文件的路径 **/
		public var path:String;
		/** 文件的引用 **/
		public var file:*;
		/** 文件FileStream或二进制的引用 **/
		public var link:*;
		/** 二进制是否是文件 **/
		public var isFile:Boolean = false;
		/** 文件模式, 空为关闭的文件 **/
		public var fileMode:String = "";
		
		/** ByteLink.GetLink 使用本参数初始化 **/
		public function ByteLink(e:Enforcer) { }
		
		/**
		 * 获取一个文件连接,这里将不会在出现文件出现乱七八糟的现象,而且可以非常好的
		 * @param	link
		 * @param	file
		 * @param	path
		 */
		public static function GetLink(link:*, file:* = null, path:String = ""):ByteLink
		{
			var o:ByteLink;
			if (file)
			{
				if (path == "")
				{
					g.log.pushLog(ByteLink, LogType._ErrorLog, "文件未找到路径" + file.nativePath);
				}
				if (fileLink.hasOwnProperty(path))
				{
					return fileLink[path];
				}
				o = new ByteLink(new Enforcer());
				o.link = link;
				o.file = file;
				o.path = path;
				o.isFile = true;
				fileLink[path] = o;
			}
			else
			{
				o = new ByteLink(new Enforcer());
				o.link = link;
			}
			return o;
		}
		
		/**
		 * 删除关联的File内容
		 * @param	path
		 * @return	是否成功删除
		 */
		public static function DelLink(path:String):Boolean
		{
			if (path && fileLink.hasOwnProperty(path))
			{
				var o:ByteLink = fileLink[path];
				if (o.isFile && o.fileMode != "")
				{
					o.link.close();
					o.fileMode = "";
					o.isFile = false;
				}
				if (o.link) o.link = null;
				if (o.file) o.file = null;
				o.path = "";
				delete fileLink[path];
				return true;
			}
			return false;
		}
		
		/**
		 * 获取连接
		 * @param	path
		 */
		public static function HasLink(path:String):ByteLink
		{
			if (fileLink.hasOwnProperty(path))
			{
				return fileLink[path];
			}
			return null;
		}
		
		/** 将文件指针的当前位置（以字节为单位）移动或返回到 ByteArray 对象中。下一次调用读取方法时将在此位置开始读取，或者下一次调用写入方法时将在此位置开始写入。 **/
		public function get position():uint { return link.position; }
		/** 将文件指针的当前位置（以字节为单位）移动或返回到 ByteArray 对象中。下一次调用读取方法时将在此位置开始读取，或者下一次调用写入方法时将在此位置开始写入。 **/
		public function set position(value:uint):void { link.position = value; }
		
		/** 改变读取模式 **/
		public function changeMode(mode:String):void
		{
			if (isFile)
			{
				switch (fileMode) 
				{
					case mode:
						break;
					case "":
						link.open(file, mode);
						fileMode = mode;
						break;
					default:
						link.close();
						link.open(file, mode);
						fileMode = mode;
				}
			}
		}
		
		/**
		 * 从文件流、字节流或字节数组中读取 length 参数指定的数据字节数。将从 offset 指定的位置开始，将字节读入 bytes 参数指定的 SByte 对象。
		 * @param	bytes	要将数据读入的 SByte 对象。
		 * @param	offset	bytes 参数中的偏移，应从该位置开始读取数据。
		 * @param	length	要读取的字节数。默认值 0 导致读取所有可用的数据。
		 */
		public function readBytes(bytes:SByte, offset:uint = 0, length:uint = 0):void
		{
			changeMode(ByteLink.READ);
			link.readBytes(bytes, offset, length);
		}
		
		/**
		 * 在指定的字节数组 bytes 中，从 offset（使用从零开始的索引）指定的字节开始，向文件流、字节流或字节数组中写入一个长度由 length 指定的字节序列。
		 *  如果省略 length 参数，则使用默认长度 0 并从 offset 开始写入整个缓冲区。如果还省略了 offset 参数，则写入整个缓冲区。 如果 offset 或 length 参数超出范围，它们将被锁定到 bytes 数组的开头和结尾。
		 * @param	bytes	要写入的字节数组。
		 * @param	offset	从零开始的索引，指定在数组中开始写入的位置。
		 * @param	length	一个无符号整数，指定在缓冲区中的写入范围。
		 */
		public function writeBytes(bytes:SByte, offset:uint = 0, length:uint = 0):void
		{
			changeMode(ByteLink.WRITE);
			link.writeBytes(bytes, offset, length);
		}
		
		/** 关闭文件系统 **/
		public function close():void
		{
			if (isFile && fileMode)
			{
				link.close();
				fileMode = "";
			}
		}
		
		/** 删除文件 **/
		public function dispose():void
		{
			if (isFile && fileMode != "")
			{
				link.close();
				fileMode = "";
				isFile = false;
			}
			if (path)
			{
				if (ByteLink.fileLink.hasOwnProperty(path))
				{
					delete ByteLink.fileLink[path];
				}
				path = "";
			}
			if (link) link = null;
			if (file) file = null;
		}
	}
}
class Enforcer{}