package cn.wjj.crypto
{
	import flash.utils.ByteArray;
	
	/**
	 * CRC32  加密
	 * @private
	 */
	public class CRC32
	{
		
		private static var crcTable:Array = makeCrcTable();
		
		private static var byte:ByteArray = new ByteArray();
		
		public static function getCRC32(data:ByteArray, start:int = 0, len:int = 0):uint
		{
			if (start >= data.length)
			{
				start = data.length;
			}
			if (len == 0)
			{
				len = data.length - start;
			}
			if (len + start > data.length)
			{
				len = data.length - start;
			}
			var c:int = int(0xffffffff);
			for (var i:int = start; i < len; i++)
			{
				c = int(crcTable[(c ^ data[i]) & 0xff]) ^ (c >>> 8);
			}
			return c ^ 0xffffffff;
		}
		
		/** 获取字符串的CRC32 **/
		public static function getStr(s:String):uint
		{
			if (byte.length) byte.length = 0;
			byte.writeUTFBytes(s);
			return getCRC32(byte);
		}
		
		private static function makeCrcTable():Array
		{
			var p:int = int(0xEDB88320);
			var crcTable:Array = [];
			var i:int = 256;			
			while (i--)
			{				
				var crc:uint = i;
				var j:int = 8;
				while (j--)
				{
					crc = (crc & 1) ? (crc >>> 1) ^ p : (crc >>> 1);
				}
				crcTable[i] = crc;		
			}
			return crcTable;
		}
	}
}