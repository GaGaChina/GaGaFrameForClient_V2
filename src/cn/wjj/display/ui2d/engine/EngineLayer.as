package cn.wjj.display.ui2d.engine
{
	import cn.wjj.display.ui2d.info.U2InfoBaseFrame;
	import cn.wjj.display.ui2d.info.U2InfoBaseFrameBitmap;
	import cn.wjj.display.ui2d.info.U2InfoBaseFrameDisplay;
	import cn.wjj.display.ui2d.info.U2InfoBaseInfo;
	import cn.wjj.display.ui2d.info.U2InfoBaseLayer;
	import cn.wjj.display.ui2d.info.U2InfoBaseLayerLib;
	import cn.wjj.display.ui2d.info.U2InfoType;
	import cn.wjj.display.ui2d.U2Bitmap;
	import cn.wjj.display.ui2d.U2Sprite;
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	
	/**
	 * 对层操作的时候执行
	 * 
	 * 当一个u2是Sprite,但是这个u2突然换了个格式为Bitmap将导致图层混乱
	 * 所以,不如直接混搭图层格式,只是对Bitmap的格式进行严格显示,要进行判断
	 * 
	 * @author GaGa
	 */
	public class EngineLayer 
	{
		
		public function EngineLayer() { }
		
		/** 对 显示对象应用其 U2InfoBaseInfo 数据层级排序 **/
		public static function displayIndex(display:DisplayObject, o:U2InfoBaseInfo):void
		{
			var s:Sprite;//不管开发还是不开发,只有Sprite需要排序
			switch (o.dType)
			{
				case 0://  容器 多层 Sprite
				case 5://  容器 多层 SpriteMovie
					s = display as Sprite;
					break;
				case 1://非容器 单层 Bitmap
				case 2://非容器 单层 Shape
				case 3://非容器 单层 BitmapMovie
				case 4://非容器 单层 ShapeMovie
					//不用动
					return;
					break;
				default:
			}
			if (s)
			{
				var lib:Vector.<U2InfoBaseLayer> = o.layer.lib;
				if (lib.length > 1)
				{
					var d:DisplayObject;
					for each (var item:U2InfoBaseLayer in lib) 
					{
						d = s.getChildByName(item.name);
						s.addChild(d);
					}
				}
			}
		}
		
		/**
		 * 处理一手数据,来绘制本场景,默认会绘制第一层
		 * @param	display
		 * @param	o
		 * @param	selfEngine
		 * @param	core
		 * @param	start
		 * @param	init			是否需要初始化数据(如果显示对象数据和容器数据不同也将初始化)
		 */
		public static function useInfo(display:DisplayObject, o:U2InfoBaseInfo, selfEngine:Boolean = true, core:int = -1, start:int = -1, init:Boolean = false, cache:Dictionary = null):void
		{
			switch (o.dType) 
			{
				case 0://  容器 多层 单帧 U2Sprite
				case 5://  容器 多层 多帧 U2SpriteMovie
					var u2Sprite:U2Sprite = display as U2Sprite;
					if (init || u2Sprite._data != o)
					{
						EngineSprite.init(u2Sprite, o, cache);
					}
					if(u2Sprite.timer)
					{
						u2Sprite.timer.selfEngine = selfEngine;
						u2Sprite.timer.timeCore(core, start, true, false);
					}
					break;
				case 1://非容器 单层 单帧 U2Bitmap
				case 3://非容器 单层 多帧 U2BitmapMovie
					var u2Bitmap:U2Bitmap = display as U2Bitmap;
					if (init || u2Bitmap.data != o)
					{
						EngineBitmap.init(u2Bitmap, o, cache);
					}
					if (u2Bitmap._timer)
					{
						u2Bitmap._timer.selfEngine = selfEngine;
						u2Bitmap._timer.timeCore(core, start, true, false);
					}
					break;
				case 2://非容器 单层 单帧 U2Shape
				case 4://非容器 单层 多帧 U2ShapeMovie
					//EngineShape.useFrameShape(display as U2Shape, o.layer.getIdLayer(0).getIdFrame(0) as U2InfoBaseFrameShape);
					g.log.pushLog(EngineLayer, LogType._ErrorLog, "没有对Shape进行处理");
					break;
			}
		}
		
		
		/**
		 * 自动获取并设置配置,u2Line,isPlay,isPlayThis,isPlayChild
		 * 
		 * @param	layer
		 */
		public static function autoConfig(layer:U2InfoBaseLayer):void
		{
			if (layer.pathLine == false)
			{
				layer.pathLine = true;
			}
			if (layer.isPlayChild)
			{
				layer.isPlayChild = false;
			}
			//本层是否可以播放
			if (layer.length > 1)
			{
				if (layer.isPlay == false)
				{
					layer.isPlay = true;
				}
				if (layer.isPlayThis == false)
				{
					layer.isPlayThis = true;
				}
			}
			else
			{
				if (layer.isPlay)
				{
					layer.isPlay = false;
				}
				if (layer.isPlayThis)
				{
					layer.isPlayThis = false;
				}
			}
			if (layer.length)
			{
				var frame:U2InfoBaseFrame;
				var frameDisplay:U2InfoBaseFrameDisplay;
				var frameBitmap:U2InfoBaseFrameBitmap;
				var path:String;
				var pathTemp:String;
				for (var i:int = 0; i < layer.length; i++) 
				{
					path = "";
					frame = layer.lib[i];
					if (frame.type == U2InfoType.baseFrameDisplay)
					{
						frameDisplay = frame as U2InfoBaseFrameDisplay;
						path = frameDisplay.display.path;
						frameDisplay.display.pathType = EnginePathType.getPathType(path);
						if (layer.isPlayChild == false && frameDisplay.display.pathType == 1)
						{
							if (layer.isPlay == false) layer.isPlay = true;
							layer.isPlayChild = true;
						}
					}
					else if (frame.type == U2InfoType.baseFrameBitmap)
					{
						frameBitmap = frame as U2InfoBaseFrameBitmap;
						path = frameBitmap.display.path;
						frameBitmap.display.pathType = EnginePathType.getPathType(path);
					}
					if (i == 0 && path != "")
					{
						pathTemp = path;
					}
					else if(pathTemp != path || path == "")
					{
						if (layer.pathLine) layer.pathLine = false;
					}
				}
			}
		}
		
		/**
		 * 自动获取并设置配置,isPlay,isPlayThis,isPlayChild
		 * 
		 * @param	lib
		 */
		public static function autoConfigLib(info:U2InfoBaseInfo):void
		{
			var lib:U2InfoBaseLayerLib = info.layer;
			if (lib.isPlay)
			{
				lib.isPlay = false;
			}
			if (lib.isPlayThis)
			{
				lib.isPlayThis = false;
			}
			if (lib.isPlayChild)
			{
				lib.isPlayChild = false;
			}
			if (lib.length)
			{
				for each (var layer:U2InfoBaseLayer in lib.lib) 
				{
					autoConfig(layer);
					if (layer.isPlayThis)
					{
						if (lib.isPlay == false)
						{
							lib.isPlay = true;
						}
						if (lib.isPlayThis == false)
						{
							lib.isPlayThis = true;
						}
					}
					if (layer.isPlayChild)
					{
						if (lib.isPlay == false)
						{
							lib.isPlay = true;
						}
						if (lib.isPlayChild == false)
						{
							lib.isPlayChild = true;
						}
					}
				}
			}
			if (info.eventLib.eventLength)
			{
				if (lib.isPlay == false)
				{
					lib.isPlay = true;
				}
				if (lib.isPlayThis == false)
				{
					lib.isPlayThis = true;
				}
			}
		}
	}
}