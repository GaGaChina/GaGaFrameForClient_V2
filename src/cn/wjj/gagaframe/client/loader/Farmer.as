package cn.wjj.gagaframe.client.loader
{
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	import flash.utils.ByteArray;
	import flash.utils.getDefinitionByName;
	
	/**
	 * 负责进行下载的一个个进行,相当于农民,下载完毕一个会回到队列中,去下载下一个任务
	 * _tempItem 就是正在下载的队列,完成后会通知farm的.
	 * 
	 * @version 0.0.2
	 * @author GaGa wjjhappy@Gmail.com
	 * @copy 王加静 www.5ga.cn
	 */
	internal class Farmer
	{
		/** 资源的状态,闲置 **/
		internal var isWork:Boolean = false;
		/** 当前下载的单一队列 **/
		internal var item:Item;
		private var _loaderSound:JobSound;
		private var _loaderStream:JobStream;
		private var _loaderLoader:JobLoader;
		/** 分布式ID **/
		private var distributedId:int = 0;
		
		public function Farmer():void { }
		
		/** 获取声音下载对象 **/
		private function get loaderSound():JobSound
		{
			if(_loaderSound == null)_loaderSound = new JobSound(this);
			return _loaderSound;
		}
		
		/** 获取流下载对象 **/
		private function get loaderStream():JobStream
		{
			if(_loaderStream == null)_loaderStream = new JobStream(this);
			return _loaderStream;
		}
		
		/** 获取下载对象 **/
		private function get loaderLoader():JobLoader
		{
			if(_loaderLoader == null)_loaderLoader = new JobLoader(this);
			return _loaderLoader;
		}
		
		/** 添加一个下载 **/
		internal function run(item:Item):void
		{
			if (g.loader.isLog)
			{
				g.log.pushLog(this, LogType._Frame, "Farmer RunURL : " + item.url);
			}
			g.loader.farm.delInFarmList(item);
			this.item = item;
			this.isWork = true;
			item.state = ItemState.START;
			var url:String;
			if(g.bridge.root && g.bridge.root.hasOwnProperty("loaderInfo") && g.bridge.root.loaderInfo.hasOwnProperty("loaderURL"))
			{
				url = String(g.bridge.root.loaderInfo.loaderURL);
				if(url)
				{
					var swfRootArr:Array = url.split("/");
					url = swfRootArr[swfRootArr.length - 1];
				}
			}
			if ((url && url == item.url) || item.url == "frame.bridge.swfRoot")
			{
				//本地处理
				item.fileData = "frame.bridge.swfRoot";
				switch(item.fileType)
				{
					case AssetType.SWFCLASS:
						distributedId = 0;
						distributed();
						break;
					case AssetType.FONT:
					case AssetType.SWFCLASSLIB:
						item.firstAsset.data = g.bridge.root;
						resetting(true)
						break;
					default:
						resetting(true)
				}
			}
			else if(g.loader.config_getClassInRoot && item.fileType == AssetType.SWFCLASS)
			{
				//IOS处理
				item.fileData = "frame.bridge.swfRoot";
				distributedId = 0;
				distributed();
			}
			else if(g.loader.config_getClassInRoot && (item.fileType == AssetType.SWFCLASSLIB || item.fileType == AssetType.FONT))
			{
				//IOS处理
				item.fileData = "frame.bridge.swfRoot";
				item.firstAsset.data = g.bridge.root;
				resetting(true)
			}
			else if(item.isComplete == false)
			{
				//没有下载完毕
				switch(item.fileType)
				{
					case AssetType.SOUND:
						loaderSound.run();
						break;
					case AssetType.ZIP:
					case AssetType.AMFFILE:
					case AssetType.AMFFILELIST:
					case AssetType.JSON:
					case AssetType.XML:
						loaderStream.run();
						break;
					default:
						if(item.cacheSO)
						{
							loaderStream.run();
						}
						else
						{
							loaderLoader.run();
						}
						break;
				}
			}
			else if(item.fileData == null)
			{
				//没有数据的时候
				if(item.loadApiID == g.id)
				{
					//是下载这个api下载的,就不用检查尺寸了
					//二进制数据有了,但是没有内容数据的时候
					loadObject();
				}
				else
				{
					//是否需要检查缓存的文件的大小,来判断是不是已经有了更新
					switch(item.fileType)
					{
						case AssetType.SOUND:
							if(g.loader.config_getClassInRoot)
							{
								loaderSound.run();
							}
							else
							{
								loaderSound.run(g.loader.config_checkSOSize);
							}
							break;
						case AssetType.XML:
						case AssetType.JSON:
							if(g.loader.config_getClassInRoot)
							{
								loaderStream.run();
							}
							else
							{
								loaderStream.run(g.loader.config_checkSOSize);
							}
							break;
					}
				}
			}
			else
			{
				//二边的数据都有的时候.既然内存中有了这个实例化对象,表明一切都很OK了,使用不需要在检查了
				resetting(true)
			}
		}
		
		/** 分布式抽取 **/
		private function distributed():void
		{
			if (distributedId < item.assetList.length)
			{
				var t:AssetItem = item.assetList[distributedId];
				if(t.config_className)
				{
					doGetClassName(t, "Farmer抽取本地文件", 0);
				}
				distributedId++;
				g.status.process.pushMethod(distributed);
			}
			else
			{
				resetting(true)
			}
		}
		
		/**
		 * 抽取内容
		 * @param item
		 * @param doName
		 * @param doTimes
		 */
		private function doGetClassName(item:AssetItem, doName:String, doTimes:uint):void
		{
			try
			{
				item.data = getDefinitionByName(item.config_className) as Class;
				if (g.loader.isLog)
				{
					g.log.pushLog(this, LogType._Frame, doName + "成功 : " + item.name + " className:" + item.config_className);
				}
			}
			catch (e:Error)
			{
				if (g.loader.isLog || g.loader.isLogError)
				{
					g.log.pushLog(this, LogType._ErrorLog, doName + "错误 : " + item.name + " className:" + item.config_className + " SMG : " + e.toString());
				}
				doTimes++
				if(doTimes < 5)
				{
					doGetClassName(item, doName, doTimes);
				}
				else
				{
					return;
				}
			}
		}
		
		/** 获取了文件大小 **/
		public function getFileSizeOver():void
		{
			if((item.fileData as ByteArray).length == item.bytesTotal)
			{
				item.loadApiID = g.id;
			}
			else
			{
				if(g.loader.isLog)
				{
					g.log.pushLog(this, LogType._Frame, "发现下载的内容和os硬盘缓存的内容尺寸不一样,选择重新下载内容!");
				}
				item.fileData = null;
			}
			run(item);
		}
		
		/** 当有二进制内容的时候, Loader他的内容 **/
		public function loadObject():void
		{
			switch(item.fileType)
			{
				case AssetType.SOUND:
					item.firstAsset.data = item.fileData;
					item.fileData = null;
					resetting(true)
					break;
				case AssetType.XML:
				case AssetType.JSON:
					var textData:ByteArray = item.fileData as ByteArray;
					textData.position = 0;
					item.fileData = null;
					item.firstAsset.data = new String(textData.readUTFBytes(textData.length));
					resetting(true)
					break;
				case AssetType.ZIP:
				case AssetType.AMFFILE:	
				case AssetType.AMFFILELIST:	
					(item.fileData as ByteArray).position = 0;
					item.firstAsset.data = item.fileData;
					item.fileData = null;
					resetting(true)
					break;
				case AssetType.BYTE:
					item.firstAsset.data = item.fileData as ByteArray;
					item.fileData = null;
					resetting(true)
					break;
				case AssetType.IMAGE:
				case AssetType.FONT:
				case AssetType.SWF:
				case AssetType.SWFCLASS:
				case AssetType.SWFCLASSLIB:
					loaderLoader.run();
					break;
				default:
					break;
			}
		}
		
		/** 重置这个对象,以便下次使用这个Frame **/
		internal function resetting(isFinish:Boolean):void
		{
			if(_loaderSound)
			{
				_loaderSound.resetting();
				_loaderSound = null;
			}
			if(_loaderLoader)
			{
				_loaderLoader.resetting();
				_loaderLoader = null;
			}
			if(_loaderStream)
			{
				_loaderStream.resetting();
				_loaderStream = null;
			}
			isWork = false;
			var temp:Item = item;
			item = null;
			if(isFinish)
			{
				temp.state = ItemState.FINISH;
				temp.state = ItemState.COMPLETE;
				g.loader.farm.doTeam.changeState(temp , ItemState.FINISH);
			}
			g.loader.farm.start();
		}
		
		/** 关闭这个链接 **/
		internal function close():void
		{
			if(_loaderSound)_loaderSound.close();
			if(_loaderLoader)_loaderLoader.close();
			if(_loaderStream)_loaderStream.close();
		}
		
		/** 删除这个下载的农民 **/
		internal function del():void
		{
			isWork = false;
			resetting(false);
		}
		
		/** 摧毁这个对象 **/
		internal function destroy():void
		{
			resetting(false);
			if(_loaderSound)
			{
				_loaderSound.destroy();
				_loaderSound = null;
			}
			if(_loaderLoader)
			{
				_loaderLoader.destroy();
				_loaderLoader = null;
			}
			if(_loaderStream)
			{
				_loaderStream.destroy();
				_loaderStream = null;
			}
		}
	}
}