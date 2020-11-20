package cn.wjj.display.ui2d.info
{
	import cn.wjj.gagaframe.client.speedfact.SByte;
	
	/**
	 * 播放控制数据
	 * 
	 * @version 2.0.0
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 */
	public class U2InfoPlayEvent extends U2InfoBase 
	{
		/** 是否使用时间 **/
		public var useTime:Boolean = true;
		/** 父级中的时间轴的时间点,毫秒 **/
		public var timeLine:uint = 0;
		/** 是否控制单独的图层,如果空就不控制 **/
		public var layerName:String = "";
		/** 本层是否播放 **/
		public var playThis:Boolean = true;
		/** 开始时间,毫秒 **/
		public var playChild:Boolean = true;
		/** 跳转到某时间点 **/
		public var gotoTime:int = -1;
		/** 停留播放某标签 **/
		public var playLabel:String = "";
		/** 循环次数-128 128 **/
		public var loop:int = -1;
		/** 停留播放某标签 **/
		public var overLabel:String = "";
		/** 播放完毕后是停留在开始,还是停留在最后幀,如果设置overLabel就忽略这个参数 **/
		public var stopBegin:Boolean = true;
		
		public function U2InfoPlayEvent(parent:U2InfoBaseInfo):void
		{
			super(parent);
			this.type = U2InfoType.playEvent;
		}
		
		/** 获取这个对象的全部属性信息 **/
		override public function getByte():SByte 
		{
			var b:SByte = SByte.instance();
			b.writeBoolean(useTime);
			b.writeUnsignedInt(timeLine);
			b._w_String(layerName);
			b.writeBoolean(playThis);
			b.writeBoolean(playChild);
			b.writeInt(gotoTime);
			b._w_String(playLabel);
			b.writeByte(loop);
			b._w_String(overLabel);
			b.writeBoolean(stopBegin);
			return b;
		}
		
		/** 读取这个内容 **/
		override public function setByte(b:SByte):void
		{
			useTime = b.readBoolean();
			timeLine = b.readUnsignedInt();
			layerName = b._r_String();
			playThis = b.readBoolean();
			playChild = b.readBoolean();
			gotoTime = b.readInt();
			playLabel = b._r_String();
			loop = b.readByte();
			overLabel = b._r_String();
			stopBegin = b.readBoolean();
		}
		
		/** 克隆一个对象 **/
		public function clone(parent:U2InfoBaseInfo):U2InfoPlayEvent
		{
			var o:U2InfoPlayEvent = new U2InfoPlayEvent(parent);
			o.useTime = useTime;
			o.timeLine = timeLine;
			o.layerName = layerName;
			o.playThis = playThis;
			o.playChild = playChild;
			o.gotoTime = gotoTime;
			o.playLabel = playLabel;
			o.loop = loop;
			o.overLabel = overLabel;
			o.stopBegin = stopBegin;
			return o;
		}
	}
}