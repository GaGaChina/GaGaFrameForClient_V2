package cn.wjj.display.speed
{
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.factory.FBitmap;
	import cn.wjj.gagaframe.client.log.LogType;
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	
	public class BitmapMovie extends Bitmap
	{
		/** 是否在播放中 **/
		private var _isPlaying:Boolean = false;
		/** 现在播放那一幀 **/
		private var _currentFrame:int = 1;
		/** 现在要播放那个Label区间 **/
		public var playLabel:String = "";
		/** 播放的时候循环几次 **/
		private var playLoop:int = 0;
		/** 播放的帧频 **/
		private var _FPS:int = 0;
		/** 现在播放的幀的数据 **/
		private var item:BitmapDataItem;
		/** 这个对象引用的原先的数据对象 **/
		private var movieData:BitmapMovieData;
		/** 播放完毕后执行某特定函数 **/
		private var method:Function;
		/** 播放完毕后播放那个区间 **/
		private var overPlayLabel:String;
		/** 播放完毕后停留在开始还是结束位置 **/
		private var stopInBegin:Boolean = true;
		/** 是否强制刷新UI **/
		public var autoUpdateUI:Boolean = true;
		
		/**
		 * 通过一个MovieClip的类或者是MovieClip实例获取一个BitmapMovie对象.
		 * @param	movieDisplayOrClass		GBitmapMovieData, BitmapMovieData, MovieClip或Class,还有GBitmapMovieData对象
		 * @param	fps						这个MovieClip的FPS
		 * @param	directBitData			(测试效果不好)如果本幀只有一个Bitmap就取出BitmapData信息
		 * @return
		 */
		public static function create(info:*, fps:int = -1, directBitData:Boolean = false):BitmapMovie
		{
			if (info is BitmapMovieData)
			{
				return BitmapMovie.instance(info, fps);
			}
			else if(info is Class || info is MovieClip)
			{
				var bitmapData:BitmapMovieData = BitmapMovieLib.getBitmap(info, true, directBitData);
				if(bitmapData == null)
				{
					g.log.pushLog(BitmapMovie, LogType._Warning, "getBitmapMovie 未获取到任何 BitmapData !");
				}
				else
				{
					return BitmapMovie.instance(bitmapData, fps);
				}
			}
			else
			{
				g.log.pushLog(BitmapMovie, LogType._ErrorLog, "必须是一个MovieClip类或是MovieClip实例,现在是:" + typeof info);
			}
			return null;
		}
		
		/**
		 * [警告]请走 BitmapMovie.create 制作一个 BitmapMovie
		 * @param	bitmapdata		播放数据的引用
		 * @param	fps				播放的fps
		 */
		public function BitmapMovie(bitmapdata:BitmapMovieData = null, fps:int = -1):void
		{
			if (bitmapdata && fps != -1)
			{
				setInfo(bitmapdata, fps);
			}
		}
		
		/** 初始化 Shape **/
		public static function instance(bitmapdata:BitmapMovieData = null, fps:int = -1):BitmapMovie
		{
			return new BitmapMovie(bitmapdata, fps);
		}
		
		public function setInfo(bitmapdata:BitmapMovieData, fps:int = -1):void
		{
			var sX:Number;
			var sY:Number;
			if(movieData)
			{
				sX = this.scaleX;
				sY = this.scaleY;
			}
			else
			{
				sX = super.scaleX;
				sY = super.scaleY;
			}
			movieData = bitmapdata;
			this.scaleX = sX;
			this.scaleY = sY;
			gotoAndStop(_currentFrame);
			if(fps > 0)
			{
				this.FPS = fps;
			}
		}
		
		//----------------------------------------------------公共属性-----------------------------------------------------
		/** 指定播放头在 MovieClip 实例的时间轴中所处的帧的编号 **/
		public function get currentFrame():int
		{
			return _currentFrame;
		}
		
		/** MovieClip 实例的时间轴中当前帧上的标签 **/
		public function get currentFrameLabel():String
		{
			return this.movieData.data[(_currentFrame - 1)].frameLabel;
		}
		
		/** 在 MovieClip 实例的时间轴中播放头所在的当前标签 **/
		public function get currentLabel():String
		{
			return this.movieData.data[(_currentFrame - 1)].label;
		}
		
		/** MovieClip 实例中帧的总数 **/
		public function get totalFrames():int
		{
			return movieData.data.length;
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
					g.event.addEnterFrame(nextFrameInLabel);
				}
				else
				{
					g.event.addFPSEnterFrame(_FPS, nextFrameInLabel, autoUpdateUI);
				}
			}
			else
			{
				if(_FPS == 0)
				{
					g.event.removeEnterFrame(nextFrameInLabel);
				}
				else
				{
					g.event.removeFPSEnterFrame(_FPS, nextFrameInLabel);
				}
			}
			_isPlaying = isPlay;
		}
		
		//----------------------------------------------------公共方法-----------------------------------------------------
		/** 从指定帧开始播放 SWF 文件 **/
		public function gotoAndPlay(scene:* = null):void
		{
			this.method = null;
			this.overPlayLabel = "";
			this.playLoop = 0;
			if(scene == null)
			{
				play();
				return;
			}
			var frameId:int = int(Number(scene));
			if (String(frameId) != scene)
			{
				//在这里找到这个lead的真实幀
				frameId = 0;
				for (var id:* in movieData.data)
				{
					if (movieData.data[id].frameLabel == scene)
					{
						frameId = id + 1;
					}
				}
				if (frameId == 0)
				{
					g.log.pushLog(this, g.log.logType._Frame, "gotoAndPlay未在资源里找到名称为" + scene + "的幀!");
					return;
				}
			}
			_currentFrame = frameId;
			gotoFrame(_currentFrame);
			play();
		}
		
		/**
		 * 播放那一帧,循环几次,播放完毕后执行函数
		 * @param frame			播放的标签或第几帧
		 * @param loop			循环的次数.
		 * @param method		播放完毕后触发函数
		 * @param overPlayLabel	播放完毕后播放那个区间
		 * @param stopInBegin	播放完毕后是停留在开始,还是停留在最后幀,如果设置overPlayLabel就忽略这个参数
		 */
		public function gotoPlay(scene:*, loop:int = 0, method:Function = null, overPlayLabel:String = "", stopInBegin:Boolean = true):void
		{
			gotoAndStop(scene);
			this.method = method;
			if (String(int(Number(scene))) != String(scene))
			{
				this.playLabel = String(scene);
			}
			else
			{
				this.playLabel = "";
			}
			this.overPlayLabel = overPlayLabel;
			this.playLoop = loop;
			this.stopInBegin = stopInBegin;
			isPlaying = true;
		}
		
		/**
		 * 播放名称为labelName的几个幀的序列
		 * @param labelName		
		 * @param loop			循环次数,0无限循环,1循环一次停止
		 * @param method		播放完毕后触发函数
		 * @param overPlayLabel	播放完毕后播放那个区间
		 * @param stopInBegin	播放完毕后是停留在开始,还是停留在最后幀,如果设置overPlayLabel就忽略这个参数
		 */
		public function gotoAndPlayLabel(labelName:String, loop:int = 0, method:Function = null, overPlayLabel:String = "", stopInBegin:Boolean = true):void
		{
			var frameId:int = 0;
			this.method = method;
			this.overPlayLabel = overPlayLabel;
			this.stopInBegin = stopInBegin;
			for (var id:* in movieData.data)
			{
				if (movieData.data[id].frameLabel == labelName)
				{
					frameId = id + 1;
				}
			}
			if (frameId != 0)
			{
				this.playLabel = labelName;
				this.playLoop = loop;
				gotoFrame(frameId);
				isPlaying = true;
			}
			else
			{
				g.log.pushLog(this, g.logType._Frame, "未在资源里找到名称为" + labelName + "的幀!");
			}
		}
		
		/** 将播放头移到影片剪辑的指定帧并停在那里 **/
		public function gotoAndStop(scene:* = null):void
		{
			this.method = null;
			this.overPlayLabel = "";
			this.playLoop = 0;
			if (scene == null)
			{
				stop();
			}
			else
			{
				var frameId:int = int(Number(scene));
				//查看是不是移动幀
				if (String(frameId) != scene)
				{
					//在这里找到这个lead的真实幀
					frameId = 0;
					for (var id:* in movieData.data)
					{
						if (movieData.data[id].frameLabel == scene)
						{
							frameId = id + 1;
						}
					}
					if (frameId == 0)
					{
						g.log.pushLog(this, g.logType._Frame, "gotoAndStop" + scene + "的幀!");
						return;
					}
				}
				gotoFrame(frameId);
				stop();
			}
		}
		
		/** 跳转到特定幀 **/
		private function gotoFrame(id:int):void
		{
			_currentFrame = id;
			var tempX:Number = 0;
			var tempY:Number = 0;
			if (item)
			{
				tempX = this.x;
				tempY = this.y;
			}
			id--;
			item = movieData.data[id].data;
			if (this.bitmapData !== item.bitmapData)
			{
				this.bitmapData = item.bitmapData;
				this.x = tempX;
				this.y = tempY;
			}
		}
		
		/** 将播放头转到下一帧并停止 **/
		public function nextFrame():void
		{
			method = null;
			overPlayLabel = "";
			playLoop = 0;
			playLabel = "";
			if (++_currentFrame > movieData.data.length )
			{
				_currentFrame = 1;
			}
			gotoFrame(_currentFrame);
			stop();
		}
		
		/** 将播放头转到前一帧并停止 **/
		public function prevFrame():void
		{
			method = null;
			overPlayLabel = "";
			playLoop = 0;
			playLabel = "";
			if (_currentFrame <= 1 )
			{
				gotoFrame(1);
			}
			else
			{
				gotoFrame(_currentFrame--);
			}
			stop();
		}
		
		/** 如果有Label就在这个Label中播放 **/
		private function nextFrameInLabel():void
		{
			/** 现在播放的幀 **/
			var nowFrame:int = _currentFrame;
			if (playLabel)
			{
				var max:int = 200;
				var id:int = 0;
				var tempLable:String = currentLabel;
				do{
					if (_currentFrame++ >= movieData.data.length )
					{
						_currentFrame = 1;
					}
					id++;
					if (id > max)
					{
						g.log.pushLog(this, g.logType._Frame, "nextFrameInLabel都跑200遍了也没找到名称为:" + playLabel + "的Label!");
						break;
					}
				} while(currentLabel != playLabel);
				if (playLoop > 0 && tempLable == currentLabel)
				{
					if (_currentFrame < nowFrame)
					{
						playLoop--;
					}
					if (playLoop == 0)
					{
						if (this.stopInBegin)
						{
							//这里并没有找到开始
							_currentFrame = 0;
							id = 0;
							do{
								if (_currentFrame++ >= movieData.data.length )
								{
									_currentFrame = 1;
								}
								id++;
								if (id > max)
								{
									g.log.pushLog(this, g.logType._Frame, "nextFrameInLabel都跑10000遍了也没找到名称为:" + playLabel + "的Label!");
									break;
								}
							} while(currentLabel != playLabel);
							gotoFrame(_currentFrame);
						}
						else
						{
							_currentFrame = nowFrame;
							gotoFrame(nowFrame);
						}
						playLabel = "";
						stop();
						if (method != null)
						{
							var tempMethod1:Function = method;
							method = null;
							tempMethod1();
						}
						if (overPlayLabel != "")
						{
							gotoAndPlayLabel(overPlayLabel);
						}
						return;
					}
				}
			}
			else
			{
				//这里也加入playLoop的控制
				if (_currentFrame++ >= movieData.data.length )
				{
					_currentFrame = 1;
					if (playLoop > 0)
					{
						playLoop--;
						if (playLoop == 0)
						{
							if (this.stopInBegin)
							{
								gotoFrame(_currentFrame);
							}
							else
							{
								_currentFrame = nowFrame;
								gotoFrame(nowFrame);
							}
							playLabel = "";
							stop();
							if (method != null)
							{
								var tempMethod:Function = method;
								method = null;
								tempMethod();
							}
							if (overPlayLabel != "")
							{
								gotoAndPlayLabel(overPlayLabel);
							}
							return;
						}
					}
					
				}
			}
			gotoFrame(_currentFrame);
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
			if(_FPS != fps)
			{
				if (g.bridge.stage && g.bridge.stage.frameRate)
				{
					if (fps == g.bridge.stage.frameRate)
					{
						if (_isPlaying)
						{
							g.event.removeFPSEnterFrame(_FPS, nextFrameInLabel);
							_FPS = 0;
							g.event.addEnterFrame(nextFrameInLabel);
						}
						else
						{
							_FPS = 0;
						}
					}
					else
					{
						if (_FPS != fps)
						{
							if (_isPlaying)
							{
								g.event.removeEnterFrame(nextFrameInLabel);
								g.event.removeFPSEnterFrame(_FPS, nextFrameInLabel);
								_FPS = fps;
								g.event.addFPSEnterFrame(_FPS, nextFrameInLabel, autoUpdateUI);
							}
							else
							{
								_FPS = fps;
							}
						}
					}
				}
				else
				{
					g.log.pushLog(this, g.logType._Frame, "设置FPS必须先设置frame.bridge.swfRoot对象!并且已经初始化场景,可以获取到stage.frameRate!");
				}
			}
		}
		
		override public function get x():Number 
		{
			if (item)
			{
				if (this.rotation == 180)
				{
					return super.x + item.x * super.scaleX;
				}
				else
				{
					return super.x - item.x * super.scaleX;
				}
			}
			return super.x
		}
		
		override public function set x(value:Number):void 
		{
			if (item)
			{
				if (this.rotation == 180)
				{
					value = value - item.x * super.scaleX;
				}
				else
				{
					value = value + item.x * super.scaleX;
				}
			}
			if(super.x != value) super.x = value;
		}
		
		override public function get y():Number 
		{
			if (item)
			{
				if (this.rotation == 180)
				{
					return super.y + item.y * super.scaleY;
				}
				else
				{
					return super.y - item.y * super.scaleY;
				}
			}
			return super.y
		}
		
		override public function set y(value:Number):void 
		{
			if (item)
			{
				if (this.rotation == 180)
				{
					value = value - item.y * super.scaleY;
				}
				else
				{
					value = value + item.y * super.scaleY;
				}
			}
			if(super.y != value) super.y = value;
		}
		
		override public function get scaleX():Number 
		{
			if(movieData)
			{
				return super.scaleX / movieData.scaleX;
			}
			return super.scaleX;
		}
		
		override public function set scaleX(value:Number):void 
		{
			if(movieData)
			{
				var temp:Number = this.x;
				super.scaleX = value * movieData.scaleX;
				this.x = temp;
			}
			else
			{
				super.scaleX = value;
			}
		}
		
		override public function get scaleY():Number 
		{
			if(movieData)
			{
				return super.scaleY / movieData.scaleY;
			}
			return super.scaleY;
		}
		
		override public function set scaleY(value:Number):void 
		{
			if(movieData)
			{
				var temp:Number = this.y;
				super.scaleY = value * movieData.scaleY;;
				this.y = temp;
			}
			else
			{
				super.scaleY = value;
			}
		}
		
		//----------------------------------------------------一些其他的方法---------------------------------------------------
		/** 移除,清理,并回收 **/
		public function dispose():void
		{
			if (this.parent) this.parent.removeChild(this);
			if (this.isPlaying != false) this.isPlaying = false;
			if (this._currentFrame != 1) this._currentFrame = 1;
			if (this.item != null) this.item = null;
			if (this.method != null) this.method = null;
			if (this.overPlayLabel != "") this.overPlayLabel = "";
			//这个不能直接处理
			if (this.movieData != null) this.movieData = null;
			if (this.cacheAsBitmap != false) this.cacheAsBitmap = false;
			if (this.bitmapData != null) this.bitmapData = null;
			if (this.filters != null) this.filters = null;
		}
	}
}