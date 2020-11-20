package cn.wjj.gagaframe.client.info
{
	import cn.wjj.g;
	import cn.wjj.data.ObjectAction;
	import flash.utils.ByteArray;
	
	/**
	 * 框架的全部数据
	 */
	public class DataModel
	{
		/** 将这些值设置为默认值 **/
		public static function get defaultObject():Object
		{
			if (!__default)
			{
				__default = new Object();
				__default.deviceId = "";
			}
			return __default;
		}
		//--------------------------------------------------------------------------------------
		/** 索引字段 **/
		internal static var __keyList:Array = [];
		/** [默认:""]设备的唯一ID **/
		public function get deviceId():String {
			return __modelGet("deviceId");
		}
		/** [默认:""]设备的唯一ID **/
		public function set deviceId(vars:String):void {
			__modelSet("deviceId", vars, false);
		}
		//--------------------------------------------------------------------------------------
		/** 对象引用的数据对象 **/
		private var __info:Object;
		/** 初始默认值的对象 **/
		private static var __default:Object;
		/** AllData的在框架g.bridge.getObjByName引用的名称 **/
		private var __allDataBridgeName:String;
		/** 这个对象在allData上的引用位置 **/
		private var __thisGroupName:String;
		
		/**
		 * 框架的全部数据
		 * @param	baseInfo			传入null并且thisGroupName=""的时候,生成一个new Object()
		 * @param	allDataBridgeName	全部数据在框架g.bridge.getObjByName引用的名称,默认allData
		 * @param	thisGroupName		这个数据在全部数据集合上的引用位置(设置后将自动弃用baseInfo,而是从位置里获取内容)
		 * @return
		 */
		public function DataModel(baseInfo:Object = null, allDataBridgeName:String = "", thisGroupName:String = ""):void
		{
			__allDataBridgeName = allDataBridgeName;
			if (baseInfo && allDataBridgeName && thisGroupName)
			{
				ObjectAction.setGroupVar(g.bridge.getObjByName(allDataBridgeName), thisGroupName, baseInfo);
			}
			if (!baseInfo && !thisGroupName)
			{
				setObject(null);
				return;
			}
			if (allDataBridgeName && thisGroupName)
			{
				setGroupInfo(allDataBridgeName, thisGroupName);
			}
			else
			{
				setObject(baseInfo);
			}
		}
		/**
		 * 框架的全部数据
		 * @param	baseInfo			传入null并且thisGroupName=""的时候,生成一个new Object()
		 * @param	allDataBridgeName	全部数据在框架g.bridge.getObjByName引用的名称,默认allData
		 * @param	thisGroupName		这个数据在全部数据集合上的引用位置(设置后将自动弃用baseInfo,而是从位置里获取内容)
		 * @return
		 */
		public static function getThis(baseInfo:Object = null, allDataBridgeName:String = "", thisGroupName:String = ""):DataModel
		{
			return new DataModel(baseInfo, allDataBridgeName, thisGroupName);
		}
		
		/**
		 * 获取值,当缺少自动赋初始值
		 * @param	n
		 * @return
		 */
		private function __modelGet(n:String):*
		{
			if (__allDataBridgeName && __thisGroupName)
			{
				__info = ObjectAction.getGroupVar(g.bridge.getObjByName(__allDataBridgeName), __thisGroupName);
			}
			if (__info.hasOwnProperty(n))
			{
				return __info[n];
			}
			else
			{
				__info[n] = DataModel.defaultObject[n];
				return __info[n];
			}
		}
		
		/**
		 * 设置一个对象的参数
		 * @param	n				属性名称
		 * @param	vars			值
		 * @param	isRunEvent		是否自动触发事件桥
		 */
		private function __modelSet(n:String, vars:*, isRunEvent:Boolean = false):void
		{
			if (__allDataBridgeName && __thisGroupName)
			{
				__info = ObjectAction.getGroupVar(g.bridge.getObjByName(__allDataBridgeName), __thisGroupName);
			}
			if(__info[n] !== vars){
				__info[n] = vars;
				if (isRunEvent)
				{
					if (__thisGroupName)
					{
						g.event.runEventData(g.bridge.getObjByName(__allDataBridgeName), __thisGroupName + "." + n);
					}
					else
					{
						g.event.runEventData(g.bridge.getObjByName(__allDataBridgeName));
					}
				}
			}
		}
		
		/**
		 * 设置这个对象引用的数据对象
		 * @param	baseInfo	当传入null的时候,自动生成一个new Object()
		 * @return
		 */
		public function setObject(baseInfo:Object = null):DataModel
		{
			if(baseInfo == null){
				baseInfo = new Object();
			}
			__info = baseInfo;
			return this;
		}
		
		/**
		 * 设置对象在一个数据集合中的位置,并且获取这个对象数据,写入这个对象里
		 * @param	allDataBridgeName		全部数据在框架g.bridge.getObjByName引用的名称,默认allData
		 * @param	thisGroupName			这个数据在全部数据集合上的引用位置(设置后自动覆盖这里的数据对象)
		 */
		public function setGroupInfo(allDataBridgeName:String = "", thisGroupName:String = ""):DataModel
		{
			__allDataBridgeName = allDataBridgeName;
			__thisGroupName = thisGroupName;
			if (allDataBridgeName && thisGroupName)
			{
				var o:Object = g.bridge.getObjByName(allDataBridgeName);
				__info = ObjectAction.getGroupVar(o, thisGroupName);
			}
			return this;
		}
		
		/** 获取数据模型引用的对象 **/
		public function getObject():Object
		{
			return __info;
		}
		
		/** 将初始化数据覆盖进去 **/
		public function setDefault():void
		{
			overlapObject(DataModel.defaultObject);
		}
		
		/**
		 * 设置这个对象的信息,或者覆盖到这个老的数据之上,当从网上传值过来的时候使用
		 * @param	baseInfo
		 * @return
		 */
		public function overlapObject(baseInfo:Object):DataModel
		{
			var o:DataModel = new DataModel(baseInfo, "", "");
			for (var n:String in baseInfo) 
			{
				this[n] = o[n];
			}
			return this;
		}
		
	}
}
