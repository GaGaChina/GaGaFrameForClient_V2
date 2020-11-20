package cn.wjj.data
{
	import cn.wjj.g;
	import flash.utils.Dictionary;
	
	/**
	 * 建立弱引用对象,可以赋值过来,但是值会以弱引用存在,当值消失的时候会返回null
	 * 
	 * @version 1.0.0
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 * @date 2012-08-17
	 */
	public class DictValue
	{
		public static function instance(vars:* = null):DictValue
		{
			return new DictValue(vars);
		}
		
		/** 移除,清理,并回收 **/
		public function dispose():void
		{
			if (value != null) value = null;
		}
		
		/** 对数据的引用 **/
		private var link:Dictionary = new Dictionary(true);
		
		public function DictValue(vars:* = null):void
		{
			value = vars;
		}
		
		/**
		 * 赋值对象的引用
		 * @param vars	必须是一个对象的引用,不能是一个值
		 */
		public function set value(o:*):void
		{
			var temp:*;
			if (o == null || o is Boolean || o is Number || o is String)
			{
				if (link)
				{
					for (temp in link) 
					{
						delete link[temp];
					}
					g.speedFact.d_dictWeak(link);
					link = null;
				}
			}
			else
			{
				if (link == null)
				{
					link = g.speedFact.n_dictWeak();
					link[o] = null;
				}
				else
				{
					for (temp in link) 
					{
						if(temp == o)
						{
							return;
						}
						else
						{
							delete link[temp];
						}
					}
					link[o] = null;
				}
			}
		}
		
		/**
		 * 获取所赋值
		 * @return 
		 */
		public function get value():*
		{
			for (var temp:* in link) 
			{
				return temp;
			}
			return null;
		}
	}
}