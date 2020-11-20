package cn.wjj.data.file 
{
	import cn.wjj.display.grid9.Grid9Info;
	import cn.wjj.display.ui2d.info.U2InfoBitmapX;
	import cn.wjj.gagaframe.client.speedfact.SByte;
	
	/**
	 * 九宫格图形
	 * 
	 * @version 1.0.0
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 */
	public class GGrid9Info extends GFileBase
	{
		public function GGrid9Info():void
		{
			type = GFileType.Grid9Info;
		}
		
		/** 写入包体的内容,直接写入的是包内容二进制 **/
		override public function setBodyByte(b:SByte, disposeByte:Boolean = false):*
		{
			//已经错误了,多取了一个Package的内容,其实是要做映射
			b.position = 0;
			var grid9:Grid9Info = new Grid9Info();
			grid9.setByte(b);
			if (isBuilder)
			{
				sourceByte = b;
			}
			else if (disposeByte)
			{
				b.dispose();
			}
			this.obj = grid9;
			return grid9;
		}
		
		/** 把包体的内容输出 **/
		override public function getBodyByte():SByte
		{
			if (isBuilder && sourceByte)
			{
				sourceByte.position = 0;
				return sourceByte;
			}
			return (obj as Grid9Info).getByte();
		}
	}
}