package cn.wjj.gagaframe.client.speedfact
{
	import flash.utils.Dictionary;
	
	/**
	 * 全部的对象池管理者
	 * @author GaGa
	 */
	public class SpeedFact 
	{
		/** Array 对象池 **/
		public var lib_array:SpeedLib = new SpeedLib(500);
		/** Object 对象池 **/
		public var lib_object:SpeedLib = new SpeedLib(1000);
		/** Object 对象池 **/
		public var lib_dict:SpeedLib = new SpeedLib(1000);
		/** Object 对象池 **/
		public var lib_dictWeak:SpeedLib = new SpeedLib(1000);
		/** Vector  **/
		private var lib_vector:Object = new Object();
		
		public function SpeedFact():void { }
		
		/** 创建 Array 数组 **/
		public function n_array():Array
		{
			var o:Array = lib_array.instance() as Array;
			if (o) return o;
			return new Array();
		}
		
		/** 回收 Array 数组 **/
		public function d_array(o:Array):void
		{
			if (o.length) o.length = 0;
			lib_array.recover(o);
		}
		
		/** 创建 Object 数组 **/
		public function n_object():Object
		{
			var o:Object = lib_object.instance();
			if (o) return o;
			return new Object();
		}
		
		/** [需自行清理]回收 Object 数组 **/
		public function d_object(o:Object):void
		{
			lib_object.recover(o);
		}
		
		/** [需自行清理]回收 Dictionary(强引用) 数组 **/
		public function d_dict(o:Object):void
		{
			lib_dict.recover(o);
		}
		
		/** [需自行清理]回收 Dictionary(弱引用) 数组 **/
		public function d_dictWeak(o:Object):void
		{
			lib_dictWeak.recover(o);
		}
		
		/** 创建 Dictionary(强引用) 数组 **/
		public function n_dict():Dictionary
		{
			var o:Dictionary = lib_dict.instance() as Dictionary;
			if (o) return o;
			return new Dictionary();
		}
		
		/** 创建 Dictionary(弱引用) 数组 **/
		public function n_dictWeak():Dictionary
		{
			var o:Dictionary = lib_dictWeak.instance() as Dictionary;
			if (o) return o;
			return new Dictionary(true);
		}
		
		/** 直接获取某中类型的 Vector ,如果没有就返回null **/
		public function n_vector(type:Class):*
		{
			var lib:SpeedLib;
			if (lib_vector.hasOwnProperty(type))
			{
				lib = lib_vector[type];
				return lib.instance();
			}
			return null;
		}
		
		/** 回收 Vector 数组 **/
		public function d_vector(type:Class, o:*):void
		{
			o.length = 0;
			var lib:SpeedLib;
			if (lib_vector.hasOwnProperty(type))
			{
				lib = lib_vector[type];
				lib.recover(o);
			}
			else
			{
				lib = new SpeedLib(50);
				lib.recover(o);
				lib_vector[type] = lib;
			}
		}
		
		/** 改变某一种特定类型 type 的对象池数量 **/
		public function l_vector(type:Class, length:uint):void
		{
			var lib:SpeedLib;
			if (lib_vector.hasOwnProperty(type))
			{
				lib = lib_vector[type];
			}
			else
			{
				lib = new SpeedLib(50);
				lib_vector[type] = lib;
			}
			lib.length = length;
		}
		
		/** 将某中特定类型的 Vector 全部回收 **/
		public function r_vector(type:Class):void
		{
			if (lib_vector.hasOwnProperty(type))
			{
				var lib:SpeedLib = lib_vector[type];
				lib.dispose();
				delete lib_vector[type];
			}
		}
	}
}