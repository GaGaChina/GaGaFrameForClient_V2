package cn.wjj.tool
{

	/**
	 * 创建类对象的复合参数
	 * 
	 * @version 0.0.1
	 * @author GaGa wjjhappy@Gmail.com
	 * @copy 王加静 www.5ga.cn
	 * @date 2013-05-24
	 */
	public class ClassParameter 
	{
		/** 参数列表 **/
		public var lib:Array;
		/** 临时变量数组长度 **/
		private var l:uint;
		/** 参数类对象,如果没有,就在其他地方的应用所引用 **/
		public var classObj:Class;
		/** 独立的摧毁方法名称 **/
		public var destroyName:String;
		
		public function ClassParameter() 
		{
			lib = new Array();
		}
		
		/**
		 * 添加调用的方法和参数
		 * @param	method
		 * @param	...args
		 */
		public function push(method:String, ...args):void
		{
			var info:Object = new Object();
			info.m = method;
			info.a = args;
			lib.push(info);
		}
		
		/**
		 * 找到一个方法的设置参数
		 * @param	method
		 * @return	要设置的内容的Array参数
		 */
		public function find(method:String):Array
		{
			l = lib.length;
			while (--l > -1)
			{
				if (lib[l].m == method)
				{
					return lib[l].a;
				}
			}
			return null;
		}
		
		/**
		 * 改变赋值里全部为method值为传入值
		 * @param method
		 * @param args
		 */
		public function changeVars(method:String, ...args):void
		{
			l = lib.length;
			while (--l > -1)
			{
				if (lib[l].m == method)
				{
					lib[l].a = args;
				}
			}
		}
		
		/**
		 * 执行一个对象的赋值
		 * @param	o
		 * @param	p
		 */
		public static function run(o:Object, p:ClassParameter):void
		{
			if (o && p)
			{
				var l:uint = p.lib.length;
				var n:String;
				var i:int = -1;
				var a:Array;
				var f:*;
				while (++i < l)
				{
					n = p.lib[i].m;
					if (o.hasOwnProperty(n))
					{
						a = p.lib[i].a;
						f = o[n];
						if (f is Function)
						{
							if (a.length)
							{
								f.apply(null, a);
							}
							else
							{
								f();
							}
						}
						else
						{
							if (a.length)
							{
								o[n] = a[0];
							}
						}
					}
				}
			}
		}
	}
}