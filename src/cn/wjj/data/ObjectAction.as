package cn.wjj.data
{
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	
	/**
	 * Object对象操作的类
	 * 
	 * @version 0.6.5
	 * @author GaGa wjjhappy@Gmail.com
	 * @copy 王加静 www.5ga.cn
	 */
	public class ObjectAction
	{
		
		/** 临时内部变量 **/
		private static var a:Array;
		private static var i:int;
		private static var l:uint;
		private static var n:String;
		
		/**
		 * 为obj对象设置propertyName名称的属性,值为vars
		 * @param propertyName
		 * @param obj
		 * @param vars
		 */
		public static function setVar(obj:Object, name:String, vars:*):void
		{
			obj[name] = vars;
		}
		
		/**
		 * 在obj对象中找groupName次序内容并设置它,例:"display.menu.glod",在Object里找display对象,在display里找menu对象,在menu里在找glod对象,然后设置他的值为vars
		 * 数据要自己像里面写数组
		 * 
		 * @param groupName
		 * @param display
		 * @return 				是否设置成功
		 */
		public static function setGroupVar(obj:Object, groupName:String, vars:*, isTrace:Boolean = true):Boolean
		{
			if(!groupName)
			{
				obj = vars;
				return true;
			}
			a = groupName.split(".");
			l = a.length;
			for (i = 0 ; i < l; i++)
			{
				n = a[i];
				if (i < (l - 1))
				{
					if (obj && obj.hasOwnProperty(n))
					{
						obj = obj[n];
					}
					else
					{
						obj[n] = new Object();
						obj = obj[n];
					}
				}
				else
				{
					obj[n] = vars;
				}
			}
			return true;
		}
		
		/**
		 * 查询obj中的名称为name的属性,并输出,如果没有返回null,有返回这个属性值
		 * 
		 * @param name
		 * @param obj
		 * @return 
		 */
		public static function getVar(obj:Object, name:String):*
		{
			if (obj && obj.hasOwnProperty(name))
			{
				return obj[name];
			}
			return null;
		}
		
		/**
		 * 在一个容器里通过名称检索对象,例:"display.menu.glod",在容器里找display对象,在display里找menu对象,在menu里在找glod对象
		 * @param groupName
		 * @param display
		 * @return 
		 */
		public static function getGroupVar(obj:*, groupName:String, isTrace:Boolean = true):*
		{
			if(obj == null || !groupName)
			{
				return obj;
			}
			a = groupName.split(".");
			l = a.length;
			for (i = 0 ; i < l; i++)
			{
				n = a[i];
				if (obj && obj.hasOwnProperty(n))
				{
					obj = obj[n];
				}
				else
				{
					if(isTrace && g.log.isLog)
					{
						g.log.pushLog(ObjectUtil, LogType._ErrorLog, "getGroupVar 没有通过属性检索到对象 : " + groupName);
					}
					return null;
				}
			}
			return obj;
		}
	}
}