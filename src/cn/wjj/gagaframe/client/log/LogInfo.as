package cn.wjj.gagaframe.client.log
{
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.worker.WorkerInfo;
	import cn.wjj.gagaframe.client.worker.WorkerJobType;
	import cn.wjj.gagaframe.client.worker.WorkerTask;
	import cn.wjj.time.TimeToString;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * 日志数据信息
	 * 
	 * @version 1.0.0
	 * @author GaGa wjjhappy@Gmail.com
	 * @copy 王加静 www.5ga.cn
	 * @date 2011-11-04
	 */
	internal class LogInfo
	{
		/** 最后一个日志ID **/
		private var id:int = 0;
		/** 全部日志 **/
		internal var lib:Vector.<Object> = new Vector.<Object>;
		/** 现在日志长度 **/
		private var length:int = 0;
		/** 需要清理的行数 **/
		private var clearLength:int;
		/** 上一个日志记录的时间 **/
		private var tempTime:Number = 0;
		
		/** 日志的时间,单位毫秒 **/
		private var o_t:Number;
		/** 日志内容 **/
		private var o_i:String;
		
		/**
		 * 日志数据信息
		 * @param	frame	框架的引入
		 */
		public function LogInfo() { }
			
		/**
		 * 获取相关日志.
		 * time		获取日志在那个时间后
		 */
		internal function getLog(time:Number = 0):Vector.<Object>
		{
			if(time == 0)
			{
				return lib;
			}
			else
			{
				var o:Vector.<Object> = new Vector.<Object>;
				for each (var temp:Object in lib)
				{
					if(temp.time > time)
					{
						o.push(temp);
					}
				}
				return o;
			}
		}
		
		/**
		 * 通过指针来获取这个对象
		 * @return
		 */
		internal function getLogUsePosition(p:Object):Vector.<Object>
		{
			if(p && length)
			{
				var o:Vector.<Object> = new Vector.<Object>;
				var start:Boolean = false;
				for each (var i:Object in lib)
				{
					if(p == i)
					{
						start = true;
						continue;
					}
					if (start)
					{
						o.push(i);
					}
				}
				//可能是对象里没有一样的,被清理掉了,所以里面全部都是最新的
				if (start == false)
				{
					return lib;
				}
				return o;
			}
			return lib;
		}
		
		/**
		 * 获取线程里的数据
		 * @param	name	线程的名称
		 * @param	info	线程数据
		 */
		internal function workerLog(name:String, info:Object):void
		{
			//先看是不是超出了,如果超出就回收一个对象
			clearLength = length - g.log.maxItem;
			var o:Object;
			if(clearLength > 0)
			{
				o = lib.shift();
			}
			else
			{
				o = new Object();
				length++;
			}
			o.id = id++;
			//-------------------------记录日志时间
			o.useTime = info.info.useTime
			o.targetType = info.info.targetType;
			o.targetName = info.info.targetName;
			o.type = info.info.type;
			o.time = info.info.logTime;
			o.worker = name;//新加类型,是否是线程
			o.info = "◆" + info.info.info;
			//--------------------------创建日志
			lib.push(o);
			//判断是不是要trace出来,如果是就输出.
			if (g.log.isTrace)
			{
				trace(getItemString(o));
			}
			if (g.log.float)
			{
				g.log.float.pushLog(o);
			}
		}
		
		/**
		 * 添加一条日志,可以包含发出日志的对象,日志的类型,以及要输出的一系列参数
		 * 
		 * useTime		日志距离上个日志的耗,如果没有上个,这个值为0
		 * type			日志类型
		 * targetType	日志对象的类型,比如:MovieClip,Class,Button
		 * targetName	日志对象的名称
		 * 
		 * @param	target		发出日志的对象
		 * @param	type		记录的日志类型:记录,错误,用户操作,截图,用户提交,警告,系统,框架
		 * @param	...args		内容,类似于使用trace()方法
		 */
		internal function pushLog(target:* = null, type:uint = 0, ...args):void
		{
			var o:Object;
			var l:int;
			if (g.worker.isPrimordial || g.worker.isStart == false)
			{
				//先看是不是超出了,如果超出就回收一个对象
				clearLength = length - g.log.maxItem;
				if(clearLength > 0)
				{
					o = lib.shift();
				}
				else
				{
					o = new Object();
					length++;
				}
				o.id = id++;
				//-------------------------记录日志时间
				o_t = new Date().time;
				if (tempTime == 0)
				{
					o.useTime = 0;
				}
				else
				{
					o.useTime = o_t - tempTime;
				}
				tempTime = o_t;
				//------------------------记录对象类型和名称
				if(target)
				{
					o.targetType = getQualifiedClassName(target);
					if(target.hasOwnProperty("name"))
					{
						o.targetName = String(target.name);
					}
					else
					{
						o.targetName = "";
					}
				}
				else
				{
					o.targetType = "";
					o.targetName = "";
				}
				//-------------------------记录日志类型
				o.type = type;
				//--------------------------记录日志信息
				l = args.length;
				o_i = "";
				while(--l > -1)
				{
					if(o_i == "")
					{
						o_i = args[l].toString();
					}
					else
					{
						o_i = args[l].toString() + " , " + o_i;
					}
				}
				//--------------------------加入
				o.time = o_t;
				o.info = o_i;
				//--------------------------创建日志
				lib.push(o);
				//判断是不是要trace出来,如果是就输出.
				if (g.log.isTrace)
				{
					trace(getItemString(o));
				}
				if (g.log.float)
				{
					g.log.float.pushLog(o);
				}
			}
			else
			{
				o = new Object();
				o.type = "log";
				o.info = new Object();
				o.info.logTime = new Date().time;
				o.info.type = type;
				if(target)
				{
					o.info.targetType = getQualifiedClassName(target);
					if(target.hasOwnProperty("name"))
					{
						o.info.targetName = String(target.name);
					}
				}
				else
				{
					o.info.targetType = "";
				}
				l = args.length;
				o_i = "";
				while(--l > -1)
				{
					if(o_i == "")
					{
						o_i = args[l].toString();
					}
					else
					{
						o_i = args[l].toString() + " , " + o_i;
					}
				}
				o.info.info = o_i;
				
				var worker:WorkerTask = new WorkerTask();
				worker.item = new WorkerInfo();
				worker.item.type = WorkerJobType.Frame_Log;
				worker.item.send.info = o;
				g.worker.taskSend(worker);
			}
		}
		
		/**
		 * 将一个LogItem转换为一个输出内容,独立出来减少Item的函数量
		 * @param	tempObj		要输出的LogItem
		 * @return
		 */
		private function getItemString(o:Object):String
		{
			var s:String = "";
			if(o.time)
			{
				if(g.log.config_ShowTimeType)
				{
					s += "[" + TimeToString.NumberToChinaTime(Number(o.time)) + "]";
				}
				else
				{
					s += "[" + TimeToString.NumberToOtherMinTime(Number(o.time)) + "]";
				}
			}
			if(g.log.config_ShowUseTime && o.useTime)
			{
				s += "[" + TimeToString.UseTimeToString(o.useTime) + "]";
			}
			if (o.targetName)
			{
				s += "[" + o.targetName + "]";
			}
			if (o.targetType)
			{
				s += "[" + o.targetType + "]";
			}
			if (o.type)
			{
				s += "[" + g.logType.getTypeString(o.type) + "]";
			}
			s += " : " + o.info;
			return s;
		}
		
		/**
		 * 输出全部的日志
		 * @return
		 */
		internal function toString():String
		{
			var s:String = "";
			for each(var o:Object in lib)
			{
				if(s != "")
				{
					s += "\n";
				}
				s += getItemString(o);
			}
			return s;
		}
		
		/** 根据最大日志条数:g.log.maxItem,清理日志 **/
		internal function c(isAll:Boolean = false):void
		{
			if (isAll)
			{
				length = 0;
				lib.length = 0;
			}
			else
			{
				clearLength = length - g.log.maxItem;
				if (clearLength > 0)
				{
					length -= clearLength;
					lib.slice(0, clearLength);
				}
			}
		}
	}
}