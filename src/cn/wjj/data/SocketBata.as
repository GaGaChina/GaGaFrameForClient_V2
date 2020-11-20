package cn.wjj.data
{
	import cn.wjj.gagaframe.client.speedfact.SByte;
	import flash.net.Socket;
	import flash.utils.Endian;
	import cn.wjj.tool.BigInt;
	
	/**
	 * 方便调用的Socket对象
	 * 
	 * @version 1.0.0
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 */
	public class SocketBata extends Socket 
	{
		/**
		 * 创建一个 Socket 对象。 若未指定参数，将创建一个最初处于断开状态的套接字。 若指定了参数，则尝试连接到指定的主机和端口。
		 * @param	host	— 要连接的主机的名称。 若未指定此参数，将创建一个最初处于断开状态的套接字。
		 * @param	port
		 */
		public function SocketBata(host:String = null, port:int = 0):void
		{
			super(host, port);
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
		 * @param	value	要写入的String字符串
		 * @param	sign	长度使用有符号true数表述,还是使用无符号false数表述
		 * @param	len		使用8,16,32位来抽取
		 */
		public function _w_String(value:String = "", sign:Boolean = false, len:int = 16):void
		{
			if (sign == false && len == 16)
			{
				this.writeUTF(value);
				return;
			}
			var b:SByte = SByte.instance();
			b.writeUTFBytes(value);
			if (sign)
			{
				//有符号
				switch (len) 
				{
					case 8:
						this._w_Int8(b.length);
						break;
					case 16:
						this._w_Int16(b.length);
						break;
					case 32:
						this._w_Int32(b.length);
						break;
				}
			}
			else
			{
				//无符号
				switch (len) 
				{
					case 8:
						this._w_Uint8(b.length);
						break;
					case 32:
						this._w_Uint32(b.length);
						break;
				}
			}
			this.writeBytes(b);
			b.dispose();
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
		 * @param	sign	长度使用有符号true数表述,还是使用无符号false数表述
		 * @param	len		使用8,16,32,64位来抽取
		 * @return
		 */
		public function _r_String(sign:Boolean = false, len:int = 16):String
		{
			if (sign == false && len == 16)
			{
				return this.readUTF();
			}
			if (sign)
			{
				//有符号
				switch (len) 
				{
					case 8:
						return this.readUTFBytes(this._r_Int8());
						break;
					case 16:
						return this.readUTFBytes(this._r_Int16());
						break;
					case 32:
						return this.readUTFBytes(this._r_Int32());
						break;
				}
			}
			else
			{
				//无符号
				switch (len) 
				{
					case 8:
						return this.readUTFBytes(this._r_Uint8());
						break;
					case 32:
						return this.readUTFBytes(this._r_Uint32());
						break;
				}
			}
			return "";
		}
	}
}