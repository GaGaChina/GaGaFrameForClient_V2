package cn.wjj.gagaframe.client.log 
{
	import cn.wjj.display.speed.BitmapDataItem;
	import cn.wjj.display.speed.GetBitmapData;
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.speedfact.SBitmap;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	/**
	 * 日志台头的按钮
	 * @author GaGa
	 */
	public class FloatShowBt extends Sprite 
	{
		/** 鼠标触发的高度 **/
		private var mouseHeigth:int = 0;
		
		/** 锁定Lock的按钮 **/
		private var btLock:SBitmap;
		/** 自动刷新的按钮 **/
		private var btAuto:SBitmap;
		/** Stop的按钮 **/
		private var btStop:SBitmap;
		/** Copy的按钮 **/
		private var btCopy:SBitmap;
		/** 显示的按钮 **/
		private var btShow:SBitmap;
		/** 透明的按钮 **/
		private var btAlpha:SBitmap;
		/** 隐藏的按钮 **/
		private var btHide:SBitmap;
		/** 清除日志按钮 **/
		private var btClear:SBitmap;
		/** 向上的按钮 **/
		private var btPageDel:SBitmap;
		/** 向下的按钮 **/
		private var btPageAdd:SBitmap;
		
		/** 按钮的X左侧坐标 **/
		private var btXArray:Array = new Array();
		
		public function FloatShowBt() { }
		
		/**
		 * 设置文本
		 * @param	w		整个条宽度
		 * @param	size	字体大小
		 */
		internal function setSize(w:int, size:int):void
		{
			mouseHeigth = size + 8;
			this.graphics.clear();
			this.graphics.beginFill(0xFF0000, 0.4);
			this.graphics.drawRect(0, 0, w, mouseHeigth);
			this.graphics.endFill();
			
			var filter:GlowFilter = new GlowFilter(0xFFFFFF, 1, 2, 2, 10, 2, false, false);
			var format:TextFormat = new TextFormat(null, 14, 0x000000, null, null, null, null, null, null, 0, 0, null, null);
			var a:Array = new Array();
			a.push(filter);
			var tx:TextField = new TextField();
			format.size = size;
			tx.defaultTextFormat = format;
			tx.setTextFormat(format);
			tx.type = TextFieldType.DYNAMIC;
			tx.selectable = false;
			tx.mouseEnabled = false;
			tx.filters = a;
			tx.alpha = 1;
			tx.width = 300;
			tx.height = size + 4;
			
			btXArray.length = 0;
			addButton(tx, "btLock", "【LOG】");
			addButton(tx, "btAuto", "Auto");
			addButton(tx, "btStop", "Stop");
			addButton(tx, "btCopy", "Copy");
			addButton(tx, "btShow", "Show");
			addButton(tx, "btAlpha", "Alpha");
			addButton(tx, "btHide", "Hide");
			addButton(tx, "btClear", "Clear");
			addButton(tx, "btPageDel", "Page--");
			addButton(tx, "btPageAdd", "Page++");
			
			btAuto.y = 0;
			btStop.alpha = 0.5;
		}
		
		/** 添加一个按钮 **/
		private function addButton(tx:TextField, bt:String, str:String):void
		{
			tx.text = str;
			var b:BitmapDataItem = GetBitmapData.cacheBitmap(tx, true, 0x00000000, 1, true, "best", false);
			var fb:SBitmap;
			if (this[bt])
			{
				fb = this[bt];
				
			}
			else
			{
				fb = SBitmap.instance();
				this[bt] = fb;
			}
			fb.bitmapData = b.bitmapData;
			var startX:int;
			if (btXArray.length)
			{
				startX = btXArray[btXArray.length - 1];
			}
			else
			{
				startX = 0;
			}
			fb.x = startX + 3;
			fb.y = 3;
			btXArray.push(fb.width + fb.x + 3);
			this.addChild(fb);
		}
		
		/** 按钮点上 **/
		internal function mouseDo(sx:int, sy:int):Boolean
		{
			if (sy <= mouseHeigth)
			{
				var l:int = btXArray.length;
				var tempX:int;
				for (var i:int = 0; i < l; i++) 
				{
					tempX = btXArray[i];
					if (sx <= tempX)
					{
						var float:FloatShow = g.log.float;
						switch (i) 
						{
							case 0://LOG Button Lock
								break;
							case 1://Auto
								float.showAuto = true;
								btStop.y = 3;
								btStop.alpha = 0.5;
								btAuto.y = 0;
								btAuto.alpha = 1;
								float.pushAll(g.log.logInfo.lib);
								break;
							case 2://Stop
								showStop();
								float.pushAll(g.log.logInfo.lib);
								break;
							case 3://Copy
								var s:String = g.log.logInfo.toString();
								Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, s);
								break;
							case 4://Show
								if (float.barSprite.alpha != 1) float.barSprite.alpha = 1;
								if (float.contains(float.barSprite) == false)
								{
									float.addChild(float.barSprite);
								}
								break;
							case 5://Alpha
								if (float.barSprite.alpha != 0.5) float.barSprite.alpha = 0.5;
								if (float.contains(float.barSprite) == false)
								{
									float.addChild(float.barSprite);
								}
								break;
							case 6://Hide
								if (float.barSprite.parent)
								{
									float.barSprite.parent.removeChild(float.barSprite);
								}
								break;
							case 7://btClear
								g.log.logInfo.c(true);
								float.showAuto = true;
								btStop.y = 3;
								btStop.alpha = 0.5;
								btAuto.y = 0;
								btAuto.alpha = 1;
								float.pushAll(g.log.logInfo.lib);
								break;
							case 8://Page--
								showStop();
								float.changePage(false);
								break;
							case 9://Page++
								showStop();
								float.changePage(true);
								break;
							default:
						}
						return true;
					}
				}
			}
			return false;
		}
		
		private function showStop():void
		{
			g.log.float.showAuto = false;
			btStop.y = 0;
			btStop.alpha = 1;
			btAuto.y = 3;
			btAuto.alpha = 0.5;
		}
		
		/** 摧毁日志按钮 **/
		internal function dispose():void
		{
			this.graphics.clear();
			if (mouseHeigth != 0) mouseHeigth = 0;
			if (btLock)
			{
				btLock.dispose();
				btLock = null;
			}
			if (btAuto)
			{
				btAuto.dispose();
				btAuto = null;
			}
			if (btStop)
			{
				btStop.dispose();
				btStop = null;
			}
			if (btCopy)
			{
				btCopy.dispose();
				btCopy = null;
			}
			if (btShow)
			{
				btShow.dispose();
				btShow = null;
			}
			if (btAlpha)
			{
				btAlpha.dispose();
				btAlpha = null;
			}
			if (btHide)
			{
				btHide.dispose();
				btHide = null;
			}
			if (btPageDel)
			{
				btPageDel.dispose();
				btPageDel = null;
			}
			if (btPageAdd)
			{
				btPageAdd.dispose();
				btPageAdd = null;
			}
			btXArray.length = 0;
		}
	}
}