package cn.wjj.gagaframe.client.speedfact 
{
	import flash.utils.Dictionary;
	
	/**
	 * [系统内使用的]工厂的仓库
	 * @author GaGa
	 */
	public class SpeedLib 
	{
		/** 全部没有回收的对象 **/
		private var a:Dictionary;
		/** 存放对象的对象池 **/
		private var f:Array;
		/** 存放对象的对象池现在的尺寸 **/
		private var l:uint = 0;
		/** 存放对象非对象池对象 **/
		private var d:Dictionary;
		/** 对象池强引用的最大数量 **/
		private var m:uint = 0;
		/** 临时记录的对象 **/
		private var o:Object;
		/** 临时记录的数组 **/
		private var t:Array;
		/** 临时的变量 **/
		private var i:int;
		
		public function SpeedLib(length:uint)
		{
			a = new Dictionary(true);
			f = new Array();
			d = new Dictionary(true);
			this.length = length;
		}
		
		/** Get Lib Object **/
		public function instance():Object
		{
			var o:Object;
			if (l > 0)
			{
				o = f.pop();
				l--;
				return o;
			}
			for (o in d)
			{
				delete d[o];
				return o;
			}
			return null;
		}
		
		public function recover(o:Object):void
		{
			if(f.indexOf(o) == -1)
			{
				if (l < m)
				{
					f.push(o);
					l++;
				}
				else
				{
					d[o] = null;
				}
			}
		}
		
		/** 对象池强引用的最大数量 **/
		public function get length():uint 
		{
			return m;
		}
		
		/** 对象池强引用的最大数量 **/
		public function set length(value:uint):void 
		{
			if (m != value)
			{
				m = value;
				if (l > value)
				{
					t = f.slice(value);
					l = value;
					for each (o in t) 
					{
						d[o] = null;
					}
					t.length = 0;
					t = null;
					o = null;
				}
			}
		}
		
		/** 移除,清理,并回收 **/
		public function dispose():void
		{
			if (f)
			{
				f.length = 0;
				f = null;
			}
			d = null;
			a = null;
		}
	}
}