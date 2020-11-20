package cn.wjj.gagaframe.client.time
{
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	
	public class TimerItemBase
	{
		/** 计时器名称 **/
		internal var _name:String;
		/** 回调函数 **/
		internal var methodList:Vector.<Function>;
		/** 是否运行完毕后自动删除这个事件.清理这个连接 **/
		internal var autoDel:Boolean = true;
		/** 从什么地方获取时间 **/
		internal var _getTimeType:String = GetTimeType.GAGAFRAME;
		//-------------------------------------当秒值发生变化的时候触发
		/** 当秒的值发生变化的时候触发 **/
		internal var secondsRun:Boolean = false;
		/** 每秒触发函数 **/
		internal var secondsMethodList:Vector.<Function>;
		/**旧的秒的时间**/
		internal var secondsOld:Number = 0;
		
		public function TimerItemBase() { }
		
		/** 计时器名称 **/
		public function get name():String
		{
			return _name;
		}
		/**
		 * 计时器名称
		 * @param value	这个计时器的名称,如果重复,将自动重新起一个新名称.如果没有就随机给一个名称
		 */
		public function set name(value:String):void
		{
			if(value == "" || value == null)
			{
				value = "timerItem" + g.time.getTime() + Math.floor((Math.random()*1000));
				g.log.pushLog(this, LogType._Warning, "你添加的计时器没有名称,系统自动生成名称: " + value);
			}
			else if(g.time.getTimerForName(value))
			{
				var nameOld:String = value;
				value = "timerItem" + g.time.getTime() + Math.floor((Math.random()*1000));
				g.log.pushLog(this, LogType._Warning, "你添加的计时器名称 " + nameOld +" 已经存在,系统自动生成名称: " + value);
			}
			_name = value;
		}
		
		/**
		 * 添加一个函数，如果有就不会添加重复的函数
		 * @param method
		 */
		public function pushMethod(method:Function):void
		{
			if(methodList == null)
			{
				methodList = new Vector.<Function>;
				methodList.push(method);
				return;
			}
			for each(var _method:Function in methodList)
			{
				if(_method == method)
				{
					return;
				}
			}
			methodList.push(method);
		}
		
		/**
		 * 运行Vector的一系列的函数
		 * @param temp
		 */
		internal function runMethod(temp:Vector.<Function>):void
		{
			for each(var _method:Function in temp)
			{
				_method();
			}
		}
		
		/**
		 * 添加一个函数，如果有就不会添加重复的函数,每秒运行的函数
		 * @param method
		 */
		public function pushSecondsMethod(method:Function):void
		{
			if(secondsMethodList == null)
			{
				secondsMethodList = new Vector.<Function>;
				secondsMethodList.push(method);
				return;
			}
			for each(var _method:Function in secondsMethodList)
			{
				if(_method == method)
				{
					return;
				}
			}
			secondsMethodList.push(method);
		}
		
		/** 从什么地方获取时间 **/
		public function get getTimeType():String
		{
			return _getTimeType;
		}
		/** 从什么地方获取时间 **/
		public function set getTimeType(value:String):void
		{
			g.log.pushLog(this, LogType._Frame, "请在初始化这个计时器前设置getTimeType,否则不准确");
			switch(value)
			{
				case GetTimeType.SYSTEM:
					_getTimeType = GetTimeType.SYSTEM;
					break;
				case GetTimeType.SERVER:
					_getTimeType = GetTimeType.SERVER;
					break;
				default:
					_getTimeType = GetTimeType.GAGAFRAME;
			}
		}
		
		/** 每过一秒运行一次,这个当计时器结束的时候会自动删除 **/
		public function perSeconds(method:Function):void
		{
			this.secondsRun = true;
			pushSecondsMethod(method);
		}
		
		/** 自动判断时间是否要做处理 **/
		internal function run():void{}
		
		/** 根据设置的获取值的位置,获取一个值使用 **/
		internal function getTime():Number
		{
			return g.time.getTime(_getTimeType);
		}
		
		/** 删除这个计时器 **/
		public function del():void
		{
			if(g.time.timerManager.timerList.length)
			{
				for(var item:String in g.time.timerManager.timerList)
				{
					if (g.time.timerManager.timerList[item] == this)
					{
						g.time.timerManager.timerList.splice(Number(item), 1);
					}
				}
			}
		}
	}
}