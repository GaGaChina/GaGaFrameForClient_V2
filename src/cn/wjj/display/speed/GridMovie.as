package cn.wjj.display.speed
{
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	
	/**
	 * 矩阵序列幀转换影片对象
	 * 置入Sprite对象,提供FPS控制,播放控制,播放区间控制,播放次数控制,获取幀,获取播放标签
	 * BitmapData转换为Bitmap
	 */
	public class GridMovie extends Sprite
	{
		
		/** 显示对象里的Bitmap对象 **/
		private var bitmap:Bitmap;
		/** 是否在播放中 **/
		private var _isPlaying:Boolean = false;
		/** 播放的时候循环几次 **/
		private var playLoop:int = 0;
		/** 播放的帧频 **/
		private var _FPS:int = 0;
		/** 这个对象引用的原先的数据对象 **/
		private var bitmapData:BitmapGridData;
		/** 播放完毕后执行某特定函数 **/
		private var _method:Function;
		/** 播放完毕后播放那个区间 **/
		private var _overPlayRow:int = -1;
		private var _overPlayColumn:int = -1;
		/** 播放的列表 **/
		private var playList:Array;
		/** 播放列表中的那个特定帧 **/
		private var playNumber:int;
		/** 正在播放的行数 **/
		private var _playRow:int;
		/** 正在播放的列数 **/
		private var _playColumn:int;
		
		/**
		 * 
		 * @param	bitmapdata		矩阵数据
		 * @param	fps				播放的FPS
		 */
		public function GridMovie(bitmapdata:BitmapGridData, fps:int = -1):void
		{
			this.bitmap = new Bitmap();
			this.bitmapData = bitmapdata;
			if(fps > 0)
			{
				this.FPS = fps;
			}
			gotoStop(0,0);
			this.addChild(bitmap);
			this.mouseEnabled = false;
			this.mouseChildren = false;
		}
		
		public function get bitmapGridData():BitmapGridData
		{
			return bitmapData;
		}
		
		//----------------------------------------------------公共属性-----------------------------------------------------
		/** 实例中帧的总数 **/
		public function get totalFrames():int
		{
			return bitmapData.row * bitmapData.column;
		}
		
		/** 是否在播放中 **/
		public function get isPlaying():Boolean
		{
			return this._isPlaying;
		}
		
		/** 设置是否在播放 **/
		public function set isPlaying(isPlay:Boolean):void
		{
			if(isPlay)
			{
				if(_FPS == 0)
				{
					g.event.addEnterFrame(nextFrame);
				}
				else
				{
					g.event.addFPSEnterFrame(_FPS, nextFrame);
				}
			}
			else
			{
				g.event.removeEnterFrame(nextFrame);
				g.event.removeFPSEnterFrame(_FPS, nextFrame);
			}
			_isPlaying = isPlay;
		}
		
		//----------------------------------------------------公共方法-----------------------------------------------------
		/**
		 * 播放那一帧,循环几次,播放完毕后执行函数
		 * @param row				行数(0-?),-1为不限制行
		 * @param column			列数(0-?),-1为不限制列
		 * @param loop				循环的次数
		 * @param method			播放完毕后触发函数
		 * @param _overPlayRow		播放完毕后播放那个区间(二个-1为停止)
		 * @param _overPlayColumn	播放完毕后播放那个区间(二个-1为停止)
		 */
		public function gotoPlay(row:int = -1, column:int = -1, loop:int = 0, method:Function = null, _overPlayRow:int = -1, _overPlayColumn:int = -1):void
		{
			this._method = method;
			this._overPlayRow = _overPlayRow;
			this._overPlayColumn = _overPlayColumn;
			this.playLoop = loop;
			getPlayArray(row,column);
			isPlaying = true;
		}
		
		/**
		 * 播放特定区域
		 * @param row		行数(0-?),-1为不限制行
		 * @param column	列数(0-?),-1为不限制列
		 */
		private function getPlayArray(row:int = 0,column:int = 0):void
		{
			if(row == -1 && column == -1)
			{
				stop();
			}
			else
			{
				playList = new Array();
				var i:int;
				if (row == 0 && column == 0)
				{
					//停到第一针
					playList.push(bitmapData.gridBitDataArray[0][0]);
				}
				else if (row != -1 && column != -1)
				{
					//播放固定的一帧
					playList.push(bitmapData.gridBitDataArray[row][column]);
				}
				else if (row == -1 && column != -1)
				{
					//播放特定的某列
					for (i = 0; i < bitmapData.gridBitDataArray.length; i++)
					{
						if (bitmapData.gridBitDataArray[i].length > column)
						{
							playList.push(bitmapData.gridBitDataArray[i][column]);
						}
					}
				}
				else if (row != -1 && column == -1)
				{
					//播放特定的某行
					for (i = 0; i < bitmapData.gridBitDataArray[row].length; i++)
					{
						playList.push(bitmapData.gridBitDataArray[row][i]);
					}
				}
			}
		}
		
		/** 将播放头移到影片剪辑的指定帧并停在那里 **/
		public function gotoStop(row:int = 0, column:int = 0):void
		{
			this._method = null;
			this._overPlayRow = -1;
			this._overPlayColumn = -1;
			this.playLoop = 0;
			stop();
			getPlayArray(row,column);
			nextFrame();
		}
		
		/** 如果有Label就在这个Label中播放 **/
		private function nextFrame():void
		{
			if (playList.length)
			{
				if (playList.length < 2)
				{
					bitmap.bitmapData = playList[0];
				}
				else
				{
					//这里也加入playLoop的控制
					if (playNumber++ >= playList.length )
					{
						playNumber = 1;
						if (playLoop > 0)
						{
							playLoop--;
							if (playLoop == 0)
							{
								stop();
								if (this._method != null)
								{
									_method();
									this._method = null;
								}
								if (_overPlayRow != -1 || _overPlayColumn != -1)
								{
									gotoPlay(_overPlayRow,_overPlayColumn);
								}
								return;
							}
						}
					}
					bitmap.bitmapData = playList[(playNumber - 1)];
				}
			}
		}
		
		/** 在影片剪辑的时间轴中移动播放头 **/
		public function play():void
		{
			isPlaying = true;
		}
		
		/** 停止影片剪辑中的播放头 **/
		public function stop():void
		{
			isPlaying = false;
		}
		
		public function set FPS(fps:int):void
		{
			if (g.bridge.stage && g.bridge.stage.frameRate)
			{
				if (fps == g.bridge.stage.frameRate)
				{
					_FPS = 0;
				}
				else
				{
					_FPS = fps;
					isPlaying = isPlaying;
				}
			}
			else
			{
				g.log.pushLog(this, LogType._Frame, "设置FPS必须先设置frame.bridge.swfRoot对象!并且已经初始化场景,可以获取到stage.frameRate!");
			}
		}
		
		//----------------------------------------------------一些其他的方法---------------------------------------------------
		/** 销毁对象，释放资源 **/
		public function dispose():void
		{
			isPlaying = false;
			_method = null;
			this.bitmapData = null;
			bitmap.bitmapData = null;
			if (contains(bitmap))
			{
				removeChild(bitmap);
			}
			if (this.hasEventListener("parent") && this.parent)
			{
				this.parent.removeChild(this);
			}
		}
		
		/** 获取或设置位图是否启用平滑处理 **/
		public function get smoothing():Boolean
		{ 
			return bitmap.smoothing; 
		}
		
		public function set smoothing(value:Boolean):void
		{
			bitmap.smoothing = value;
		}
	}
}