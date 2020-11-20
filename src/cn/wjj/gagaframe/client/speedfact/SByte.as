package cn.wjj.gagaframe.client.speedfact 
{
	import cn.wjj.tool.BigInt;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	/**
	 * [加入对象池]特殊二进制
	 * @author GaGa
	 */
	public class SByte extends ByteArray
	{
		/** 对象池 **/
		private static var __f:SpeedLib = new SpeedLib(3000);
		/** 对象池强引用的最大数量 **/
		static public function get __m():uint { return __f.length; }
		/** 对象池强引用的最大数量 **/
		static public function set __m(value:uint):void { __f.length = value; }
		
		public function SByte() 
		{
			super();
			if (endian != Endian.BIG_ENDIAN) endian = Endian.BIG_ENDIAN;
		}
		
		/**
		 * 初始化 Bitmap 对象以引用指定的 BitmapData 对象。
		 * @param	bitmapData		被引用的 BitmapData 对象。
		 * @param	pixelSnapping	Bitmap 对象是否贴紧至最近的像素。
		 * @param	smoothing		在缩放时是否对位图进行平滑处理。例如，下例显示使用系数 3 缩放的同一位图，smoothing 设置为 false（左侧）和 true（右侧）：
		 */
		public static function instance():SByte
		{
			var o:SByte = __f.instance() as SByte;
			if (o) return o;
			return new SByte();
		}
		
		/** 移除,清理,并回收 **/
		public function dispose():void 
		{
			clear();
			if (endian != Endian.BIG_ENDIAN) endian = Endian.BIG_ENDIAN;
			SByte.__f.recover(this);
		}
		
		/** 写入8位带符号整数 (-128 到 127) **/
		public function _w_Int8(value:int):void
		{
			this.writeByte(value);
		}
		/** 写入16位带符号整数 (-32768 到 32767) **/
		public function _w_Int16(value:int):void
		{
			this.writeShort(value);
		}
		/** 写入32位带符号整数 (-2147483648 到 2147483647) **/
		public function _w_Int32(value:int):void
		{
			this.writeInt(value);
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
			if (this.endian == Endian.BIG_ENDIAN)
			{
				this.writeInt(left);
				this.writeUnsignedInt(right);
			}
			else
			{
				this.writeUnsignedInt(right);
				this.writeInt(left);
			}
		}
		/** 写入8位无符号整数(等同 _w_Int8 ) (0 到 255) **/
		public function _w_Uint8(value:uint):void
		{
			this.writeByte(value);
		}
		/** 写入16位无符号整数(等同 _w_Int16 ) (0 到 65535) **/
		public function _w_Uint16(value:uint):void
		{
			this.writeShort(value);
		}
		/** 写入32位无符号整数 (0 到 4294967295) **/
		public function _w_Uint32(value:uint):void
		{
			this.writeUnsignedInt(value);
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
			if (this.endian == Endian.BIG_ENDIAN)
			{
				this.writeUnsignedInt(left);
				this.writeUnsignedInt(right);
			}
			else
			{
				this.writeUnsignedInt(right);
				this.writeUnsignedInt(left);
			}
		}
		/** 写入 IEEE 754 单精度（32 位）浮点数 **/
		public function _w_Number32(value:Number):void
		{
			this.writeFloat(value);
		}
		/** 写入 IEEE 754 双精度（64 位）浮点数 **/
		public function _w_Number64(value:Number):void
		{
			this.writeDouble(value);
		}
		/**
		 * 写入字符串,默认 : Uint16 + String 使用系统自带writeUTF处理
		 * 全部使用无符号记录长度
		 * @param	value	要写入的String字符串
		 * @param	len		使用8,16,32位来抽取
		 */
		public function _w_String(value:String = "", len:int = 16):void
		{
			if (len == 16)
			{
				this.writeUTF(value);
			}
			else
			{
				var o:SByte = SByte.instance();
				o.writeUTFBytes(value);
				switch (len) 
				{
					case 8:
						this.writeByte(o.length);
						break;
					case 32:
						this.writeUnsignedInt(o.length);
						break;
				}
				this.writeBytes(o);
				o.dispose();
			}
		}
		/** 以 AMF 序列化格式将一个对象写入套接字 **/
		public function _w_CByteArray(value:SByte, len:int = 16):void
		{
			switch (len) 
			{
				case 8:
					this.writeByte(value.length);
					break;
				case 16:
					this.writeShort(value.length);
					break;
				case 32:
					this.writeUnsignedInt(value.length);
					break;
			}
			this.writeBytes(value);
		}
		/** 读取带符号8位整数 (-128 到 127) **/
		public function _r_Int8():int
		{
			return this.readByte();
		}
		/** 读取带符号16位整数 (-32768 到 32767) **/
		public function _r_Int16():int
		{
			return this.readShort();
		}
		/** 读取带符号32位整数 (-2147483648 到 2147483647) **/
		public function _r_Int32():int
		{
			return this.readInt();
		}
		/** 读取64位无符号整数 C++中的int64 (-9223372036854775808 到 9223372036854775807) **/
		public function _r_Int64():String
		{
			var left:int, right:uint;
			if (this.endian == Endian.BIG_ENDIAN)
			{
				left = this.readInt();
				right = this.readUnsignedInt();
			}
			else
			{
				right = this.readUnsignedInt();
				left = this.readInt();
			}
			var bigLeft:BigInt = BigInt.multiply(left, 4294967296);
			var bigRight:BigInt = new BigInt(right);
			bigRight = BigInt.plus(bigLeft, bigRight);
			return bigRight.toString();
		}
		/** 读取无符号8位整数 (0 到 255) **/
		public function _r_Uint8():uint
		{
			return this.readUnsignedByte();
		}
		/** 读取无符号16位整数 (0 到 65535) **/
		public function _r_Uint16():uint
		{
			return this.readUnsignedShort();
		}
		/** 读取无符号32位整数 (0 到 4294967295) **/
		public function _r_Uint32():uint
		{
			return this.readUnsignedInt();
		}
		/** 读取64位无符号整数 C++中的uint64 (0 到 18446744073709551615) **/
		public function _r_Uint64():String
		{
			var left:uint, right:uint;
			if (this.endian == Endian.BIG_ENDIAN)
			{
				left = this.readUnsignedInt();
				right = this.readUnsignedInt();
			}
			else
			{
				right = this.readUnsignedInt();
				left = this.readUnsignedInt();
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
			return this.readFloat();
		}
		/** 读取 IEEE 754 双精度（64 位）浮点数 **/
		public function _r_Number64():Number
		{
			return this.readDouble();
		}
		
		/**
		 * 读取字符串,默认 : Uint16 + String 使用系统自带readUTF处理
		 * 全部使用无符号记录长度
		 * @param	len		使用8,16,32,64位来抽取
		 * @return
		 */
		public function _r_String(sign:Boolean = false, len:int = 16):String
		{
			if (len == 16)
			{
				return this.readUTF();
			}
			//无符号
			switch (len) 
			{
				case 8:
					return this.readUTFBytes(this.readUnsignedByte());
					break;
				case 32:
					return this.readUTFBytes(this.readUnsignedInt());
					break;
			}
			return "";
		}
		/** 读取二进制内容 **/
		public function _r_CByteArray(len:int = 16):SByte
		{
			var o:SByte = SByte.instance();
			if (o.endian != this.endian) o.endian = this.endian;
			switch (len) 
			{
				case 8:
					this.readBytes(o, 0, this.readUnsignedByte());
					break;
				case 16:
					this.readBytes(o, 0, this.readUnsignedShort());
					break;
				case 32:
					this.readBytes(o, 0, this.readUnsignedInt());;
					break;
			}
			return o;
		}
	}
}