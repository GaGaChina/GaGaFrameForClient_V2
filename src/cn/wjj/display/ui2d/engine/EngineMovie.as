package cn.wjj.display.ui2d.engine
{
	import cn.wjj.display.ui2d.info.U2InfoBaseFrame;
	import cn.wjj.display.ui2d.info.U2InfoBaseFrameBitmap;
	import cn.wjj.display.ui2d.info.U2InfoBaseFrameDisplay;
	import cn.wjj.display.ui2d.info.U2InfoBaseLayer;
	import cn.wjj.display.ui2d.info.U2InfoType;
	
	/**
	 * 处理动画信息
	 * 
	 * 
	 * @author GaGa
	 */
	public class EngineMovie 
	{
		
		/** 临时变量,字符串 **/
		private static var __s:String;
		/** 临时变量,字符串 **/
		private static var __s2:String;
		/** 临时变量,int **/
		private static var __i:int;
		/** 临时变量,int **/
		private static var __i2:int;
		/** 临时变量,int **/
		private static var __i3:int;
		/** 临时变量Number **/
		private static var __n:Number;
		
		public function EngineMovie() { }
		
		/**
		 * 从帧队列中找到,要播放的帧ID,从1开始的
		 * @param	scene
		 * @param	currentFrame	现在影片在播放那帧
		 * @param	layer			层信息
		 * @return
		 */
		public static function getFrameId(scene:*, currentFrame:int, layer:U2InfoBaseLayer):int
		{
			__i = 1;
			if (scene == null || scene == undefined)
			{
				return currentFrame;
			}
			else
			{
				__i = int(Number(scene));
				if (String(__i) != scene)//是否为名称帧
				{
					__i = 0;
					if (layer && layer.length)
					{
						var i:uint = 0;
						for each (var item:U2InfoBaseFrame in layer.lib) 
						{
							i++;
							if (item.label == scene)
							{
								return i;
							}
						}
					}
				}
				if (__i < 1)
				{
					__i = 1;
				}
			}
			return __i;
		}
		
		/**
		 * 在环境时间time 在图层中找到帧frame,相同路径,前面一直正常走需要走多少时间
		 * @param	layer
		 * @param	frame
		 * @param	time
		 * @return
		 */
		public static function getFrameUseTime(layer:U2InfoBaseLayer, frame:U2InfoBaseFrame, time:Number):int
		{
			var tempFrame:U2InfoBaseFrame;
			__n = time % layer.frequency;
			__i = layer.lib.indexOf(frame);
			__i2 = __i;
			//__s2 : 循环取帧里的路径
			//缓存帧里路径
			__s = "";
			if (frame.type ==  U2InfoType.baseFrameBitmap)
			{
				__s = (frame as U2InfoBaseFrameBitmap).display.path;
			}
			else if (frame.type ==  U2InfoType.baseFrameDisplay)
			{
				__s = (frame as U2InfoBaseFrameDisplay).display.path;
			}
			while (--__i > -1)
			{
				tempFrame = layer.lib[__i];
				if (tempFrame.type == frame.type)
				{
					__s2 = "";
					if (frame.type == U2InfoType.baseFrameBitmap)
					{
						__s2 = (tempFrame as U2InfoBaseFrameBitmap).display.path;
					}
					else if (frame.type == U2InfoType.baseFrameDisplay)
					{
						__s2 = (tempFrame as U2InfoBaseFrameDisplay).display.path;
					}
					if (__s2 != __s)
					{
						break;
					}
				}
				else
				{
					break;
				}
			}
			__i++;
			//frameLength 帧长度
			__i3 = 0;
			if (__i == 0)
			{
				__i3 = __i2 - __i
				if (time > layer.timeLength)
				{
					__i = layer.length - 1;
					while (--__i > -1)
					{
						tempFrame = layer.lib[__i];
						if (tempFrame.type == frame.type)
						{
							__s2 = "";
							if (frame.type == U2InfoType.baseFrameBitmap)
							{
								__s2 = (tempFrame as U2InfoBaseFrameBitmap).display.path;
							}
							else if (frame.type == U2InfoType.baseFrameDisplay)
							{
								__s2 = (tempFrame as U2InfoBaseFrameDisplay).display.path;
							}
							if (__s2 != __s)
							{
								break;
							}
						}
						else
						{
							break;
						}
					}
					__i++;
					__i3 = __i3 + layer.length - __i;
				}
			}
			else  if (__i > -1)
			{
				__i3 = __i2 - __i;
			}
			//使用floor是为了预防穿过最后一帧
			__n = Math.floor(__i3 * layer.frequency + __n);
			return __n;
		}
	}
}