package cn.wjj.display.speed
{
	import cn.wjj.g;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	
	/**
	 * 旋转播放的一个加速影片剪辑
	 */
	public class BitmapRotation extends Sprite
	{
		
		/** 显示对象里的Bitmap对象 **/
		private var bitmap:Bitmap;
		/** 是否在播放中 **/
		private var _isPlaying:Boolean = false;
		/** 现在播放那一幀 **/
		private var _rotation:int = 0;
		/** 旋转的时候循环几次 **/
		private var playLoop:int = 0;
		/** 旋转的帧频 **/
		private var _FPS:int = 0;
		/** 这个对象引用的原先的数据对象 **/
		private var bitmapData:BitmapRotationData;
		
		public function BitmapRotation(bitmapdata:BitmapRotationData , fps:int = -1)
		{
			bitmap = new Bitmap();
			bitmapData = bitmapdata;
			changeRotation(_rotation);
			if (fps > 0)
			{
				this.FPS = fps;
			}
			this.addChild(bitmap);
			this.mouseEnabled = false;
			this.mouseChildren = false;
		}
		
		public function changeRotation(rotationInt:int):void
		{
			rotationInt = rotationInt % 360;
			var temp:BitmapDataItem = BitmapRotationData.getRotation(bitmapData , rotationInt);
			if (bitmap.bitmapData == null || BitmapDataLib.getID(bitmap.bitmapData) != BitmapDataLib.getID(temp.bitmapData))
			{
				bitmap.bitmapData = temp.bitmapData;
			}
			bitmap.x = temp.x;
			bitmap.y = temp.y;
		}
		
		/** 将播放头转到下一帧并停止 **/
		public function nextRotation():void
		{
			_rotation++;
			_rotation = _rotation % 360;
			gotoAndStop(_rotation);
		}
		
		/** 如果有Label就在这个Label中播放 **/
		private function nextFrameInLabel():void
		{
			_rotation++;
			_rotation = _rotation % 360;
			changeRotation(_rotation);
		}
		
		/** 是否在播放中 **/
		public function get isPlaying():Boolean
		{
			return this._isPlaying;
		}
		
		/** 设置是否在播放 **/
		public function set isPlaying(isPlay:Boolean):void
		{
			if (isPlay)
			{
				if (_FPS == 0)
				{
					g.event.addEnterFrame(nextFrameInLabel);
				}
				else
				{
					g.event.addFPSEnterFrame(_FPS, nextFrameInLabel);
				}
			}
			else
			{
				g.event.removeEnterFrame(nextFrameInLabel);
				g.event.removeFPSEnterFrame(_FPS, nextFrameInLabel);
			}
			_isPlaying = isPlay;
		}
		
		/** 从指定帧开始播放 SWF 文件 **/
		public function gotoAndPlay(scene:* = null):void
		{
			if (scene == null)
			{
				play();
				return;
			}
			var frameId:int = int(Number(scene));
			_rotation = frameId;
			changeRotation(_rotation);
			play();
		}
		
		/**
		 * 播放名称为labelName的几个幀的序列
		 * @param labelName		
		 * @param loop			循环次数,0无限循环,1循环一次停止
		 * 
		 */
		public function gotoAndPlayLabel(labelName:String, loop:int = 0):void
		{
			var frameId:int = 0
			for (var id:* in bitmapData.data)
			{
				if (String(bitmapData.data[id].rotation) == labelName)
				{
					frameId = id + 1;
				}
			}
			if (frameId != 0)
			{
				this.playLoop = loop;
				changeRotation(frameId);
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
			if (scene == null)
			{
				play();
				return;
			}
			var frameId:int = int(Number(scene));
			changeRotation(frameId);
			stop();
		}
		
		/** 将播放头转到前一帧并停止 **/
		public function prevFrame():void
		{
			_rotation--;
			_rotation = _rotation % 360;
			gotoAndStop(_rotation);
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
					if (_FPS != fps)
					{
						g.event.removeEnterFrame(nextFrameInLabel);
						g.event.removeFPSEnterFrame(_FPS, nextFrameInLabel);
						_FPS = fps;
						if (isPlaying) {
							isPlaying = true;
						}
					}
				}
			}
			else
			{
				g.log.pushLog(this, g.logType._Frame, "设置FPS必须先设置frame.bridge.swfRoot对象!并且已经初始化场景,可以获取到stage.frameRate!");
			}
		}
		
		//----------------------------------------------------一些其他的方法---------------------------------------------------
		/** 销毁对象，释放资源 **/
		public function dispose():void
		{
			isPlaying = false;
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