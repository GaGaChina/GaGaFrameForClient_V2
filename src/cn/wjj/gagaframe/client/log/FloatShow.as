package cn.wjj.gagaframe.client.log 
{
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.speedfact.SBitmap;
	import cn.wjj.time.TimeToString;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * 浮动的日志显示框
	 * 从上向下排列,当下面到头后,内容向上跑,移出屏幕外的删除掉.
	 * 获取text文本,然后取得Bitmap,对text的长度进行限制,防止超出屏幕.
	 * 根据屏幕分辨率设置字体大小.
	 * 鼠标放操作上会显示类名, 点击复制,点击条目复制内容
	 * 背景加色块,时间一块,操作一块,内容一块
	 * 
	 * 块过多,CPU比较低,然后GM日志的尺寸也很重要,尺寸过大消耗大
	 * 
	 * 每条的高,字体高度+4,然后在+1是每条实际高,最终高是全高-1
	 * 条上的按钮高度,字体高度+2,然后上下各加3,是按钮的高
	 * 
	 * 
	 * 左边时间 | 类型  | 内容
	 * 
	 * 04:54:11.235  操作    内容范德萨佛挡杀佛范德萨发.......
	 * 04:54:11.235  操作    内容
	 *          325  操作    内容
	 *               操作    内容
	 * 04:54:11.235  操作    内容
	 * 04:54:11.235  操作    内容
	 *               操作    内容
	 * 
	 * list          list    list
	 * 
	 * @author GaGa
	 */
	internal class FloatShow extends Sprite 
	{
		/** 放条的容器 **/
		internal var barSprite:Sprite;
		/** 是否暂停滚动 **/
		internal var showAuto:Boolean = true;
		/** 获取文本Bitmap的条 **/
		private var bar:FloatShowBar;
		/** 单独显示在外面的条 **/
		private var showBar:FloatShowBar;
		/** 获取文本Bitmap的按钮 **/
		private var bt:FloatShowBt;
		/** 显示区域占主场景的宽度比例 **/
		private var scaleWidth:int = 100;
		/** 显示区域占主场景的高度比例 **/
		private var scaleHeight:int = 100;
		/** 显示区域的宽度 **/
		private var rWidth:uint = 0;
		/** 显示区域的高度 **/
		private var rHeight:uint = 0;
		
		/** 开始的ID **/
		private var startId:int = 0;
		/** 已经设置的Bitmap **/
		private var showBarList:Vector.<SBitmap>;
		/** 已经添加的文字的信息 **/
		private var showBarInfo:Vector.<Object>;
		/** 设置每个条上的字体大小 **/
		private var showBarTextSize:int = 24;
		/** 每页显示的条数 **/
		private var pageMax:int = 0;
		/** 现在显示的ID号 **/
		private var showLibId:int = 0;
		/** 内容开始的Y坐标 **/
		private var infoStartY:int = 0;
		/** 显示在外面的条的ID **/
		private var showBarId:int = 0;
		/** 单独显示的条 **/
		private var showBarBitmap:SBitmap;
		
		public function FloatShow() 
		{
			barSprite = new Sprite();
			barSprite.mouseChildren = false;
			barSprite.mouseEnabled = false;
			mouseEnabled = false;
			mouseChildren = false;
			bar = new FloatShowBar(1, 0.7, false);
			showBar = new FloatShowBar(1, 1, true);
			bt = new FloatShowBt();
			reSet();
			this.addChild(bt);
			showBarList = new Vector.<SBitmap>();
			showBarInfo = new Vector.<Object>();
			g.event.addFPSEnterFrame(1, reSetIndex, this);
			g.event.addListener(g.bridge.stage, Event.RESIZE, resize);
			g.event.addListener(g.bridge.stage, MouseEvent.MOUSE_DOWN, mouseDo);
			g.event.addListener(g.bridge.stage, MouseEvent.MOUSE_UP, mouseDo);
			reSetIndex();
		}
		
		private function resize(e:Event):void
		{
			reSet();
			pushAll(g.log.logInfo.lib);
			reSetIndex();
		}
		
		/**
		 * 显示区域占主场景的宽度比例
		 * @param	w	10 <= w <= 100
		 * @param	h	10 <= w <= 100
		 */
		internal function changeSize(w:uint, h:uint):void
		{
			if (w < 10)
			{
				w = 10;
			}
			else if (w > 100)
			{
				w = 100;
			}
			if (h < 10)
			{
				h = 10;
			}
			else if (h > 100)
			{
				h = 100;
			}
			if (w != scaleWidth || h != scaleHeight)
			{
				scaleWidth = w;
				scaleHeight = h;
				reSet();
			}
		}
		
		/** 重新设置条的信息 **/
		private function reSet():void
		{
			var w:int = g.bridge.stage.stageWidth;
			rWidth = int(w * scaleWidth / 100);
			rHeight = int(g.bridge.stage.stageHeight * scaleHeight / 100);
			if (w < (640 + 1))
			{
				showBarTextSize = 16;
			}
			else if (w < (768 + 1))
			{
				showBarTextSize = 18;
			}
			else if (w < (1024 + 1))
			{
				showBarTextSize = 20;
			}
			else if (w < (1280 + 1))
			{
				showBarTextSize = 24;
			}
			else if (w < (1480 + 1))
			{
				showBarTextSize = 28;
			}
			else if (w < (1536 + 1))
			{
				showBarTextSize = 32;
			}
			else if (w < (1600 + 1))
			{
				showBarTextSize = 36;
			}
			else
			{
				showBarTextSize = 48;
			}
			bar.setSize(rWidth, showBarTextSize);
			showBar.setSize(rWidth, showBarTextSize);
			bt.setSize(rWidth, showBarTextSize);
			infoStartY = showBarTextSize + 9;
			pageMax = int((rHeight - infoStartY) / (showBarTextSize + 5));
		}
		
		internal function pushAll(lib:Vector.<Object>):void
		{
			startId = 0;
			for each (var b:SBitmap in showBarList) 
			{
				b.dispose();
			}
			showBarInfo.length = 0;
			showBarList.length = 0;
			var o:Object;
			var length:int = lib.length;
			var i:int;
			if (length)
			{
				if (showAuto)
				{
					if (length >= pageMax)
					{
						//倒序
						i = length - pageMax;
						o = lib[i];
						startId = o.id;
						for (; i < length; i++)
						{
							o = lib[i];
							b = SBitmap.instance(bar.getBitmap(o));
							b.y = showBarInfo.length * (showBarTextSize + 5) + infoStartY;
							showBarInfo.push(o);
							showBarList.push(b);
							barSprite.addChild(b);
						}
					}
					else
					{
						//正序
						i = 0;
						o = lib[i];
						startId = o.id;
						for (; i < length; i++)
						{
							o = lib[i];
							b = SBitmap.instance(bar.getBitmap(o));
							b.y = showBarInfo.length * (showBarTextSize + 5) + infoStartY;
							showBarInfo.push(o);
							showBarList.push(b);
							barSprite.addChild(b);
						}
					}
				}
				else
				{
					//正序
					i = 0;
					o = lib[i];
					startId = o.id;
					for (; i < length; i++)
					{
						o = lib[i];
						b = SBitmap.instance(bar.getBitmap(o));
						b.y = showBarInfo.length * (showBarTextSize + 5) + infoStartY;
						showBarInfo.push(o);
						showBarList.push(b);
						barSprite.addChild(b);
					}
				}
			}
			if (showBarBitmap)
			{
				barSprite.addChild(showBarBitmap);
			}
		}
		
		/** 向后翻页 **/
		internal function changePage(add:Boolean):void
		{
			var lib:Vector.<Object> = g.log.logInfo.lib;
			var length:int = lib.length;
			if (length)
			{
				var id:int;
				var index:int;
				index = lib.indexOf(showBarInfo[0]);
				if (length > pageMax && index != -1 && showBarInfo[0].id == startId)
				{
					if (add)
					{
						index = index + pageMax;
						if ((index + pageMax) > length)
						{
							index = length - pageMax;
						}
						id = lib[index].id;
					}
					else
					{
						index = index - pageMax;
						if (index < 0)
						{
							index = 0;
						}
						id = lib[index].id;
					}
				}
				else
				{
					//从头开始
					index = 0;
					id = lib[0].id;
				}
				if (id != startId)
				{
					var o:Object;
					startId = id;
					for each (var b:SBitmap in showBarList) 
					{
						b.dispose();
					}
					showBarInfo.length = 0;
					showBarList.length = 0;
					if (length > index + pageMax)
					{
						length = index + pageMax;
					}
					for (; index < length; index++)
					{
						o = lib[index];
						b = SBitmap.instance(bar.getBitmap(o));
						b.y = showBarInfo.length * (showBarTextSize + 5) + infoStartY;
						showBarInfo.push(o);
						showBarList.push(b);
						barSprite.addChild(b);
					}
				}
			}
		}
		
		/**
		 * 这里不可能添加多条的情况出现
		 * @param	o
		 */
		internal function pushLog(o:Object):void
		{
			var b:SBitmap;
			var nowLength:int = showBarInfo.length;
			if ((o.id - startId) >= pageMax)
			{
				if (showAuto)
				{
					if (nowLength == pageMax)
					{
						//把内容都向上移动一位,然后把最新的数据丢进去
						startId++;
						nowLength--;
						for (var i:int = 0; i < nowLength; i++) 
						{
							showBarList[i].bitmapData = showBarList[i + 1].bitmapData;
							showBarInfo[i] = showBarInfo[i + 1];
						}
						showBarList[nowLength].bitmapData = bar.getBitmap(o);
						showBarInfo[nowLength] = o;
					}
					else
					{
						//未满,可以加到后面否
						showBarInfo.push(o);
						b = SBitmap.instance(bar.getBitmap(o));
						b.y = nowLength * (showBarTextSize + 5) + infoStartY;
						showBarList.push(b);
						barSprite.addChild(b);
					}
				}
				else
				{
					//如果不是满的,补全
					if (showBarInfo.length != pageMax)
					{
						showBarInfo.push(o);
						b = SBitmap.instance(bar.getBitmap(o));
						b.y = nowLength * (showBarTextSize + 5) + infoStartY;
						showBarList.push(b);
						barSprite.addChild(b);
					}
				}
			}
			else
			{
				//将最新的数据加到后面
				showBarInfo.push(o);
				b = SBitmap.instance(bar.getBitmap(o));
				b.y = nowLength * (showBarTextSize + 5) + infoStartY;
				showBarList.push(b);
				barSprite.addChild(b);
			}
			if (showBarBitmap)
			{
				barSprite.addChild(showBarBitmap);
			}
		}
		
		/** 重置层级,每秒一次 **/
		private function reSetIndex():void
		{
			var dc:DisplayObjectContainer = g.bridge.root as DisplayObjectContainer;
			if (dc.contains(this))
			{
				var index:int = dc.getChildIndex(this);
				if (index < dc.numChildren - 2)
				{
					dc.setChildIndex(this, dc.numChildren - 1);
				}
			}
			else
			{
				dc.addChild(this);
			}
		}
		
		/**
		 * 全局鼠标事件
		 * @param	e
		 */
		private function mouseDo(e:MouseEvent):void
		{
			switch (e.type) 
			{
				case MouseEvent.MOUSE_DOWN:
					if (bt.mouseDo(g.bridge.stage.mouseX, g.bridge.stage.mouseY) == false)
					{
						g.event.addEnterFrame(showInfoBar, this);
					}
					break;
				case MouseEvent.MOUSE_UP:
					g.event.removeEnterFrame(showInfoBar, this);
					if (showBarId)
					{
						showBarId = 0;
						showBarBitmap.dispose();
						showBarBitmap = null;
					}
					break;
			}
		}
		
		private function showInfoBar():void
		{
			if (this.contains(barSprite))
			{
				var mouseY:int = g.bridge.stage.mouseY;
				if (infoStartY <= mouseY && (pageMax * (showBarTextSize + 5) + infoStartY) >= mouseY)
				{
					var id:int = int((mouseY - infoStartY) / (showBarTextSize + 5));
					if (id < showBarInfo.length)
					{
						if (showBarId != (id + startId))
						{
							showBarId = (id + startId);
							var bitmapData:BitmapData = showBar.getBitmap(showBarInfo[id]);
							if (showBarBitmap == null) showBarBitmap = SBitmap.instance();
							showBarBitmap.bitmapData = bitmapData;
							var b:SBitmap = showBarList[id];
							showBarBitmap.x = b.x;
							showBarBitmap.y = b.y;
							if ((b.y + showBarBitmap.height) > rHeight)
							{
								showBarBitmap.y = rHeight - showBarBitmap.height;
							}
							Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, getString(showBarInfo[id]));
							this.addChild(showBarBitmap);
						}
						return;
					}
				}
			}
			else
			{
				g.event.removeEnterFrame(showInfoBar, this);
			}
			if (showBarId)
			{
				showBarId = 0;
				showBarBitmap.dispose();
				showBarBitmap = null;
			}
		}
		
		private function getString(o:Object):String
		{
			var s:String = "ID:" + o.id + "\n";
			s += "类型:" + g.logType.getTypeString(o.type) + "\n";
			s += "时间:" + TimeToString.NumberToChinaTime(o.time) + "\n";
			s += "对象:" + o.targetName + "\n";
			s += "程序:" + o.targetType + "\n";
			s += "内容:\n"
			s += o.info;
			return s;
		}
		
		/** 摧毁日志浮动框 **/
		internal function dispose():void
		{
			g.event.removeEnterFrame(showInfoBar, this);
			g.event.removeFPSEnterFrame(1, reSetIndex, this);
			g.event.removeListener(g.bridge.stage, Event.RESIZE, resize);
			g.event.removeListener(g.bridge.stage, MouseEvent.MOUSE_DOWN, mouseDo);
			g.event.removeListener(g.bridge.stage, MouseEvent.MOUSE_UP, mouseDo);
			if (showBarList)
			{
				for each (var b:SBitmap in showBarList) 
				{
					b.dispose();
				}
				showBarList.length = 0;
				showBarList = null;
			}
			if (showBarInfo)
			{
				showBarInfo.length = 0;
				showBarInfo = null;
			}
			if (showBarId)
			{
				showBarId = 0;
				showBarBitmap.dispose();
				showBarBitmap = null;
			}
			if (bt)
			{
				bt.dispose();
				bt = null;
			}
			if (barSprite)
			{
				barSprite.removeChildren();
				if (barSprite.parent)
				{
					barSprite.parent.removeChild(barSprite);
				}
				barSprite = null;
			}
			if (bar)
			{
				bar.dispose();
				bar = null;
			}
			if (showBar)
			{
				showBar.dispose();
				showBar = null;
			}
			this.removeChildren();
			if (this.parent)
			{
				this.parent.removeChild(this);
			}
		}
	}
}