package cn.wjj.display.ui2d.info 
{
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.speedfact.SByte;
	
	/**
	 * 画布的属性
	 * @author GaGa
	 */
	public class U2InfoBaseStageInfo extends U2InfoBase 
	{
		/** x的起点 **/
		public var startX:int = 0;
		/** y的起点 **/
		public var startY:int = 0;
		/** x的终点 **/
		public var width:int = 0;
		/** y的终点 **/
		public var height:int = 0;
		/** 背景颜色 **/
		public var bgColor:uint = 0;
		/** 背景透明度 **/
		public var bgAlpha:Number = 1;
		/** 根据内容自动设置背景,20%,最小值50*50 **/
		public var autoBg:Boolean = true;
		
		public function U2InfoBaseStageInfo(parent:U2InfoBaseInfo):void
		{
			super(parent);
			this.type = U2InfoType.baseStageInfo;
		}
		
		/** 获取这个对象的全部属性信息 **/
		override public function getByte():SByte 
		{
			var b:SByte = SByte.instance();
			b.writeShort(startX);
			b.writeShort(startY);
			b.writeShort(width);
			b.writeShort(height);
			b.writeUnsignedInt(bgColor);
			if (bgAlpha > 1)
			{
				bgAlpha = 1;
			}
			b.writeByte(uint(bgAlpha * 100));
			b.writeBoolean(autoBg);
			return b;
		}
		
		/** 读取这个内容 **/
		override public function setByte(b:SByte):void
		{
			startX = b.readShort();
			startY = b.readShort();
			width = b.readShort();
			height = b.readShort();
			bgColor = b.readUnsignedInt();
			bgAlpha = b.readUnsignedByte() / 100;
			if (parent.ver < 5)
			{
				if (startX == -300 && startY == -300 && width == 600 && height == 600)
				{
					autoBg = true;
				}
				else
				{
					autoBg = b.readBoolean();
				}
			}
			else
			{
				autoBg = b.readBoolean();
			}
		}
		
		/** 克隆一个对象 **/
		public function clone(parent:U2InfoBaseInfo):U2InfoBaseStageInfo
		{
			var o:U2InfoBaseStageInfo = new U2InfoBaseStageInfo(parent);
			o.startX = startX;
			o.startY = startY;
			o.width = width;
			o.height = height;
			o.bgColor = bgColor;
			o.bgAlpha = bgAlpha;
			o.autoBg = autoBg;
			return o;
		}
	}
}