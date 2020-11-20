package cn.wjj.data
{
	import cn.wjj.g;
	import flash.utils.Dictionary;
	
	/**
	 * 设置一个弱引用对象,如果这个对象没有被回收,就会辅助记录一个连接对象
	 * 如果这个对象被回收,就会把辅助记录的一个连接对象也释放.
	 */
	public class DictLink
	{
		
		private var dict:Dictionary;
		
		/**
		 * 设置一个弱引用对象,如果这个对象没有被回收,就会辅助记录一个连接对象
		 * 如果这个对象被回收,就会把辅助记录的一个连接对象也释放.
		 * 
		 * @param link	用什么对象来连接
		 * @param vars	记录一个什么值
		 */
		public function DictLink(link:*, vars:*):void
		{
			setLinkValue(link, vars);
		}
		
		/**
		 * 设置一个弱引用对象,如果这个对象没有被回收,就会辅助记录一个连接对象
		 * 如果这个对象被回收,就会把辅助记录的一个连接对象也释放.
		 * 
		 * @param link	用什么对象来连接
		 * @param vars	记录一个什么值
		 */
		public function setLinkValue(link:*, vars:*):void
		{
			var temp:*;
			if (link == null || link is Boolean || link is Number || link is String)
			{
				throw new Error("传值不符");
			}
			else if (dict == null)
			{
				dict = g.speedFact.n_dictWeak();
				dict[link] = vars;
			}
			else
			{
				for(temp in dict) 
				{
					delete dict[temp];
				}
				dict[link] = vars;
			}
		}
		
		/**
		 * 这个弱引用要连接的值
		 * @param vars	必须是一个对象的引用,不能是一个值
		 */
		public function set value(vars:*):void
		{
			if (dict)
			{
				for(var temp:* in dict) 
				{
					dict[temp] = vars;
				}
			}
			else
			{
				throw new Error("未初始化");
			}
		}
		
		/**
		 * 获取所赋值
		 * @return 
		 */
		public function get value():*
		{
			if (dict)
			{
				for each(var temp:* in dict) 
				{
					return temp;
				}
			}
			return null;
		}
		
		/** 清理删除及引用 **/
		public function dispose():void
		{
			if (dict)
			{
				for (var temp:* in dict) 
				{
					delete dict[temp];
				}
				g.speedFact.d_dictWeak(dict);
				dict = null;
			}
		}
	}
}