package cn.wjj.display.ui2d.info
{
	import cn.wjj.gagaframe.client.speedfact.SByte;
	
	/**
	 * 记录声音
	 * @version 2.0.0
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 */
	public class U2InfoSound extends U2InfoBase 
	{
		/** 是否使用时间 **/
		public var useTime:Boolean = true;
		/** 父级中的时间轴的时间点,毫秒 **/
		public var timeLine:uint = 0;
		/** 保存的路径 **/
		public var path:String = "";
		/** 声音的队列名称 **/
		public var team:String = "音效";
		/** (0 到 255)是否循环播放,和循环播放次数 **/
		public var loop:uint = 1;
		/** 开始时间,毫秒 **/
		public var start:int = 0;
		/** 结束时间,毫秒 **/
		public var end:int = -1;
		/** 声音大小 **/
		public var volume:Number = 1;
		/** 是否检查队列音量,如果没有音量,自动不去播放声音, true是检查,false必定播放 **/
		public var checkTeam:Boolean = true;
		/** (先不生效,不做)是否根据动画的播放帧,对准声音的播放时间 **/
		public var aimSound:Boolean = false;
		
		public function U2InfoSound(parent:U2InfoBaseInfo):void
		{
			super(parent);
			this.type = U2InfoType.sound;
		}
		
		/** 获取这个对象的全部属性信息 **/
		override public function getByte():SByte 
		{
			var b:SByte = SByte.instance();
			b.writeBoolean(useTime);
			b._w_String(path);
			b._w_String(team);
			b.writeByte(loop);
			b.writeInt(start);
			b.writeInt(end);
			b.writeShort(uint(volume * 1000));
			b.writeUnsignedInt(timeLine);
			b.writeBoolean(checkTeam);
			b.writeBoolean(aimSound);
			return b;
		}
		
		/** 读取这个内容 **/
		override public function setByte(b:SByte):void
		{
			useTime = b.readBoolean();
			path = b._r_String();
			team = b._r_String();
			loop = b.readUnsignedByte();
			start = b.readInt();
			end = b.readInt();
			volume = b.readUnsignedShort() / 1000;
			timeLine = b.readUnsignedInt();
			checkTeam = b.readBoolean();
			aimSound = b.readBoolean();
		}
		
		/** 克隆一个对象 **/
		public function clone(parent:U2InfoBaseInfo):U2InfoSound
		{
			var o:U2InfoSound = new U2InfoSound(parent);
			o.useTime = useTime;
			o.path = path;
			o.team = team;
			o.loop = loop;
			o.start = start;
			o.end = end;
			o.volume = volume;
			o.timeLine = timeLine;
			o.checkTeam = checkTeam;
			o.aimSound = aimSound;
			return o;
		}
	}
}