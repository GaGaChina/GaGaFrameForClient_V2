package cn.wjj.data
{
	import cn.wjj.gagaframe.client.speedfact.SByte;
	import flash.net.getClassByAlias;
	import flash.net.registerClassAlias;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	
	public class ObjectClone
	{
		/**
		 * 对象深度复制 : 将实例及子实例的所有成员(属性和方法, 静态的除外)都复制一遍, (引用要重新分配空间!)
		 *
		 * 局限性 :
		 * 1. 不能对显示对象进行复制
		 * 2. obj 必须有默认构造函数(没有参数或有默认值)
		 * 3. obj 里有obj类型 之外 的非内置数据类型时, 返回类型将不确定
		 * @param	o		深复制的对象
		 * @return
		 */
		public static function deepClone(o:*):*
		{
			var aliasClass:Class;
			var classDefinition:Class = Object(o).constructor as Class;
			var className:String = getQualifiedClassName(o);
			// 获取已注册 obj的类名的类型
			try
			{
				aliasClass = getClassByAlias(className);
			}
			catch (e:Error)
			{
				
			}
			// 没有注册 AliasName
			if (!aliasClass)
			{
				registerClassAlias(className, classDefinition);
			}
			else if (aliasClass != classDefinition)
			{
				//已经注册了 AliasName ,且不是它的全类名,要重新注册个
				registerClassAlias(className +":/:" + className, classDefinition);
			}
			//else
			// 注册的AliasName 为 全类名
			var byte:SByte = SByte.instance();
			byte.writeObject(o);
			byte.position = 0;
			o = byte.readObject();
			byte.dispose();
			return o;
		}
		
		/**
		 * 浅复制一个对象<br/>
		 * 对象浅度复制 : 将实例及子实例的所有成员(属性和方法, 静态的除外)都复制一遍, (引用不必重新分配空间!)
		 * 
		 * @param	obj
		 * @return
		 */
		public static function clone(obj:*):*
		{
			if (obj == null || obj is Class || obj is Function || ObjectUtil.isPrimitiveType(obj))
			{
				return obj;
			}
			var xml:XML = describeType(obj);
			var o:* = new (Object(obj).constructor as Class);
			// clone var variables
			for each(var key:XML in xml.variable)
			{
				o[key.@name] = obj[key.@name];
			}
			// clone getter setter, if the accessor is "readwrite" then set this accessor.
			for each(key in xml.accessor)
			{
				if ("readwrite" == key.@access) o[key.@name] = obj[key.@name];
			}
			// clone dynamic variables
			for (var k:String in obj)
			{
				o[k] = obj[k];
			}
			return o;
		}
		
		/**
		 * 将copyIn里的所有数据清除,然后将copyOut的键和值复制进copyIn内
		 * @param	copyIn
		 * @param	copyOut
		 */
		public static function clearAddCopy(copyIn:Object, copyOut:Object):void
		{
			var k:String;
			for (k in copyIn)
			{
				delete copyIn[k];
			}
			for (k in copyOut)
			{
				copyIn[k] = copyOut[k];
			}
		}
	}
}