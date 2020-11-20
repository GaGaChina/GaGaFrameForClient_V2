package cn.wjj.display.grid9
{
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.speedfact.SByte;
	
	/**
	 * 对Sprite进行操作
	 * @author GaGa
	 */
	public class Grid9Engine 
	{
		
		public function Grid9Engine() { }
		
		/**
		 * 如果小于最小宽度,将缩放
		 * 如果大于最小高度,也将缩放
		 * @param	o			九宫格数据
		 * @param	w			九宫格的宽度
		 * @param	h			九宫格的高度
		 * @param	refresh		当宽度高度是一样的时候,是否执行强制刷新尺寸
		 * @return
		 */
		public static function create(o:Grid9Info, w:uint, h:uint, sx:Number = 1, sy:Number = 1, refresh:Boolean = false):Grid9Sprite
		{
			var d:Grid9Sprite = Grid9Sprite.instance();
			d.setSize(w, h, sx, sy, refresh);
			return d;
		}
		
		/**
		 * 通过二进制数据,创建九宫格对象
		 * @param	byte
		 * @param	gfile
		 * @param	w			九宫格的宽度
		 * @param	h			九宫格的高度
		 * @param	refresh		当宽度高度是一样的时候,是否执行强制刷新尺寸
		 * @return
		 */
		public static function open(byte:SByte, gfile:*, w:uint, h:uint, sx:Number = 1, sy:Number = 1, refresh:Boolean = false):Grid9Sprite
		{
			var o:Grid9Info = openByte(byte, gfile);
			if (o)
			{
				return create(o, w, h, sx, sy, refresh);
			}
			return null;
		}
		
		/**
		 * 获取一个数据的内容
		 * @param	byte
		 * @param	gfile
		 * @return
		 */
		public static function openByte(byte:SByte, gfile:* = null):Grid9Info
		{
			var o:Grid9Info = new Grid9Info();
			o.setByte(byte);
			if (gfile) o.gfile = gfile;
			return o;
		}
		
		/** 让一个显示对象使用某一个数据,子对象等 **/
		public static function openForDisplay(d:Grid9Sprite, gfile:*, path:String, w:uint, h:uint, sx:Number = 1, sy:Number = 1, refresh:Boolean = false):void
		{
			var o:Grid9Info;
			if (path != "") o = openGFilePath(gfile, path);
			if (o)
			{
				Grid9EngineSprite.init(d, o, w, h, sx, sy, refresh);
			}
			else if(d)
			{
				Grid9Sprite.clear(d);
			}
		}
		
		/**
		 * 打开GFile文件里二进制,并获取数据对象
		 * @param	gfile
		 * @param	path
		 * @return
		 */
		public static function openGFilePath(gfile:*, path:String):Grid9Info
		{
			if(path)
			{
				var out:*;
				if (g.grid9.gridUseDefGFile)
				{
					out = g.dfile.getPathObj(path);
				}
				else
				{
					out = g.gfile.getPathObj(gfile, path);
				}
				if (out is Grid9Info)
				{
					return out;
				}
				else if(out is SByte)
				{
					out.position = 0;
					var o:Grid9Info = new Grid9Info();
					o.gfile = gfile;
					o.setByte(out);
					return o;
				}
			}
			return null;
		}
	}
}