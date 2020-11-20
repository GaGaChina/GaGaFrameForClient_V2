package cn.wjj.gagaframe.client.worker 
{
	import cn.wjj.gagaframe.client.speedfact.SByte;
	import cn.wjj.tool.BigInt;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	/**
	 * 为多线程提供的特殊数组
	 * @author GaGa
	 */
	public class WorkerByteArray 
	{
		/** 共享二进制对象 **/
		private var b:ByteArray;
		
		public function WorkerByteArray(byte:ByteArray)
		{
			b = byte;
		}
		
		/** ByteArray 对象的长度（以字节为单位） **/
		public function get length():uint
		{
			return b.length;
		}
		/** ByteArray 对象的长度（以字节为单位） **/
		public function set length(value:uint):void
		{
			b.length = value;
		}
		/** 将文件指针的当前位置（以字节为单位）移动或返回到 ByteArray 对象中 **/
		public function get position():uint
		{
			return b.position;
		}
		/** 将文件指针的当前位置（以字节为单位）移动或返回到 ByteArray 对象中 **/
		public function set position(offset:uint):void
		{
			b.position = offset;
		}
		/** 更改或读取数据的字节顺序；Endian.BIG_ENDIAN 或 Endian.LITTLE_ENDIAN **/
		public function get endian():String
		{
			return b.endian;
		}
		/** 更改或读取数据的字节顺序；Endian.BIG_ENDIAN 或 Endian.LITTLE_ENDIAN **/
		public function set endian(type:String):void
		{
			b.endian = type;
		}
		/**
		 * 可从字节数组的当前位置到数组末尾读取的数据的字节数。
		 * 每次访问 ByteArray 对象时，将 bytesAvailable 属性与读取方法结合使用，以确保读取有效的数据。
		 */
		public function get bytesAvailable():uint
		{
			return b.bytesAvailable;
		}
		
		/** 清除字节数组的内容，并将 length 和 position 属性重置为 0。明确调用此方法将释放 ByteArray 实例占用的内存 **/
		public function clear():void
		{
			b.clear();
		}
		
		/** 从字节流中读取布尔值。读取单个字节，如果字节非零，则返回 true，否则返回 false, 如果字节不为零，则返回 true，否则返回 false **/
		public function readBoolean():Boolean
		{
			return b.readBoolean();
		}
		/** 写入布尔值。根据 value 参数写入单个字节。如果为 true，则写入 1，如果为 false，则写入 0 **/
		public function writeBoolean(value:Boolean):void
		{
			b.writeBoolean(value);
		}
		
		
		/**
		 * 从字节流中读取 length 参数指定的数据字节数。从 offset 指定的位置开始，将字节读入 bytes 参数指定的 ByteArray 对象中，并将字节写入目标 ByteArray 中。
		 * @param	bytes	要将数据读入的 ByteArray 对象。
		 * @param	offset	bytes 中的偏移（位置），应从该位置写入读取的数据。
		 * @param	length	要读取的字节数。默认值 0 导致读取所有可用的数据。
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 * @throws	EOFError 没有足够的数据可供读取。
		 * @throws	RangeError 所提供的位移和长度的组合值大于单元的最大值。
		 */
		public function readBytes (bytes:ByteArray, offset:uint = 0, length:uint = 0):void
		{
			b.readBytes(bytes, offset, length);
		}
		/**
		 * 将指定字节数组 bytes（起始偏移量为 offset，从零开始的索引）中包含 length 个字节的字节序列写入字节流。
		 * 
		 *   如果省略 length 参数，则使用默认长度 0；该方法将从 offset 开始写入整个缓冲区。如果还省略了 offset 参数，则写入整个缓冲区。 如果 offset 或 length 超出范围，它们将被锁定到 bytes 数组的开头和结尾。
		 * @param	bytes	ByteArray 对象。
		 * @param	offset	从 0 开始的索引，表示在数组中开始写入的位置。
		 * @param	length	一个无符号整数，表示在缓冲区中的写入范围。
		 * @langversion	3.0
		 * @playerversion	Flash 9
		 * @playerversion	Lite 4
		 */
		public function writeBytes(bytes:ByteArray, offset:uint = 0, length:uint = 0):void
		{
			b.writeBytes(bytes, offset, length);
		}
		
		/** 写入8位带符号整数 (-128 到 127) **/
		public function _w_Int8(value:int):void
		{
			b.writeByte(value);
		}
		/** 写入16位带符号整数 (-32768 到 32767) **/
		public function _w_Int16(value:int):void
		{
			b.writeShort(value);
		}
		/** 写入32位带符号整数 (-2147483648 到 2147483647) **/
		public function _w_Int32(value:int):void
		{
			b.writeInt(value);
		}
		/** 写入64位无符号整数 C++中的int64 (-9223372036854775808 到 9223372036854775807) **/
		public function _w_Int64(value:String):void
		{
			var left:int, right:uint;
			var bigRight:BigInt = new BigInt(value);
			//看是不是前面有数字
			if (bigRight.sign && BigInt.compare(4294967296, bigRight) == 1)
			{
				//没有左侧的数字
				left = 0;
				right = uint(bigRight.toNumber());
			}
			else
			{
				var leftTemp:Number = Math.floor(bigRight.toNumber() / 4294967296);
				if (leftTemp > 2147483647)
				{
					leftTemp = 2147483647;
				}
				if (leftTemp < -2147483648)
				{
					leftTemp = -2147483648;
				}
				left = leftTemp;
				var bigLeft:BigInt = new BigInt(left);
				//bigRight - bigLeft * maxRight
				bigLeft = BigInt.multiply(bigLeft, 4294967296);
				bigRight = BigInt.minus(bigRight, bigLeft);
				right = uint(bigRight.toNumber());
			}
			if (b.endian == Endian.BIG_ENDIAN)
			{
				b.writeInt(left);
				b.writeUnsignedInt(right);
			}
			else
			{
				b.writeUnsignedInt(right);
				b.writeInt(left);
			}
		}
		/** 写入8位无符号整数(等同 _w_Int8 ) (0 到 255) **/
		public function _w_Uint8(value:uint):void
		{
			b.writeByte(value);
		}
		/** 写入16位无符号整数(等同 _w_Int16 ) (0 到 65535) **/
		public function _w_Uint16(value:uint):void
		{
			b.writeShort(value);
		}
		/** 写入32位无符号整数 (0 到 4294967295) **/
		public function _w_Uint32(value:uint):void
		{
			b.writeUnsignedInt(value);
		}
		/** 写入64位无符号整数 C++中的uint64 (0 到 18446744073709551615) **/
		public function _w_Uint64(value:String):void
		{
			var left:uint, right:uint;
			var bigRight:BigInt = new BigInt(value);
			//看是不是前面有数字
			if (BigInt.compare(4294967296, bigRight) == 1)
			{
				//没有左侧的数字
				left = 0;
				right = uint(bigRight.toNumber());
			}
			else
			{
				var leftTemp:Number = Math.floor(bigRight.toNumber() / 4294967296);
				if (leftTemp > 4294967295)
				{
					leftTemp = 4294967295;
				}
				left = leftTemp;
				var bigLeft:BigInt = new BigInt(left);
				//bigRight - bigLeft * maxRight
				bigLeft = BigInt.multiply(bigLeft, 4294967296);
				bigRight = BigInt.minus(bigRight, bigLeft);
				right = uint(bigRight.toNumber());
			}
			if (b.endian == Endian.BIG_ENDIAN)
			{
				b.writeUnsignedInt(left);
				b.writeUnsignedInt(right);
			}
			else
			{
				b.writeUnsignedInt(right);
				b.writeUnsignedInt(left);
			}
		}
		/** 写入 IEEE 754 单精度（32 位）浮点数 **/
		public function _w_Number32(value:Number):void
		{
			b.writeFloat(value);
		}
		/** 写入 IEEE 754 双精度（64 位）浮点数 **/
		public function _w_Number64(value:Number):void
		{
			b.writeDouble(value);
		}
		/**
		 * 写入字符串,默认 : Uint16 + String 使用系统自带writeUTF处理
		 * @param	value	要写入的String字符串
		 * @param	sign	长度使用有符号true数表述,还是使用无符号false数表述
		 * @param	len		使用8,16,32位来抽取
		 */
		public function _w_String(value:String = "", sign:Boolean = false, len:int = 16):void
		{
			if (sign == false && len == 16)
			{
				b.writeUTF(value);
				return;
			}
			var temp:SByte = SByte.instance();
			temp.writeUTFBytes(value);
			if (sign)
			{
				//有符号
				switch (len) 
				{
					case 8:
						_w_Int8(temp.length);
						break;
					case 16:
						_w_Int16(temp.length);
						break;
					case 32:
						_w_Int32(temp.length);
						break;
				}
			}
			else
			{
				//无符号
				switch (len) 
				{
					case 8:
						_w_Uint8(temp.length);
						break;
					case 16:
						_w_Uint16(temp.length);
						break;
					case 32:
						_w_Uint32(temp.length);
						break;
				}
			}
			b.writeBytes(temp);
			temp.dispose();
		}
		/** 以 AMF 序列化格式将一个对象写入套接字 **/
		public function _w_Object(value:Object):void
		{
			b.writeObject(value);
		}
		/** 以 AMF 序列化格式将一个对象写入套接字 **/
		public function _w_CByteArray(value:ByteArray, len:int = 16):void
		{
			switch (len) 
			{
				case 8:
					_w_Uint8(value.length);
					break;
				case 16:
					_w_Uint16(value.length);
					break;
				case 32:
					_w_Uint32(value.length);
					break;
			}
			b.writeBytes(value);
		}
		/** 读取带符号8位整数 (-128 到 127) **/
		public function _r_Int8():int
		{
			return b.readByte();
		}
		/** 读取带符号16位整数 (-32768 到 32767) **/
		public function _r_Int16():int
		{
			return b.readShort();
		}
		/** 读取带符号32位整数 (-2147483648 到 2147483647) **/
		public function _r_Int32():int
		{
			return b.readInt();
		}
		/** 读取64位无符号整数 C++中的int64 (-9223372036854775808 到 9223372036854775807) **/
		public function _r_Int64():String
		{
			var left:int, right:uint;
			if (b.endian == Endian.BIG_ENDIAN)
			{
				left = b.readInt();
				right = b.readUnsignedInt();
			}
			else
			{
				right = b.readUnsignedInt();
				left = b.readInt();
			}
			var bigLeft:BigInt = BigInt.multiply(left, 4294967296);
			var bigRight:BigInt = new BigInt(right);
			bigRight = BigInt.plus(bigLeft, bigRight);
			return bigRight.toString();
		}
		/** 读取无符号8位整数 (0 到 255) **/
		public function _r_Uint8():uint
		{
			return b.readUnsignedByte();
		}
		/** 读取无符号16位整数 (0 到 65535) **/
		public function _r_Uint16():uint
		{
			return b.readUnsignedShort();
		}
		/** 读取无符号32位整数 (0 到 4294967295) **/
		public function _r_Uint32():uint
		{
			return b.readUnsignedInt();
		}
		/** 读取64位无符号整数 C++中的uint64 (0 到 18446744073709551615) **/
		public function _r_Uint64():String
		{
			var left:uint, right:uint;
			if (b.endian == Endian.BIG_ENDIAN)
			{
				left = b.readUnsignedInt();
				right = b.readUnsignedInt();
			}
			else
			{
				right = b.readUnsignedInt();
				left = b.readUnsignedInt();
			}
			var bigLeft:BigInt = new BigInt(left);
			var bigRight:BigInt = new BigInt(right);
			if (left > 0)
			{
				bigLeft = BigInt.multiply(bigLeft, 4294967296);
			}
			bigRight = BigInt.plus(bigLeft, bigRight);
			return bigRight.toString();
		}
		/** 读取 IEEE 754 单精度（32 位）浮点数 **/
		public function _r_Number32():Number
		{
			return b.readFloat();
		}
		/** 读取 IEEE 754 双精度（64 位）浮点数 **/
		public function _r_Number64():Number
		{
			return b.readDouble();
		}
		
		/**
		 * 读取字符串,默认 : Uint16 + String 使用系统自带readUTF处理
		 * @param	sign	长度使用有符号true数表述,还是使用无符号false数表述
		 * @param	len		使用8,16,32,64位来抽取
		 * @return
		 */
		public function _r_String(sign:Boolean = false, len:int = 16):String
		{
			if (sign == false && len == 16)
			{
				return b.readUTF();
			}
			if (sign)
			{
				//有符号
				switch (len) 
				{
					case 8:
						return b.readUTFBytes(_r_Int8());
						break;
					case 16:
						return b.readUTFBytes(_r_Int16());
						break;
					case 32:
						return b.readUTFBytes(_r_Int32());
						break;
				}
			}
			else
			{
				//无符号
				switch (len) 
				{
					case 8:
						return b.readUTFBytes(_r_Uint8());
						break;
					case 16:
						return b.readUTFBytes(_r_Uint16());
						break;
					case 32:
						return b.readUTFBytes(_r_Uint32());
						break;
				}
			}
			return "";
		}
		/** 从以 AMF 序列化格式编码的套接字读取一个对象。 **/
		public function _r_Object():Object
		{
			return b.readObject();
		}
		/** 读取二进制内容 **/
		public function _r_CByteArray(len:int = 16):ByteArray
		{
			var o:ByteArray = new ByteArray();
			o.endian = b.endian;
			switch (len) 
			{
				case 8:
					b.readBytes(o, 0, _r_Uint8());
					break;
				case 16:
					b.readBytes(o, 0, _r_Uint16());
					break;
				case 32:
					b.readBytes(o, 0, _r_Uint32());;
					break;
			}
			return o;
		}
	}
}