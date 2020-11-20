package cn.wjj.gagaframe.client.display
{
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	import cn.wjj.gagaframe.client.speedfact.SByte;
	import flash.display.DisplayObject;
	
	import cn.wjj.display.ui2d.engine.EngineInfo;
	import cn.wjj.display.ui2d.info.U2InfoBaseInfo;
	
	import cn.wjj.display.ui2d.engine.EngineBitmap;null is cn.wjj.display.ui2d.engine.EngineBitmap;
	import cn.wjj.display.ui2d.engine.EngineDisplay;null is cn.wjj.display.ui2d.engine.EngineDisplay;
	import cn.wjj.display.ui2d.engine.EngineLayer;null is cn.wjj.display.ui2d.engine.EngineLayer;
	import cn.wjj.display.ui2d.engine.EngineMovie;null is cn.wjj.display.ui2d.engine.EngineMovie;
	import cn.wjj.display.ui2d.engine.EngineSprite;null is cn.wjj.display.ui2d.engine.EngineSprite;
	import cn.wjj.display.ui2d.U2Event;null is cn.wjj.display.ui2d.U2Event;
	
	/**
	 * U2编辑器对象的控制模块
	 * 提供从GFile中直接获取对象
	 */
	public class U2Manage
	{
		
		/** U2的GFile是否从框架的DefaultGFile中去取得 **/
		public var u2UseDefGFile:Boolean = true;
		
		public function U2Manage(){}
		
		/**
		 * 从一个GFile对象中创建显示对象
		 * @param	gfile
		 * @param	path
		 * @param	selfEngine
		 * @param	core
		 * @param	start
		 * @return
		 */
		public function createPath(gfile:*, path:String, selfEngine:Boolean = true, core:int = -1, start:int = -1):DisplayObject
		{
			var o:U2InfoBaseInfo = openGFilePath(gfile, path);
			if (o) return EngineInfo.create(o, selfEngine, core, start);
			return null;
		}
		
		/** 通过U2InfoBaseInfo创建界面 **/
		public function create(o:U2InfoBaseInfo, selfEngine:Boolean = true, core:int = -1, start:int = -1):DisplayObject
		{
			return EngineInfo.create(o, selfEngine, core, start);
		}
		
		/** 打开GFile文件里二进制,并获取数据对象 **/
		public function openGFilePath(gfile:*, path:String):U2InfoBaseInfo
		{
			if (gfile && path)
			{
				var o:* = gfile.getPathObj(path);
				if (o)
				{
					if (o is U2InfoBaseInfo)
					{
						if (o.gfile == null)
						{
							o.gfile = gfile;
						}
						return o;
					}
					else if(o is SByte)
					{
						var byte:SByte = o as SByte;
						byte.position = 0;
						var u2:U2InfoBaseInfo = new U2InfoBaseInfo(null);
						u2.gfile = gfile;
						u2.setByte(byte);
						return u2;
					}
				}
				else
				{
					g.log.pushLog(this, LogType._ErrorLog, "GFile Error : " + path);
				}
			}
			return null;
		}
	}
}