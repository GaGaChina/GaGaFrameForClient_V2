package cn.wjj.data.file 
{
	import cn.wjj.gagaframe.client.speedfact.SByte;
	import flash.media.Sound;
	
	/**
	 * 一个被删除后,留下来的空白区域
	 * 
	 * @version 1.0.0
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 */
	public class GMP3 extends GFileBase
	{
		
		public function GMP3():void
		{
			type = GFileType.MP3;
		}
		
		/**
		 * 写入包体的内容,特指JPG,PNG的二进制
		 * @param	b
		 * @param	transparent
		 */
		override public function setBodyByte(b:SByte, disposeByte:Boolean = false):*
		{
			var o:Sound = new Sound();
			o.loadCompressedDataFromByteArray(b, b.length);
			if (isBuilder)
			{
				sourceByte = b;
			}
			else if (disposeByte)
			{
				b.dispose();
			}
			this.obj = o;
			return o;
		}
	}
}