package cn.wjj.display.filter 
{
	import cn.wjj.g;
	import flash.display.DisplayObject;
	import flash.geom.ColorTransform;
	import flash.utils.Dictionary;
	/**
	 * 颜色改变保持控制器
	 * 如果单独对象重复,颜色一样,就会叠加末尾的时间
	 * 如果单独对象重复,颜色不同,就会使用新的颜色
	 * 
	 * lib[DisplayObject] = new Object();
	 * 						length = 0			里面的数量
	 * 						time = array		结束的时间点
	 * 						end = vect			结束颜色
	 * 						trans = vect		使用 的颜色
	 * 
	 * @author GaGa
	 */
	public class ColorTransHold 
	{
		/** 对象 **/
		internal static var lib:Dictionary = new Dictionary(true);
		/** 现在里面对象的数量 **/
		internal static var length:int = 0;
		/** 是否在播放 **/
		private static var isPlay:Boolean = false;
		
		public function ColorTransHold() { }
		
		/**
		 * 
		 * @param	display
		 * @param	endTime
		 * @param	trans
		 * @param	end
		 */
		internal static function push(display:DisplayObject, endTime:Number, trans:ColorTransform, end:ColorTransform):void
		{
			var o:Object;
			if (lib[display])
			{
				o = lib[display];
				var v_time:Vector.<Number>;
				var v_trans:Vector.<ColorTransform>;
				var v_end:Vector.<ColorTransform>;
				if (o.length == 1)
				{
					//处理普通形式
					if (o.time > endTime)
					{
						v_time = new Vector.<Number>();
						v_trans = new Vector.<ColorTransform>();
						v_end = new Vector.<ColorTransform>();
						v_time.push(endTime);
						v_trans.push(trans);
						v_end.push(end);
						v_time.push(o.time);
						v_trans.push(o.trans);
						v_end.push(o.end);
						length++;
					}
					else
					{
						o.time = endTime;
						o.trans = trans;
						o.end = end;
					}
				}
				else
				{
					//处理数组形式
					v_time = o.time;
					v_trans = o.trans;
					v_end = o.end;
					//开始操作的位置,-1就是在前面添加,如果是0,就是修改第0个,如果是1,就是删除一个,并修改现在的第一位
					var d_start:int = -1;
					for each (var t:Number in v_time)
					{
						if (t > endTime)
						{
							d_start++;
						}
						else
						{
							break;
						}
					}
					if (d_start > 0)
					{
						v_time.splice(0, d_start);
						v_trans.splice(0, d_start);
						v_end.splice(0, d_start);
					}
					v_time[0] = endTime;
					v_trans[0] = trans;
					v_trans[0] = end;
					o.length = v_time.length;
				}
			}
			else
			{
				o = new Object();
				o.time = endTime;
				o.trans = trans;
				o.end = end;
				o.length = 1;
				lib[display] = o;
				length++;
			}
			display.transform.colorTransform = trans;
			start();
		}
		
		/** 获取结束时间点 **/
		internal static function endTime(display:DisplayObject):Number
		{
			if (lib[display])
			{
				var o:Object = lib[display];
				if (o.length == 1)
				{
					return o.time;
				}
				else
				{
					return o.time[o.length - 1];
				}
			}
			return 0;
		}
		
		/**
		 * 移除
		 * @param	display
		 * @param	useEnd
		 */
		public static function remove(display:DisplayObject, useEnd:Boolean = true):void
		{
			if (lib[display])
			{
				if (useEnd)
				{
					var o:Object = lib[display];
					if (o.length == 1)
					{
						display.transform.colorTransform = o.end;
					}
					else
					{
						display.transform.colorTransform = o.end[o.length - 1];
					}
				}
				delete lib[display];
				length--;
				if (length <= 0) stop();
			}
		}
		
		private static function start():void
		{
			if (isPlay == false)
			{
				isPlay = true;
				g.event.addEnterFrame(play);
			}
		}
		
		private static function stop():void
		{
			if (isPlay == true)
			{
				isPlay = false;
				g.event.removeEnterFrame(play);
			}
		}
		
		private static function play():void
		{
			var time:Number = new Date().time;
			var display:DisplayObject;
			var info:Object;
			length = 0;
			var i:int;
			var r:Boolean;
			for (var d:* in lib) 
			{
				display = d;
				info = lib[d];
				if (info.length == 1)
				{
					if (info.time > time)
					{
						length++;
					}
					else
					{
						display.transform.colorTransform = info.end;
						delete lib[d];
					}
				}
				else
				{
					r = false;
					i = -1;
					while (++i < info.length)
					{
						if (info.time[i] > time)
						{
							r = true;
							break;
						}
					}
					if (r == true)
					{
						if (i != 0)
						{
							//使用最新的
							display.transform.colorTransform = info.trans[i];
							//删除多余的
							info.length = info.length - i;
							if (info.length == 1)
							{
								info.time = info.time[i];
								info.trans = info.trans[i];
								info.end = info.end[i];
							}
							else
							{
								info.time.splice(0, i);
								info.trans.splice(0, i);
								info.end.splice(0, i);
							}
						}
						length++;
					}
					else
					{
						//删除全部
						display.transform.colorTransform = info.end[info.length - 1];
						delete lib[d];
					}
				}
			}
			if (length == 0) stop();
		}
	}

}