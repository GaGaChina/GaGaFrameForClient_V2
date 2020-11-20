package cn.wjj.data.file 
{
	import cn.wjj.gagaframe.client.speedfact.SByte;
	
	/**
	 * 二进制和AMF互转
	 * 
	 * @version 1.0.0
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 */
	public class AMFFile extends GFileBase
	{
		public function AMFFile():void
		{
			type = GFileType.AMF;
		}
		
		/** 写入包体的内容 **/
		override public function setBodyByte(b:SByte, disposeByte:Boolean = false):*
		{
			var o:Object = b.readObject();
			obj = o;
			if (isBuilder)
			{
				sourceByte = b;
			}
			else if (disposeByte)
			{
				b.dispose();
			}
			return o;
		}
		
		/** 把包体的内容输出 **/
		override public function getBodyByte():SByte
		{
			if (isBuilder && sourceByte)
			{
				return sourceByte;
			}
			var b:SByte = SByte.instance();
			b.writeObject(obj);
			b.position = 0;
			return b;
		}
	}
}