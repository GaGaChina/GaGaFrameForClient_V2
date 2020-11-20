package cn.wjj.tool
{
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author GaGa
	 */
	public final class EncodeCode
	{
		public function EncodeCode()
		{
			throw new Error("文字转换工具包无法实例化！");
		}
		
		public static function EncodeUtf8(str:String):String 
		{
			var oriByteArr:ByteArray = new ByteArray();
			oriByteArr.writeUTFBytes(str);
			var tempByteArr : ByteArray = new ByteArray();
			for (var i:int = 0; i < oriByteArr.length; i++)
			{
				if (oriByteArr[i] == 194)
				{
					  tempByteArr.writeByte(oriByteArr[i+1]);
					  i++;
				}
				else if (oriByteArr[i] == 195)
				{
					tempByteArr.writeByte(oriByteArr[i+1] + 64);
					i++;
				}
				else
				{
					tempByteArr.writeByte(oriByteArr[i]);
				}
			}
			tempByteArr.position = 0;
			return tempByteArr.readMultiByte(tempByteArr.bytesAvailable, "chinese");
		}
	}
}
