package cn.wjj.display.ui2d.info
{
	import cn.wjj.gagaframe.client.speedfact.SByte;
	
	/**
	 * 鼠标事件数据
	 * 
	 * 控制某一层的鼠标事件
	 * 在播放的时候,会向上传递到总控制器中U2Sprite,在U2Sprite中进行监听
	 * 传递中需要把显示对象一起传递上来,当显示对象发生变化的时候,删除等需要重新传递?
	 * 
	 * 
	 * @version 1.0.0
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 */
	public class U2InfoMouseEvent extends U2InfoBase 
	{
		/** 是否控制单独的图层,如果空就不控制 **/
		public var mouseType:String = "click";
		/** 事件列表 **/
		public var frameLength:int = 0;
		/** 作用在那几帧,从1开始 **/
		public var frameLib:Vector.<uint>;
		/** 是否使用透明度检测 **/
		public var alpha:Boolean = true;
		/** 事件列表 **/
		public var eventLib:U2InfoEventLib;
		
		public function U2InfoMouseEvent(parent:U2InfoBaseInfo):void
		{
			super(parent);
			this.type = U2InfoType.mouseEvent;
			frameLib = new Vector.<uint>();
			eventLib = new U2InfoEventLib(parent);
		}
		
		/** 获取这个对象的全部属性信息 **/
		override public function getByte():SByte 
		{
			var b:SByte = SByte.instance();
			b._w_String(mouseType);
			b._w_Uint16(frameLength);
			for each (var i:int in frameLib) 
			{
				b._w_Uint16(i);
			}
			b.writeBoolean(alpha);
			b._w_CByteArray(eventLib.getByte());
			return b;
		}
		
		/** 读取这个内容 **/
		override public function setByte(b:SByte):void
		{
			mouseType = b._r_String();
			frameLength = b._r_Uint16();
			var i:int = frameLength;
			frameLib.length = 0;
			while (--i > -1)
			{
				frameLib.push(b._r_Uint16());
			}
			alpha = b.readBoolean();
			b.readUnsignedShort();
			eventLib.setByte(b);
		}
		
		/** 克隆一个对象 **/
		public function clone(parent:U2InfoBaseInfo):U2InfoMouseEvent
		{
			var o:U2InfoMouseEvent = new U2InfoMouseEvent(parent);
			o.mouseType = mouseType;
			o.frameLength = frameLength;
			for each (var i:uint in frameLib) 
			{
				o.frameLib.push(i);
			}
			o.alpha = alpha;
			o.eventLib = eventLib.clone(parent);
			return o;
		}
	}
}