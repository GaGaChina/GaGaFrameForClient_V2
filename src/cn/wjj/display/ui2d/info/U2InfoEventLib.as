package cn.wjj.display.ui2d.info
{
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.speedfact.SByte;
	
	/**
	 * 播放控制数据
	 * 
	 * @version 1.0.0
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 */
	public class U2InfoEventLib extends U2InfoBase 
	{
		/** 事件列表 **/
		public var eventLength:int = 0;
		/** 事件数据 **/
		public var eventList:Vector.<U2InfoBase>;
		
		public function U2InfoEventLib(parent:U2InfoBaseInfo):void
		{
			super(parent);
			this.type = U2InfoType.eventLib;
			eventList = new Vector.<U2InfoBase>();
		}
		
		/** 获取这个对象的全部属性信息 **/
		override public function getByte():SByte 
		{
			var b:SByte = SByte.instance();
			b.writeShort(eventLength);
			for each (var item:U2InfoBase in eventList) 
			{
				b.writeShort(item.type);
				b._w_CByteArray(item.getByte());
			}
			return b;
		}
		
		/** 读取这个内容 **/
		override public function setByte(b:SByte):void
		{
			eventLength = b.readUnsignedShort();
			if (eventList.length != 0) eventList.length = 0;
			if (eventLength)
			{
				var eventType:int;
				var eventSound:U2InfoSound;
				var eventBridge:U2InfoEventBridge;
				var eventPlay:U2InfoPlayEvent;
				var i:int = eventLength;
				while (--i > -1)
				{
					eventType = b.readUnsignedShort();
					switch (eventType) 
					{
						case U2InfoType.sound:
							eventSound = new U2InfoSound(parent);
							b.readUnsignedShort();
							eventSound.setByte(b);
							eventList.push(eventSound);
							break;
						case U2InfoType.eventBridge:
							eventBridge = new U2InfoEventBridge(parent);
							b.readUnsignedShort();
							eventBridge.setByte(b);
							eventList.push(eventBridge);
							break;
						case U2InfoType.playEvent:
							eventPlay = new U2InfoPlayEvent(parent);
							b.readUnsignedShort();
							eventPlay.setByte(b);
							eventList.push(eventPlay);
							break;
					}
				}
			}
		}
		
		/** 克隆一个对象 **/
		public function clone(parent:U2InfoBaseInfo):U2InfoEventLib
		{
			var o:U2InfoEventLib = new U2InfoEventLib(parent);
			o.eventLength = eventLength;
			for each (var item:* in eventList) 
			{
				o.eventList.push(item.clone());
			}
			return o;
		}
	}
}