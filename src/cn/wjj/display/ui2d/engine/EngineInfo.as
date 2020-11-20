package cn.wjj.display.ui2d.engine
{
	import cn.wjj.display.ui2d.info.U2InfoBaseFrame;
	import cn.wjj.display.ui2d.info.U2InfoBaseFrameBitmap;
	import cn.wjj.display.ui2d.info.U2InfoBaseFrameDisplay;
	import cn.wjj.display.ui2d.info.U2InfoBaseInfo;
	import cn.wjj.display.ui2d.IU2Base;
	import cn.wjj.display.ui2d.U2Bitmap;
	import cn.wjj.display.ui2d.U2Sprite;
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	import cn.wjj.gagaframe.client.speedfact.SByte;
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	
	/**
	 * 处理信息的入口
	 * @author GaGa
	 */
	public class EngineInfo 
	{
		public function EngineInfo() {}
		
		/**
		 * 通过U2InfoBaseInfo创建界面,带入时间全为修正时间(不可能叠加),并且全部不启用speed控制
		 * @param	o				U2数据
		 * @param	selfEngine		是否自己驱动
		 * @param	core			核心时间
		 * @param	start			开始运行时间
		 * @param	cache			是否启动缓存
		 * @param	isFactory		创建的显示对象是否属于对象池对象
		 * @return
		 */
		public static function create(o:U2InfoBaseInfo, selfEngine:Boolean = true, core:int = -1, start:int = -1, cache:Dictionary = null, isFactory:Boolean = false):DisplayObject
		{
			// 获取需要被绘制的操作容器
			var d:DisplayObject = getTypeDisplay(o.dType, isFactory);
			EngineLayer.useInfo(d, o, selfEngine, core, start, true, cache);
			(d as IU2Base).setPlay(true, core);
			return d;
		}
		
		/**
		 * 通过二进制数据,创建U2对象
		 * @param	byte			U2的二进制
		 * @param	gfile			U2中的内容所使用的GFile
		 * @param	selfEngine		是否自己驱动
		 * @param	core			核心时间
		 * @param	start			开始运行时间
		 * @param	cache			是否启动缓存
		 * @param	isFactory		创建的显示对象是否属于对象池对象
		 * @return
		 */
		public static function open(byte:SByte, gfile:*, selfEngine:Boolean = true, core:int = -1, start:int = -1, cache:Dictionary = null, isFactory:Boolean = false):DisplayObject
		{
			var o:U2InfoBaseInfo = openByte(byte, gfile);
			return create(o, selfEngine, core, start, cache, isFactory);
		}
		
		/**
		 * 获取一个数据的内容
		 * @param	byte
		 * @param	gfile
		 * @return
		 */
		public static function openByte(byte:SByte, gfile:* = null):U2InfoBaseInfo
		{
			var o:U2InfoBaseInfo = new U2InfoBaseInfo(null);
			o.setByte(byte);
			if (gfile) o.gfile = gfile;
			return o;
		}
		
		/** 让一个显示对象使用某一个数据,子对象等 **/
		public static function openForDisplay(display:DisplayObject, gfile:*, path:String, selfEngine:Boolean = true, core:int = -1, start:int = -1, cache:Dictionary = null):void
		{
			var o:U2InfoBaseInfo;
			if (path != "") o = openGFilePath(gfile, path);
			if (o)
			{
				if(isTypeDisplay(display, o.dType))
				{
					EngineLayer.useInfo(display, o, selfEngine, core, start, true, cache);
					(display as Object).path = path;
				}
				else
				{
					g.log.pushLog(EngineInfo, LogType._ErrorLog, "产生类型错误 : " + o.filePath);
				}
			}
			else if(display)
			{
				if(display is U2Sprite)
				{
					EngineSprite.clear(display as U2Sprite);
				}
				else if(display is U2Bitmap)
				{
					EngineBitmap.clear(display as U2Bitmap);
				}
			}
		}
		
		/**
		 * 打开GFile文件里二进制,并获取数据对象
		 * @param	gfile
		 * @param	path
		 * @return
		 */
		public static function openGFilePath(gfile:*, path:String):U2InfoBaseInfo
		{
			if(path)
			{
				var out:*;
				if (g.u2.u2UseDefGFile)
				{
					out = g.dfile.getPathObj(path);
				}
				else
				{
					out = g.gfile.getPathObj(gfile, path);
				}
				if (out is U2InfoBaseInfo)
				{
					return out;
				}
				else if(out is SByte)
				{
					var byte:SByte = out;
					byte.position = 0;
					var o:U2InfoBaseInfo = new U2InfoBaseInfo(null);
					o.gfile = gfile;
					o.setByte(byte);
					return o;
				}
			}
			return null;
		}
		
		/** 通过 U2InfoBaseInfo 的类型, 或 图层的类型 获取显示对象 **/
		public static function getTypeDisplay(type:int, isFactory:Boolean = false):DisplayObject
		{
			switch (type) 
			{
				case 0://  容器 多层 U2Sprite
				case 5://  容器 多层 U2SpriteMovie
					return U2Sprite.instance(isFactory);
				case 1://非容器 单层 U2Bitmap
				case 3://非容器 单层 U2BitmapMovie
					return U2Bitmap.instance(null, "auto", false, isFactory);
				//case 2://非容器 单层 U2Shape
				//case 4://非容器 单层 U2ShapeMovie
			}
			return null;
		}
		
		/** 检测显示对象和数据类型是否匹配 **/
		public static function isTypeDisplay(display:DisplayObject, type:int):Boolean
		{
			switch (type) 
			{
				case 0://  容器 多层 U2Sprite
				case 5://  容器 多层 U2SpriteMovie
					return display is U2Sprite;
				case 1://非容器 单层 U2Bitmap
				case 3://非容器 单层 U2BitmapMovie
					return display is U2Bitmap;
				//case 2://非容器 单层 U2Shape
				//case 4://非容器 单层 U2ShapeMovie
			}
			return false;
		}
		
		/** 查看帧类型是否和图层类型相符 **/
		public static function isTypeFrame(o:U2InfoBaseFrame, type:int):Boolean
		{
			switch (type) 
			{
				case 0://  容器 多层 U2Sprite
				case 5://  容器 多层 U2SpriteMovie
					return o is U2InfoBaseFrameDisplay;
				case 1://非容器 单层 U2Bitmap
				case 3://非容器 单层 U2BitmapMovie
					return o is U2InfoBaseFrameBitmap;
				//case 2://非容器 单层 U2Shape
				//case 4://非容器 单层 U2ShapeMovie
			}
			return false;
		}
	}
}