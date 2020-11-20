package cn.wjj.data.socketHead
{
	import cn.wjj.data.CustomByteArray;
	
	/**
	 * 一个最简单的Socket包头,加包头和拆包头的协议
	 * 1.uint32 位的包体长度
	 * 2.ByteArray 包体内容
	 * 
	 * @version 1.0.0
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 * @time 2012-07-26
	 */
	public class HeadEasy
	{
		/**
		 * 添加包头
		 * @param info
		 * @return 
		 */
		public static function addHead(info:CustomByteArray):CustomByteArray
		{
			var out:CustomByteArray = new CustomByteArray();
			//写入长度
			out._w_Uint32(info.length);
			//写入内容
			info.position = 0;
			out.writeBytes(info);
			return out;
		}
		
		/**
		 * 去除包头,获得包体内容
		 * @param info
		 * @return 
		 * 
		 */
		public static function delHead(info:CustomByteArray):CustomByteArray
		{
			var headSize:uint = 4;
			if(info.length >= headSize)
			{
				info.position = 0;
				var l:uint = info._r_Uint32();
				if(info.length >= (headSize + l))
				{
					var out:CustomByteArray = new CustomByteArray();
					out.endian = info.endian;
					info.readBytes(out, 0, l);
					var newByte:CustomByteArray = new CustomByteArray();
					newByte.endian = info.endian;
					info.readBytes(newByte);
					newByte.position = 0;
					info.length = 0;
					info.writeBytes(newByte);
					return out;
				}
			}
			return null;
		}
	}
}