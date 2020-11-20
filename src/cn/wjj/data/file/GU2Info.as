package cn.wjj.data.file 
{
	import cn.wjj.display.ui2d.info.U2InfoBaseInfo;
	import cn.wjj.gagaframe.client.speedfact.SByte;
	
	/**
	 * 一个被删除后,留下来的空白区域
	 * 
	 * @version 1.0.0
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 */
	public class GU2Info extends GFileBase
	{
		
		public function GU2Info():void
		{
			type = GFileType.U2Info;
		}
		
		/**
		 * 写入包体的内容
		 * @param	b
		 */
		override public function setBodyByte(b:SByte, disposeByte:Boolean = false):*
		{
			var o:U2InfoBaseInfo = new U2InfoBaseInfo(null);
			o.gfile = this.parent;
			o.setByte(b);
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
		
		/** 包体的内容输出 **/
		override public function getBodyByte():SByte 
		{
			if (isBuilder && sourceByte)
			{
				sourceByte.position = 0;
				return sourceByte;
			}
			if (obj)
			{
				var o:U2InfoBaseInfo = obj as U2InfoBaseInfo;
				if (o)
				{
					var b:SByte = o.getByte();
					b.position = 0;
					return b;
				}
			}
			return SByte.instance();
		}
	}
}