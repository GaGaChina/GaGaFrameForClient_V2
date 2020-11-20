package cn.wjj.data.file
{
	/**
	 * 文件相关操作的工具类
	 * @author 嘎嘎
	 */
	public class FileSize
	{
		 /**
		  * 给一个文件的大小,换算出大小,123456KB
		  * @param	bytes			文件的大小,字节数
		  * @param	decimals = 1	小数点后的
		  * @return
		  */
		public static function getSize(bytes:Number, decimals:int = 1):String
		{
			if(isNaN(bytes))
			{
				bytes = 0;
			}
			var name:String = "Bytes";
			var endBytes:Number;
			if (bytes >= 1152921504606846976)
			{
				name = "EB";
				endBytes = bytes / 1152921504606846976;
			}
			else if (bytes >= 1125899906842624)
			{
				name = "PB";
				endBytes = bytes / 1125899906842624;
			}
			else if (bytes >= 1099511627776)
			{
				name = "TB";
				endBytes = bytes / 1099511627776;
			}
			else if (bytes >= 1073741824)
			{
				name = "GB";
				endBytes = bytes / 1073741824;
			}
			else if (bytes >= 1048576)
			{
				name = "MB";
				endBytes = bytes / 1048576;
			}
			else if (bytes >= 1024)
			{
				name = "KB";
				endBytes = bytes / 1024;
			}
			else
			{
				return bytes + " " + name;
			}
			var decimalsNum:Number = 1;
			for (var i:int = 0; i < decimals; i++)
			{
				decimalsNum = decimalsNum * 10;
			}
			endBytes = Math.round(endBytes * decimalsNum) / decimalsNum;
			return endBytes + " " + name;
		}
		
		/**
		 * 给一个文件的大小,换算出大小
		 * @param	bytes			文件的大小,字节数
		 * @param	decimals = 1	小数点后的
		 * @return
		 */
		public static function getMinSize(bytes:Number, decimals:int = 1):String
		{
			if(isNaN(bytes))
			{
				bytes = 0;
			}
			var name:String = "byt";
			var endBytes:Number;
			if (bytes >= 1152921504606846976)
			{
				name = "e";
				endBytes = bytes / 1152921504606846976;
			}
			else if (bytes >= 1125899906842624)
			{
				name = "p";
				endBytes = bytes / 1125899906842624;
			}
			else if (bytes >= 1099511627776)
			{
				name = "t";
				endBytes = bytes / 1099511627776;
			}
			else if (bytes >= 1073741824)
			{
				name = "g";
				endBytes = bytes / 1073741824;
			}
			else if (bytes >= 1048576)
			{
				name = "m";
				endBytes = bytes / 1048576;
			}
			else if (bytes >= 1024)
			{
				name = "k";
				endBytes = bytes / 1024;
			}
			else
			{
				return bytes + name;
			}
			var decimalsNum:Number = 1;
			for (var i:int = 0; i < decimals; i++)
			{
				decimalsNum = decimalsNum * 10;
			}
			endBytes = Math.round(endBytes * decimalsNum) / decimalsNum;
			return endBytes + name;
		}
		
		/**
		 * 获取一个文件大小M的数量,百万尺寸
		 * @param bytes
		 * @param decimals
		 * @return 
		 */
		public static function getMillion(bytes:Number, decimals:int = 1):Number
		{
			if(isNaN(bytes))
			{
				bytes = 0;
			}
			//1024 * 1024 = 1048576;
			bytes = bytes / 1048576;
			var decimalsNum:Number = 1;
			for (var i:int = 0; i < decimals; i++)
			{
				decimalsNum = decimalsNum * 10;
			}
			bytes = Math.round(bytes * decimalsNum) / decimalsNum;
			return bytes;
		}
	}
}