package cn.wjj.display.ui2d.info
{
	import cn.wjj.gagaframe.client.speedfact.SByte;
	
	/**
	 * 事件桥自动执行数据
	 * 
	 * @version 2.0.0
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 */
	public class U2InfoEventBridge extends U2InfoBase 
	{
		/** 是否使用时间 **/
		public var useTime:Boolean = true;
		/** 父级中的时间轴的时间点,毫秒 **/
		public var timeLine:uint = 0;
		/** 事件桥名称 **/
		public var eventName:String = "";
		/** 长度 **/
		public var length:int = 0;
		/** 参数注释 **/
		public var listNote:Vector.<String> = new Vector.<String>();
		/** 参数名称 **/
		public var listType:Vector.<String> = new Vector.<String>();
		/** 参数名称 **/
		public var listValue:Array = new Array();
		
		public function U2InfoEventBridge(parent:U2InfoBaseInfo):void
		{
			super(parent);
			this.type = U2InfoType.eventBridge;
		}
		
		/** 获取这个对象的全部属性信息 **/
		override public function getByte():SByte 
		{
			var b:SByte = SByte.instance();
			b.writeBoolean(useTime);
			b.writeUnsignedInt(timeLine);
			b._w_String(eventName);
			b.writeShort(length);
			var valueType:String;
			for (var i:int = 0; i < length; i++)
			{
				b._w_String(listNote[i]);
				valueType = listType[i];
				b._w_String(valueType);
				switch (valueType) 
				{
					case "Null":
						break;
					case "Boolean":
						b.writeBoolean(listValue[i]);
						break;
					case "Number":
						b.writeFloat(listValue[i]);
						break;
					case "String":
						b._w_String(listValue[i]);
						break;
					case "Int32":
						b.writeInt(listValue[i]);
						break;
					case "Int16":
						b.writeShort(listValue[i]);
						break;
					case "Int8":
						b.writeByte(listValue[i]);
						break;
					case "Uint32":
						b.writeUnsignedInt(listValue[i]);
						break;
					case "Uint16":
						b.writeShort(listValue[i]);
						break;
					case "Uint8":
						b.writeByte(listValue[i]);
						break;
				}
			}
			return b;
		}
		
		/** 读取这个内容 **/
		override public function setByte(b:SByte):void
		{
			useTime = b.readBoolean();
			timeLine = b.readUnsignedInt();
			eventName = b._r_String();
			length = b.readUnsignedShort();
			if (listNote.length != 0) listNote.length = 0;
			if (listType.length != 0) listType.length = 0;
			if (listValue.length != 0) listValue.length = 0;
			var i:int = length;
			var valueType:String;
			while (--i > -1)
			{
				listNote.push(b._r_String());
				valueType = b._r_String();
				listType.push(valueType);
				switch (valueType) 
				{
					case "Null":
						listValue.push(null);
						break;
					case "Boolean":
						listValue.push(b.readBoolean());
						break;
					case "Number":
						listValue.push(b.readFloat());
						break;
					case "String":
						listValue.push(b._r_String());
						break;
					case "Int32":
						listValue.push(b.readInt());
						break;
					case "Int16":
						listValue.push(b.readShort());
						break;
					case "Int8":
						listValue.push(b.readByte());
						break;
					case "Uint32":
						listValue.push(b.readUnsignedInt());
						break;
					case "Uint16":
						listValue.push(b.readUnsignedShort());
						break;
					case "Uint8":
						listValue.push(b.readUnsignedByte());
						break;
					default:
						listValue.push(null);
				}
			}
		}
		
		/** 克隆一个对象 **/
		public function clone(parent:U2InfoBaseInfo):U2InfoEventBridge
		{
			var o:U2InfoEventBridge = new U2InfoEventBridge(parent);
			o.useTime = useTime;
			o.timeLine = timeLine;
			o.eventName = eventName;
			o.length = length;
			for each (var str:String in listNote) 
			{
				o.listNote.push(str);
			}
			for each (str in listType) 
			{
				o.listType.push(str);
			}
			for each (var value:* in listValue) 
			{
				o.listValue.push(value);
			}
			return o;
		}
	}
}