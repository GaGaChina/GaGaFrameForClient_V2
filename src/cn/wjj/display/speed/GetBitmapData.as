package cn.wjj.display.speed
{
	import cn.wjj.display.DisplaySearch;
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Transform;
	import flash.text.TextField;
	import flash.utils.getTimer;
	
	/**
	 * 获取BitmapData数据
	 * @author GaGa
	 * 
	 */
	public class GetBitmapData
	{
		static private var s:Matrix = new Matrix();
		static private var pot:Point = new Point();
		static private var tempB:Bitmap;
		
		/**
		 * 缓存位图动画
		 * @param	mc				要被绘制的影片剪辑
		 * @param	transparent		是否透明
		 * @param	fillColor		填充色
		 * @param	scale			绘制的缩放值
		 * @return
		 */
		static public function display(mc:DisplayObject, transparent:Boolean = true, fillColor:uint = 0x00000000, scale:Number = 1, directBitData:Boolean = true):BitmapMovieData
		{
			//BitmapMovieDataItem
			var bitData:BitmapMovieData = new BitmapMovieData();
			if (mc == null)
			{
				return null;
			}
			else
			{
				var thisStart:Number = getTimer();
				var i:int = 0;
				var c:int = 1;
				var m:MovieClip;
				if(mc is MovieClip)
				{
					m = mc as MovieClip;
					m.gotoAndStop(1);
					c = m.totalFrames;
					var mInfo:BitmapDataItem;
				}
				bitData.data = new Vector.<BitmapMovieDataFrameItem>(c, true);
				//如果前面一幀是Bitmap就记录它
				while (i < c)
				{
					bitData.data[i] = new BitmapMovieDataFrameItem();
					//获取一个数据对象
					if (m && tempB && m.numChildren == 1 && m.getChildAt(0) is Bitmap && tempB === m.getChildAt(0))
					{
						//和上一幀数据一样
						bitData.data[i].data = bitData.data[i - 1].data;
					}
					else
					{
						if (m && m.numChildren == 1 && m.getChildAt(0) is Bitmap)
						{
							tempB = m.getChildAt(0) as Bitmap;
							if(tempB.rotation != 0 || tempB.scaleX != 1 || tempB.scaleY != 1)
							{
								tempB = null;
							}
						}
						else
						{
							tempB = null;
						}
						if (directBitData && tempB && tempB.bitmapData)
						{
							mInfo = new BitmapDataItem();
							mInfo.x = tempB.x;
							mInfo.y = tempB.y;
							if(directBitData)
							{
								mInfo.bitmapData = tempB.bitmapData;
							}
							else
							{
								mInfo.bitmapData = BitmapDataLib.push(tempB.bitmapData);
							}
							bitData.data[i].data = mInfo;
						}
						else
						{
							bitData.data[i].data = cacheBitmap(mc, transparent, fillColor, scale);
						}
					}
					if (m)
					{
						bitData.data[i].label = m.currentLabel;
						bitData.data[i].frameLabel = m.currentFrameLabel;
					}
					//切过去的时候如果有新的MC就可以不用跳帧,防止错误的发生
					var otherMc:Array;
					if(mc is DisplayObjectContainer)
					{
						otherMc = DisplaySearch.searchMcFrame(mc as DisplayObjectContainer);
					}
					if(m)
					{
						m.nextFrame();
					}
					if(otherMc)
					{
						for each(var child:MovieClip in otherMc)
						{
							if(child.currentFrame == child.totalFrames)
							{
								child.gotoAndStop(1);
							}
							else
							{
								child.nextFrame();
							}
						}
					}
					i++;
				}
				g.log.pushLog(GetBitmapData, LogType._Frame, "GetBitmapData.display 耗时:" + String(getTimer() - thisStart));
			}
			return bitData;
		}
		
		
		/**
		 * 缓存一个显示对象的单张位图
		 * @param source			要被绘制的目标对象
		 * @param transparent		是否透明
		 * @param fillColor			填充色
		 * @param scale				绘制的缩放值
		 * @param smoothing			是否平滑
		 * @param quality			缓存品质
		 * @param pushLib			是否把BitmapDataItem缓存进Lib库方便调用
		 */
		static public function cacheBitmap(source:DisplayObject, transparent:Boolean = true, fillColor:uint = 0x00000000, scale:Number = 1, smoothing:Boolean = true, quality:String = "best", pushLib:Boolean = true):BitmapDataItem
		{
			var r:Rectangle = source.getBounds(source);
			var x:int = Math.floor(r.x * scale);
			var y:int = Math.floor(r.y * scale);
			if(source is TextField)
			{
				x = 0;
				y = 0;
			}
			//防止 "无效的 BitmapData"异常
			if (r.isEmpty())
			{
				r.width = 1;
				r.height = 1;
			}
			var width:int = Math.ceil(r.width * scale);
			var height:int = Math.ceil(r.height * scale);
			if (width > 8191) width = 8191;
			if (height > 8191) height = 8191;
			var b:BitmapData = new BitmapData(width, height, transparent, fillColor);
			s.setTo(scale, 0, 0, scale, -x, -y);
			b.drawWithQuality(source, s, null, null, null, smoothing, quality);
			//剔除边缘空白像素
			r = b.getColorBoundsRect(0xFF000000, 0x00000000, false);
			if (r.isEmpty() == false && (b.width != r.width || b.height != r.height))
			{
				width = r.width;
				height = r.height;
				if (width > 8191) width = 8191;
				if (height > 8191) height = 8191;
				var realBitData:BitmapData = new BitmapData(width, height, transparent, fillColor);
				realBitData.copyPixels(b, r, pot);
				b.dispose();
				b = realBitData;
				x += r.x;
				y += r.y;
			}
			var item:BitmapDataItem = BitmapDataItem.instance();
			item.x = x;
			item.y = y;
			if(pushLib)
			{
				item.bitmapData = BitmapDataLib.push(b);
			}
			else
			{
				item.bitmapData = b;
			}
			return item;
		}
		
		/**
		 * 缓存元件360度动画
		 * @param	mc				要被绘制的影片剪辑
		 * @param	transparent		是否透明
		 * @param	fillColor		填充色
		 * @return
		 */
		static public function bitmapRotation(mc:DisplayObject, transparent:Boolean = true, fillColor:uint = 0x00000000):BitmapRotationData
		{
			var i:int = 0;
			var c:int = 360;
			var bitData:BitmapRotationData = new BitmapRotationData();
			bitData.data = new Vector.<BitmapRotationDataItem>(c, true);
			///记录源对象的属性
			var parent:DisplayObjectContainer = mc.parent;
			var transform:Transform = mc.transform;
			var container:Sprite = new Sprite();
			container.addChild(mc);
			mc.x = 0;
			mc.y = 0;
			while (i < c)
			{
				mc.rotation = i;
				bitData.data[i] = new BitmapRotationDataItem();
				bitData.data[i].data = cacheBitmap(container, transparent, fillColor);
				i++;
			}
			///恢复源对象的属性
			if (parent != null)
			{
				parent.addChild(mc);
			}
			mc.transform = transform;
			return bitData;
		}
		
		/**
		 * 根据指定的尺寸拆分图片缓存成位图数据二维数组
		 * @param	source			要被绘制的目标对象
		 * @param	gridWidth		格子宽
		 * @param	gridHeight		格子高
		 * @param	transparent		是否透明
		 * @param	fillColor		填充色
		 * @param	scale			绘制的缩放值
		 * @return
		 */
		static public function gridBitmap(source:DisplayObject, gridWidth:int, gridHeight:int, transparent:Boolean = true, fillColor:uint = 0x00000000, scale:Number = 1):BitmapGridData
		{
			var r:Rectangle = source.getBounds(source);
			var width:int = (r.width + Math.round(r.x)) * scale;
			var height:int = (r.height + Math.round(r.y)) * scale;
			var rowCount:int = Math.ceil(height / gridHeight);
			var columnCount:int = Math.ceil(width / gridWidth);
			var row:int = 0;
			var gridArr:Array = new Array(rowCount);
			while (row < rowCount)
			{
				var column:int = 0;
				var columnArr:Array = new Array(columnCount);
				gridArr[row] = columnArr;
				while (column < columnCount)
				{
					var bitData:BitmapData = new BitmapData(gridWidth, gridHeight, transparent, fillColor);
					s.setTo(scale, 0, 0, scale, -gridWidth * column, -gridHeight * row);
					bitData.draw(source, s, null, null, null, true);
					columnArr[column] = bitData;
					column++;
				}
				row++;
			}
			var gridData:BitmapGridData = new BitmapGridData();
			gridData.row = rowCount;
			gridData.column = columnCount;
			gridData.validWidth = width;
			gridData.validHeight = height;
			gridData.gridWidth = gridWidth;
			gridData.gridHeight = gridHeight;
			gridData.gridBitDataArray = gridArr;
			return gridData;
		}
	}
}