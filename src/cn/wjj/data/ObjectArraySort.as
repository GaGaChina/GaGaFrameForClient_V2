package cn.wjj.data
{
	import cn.wjj.g;
	import flash.utils.Dictionary;
	
	/**
	 * 对一个数组进行排序
	 * 洋葱皮排序法
	 * 先对条件级别进行一级级的排序,一层层的剥条件列表,最后生成最后的排序序列.
	 * 对比的值必须为数字的类型.暂时不支持别的类型
	 * 
	 * 
	 * @version 0.0.1
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 * @time 2013-08-06
	 */
	public class ObjectArraySort 
	{
		/** 排序规则,数字排序,数字从小到大的排序 **/
		public static const SORT_NUMBER_SMAILL_BIG:String = "number_smail_big";
		/** 排序规则,当等于某一个值的时候排在前面,其余的放后面 **/
		public static const SORT_VER_IN_START:String = "ver_in_start";
		/** [本功能耗费CPU]排序规则,值按照数组的排列顺序,依次排列,如果没有在其中,就排在最外面 **/
		public static const SORT_VER_ON_ARRAY:String = "ver_on_array";
		/** [反向递归]排序规则,值按照数组的排列顺序,依次排列,如果没有在其中,就排在最外面 **/
		public static const SORT_REVERSE_VER_ON_ARRAY:String = "ver_reverse_on_array";
		/** [排序规则]如果某一项值在array中,就删除掉,不出现在结果中 **/
		public static const SORT_VER_DEL_ARRAY:String = "ver_del_array";
		
		/** 临时的项目元件 **/
		private static var o:*;
		/** 临时调用的key **/
		private static var key:*;
		/** 临时调用的值 **/
		private static var vars:*;
		/** 临时的值,标识是否要推入这个值 **/
		private static var b:Boolean;
		/** 临时的字典 **/
		private static var dict:Dictionary;
		/** 每个数组的排序算法 **/
		private static var dictS:Dictionary;
		/** 每一个分支的查询要求 **/
		private static var s:Object;
		/** 洋葱皮后的对象 **/
		private static var aTemp:Array = new Array();
		/** 要回收的数组 **/
		private static var recoverArray:Array = new Array();
		/** 后续还要进行处理的数组集合 **/
		private static var handleArrS:Array;
		private static var handleArrN:Array;
		/** 层级下排序的临时数组 **/
		private static var layer:Array;
		private static var layerRun:Array;
		private static var layerDo:Array;
		/** 层级下排序的临时数组的临时数组 **/
		private static var layerTemp:Array;
		
		/** 映射的库 **/
		private static var shiningLib:Object;
		private static var shiningLength:uint;
		/** 函数的库 **/
		private static var mothodLib:Object;
		private static var mothodLength:uint;
		
		private static var pas:String;
		private static var pao:Object;
		private static var pai:int;
		
		public function ObjectArraySort() { }
		
		/**
		 * 对一个Object数组里的内容进行复杂的排序
		 * @param	a				Array 或者 Vector
		 * @param	sort			排序的顺序和要求
		 * @param	shining			映射部分,shiningList[映射名称]
		 * @param	mothod			计算函数类型,mothodList[映射名称]
		 * @param	changeA			是否直接改变a对象,a对象必须为数组,否则参数无效
		 * @return
		 */
		public static function sort(a:*, sort:Array, shining:Array = null, mothod:Array = null, changeA:Boolean = false):Array
		{
			var copy:Array;
			if (a.length)
			{
				copy = g.speedFact.n_array();
				recoverArray.push(copy);
				if (a is Array)
				{
					//var tttt:Array = new Array();
					//tttt.push(a);
					//copy = a.concat();
					copy.push.apply(null, a);
				}
				else
				{
					if (changeA)
					{
						changeA = false;
					}
					for each (o in a) 
					{
						copy.push(o);
					}
				}
			}
			else
			{
				if (changeA)
				{
					return a;
				}
				else
				{
					return g.speedFact.n_array();
				}
			}
			/** 层级下排序的临时数组 **/
			aTemp.push(copy);
			layer = aTemp;
			layerRun = aTemp;
			dictS = new Dictionary();
			var arrayIndex:int;
			//处理映射映射
			if (shining)
			{
				shiningLength = shining.length;
				if (shiningLength)
				{
					shiningLib = new Object();
					while (--shiningLength != -1)
					{
						o = shining[shiningLength];
						shiningLib[o.n] = o;
					}
				}
			}
			//处理函数映射
			if (mothod)
			{
				mothodLength = mothod.length;
				if (mothodLength)
				{
					mothodLib = new Object();
					while (--mothodLength != -1)
					{
						o = mothod[mothodLength];
						mothodLib[o.n] = o;
					}
				}
			}
			var handleArrN2:Array
			var s_obj:Object;
			var ss:Object;
			var m_obj:Object;
			var m_arr:Array;
			var m_at:Array;
			var mm:Object;
			for each (s in sort) 
			{
				dict = new Dictionary();
				layerDo = g.speedFact.n_array();
				recoverArray.push(layerDo);
				for (key in layerRun) 
				{
					handleArrS = layerRun[key];
					if (handleArrS is Array)
					{
						layer = handleArrS;
						handleArrN = new Array();
						//加入反向的查询
						for each (o in handleArrS) 
						{
							b = true;
							if (s.t == 1)//根据ID对比
							{
								//找到这个对象的属性值
								if (s.pl == 1)
								{
									if (o.hasOwnProperty(s.p))
									{
										vars = o[s.p];
									}
									else
									{
										vars = s.d;
									}
								}
								else
								{
									vars = s.d;
									pai == 0;
									pao = o;
									for each (pas in s.p) 
									{
										pai++;
										if (pao.hasOwnProperty(pas))
										{
											if (pai == s.pl)
											{
												vars = pao[pas];
											}
											else
											{
												pao = pao[pas];
											}
										}
									}
								}
							}
							else if (s.t == 2)//根据映射对比
							{
								ss = shiningLib[s.n];
								s_obj = ss.l[o];
								if (s_obj == null)
								{
									if (o.hasOwnProperty(ss.p_p))
									{
										vars = o[ss.p_p];
									}
									else
									{
										vars = ss.p_d;
									}
									s_obj = ss.o.getItemObj(ss.t_p, vars);
									ss.l[o] = s_obj;
								}
								
								if (s.pl == 1)
								{
									if (s_obj && s_obj.hasOwnProperty(s.p))
									{
										vars = s_obj[s.p];
									}
									else
									{
										vars = s.d;
									}
								}
								else
								{
									vars = s.d;
									pai == 0;
									pao = s_obj;
									for each (pas in s.p) 
									{
										pai++;
										if (pao.hasOwnProperty(pas))
										{
											if (pai == s.pl)
											{
												vars = pao[pas];
											}
											else
											{
												pao = pao[pas];
											}
										}
									}
								}
							}
							else if (s.t == 3)//根据函数处理值对比
							{
								mm = mothodLib[s.n];
								m_obj = mm.l[o];
								if (m_obj == null)
								{
									m_arr = mm.a;
									m_at = g.speedFact.n_array();
									recoverArray.push(m_at);
									for each (m_obj in m_arr) 
									{
										if (m_obj.type == "this")
										{
											m_at.push(o);
										}
										else if (m_obj.type == "shining")
										{
											ss = shiningLib[m_obj.info];
											s_obj = ss.l[o];
											if (s_obj == null)
											{
												if (o.hasOwnProperty(ss.p_p))
												{
													vars = o[ss.p_p];
												}
												else
												{
													vars = ss.p_d;
												}
												s_obj = ss.o.getItemObj(ss.t_p, vars);
												ss.l[o] = s_obj;
											}
											m_at.push(s_obj);
										}
										else if (m_obj.type == "function")
										{
											//这个嵌套了
										}
									}
									vars = mm.o.apply(null, m_at);
									mm.l[o] = vars;
								}
								else
								{
									vars = m_obj;
								}
							}
							//if (s.s == SORT_NUMBER_SMAILL_BIG){}
							if (s.s == SORT_VER_IN_START)
							{
								if (vars == s.a)
								{
									vars = 0;
								}
								else
								{
									vars = 1;
								}
							}
							else if (s.s == SORT_VER_ON_ARRAY)
							{
								arrayIndex = s.a.indexOf(vars);
								if (arrayIndex == -1)
								{
									vars = s.l;
								}
								else
								{
									vars = arrayIndex;
								}
							}
							//看下是不是执行剔除操作
							if (s.s == SORT_VER_DEL_ARRAY)
							{
								arrayIndex = s.a.indexOf(vars);
								if (arrayIndex == -1)
								{
									//这个值不用删除
									vars = 1;
								}
								else
								{
									//删除这个值
									b = false;
								}
							}
							if (b)
							{
								if (handleArrN[vars])
								{
									//如果是数组了,就需要在继续排序下去
									if (handleArrN[vars] is Array)
									{
										layerTemp = handleArrN[vars];
										//这里要进行排序,执行排序算法
										layerTemp.push(o);
									}
									else
									{
										layerTemp = g.speedFact.n_array();
										recoverArray.push(layerTemp);
										layerTemp.push(handleArrN[vars]);
										handleArrN[vars] = layerTemp;
										//这里要进行排序,执行排序算法
										layerTemp.push(o);
									}
									//防止重复处理
									if (s.s != SORT_REVERSE_VER_ON_ARRAY && dict[layerTemp] == null)
									{
										dict[layerTemp] = true;
										layerDo.push(layerTemp);
									}
								}
								else
								{
									//如果这个对象里只有一个对象,那么不用在向下排序啦
									handleArrN[vars] = o;
								}
							}
						}
						//在这里对handleArrN进行反向遍历
						if (handleArrN.length && s.s == SORT_REVERSE_VER_ON_ARRAY)
						{
							handleArrN2 = handleArrN;
							handleArrN = g.speedFact.n_array();
							recoverArray.push(handleArrN);
							//产生新的handleArrN
							for (o in s.a) 
							{
								vars = handleArrN2[s.a[o]];
								if (vars)
								{
									handleArrN[o] = vars;
									delete handleArrN2[s.a[o]];
									if (vars is Array)
									{
										layerDo.push(vars);
									}
								}
							}
							if (handleArrN2.length)
							{
								handleArrN[s.l] = handleArrN2;
								layerDo.push(handleArrN2);
								handleArrN2 = null;
							}
						}
						handleArrS.length = 0;
						/** 记录排序 **/
						layer[key] = handleArrN;
						dictS[handleArrN] = s.o;
					}
					else
					{
						//不变
						layer[key] = handleArrS;
					}
				}
				layerRun = layerDo;
			}
			var out:Array;
			if (changeA)
			{
				out = a;
				out.length = 0;
			}
			else
			{
				out = g.speedFact.n_array();
			}
			getSortInArray(out, aTemp);
			dict = null;
			dictS = null;
			vars = null;
			handleArrS = null;
			handleArrN = null;
			layerDo = null;
			layerTemp = null;
			layer = null;
			layerRun = null;
			shiningLib = null;
			mothodLib = null;
			pao = null;
			aTemp.length = 0;
			copy = null;
			for each (o in recoverArray) 
			{
				g.speedFact.d_array(o);
			}
			recoverArray.length = 0;
			o = null;
			return out;
		}
		
		private static function getSortInArray(input:Array, output:Array):void
		{
			var a:Array = g.speedFact.n_array();
			recoverArray.push(a);
			//需要实现边界剧中偏移的排序算法~~~
			/*
			var isOk:Boolean = false;
			var aLength:uint = 0;
			//左边界
			var left:uint = 0;
			//右边界
			var right:uint = 0;
			*/
			for (key in output) 
			{
				/*
				while (isOk)
				{
					aLength = a.length;
					if (aLength == 0)
					{
						a.push(key);
						break;
					}
					else if (aLength == 1)
					{
						if (a[0] > key)
						{
							a.unshift(key);
						}
						else
						{
							a.push(key);
						}
						break;
					}
					else
					{
						//找左边界
						//找右边界
						
						
						//找中间位置
						//拆分边界
						//选新边界
						
						//反复找中间位置
						
						var left:uint = aLength / 2;
						//查找插入的位置
					}
				}
				*/
				a.push(key);
			}
			if(a.length < 3)
			{
				if(a[0] == "false" || a[0] == "true")
				{
				}
				else
				{
					a.sort(Array.NUMERIC);
				}
			}
			else
			{
				a.sort(Array.NUMERIC);
			}
			//是否翻转
			if (dictS[output] == false)
			{
				a.reverse();
			}
			for each (key in a) 
			{
				o = output[key];
				if (o is Array)
				{
					if (o.length == 1)
					{
						o = o[0];
						if (o is Array)
						{
							getSortInArray(input, o);
						}
						else
						{
							input.push(o);
						}
					}
					else
					{
						getSortInArray(input, o);
					}
				}
				else
				{
					input.push(o);
				}
			}
		}
		
		/**
		 * 添加一个对比数据,只是和Obejct内的某一项数据做对比
		 * @param	p				属性名称(如果有点.会自动被拆开)
		 * @param	defaultVer		没有的时候默认属性值
		 * @param	sortType		排序的规则
		 * @param	order			是正序,排列么
		 * @param	addVer			为每种特殊类型,添加的对比类型
		 * @return
		 */
		public static function getSortItem_p(p:String, defaultVer:*,sortType:String, order:Boolean = true, addVer:* = null):Object
		{
			var o:Object = new Object();
			o.t = 1;
			if (p.indexOf(".") == -1)
			{
				o.p = p;
				o.pl = 1;
			}
			else
			{
				o.p = p.split(".");
				o.pl = o.p.length;
			}
			o.d = defaultVer;
			o.a = addVer;
			o.s = sortType;
			o.o = order;
			if (sortType == SORT_VER_ON_ARRAY || sortType == SORT_REVERSE_VER_ON_ARRAY || sortType == SORT_VER_DEL_ARRAY)
			{
				o.l = addVer.length;
			}
			return o;
		}
		
		/**
		 * 找到这个映射对象的Object的某一个属性p,如果没有使用defaultVer,按照small_to_big去排序
		 * @param	shiningName
		 * @param	p
		 * @param	defaultVer
		 * @param	sortType		排序的规则
		 * @param	order			是正序,排列么
		 * @param	addVer			为每种特殊类型,添加的对比类型
		 * @return
		 */
		public static function getSortItem_shining(shiningName:String, p:String, defaultVer:*, sortType:String, order:Boolean = true, addVer:* = null):Object
		{
			var o:Object = new Object();
			o.t = 2;
			o.n = shiningName;
			if (p.indexOf(".") == -1)
			{
				o.p = p;
				o.pl = 1;
			}
			else
			{
				o.p = p.split(".");
				o.pl = o.p.length;
			}
			o.d = defaultVer;
			o.s = sortType;
			o.o = order;
			if (sortType == SORT_VER_ON_ARRAY || sortType == SORT_REVERSE_VER_ON_ARRAY || sortType == SORT_VER_DEL_ARRAY)
			{
				o.a = addVer;
				o.l = addVer.length;
			}
			return o;
		}
		
		public static function getSortItem_function(functionName:String, sortType:String, order:Boolean = true):Object
		{
			var o:Object = new Object();
			o.t = 3;
			o.n = functionName;
			o.s = sortType;
			o.o = order;
			return o;
		}
		
		/**
		 * 获取一个本Object的某值咋另一个Array对象里的某一个Object对象的映射,根据parent_p的default_parent值,在另一个Array的属性this_p的映射
		 * @param	shiningName			这个映射的别名
		 * @param	allData_ArrayLib	从框架ArrayLib里找这个映射
		 * @param	parent_p			Object的属性
		 * @param	default_parent		Object里的默认值
		 * @param	this_p				Array的Object里的值
		 * @return
		 */
		public static function getSortShining(shiningName:String, allData_ArrayLib:*, parent_p:String, default_parent:*, this_p:String):Object
		{
			var o:Object = new Object();
			o.n = shiningName;
			o.o = allData_ArrayLib;
			o.p_p = parent_p;
			o.p_d = default_parent;
			o.t_p = this_p;
			o.l = new Dictionary();
			return o;
		}
		
		/**
		 * 获取一个函数的排序计算值
		 * @param	functionName	函数排序的名称
		 * @param	method			计算的时候的调用方法,返回值要求是Number
		 * @param	args			[不允许套嵌函数]需要传入的值类型,比如[type:"this", info:null](把处理对象带出来), [type:"shining", info:shiningName](把映射对象带出来), [type:"function", info:functionName](把其他函数处理对象值带出来)
		 * @return
		 */
		public static function getSortFunction(functionName:String, method:Function, args:Array):Object
		{
			var o:Object = new Object();
			o.n = functionName;
			o.o = method;
			o.a = args;
			o.l = new Dictionary();
			return o;
		}
	}
}