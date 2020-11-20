package cn.wjj.display.ui2d.engine
{
	import cn.wjj.display.ui2d.info.U2InfoBaseFrame;
	import cn.wjj.display.ui2d.info.U2InfoBaseFrameBitmap;
	import cn.wjj.display.ui2d.info.U2InfoBaseFrameDisplay;
	import cn.wjj.display.ui2d.info.U2InfoBaseInfo;
	import cn.wjj.display.ui2d.info.U2InfoBaseLayer;
	import cn.wjj.display.ui2d.info.U2InfoBitmap;
	import cn.wjj.display.ui2d.info.U2InfoType;
	import cn.wjj.display.ui2d.U2Bitmap;
	import cn.wjj.display.ui2d.U2Timer;
	import cn.wjj.g;
	import flash.utils.Dictionary;
	
	/**
	 * 通过数据来操作BitmapMovie
	 * @author GaGa
	 */
	public class EngineBitmap
	{
		
		/** 临时Boolean **/
		private static var __b:Boolean;
		
		public function EngineBitmap() { }
		
		/**
		 * 对本对象及子对象数据进行设置
		 * @param	display		显示对象
		 * @param	o			信息
		 */
		public static function init(display:U2Bitmap, o:U2InfoBaseInfo, cache:Dictionary = null):void
		{
			var lib:Vector.<U2InfoBaseLayer> = o.layer.lib;
			var layer:U2InfoBaseLayer = o.layer.lib[0];
			//删除全部的图形
			if (display._timer)
			{
				__b = display._timer._playThis;
				display._timer.dispose();
				display._timer = null;
			}
			else
			{
				__b = false;
			}
			U2Bitmap.clear(display);
			display.data = o;
			if (layer.isPlay)
			{
				var timer:U2Timer;
				if (display._timer)
				{
					timer = display._timer;
					display._timer = null;
					timer.dispose();
				}
				timer = U2Timer.instance();
				display._timer = timer;
				if (__b)
				{
					timer._playThis = true;
				}
				timer.display = display;
				timer.layer = layer;
				if (cache)
				{
					timer.cache = cache;
				}
				if (o.eventLib.eventLength)
				{
					timer.eventBase = o;
				}
			}
			else if(layer.lib.length > 0)
			{
				useLayerFrame(display, layer, 0, cache);
			}
			else
			{
				//空的上面已经处理
				U2Bitmap.clear(display);
			}
		}
		
		/** 使用图层信息,设置帧信息 **/
		private static function useLayerFrame(display:U2Bitmap, layer:U2InfoBaseLayer, frameId:int = 0, cache:Dictionary = null):void
		{
			var frame:U2InfoBaseFrame = layer.getIdFrame(frameId);
			if (frame.type == U2InfoType.baseFrameBitmap)
			{
				useFrameBitmap(display, frame as U2InfoBaseFrameBitmap, cache);
			}
			else if (frame.type == U2InfoType.baseFrameDisplay)
			{
				useFrameDisplay(display, frame as U2InfoBaseFrameDisplay, cache);
			}
		}
		
		/** 处理帧数据 **/
		public static function useFrameBitmap(display:U2Bitmap, frame:U2InfoBaseFrameBitmap, cache:Dictionary = null):void
		{
			if (frame)
			{
				useInfo(display, frame.display, cache);
			}
			else
			{
				U2Bitmap.clear(display);
			}
		}
		
		/** 对 U2Bitmap 使用帧信息 **/
		public static function useFrameDisplay(display:U2Bitmap, frame:U2InfoBaseFrameDisplay, cache:Dictionary = null):void
		{
			if (frame)
			{
				if (frame.display.pathType != 0)
				{
					var path:String = frame.display.path;
					//这个里是u2的文件连接,就直接使用里面的内容
					if (frame.display.pathType == 1)
					{
						EngineInfo.openForDisplay(display, frame.parent.gfile, path, true, -1, -1, cache);
					}
					else
					{
						usePath(display, frame.parent.gfile, path, cache);
					}
				}
				else
				{
					U2Bitmap.clear(display);
				}
				EngineDisplay.useDisplayInfo(display, frame.display);
			}
			else
			{
				U2Bitmap.clear(display);
			}
		}
		
		/**
		 * 设置BimtapMovie的每一幀
		 * @param	display
		 * @param	o
		 */
		public static function useInfo(display:U2Bitmap, o:U2InfoBitmap, cache:Dictionary = null):void
		{
			if (o && o.path)
			{
				if (g.u2.u2UseDefGFile)
				{
					g.dfile.bitmapX(o.path, true, display, cache);
				}
				else
				{
					g.gfile.bitmapX(o.parent.gfile, o.path, true, display, cache);
				}
				display.setOffsetInfo(o.offsetX, o.offsetY, o.offsetAlpha, o.offsetRotation, o.offsetScaleX, o.offsetScaleY);
			}
			else
			{
				U2Bitmap.clear(display);
			}
		}
		
		/** 根据BitmapData自动设置 Empty **/
		public static function autoEmpty(display:U2Bitmap):void
		{
			if (display.bitmapData)
			{
				if (display.isEmpty) display.isEmpty = false;
			}
			else if (display.isEmpty == false)
			{
				display.isEmpty = true;
			}
		}
		
		/** 使用GFile路径来设置位图地址 **/
		public static function usePath(display:U2Bitmap, gfile:*, path:String, cache:Dictionary = null):void
		{
			if (g.u2.u2UseDefGFile)
			{
				g.dfile.bitmapX(path, true, display, cache);
			}
			else
			{
				g.gfile.bitmapX(gfile, path, true, display, cache);
			}
			display.setOffsetInfo(0, 0, 1, 0, 1, 1);
		}
		
		/** 对容器进行滞空 **/
		public static function clear(display:U2Bitmap):void
		{
			U2Bitmap.clear(display);
		}
	}
}