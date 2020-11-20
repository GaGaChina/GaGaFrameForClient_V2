package cn.wjj.data
{
	import cn.wjj.gagaframe.client.speedfact.SByte;
	
	public class ObjectUtil
	{
		/**
		 * 测试是否为原始类型 , Booelan, Number, String
		 * @param	obj
		 * @return
		 */
		static public function isPrimitiveType(obj:*):Boolean
		{
			return obj is Boolean || obj is Number || obj is String;
		}
		
		/**
		 * 判断两个对象是否相等<br/>
		 * 此方法不考虑引用地址是否相同(包括属性的引用地址),只考虑值是否相等<br/>
		 * 此方法不考虑类型信息(自定义类型和Object将区分,自定义类型与自定义类型不区分), 例如int, Number只要值相等,那么就相等.<br/>
		 * 如果registerClassAlias注册类别名,将区别类型信息,但int Number依然不区分类型信息.<br/>
		 * 建议判断的类型信息都相同<br/>
		 * @param	a
		 * @param	b
		 * @return		是否相等
		 */
		static public function equals(a:*, b:*):Boolean
		{
			var ba:SByte = SByte.instance();
			ba.writeObject(a);
			var bb:SByte = SByte.instance();
			bb.writeObject(b);
			
			var len:uint = ba.length;
			if (bb.length != len)
			{
				ba.dispose();
				bb.dispose();
				return false;
			}
			ba.position = 0;
			bb.position = 0;
			for(var i:int = 0; i < len; i++)
			{
				if (ba.readByte() != bb.readByte())
				{
					ba.dispose();
					bb.dispose();
					return false;
				}
			}
			ba.dispose();
			bb.dispose();
			return true;
		}
	}
}