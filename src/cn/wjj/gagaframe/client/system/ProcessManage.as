package cn.wjj.gagaframe.client.system
{
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import flash.utils.Timer;

	internal class ProcessManage
	{
		/** 运行的队列 **/
		private var lib:Vector.<Object>;
		/** Timer的对象 **/
		private var timer:Timer;
		/** 所占用的CPU的量 **/
		private var cpuVer:uint = 100;
		/** 没帧运行多少时间 **/
		private var runTime:uint = 0;
		/** 剩余的CPU时间 **/
		//private var runSYTime:uint = 0;
		/** 开始运行的时间 **/
		private var runStartTime:Number;
		/** 每个函数运行的时候所消耗的时间,已经算出CPU的消耗值 **/
		private var runSpeed:Dictionary;
		/** 队列是否在运行中 **/
		private var isRuning:Boolean = false;
		/** 函数开始运行的时间 **/
		private var t_s:Number;
		/** 函数运行结束的时间 **/
		private var t_e:Number;
		/** 运行函数时间对象 **/
		private var t_o:Object;
		/** 进程已经运行了多少次 **/
		private var t_r1:Boolean;
		/** 是否已经监听 **/
		private var t_t:Boolean;
		/** 上一帧的结束时间 **/
		//private var t_et:Number;
		/** 上一幀已经消耗的时间 **/
		//private var t_st:Number;
		
		/**
		 * 进城管理工具
		 * 
		 * @version 0.0.1
		 * @author GaGa wjjhappy@Gmail.com
		 * @copy 王加静 www.5ga.cn
		 * @date 2013-07-12
		 */
		public function ProcessManage()
		{
			lib = new Vector.<Object>();
			runSpeed = new Dictionary(true);
			reFrameRate();
		}
		
		/**
		 * 设置基础设置
		 * @param fps
		 * @param cpuVer
		 * 
		 */
		public function reFrameRate(fps:Number = 0, cpuVer:uint = 80):void
		{
			try
			{
				if(fps == 0 && g.bridge.stage)
				{
					fps = g.bridge.stage.frameRate;
				}
			}
			catch (e:Error) { }
			if (fps)
			{
				this.cpuVer = cpuVer;
				runTime = Math.floor((1000 / fps) * cpuVer / 100);
			}
			//runSYTime = Math.ceil((1000/fps)*(100 - cpuVer)/100);
		}
		
		/**
		 * 输入一个将要运行的异步函数
		 * @param method		将要运行的函数
		 * @param times			这个函数运行的次数
		 * @param onComplete	完成这支队列的时候的回调函数
		 */
		public function pushMethod(method:Function, times:int = 1, onComplete:Function = null):void
		{
			if(method != null)
			{
				if(cpuVer == 100)
				{
					while(times > 0)
					{
						times--;
						try
						{
							method();
							if(times == 0 && onComplete != null)
							{
								onComplete();
							}
						}
						catch(e:Error)
						{
							g.log.pushLog(this, LogType._ErrorLog, "线程出错 ID:" + e.errorID + " 名字:" + e.name + " 信息:" + e.message);
						}
					}
				}
				else
				{
					var item:Object = new Object();
					item.r = method;
					item.t = times;
					item.o = onComplete;
					if(runSpeed[method] == null)
					{
						var o:Object = new Object();
						o.t = 0;
						o.u = 0;
						o.p = 0;
						runSpeed[method] = o;
					}
					lib.push(item);
					if(t_t == false)
					{
						t_t = true;
						g.event.addEnterFrame(doing);
					}
				}
			}
			else
			{
				g.log.pushLog(this, LogType._ErrorLog, "缺乏运行函数");
			}
		}
		
		private function doing():void
		{
			//算时间
			//runStartTime = new Date().time;
			runStartTime = getTimer();
			/*
			if(t_et > 0)
			{
				//上次和这次间已经被消耗掉的时间差, runSYTime,是可以有这么多富裕
				t_st = runStartTime - t_et - runSYTime;
				if(t_st < 0)
				{
					t_st = 0;
				}
			}
			*/
			if(isRuning == false)
			{
				var l:uint = lib.length;
				if(l)
				{
					while(--l > -1)
					{
						if(lib[l].t == 0)
						{
							lib.splice(l, 1);
						}
					}
				}
			}
			run();
		}
		
		private function run():void
		{
			if(isRuning)
			{
				return;
			}
			else
			{
				isRuning = true;
				t_r1 = true;
				var l:uint = lib.length;
				if(l)
				{
					var r:uint = 0;
					var o:Object;
					while(r < l)
					{
						o = lib[r];
						t_o = runSpeed[o.r];
						//if (t_r1 || (runStartTime + runTime + t_o.p) > new Date().time)
						if (t_r1 || (runStartTime + runTime + t_o.p) > getTimer())
						{
							while(o.t > 0)
							{
								//try
								//{
									o.t--;
									t_r1 = false;
									//t_s = new Date().time;
									t_s = getTimer();
									o.r();
									//t_e = new Date().time - t_s;
									t_e = getTimer() - t_s;
									t_o.t++;
									t_o.u += t_e;
									t_o.p = uint(t_o.u / t_o.t);
									if(o.t == 0)
									{
										if(o.o != null)
										{
											o.o();
										}
										
									}
								//}
								//catch(e:Error)
								//{
								//	f.log.pushLog(this, LogType._ErrorLog, "线程出错 run ID:" + e.errorID + " 名字:" + e.name + " 信息:" + e.message);
								//}
								//t_et = new Date().time;
								//if ((runStartTime + runTime) < new Date().time)
								if ((runStartTime + runTime) < getTimer())
								{
									//f.log.pushLog(this, LogType._ErrorLog, "线程时间到达退出, 运行" + r + "剩余" + l);
									isRuning = false;
									return;
								}
							}
							
						}
						l = lib.length;
						r++;
					}
				}
				//t_et = 0;
				isRuning = false;
				if(t_t && lib.length == 0)
				{
					t_t = false;
					g.event.removeEnterFrame(doing);
				}
			}
		}
	}
}