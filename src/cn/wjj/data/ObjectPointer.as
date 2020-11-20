package cn.wjj.data
{
	import cn.wjj.g;
	import flash.utils.Dictionary;

	/**
	 * 建立指针对象
	 * 
	 * @version 0.0.1
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 * @date 2013-05-22
	 */
	public class ObjectPointer
	{
		/** 所有的指针对象列表 **/
		private static var lib:Dictionary = new Dictionary(true);
		/** 对象临时变量 **/
		private static var temp:Object;
		/** 临时操作的值 **/
		private static var vars:*;
		/** 操作的对象库 **/
		private static var oper:Dictionary;
		/** 现在操作的队列 **/
		private static var openVector:Vector.<Object>;
		
		public function ObjectPointer(){}
		
		/**
		 * 是否包含某指针
		 * @param o
		 * @return 
		 */
		public static function hasArray(o:Array):Boolean
		{
			if (lib[o] != null) return true;
			return false;
		}
		
		/**
		 * 是否包含某指针
		 * @param o
		 * @return 
		 */
		public static function hasArrayKey(o:Array, key:String):Boolean
		{
			if(lib[o] != null && lib[o][key] != null)
			{
				return true;
			}
			return false;
		}
		
		/**
		 * 创建一个指针,或者是重新建立
		 * @param o		引用的对象Array对象
		 * @param key	Array中Object的关键key
		 * @param df	如果没有这个key使用的默认值
		 */
		public static function createArray(o:Array, key:String, df:* = null):void
		{
			if (lib[o] == null)
			{
				lib[o] = g.speedFact.n_object();
			}
			else
			{
				clearArrayKey(o, key);
			}
			oper = lib[o][key];
			if (oper == null)
			{
				oper = g.speedFact.n_dict();
				lib[o][key] = oper;
			}
			for each (temp in o) 
			{
				if(temp.hasOwnProperty(key))
				{
					vars = temp[key];
				}
				else if(df != null)
				{
					vars = df;
				}
				else
				{
					continue;
				}
				if(oper[vars] is Vector.<Object>)
				{
					/*
					openVector = oper[vars] as Vector.<Object>;
					openVector.push(temp);
					*/
					oper[vars].push(temp);
				}
				else if (oper[vars] == null)
				{
					oper[vars] = temp;
				}
				else
				{
					openVector = new Vector.<Object>();
					openVector.push(oper[vars]);
					openVector.push(temp);
					oper[vars] = openVector;
				}
			}
		}
		
		/**
		 * 创建一个指针,或者是重新建立
		 * @param o		引用的对象Array对象
		 * @param key	Array中Object的关键key
		 * @param df	如果没有这个key使用的默认值
		 */
		public static function createArrayKeyList(o:Array, key:Array, df:Array = null):void
		{
			var l:int = key.length;
			if (l == 1)
			{
				if (df && df.length && df[0] != null)
				{
					createArray(o, key[0], df[0]);
				}
				else
				{
					createArray(o, key[0]);
				}
			}
			else if (l > 1)
			{
				var r:int = -1;
				var ks:String;
				var dfv:*;
				if (lib[o] == null) lib[o] = g.speedFact.n_object();
				for (r = 0; r < l; r++) 
				{
					ks = key[r];
					oper = lib[o][ks];
					if (lib[o][ks] == null)
					{
						lib[o][ks] = g.speedFact.n_dict();
					}
					else
					{
						clearArrayKey(o, ks);
					}
				}
				for each (temp in o) 
				{
					for (r = 0; r < l; r++) 
					{
						ks = key[r];
						if(temp.hasOwnProperty(ks))
						{
							vars = temp[ks];
						}
						else if(df && df.length > r && df[r] != null)
						{
							vars = df[r];
						}
						else
						{
							continue;
						}
						oper = lib[o][ks];
						if(oper[vars] is Vector.<Object>)
						{
							/*
							openVector = oper[vars] as Vector.<Object>;
							openVector.push(temp);
							*/
							oper[vars].push(temp);
						}
						else if (oper[vars] == null)
						{
							oper[vars] = temp;
						}
						else
						{
							openVector = g.speedFact.n_vector(Object);
							if(openVector == null)
							{
								openVector = new Vector.<Object>();
							}
							openVector.push(oper[vars]);
							openVector.push(temp);
							oper[vars] = openVector;
						}
					}
				}
			}
		}
		
		
		/**
		 * 清理索引
		 * @param o
		 * @param key	如果是"",就清理全部
		 */
		public static function clearArray(o:Array, key:String = ""):void
		{
			if(lib[o] != null)
			{
				if(key == "")
				{
					delete lib[o];
				}
				else if(lib[o][key] != null)
				{
					clearArrayKey(o, key);
					g.speedFact.d_dict(lib[o][key]);
					delete lib[o][key];
				}
			}
		}
		
		/**
		 * 清理索引
		 * @param	o		引用的对象Array对象
		 * @param	key		Array中Object的关键key
		 */
		private static function clearArrayKey(o:Array, key:String):void
		{
			if(lib[o] != null && lib[o][key] != null)
			{
				oper = lib[o][key];
				for (vars in oper) 
				{
					if (oper[vars] is Vector.<Object>)
					{
						g.speedFact.d_vector(Object, oper[vars]);
					}
					delete oper[vars];
				}
			}
		}
		
		/**
		 * 获取一个索引
		 * @param o
		 * @param key
		 * @param vars
		 * @return 
		 */
		public static function getArrayItem(o:Array, key:String, vars:*):Object
		{
			if(lib[o] && lib[o].hasOwnProperty(key))
			{
				oper = lib[o][key] as Dictionary;
				if(oper[vars] is Vector.<Object>)
				{
					return oper[vars][0];
				}
				else if (oper[vars])
				{
					return oper[vars];
				}
			}
			return null;
		}
		
		
		/**
		 * 获取一些列的索引值
		 * @param o
		 * @param key
		 * @param vars
		 * @return 
		 */
		public static function getArrayList(o:Array, key:String, vars:*):Vector.<Object>
		{
			var v:Vector.<Object> = g.speedFact.n_vector(Object);
			if(v == null)
			{
				v = new Vector.<Object>();
			}
			if(lib[o] && lib[o].hasOwnProperty(key))
			{
				oper = lib[o][key] as Dictionary;
				if(oper[vars] != null)
				{
					if(oper[vars] is Vector.<Object>)
					{
						openVector = oper[vars] as Vector.<Object>;
						v = v.concat(openVector);
					}
					else
					{
						v.push(oper[vars]);
					}
				}
			}
			return v;
		}
		
	}
}