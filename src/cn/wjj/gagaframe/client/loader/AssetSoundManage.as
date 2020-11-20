package cn.wjj.gagaframe.client.loader
{
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.Dictionary;
	
	/**
	 * 声音资源调用和管理类
	 * 
	 * @author GaGa 15020055@qq.com
	 * @copy 王加静 www.5ga.cn
	 */
	public class AssetSoundManage
	{
		/** 队列的声音的存储,teamList[队列名][弱引用SoundChannel] = AssetSoundItem **/
		internal var teamList:Object = new Object();
		/** 队列的声音大小,teamVolume[队列名] = 0-1值, -1不运行声音 **/
		internal var teamVolume:Object = new Object();
		/** [弱引用]所有声音实例化后库allSoundChannel[弱引用SoundChannel] = AssetSoundItem **/
		internal var allSoundChannel:Dictionary = new Dictionary(true);
		/** [禁]当true声音设置为0的时候是后台播放,如果是false的时候声音不被播放,并且将停掉所有声音,现在想想每个team都应该这样 **/
		public var config_volumeZeroPlay:Boolean = true;
		/** 是否使用SuperEnterFrame来遍历声音列表,如果不是就使用EnterFrame[效率高] **/
		private var isSuperEnterFrame:Boolean = false;
		
		public function AssetSoundManage():void { }

		/** 不断检测内容,主要看结束时间操作 **/
		private function playSound():void
		{
			for each(var item:AssetSoundItem in allSoundChannel)
			{
				if (item.endTime != -1)
				{
					if (item.soundChannel.position >= item.endTime)
					{
						stopSoundChannel(item.soundChannel);
						if (item.loops == 0)
						{
							//停止播放
							//停止播放,完成了任务
							item.assetItem = null;
							item.soundChannel = null;
							var theFunction:Function = item.onComplete;
							if(theFunction != null)
							{
								theFunction();
								item.onComplete = null;
							}
						}
						else
						{
							if (item.loops != -1)
							{
								item.loops--;
							}
							var channel:SoundChannel = (item.assetItem.data as Sound).play(item.startTime);
							item.soundChannel = channel;
							allSoundChannel[channel] = item;
							channel.soundTransform = item.transform;
							if (item.endTime == -1)
							{
								g.event.addListener(channel, Event.SOUND_COMPLETE, soundCompleteHandler);
							}
							reSetTeam(item.soundChannel, channel);
						}
					}
				}
			}
			//如果没有半道的声音就关闭这个监听
			for each(item in allSoundChannel)
			{
				if (item.endTime != -1)
				{
					return;
				}
			}
			g.event.removeEnterFrame(playSound, this);
			g.event.removeSuperEnterFrame(playSound, this);
		}
		
		/**
		 * 使用框架调用声音,建议使用这个方法关闭声音
		 * @param channel
		 */
		public function stopSoundChannel(channel:SoundChannel):void
		{
			delete allSoundChannel[channel];
			g.event.removeListener(channel, Event.SOUND_COMPLETE, soundCompleteHandler);
			channel.stop();
			/*
			for each (var team:String in teamList) 
			{
				delete teamList[team][channel];
			}
			*/
		}
		
		/** 一个片段播放完毕的时候调用 **/
		private function soundCompleteHandler(e:Event):void
		{
			if (allSoundChannel[e.currentTarget])
			{
				var newChannel:SoundChannel;
				var item:AssetSoundItem = (allSoundChannel[e.currentTarget] as AssetSoundItem);
				stopSoundChannel(item.soundChannel);
				if (item.loops == 0)
				{
					//停止播放
					//停止播放,完成了任务
					item.assetItem = null;
					item.soundChannel = null;
					var theFunction:Function = item.onComplete;
					if(theFunction != null)
					{
						theFunction();
						item.onComplete = null;
					}
				}
				else
				{
					if (item.loops != -1)
					{
						item.loops--;
					}
					//没有半路切声音,并且没有
					if(item.loops == -1 && item.endTime == -1)
					{
						newChannel = (item.assetItem.data as Sound).play(item.startTime, 2147483647);
					}
					else
					{
						newChannel = (item.assetItem.data as Sound).play(item.startTime);
					}
					item.soundChannel = newChannel;
					allSoundChannel[newChannel] = item;
					newChannel.soundTransform = item.transform;
					if (item.endTime == -1)
					{
						if(item.loops != -1)
						{
							g.event.addListener(newChannel, Event.SOUND_COMPLETE, soundCompleteHandler);
						}
					}
					else
					{
						if(isSuperEnterFrame)
						{
							g.event.removeEnterFrame(playSound, this);
							g.event.addSuperEnterFrame(playSound, this);
						}
						else
						{
							g.event.removeSuperEnterFrame(playSound, this);
							g.event.addEnterFrame(playSound, this);
						}
					}
					reSetTeam(e.currentTarget as SoundChannel, newChannel);
				}
			}
		}
		
		/** 置换新声道 **/
		private function reSetTeam(oldChannel:SoundChannel, newChannel:SoundChannel):void
		{
			for each(var list:Dictionary in teamList)
			{
				if (list[oldChannel])
				{
					delete list[oldChannel];
					list[newChannel] = allSoundChannel[newChannel];
				}
			}
		}
		
		/**
		 * 用Asset的名称来音乐
		 * @param url			媒体文件的长度
		 * @param teamName		队列名称
		 * @param startTime		开始时间
		 * @param endTime		结束时间
		 * @param loops			播放默认是1次,0次是无线循环播放
		 * @param volume		声音大小
		 * @param onComplete	完成播放后运行函数
		 * @return 
		 */
		public function playAssetName(name:String, teamName:String = "", startTime:Number = 0, endTime:Number = -1, loops:int = 1, volume:Number = 1, onComplete:Function = null):SoundChannel
		{
			if (teamName != "" && teamVolume.hasOwnProperty(teamName) && teamVolume[teamName] == -1)
			{
				return null;
			}
			var assetItem:AssetItem = g.loader.asset.asset.getAssetItem(name);
			if (assetItem)
			{
				return playAsset(assetItem, teamName, startTime, endTime, loops, volume, onComplete);
			}
			return null;
		}
		
		/**
		 * 播放一个URL的音乐(支持直接播放)
		 * @param url			媒体文件的长度
		 * @param teamName		队列名称
		 * @param startTime		开始时间
		 * @param endTime		结束时间
		 * @param loops			播放默认是1次,0次是无线循环播放
		 * @param volume		声音大小
		 * @param onComplete	完成播放后运行函数
		 * @return 
		 */
		public function playURL(url:String, teamName:String = "", startTime:Number = 0, endTime:Number = -1, loops:int = 1, volume:Number = 1, onComplete:Function = null):SoundChannel
		{
			if (teamName != "" && teamVolume.hasOwnProperty(teamName) && teamVolume[teamName] == -1)
			{
				return null;
			}
			var assetItem:AssetItem = g.loader.asset.asset.getAssetItem(url, false);
			if (assetItem == null)
			{
				var item:Item = g.loader.addItem(url);
				item.fileType = AssetType.SOUND;
				item.cacheSO = false;
				item.cacheMemory = false;
				assetItem = item.addAsset(url);
				item.start();
			}
			return playAsset(assetItem, teamName, startTime, endTime, loops, volume, onComplete);
		}
		
		/**
		 * 通过名称或者URL获取到Sound对象
		 * @param info
		 * @param useName
		 * @return 
		 * 
		 */
		public function getSound(info:String, useName:Boolean = true):Sound
		{
			var assetItem:AssetItem = g.loader.asset.asset.getAssetItem(info, useName);
			if (assetItem && assetItem.data is Sound)
			{
				return assetItem.data as Sound;
			}
			return null;
		}
		
		/**
		 * 播放一个assetItem的Sound资源内的的音乐
		 * @param url			媒体文件的长度
		 * @param teamName		队列名称
		 * @param startTime		开始时间
		 * @param endTime		结束时间
		 * @param loops			播放默认是1次,0次是无线循环播放
		 * @param volume		声音大小,如果这个音乐在一个队列里,那么这个音乐的声音就是队列声音*设置声音
		 * @param onComplete	完成播放后运行函数
		 * @return 
		 */
		public function playAsset(assetItem:AssetItem, teamName:String = "", startTime:Number = 0, endTime:Number = -1, loops:int = 1, volume:Number = 1, onComplete:Function = null):SoundChannel
		{
			if (!assetItem)
			{
				return null;
			}
			if (teamName != "" && teamVolume.hasOwnProperty(teamName) && teamVolume[teamName] == -1)
			{
				return null;
			}
			if(assetItem.data is Class)
			{
				var c:Class = assetItem.data as Class;
				assetItem.data = new c();
			}
			if (assetItem.isOnly)
			{
				var temp:SoundChannel = findAssetIsPlay(assetItem);
				if (temp)
				{
					if (g.loader.isLog)
					{
						g.log.pushLog(this, LogType._Frame, "资源 : " + assetItem.name + ",URL : "+assetItem.file.url+" 只能有一个进程进行播放!");
					}
					return temp;
				}
			}
			//如果超过32个播放对象就关闭一个最老的
			maxPlayToDel(assetItem);
			if(assetItem.data == null && assetItem.file.hasOwnProperty("data") && assetItem.file.data is Sound)
			{
				assetItem.data = assetItem.file.data;
			}
			if (assetItem.data is Sound)
			{
				var tempSound:Sound = assetItem.data as Sound;
				if (tempSound)
				{
					var channel:SoundChannel;
					//没有半路切声音,并且没有
					if(loops == 0 && endTime == -1)
					{
						channel = tempSound.play(startTime, 2147483647);
					}
					else
					{
						channel = tempSound.play(startTime);
					}
					if (channel)
					{
						var transform:SoundTransform = channel.soundTransform;
						if (transform)
						{
							var item:AssetSoundItem = new AssetSoundItem();
							item.assetItem = assetItem;
							item.soundChannel = channel;
							item.startTime = startTime;
							item.endTime = endTime;
							item.loops = (loops - 1);
							item.volume = volume;
							transform.volume = item.volume;
							item.onComplete = onComplete;
							allSoundChannel[channel] = item;
							if (teamName != "")
							{
								if (!teamList.hasOwnProperty(teamName))
								{
									teamList[teamName] = new Dictionary(true);
									teamVolume[teamName] = 1;
								}
								//根据队列的声音设置这个播放子声音
								if (teamVolume.hasOwnProperty(teamName))
								{
									transform.volume = item.volume * teamVolume[teamName];
								}
								//teamVolume[teamName] = volume;
								teamList[teamName][channel] = item;
							}
							item.transform = transform;
							channel.soundTransform = transform;
							if (endTime == -1)
							{
								if(item.loops != -1)
								{
									g.event.addListener(channel, Event.SOUND_COMPLETE, soundCompleteHandler);
								}
							}
							else
							{
								if(isSuperEnterFrame)
								{
									g.event.removeEnterFrame(playSound, this);
									g.event.addSuperEnterFrame(playSound);
								}
								else
								{
									g.event.removeSuperEnterFrame(playSound, this);
									g.event.addEnterFrame(playSound, this);
								}
							}
							return channel;
						}
					}
				}
			}
			else
			{
				if (g.loader.isLogError)
				{
					g.log.pushLog(this, LogType._ErrorLog, "资源 : " + assetItem.name + ",URL : " + assetItem.file.url + " 不属于Sound对象!");
				}
			}
			return null;
		}
		
		/** 查询一个声音是否在播放 **/
		private function findAssetIsPlay(assetItem:AssetItem):SoundChannel
		{
			for each(var item:AssetSoundItem in allSoundChannel)
			{
				if (item.assetItem === assetItem)
				{
					if ((item.loops == -1 || item.loops > 0) && item.paused == false)
					{
						return item.soundChannel;
					}
				}
			}
			return null;
		}
		
		/**
		 * 通过一个Asset名称来查询是否有播放的对象,有就返回一个
		 * @param	name
		 * @return
		 */
		public function findAssetNameIsPlay(name:String):Vector.<SoundChannel>
		{
			var out:Vector.<SoundChannel> = new Vector.<SoundChannel>();
			var assetItem:AssetItem = g.loader.asset.asset.getAssetItem(name);
			if (assetItem)
			{
				for each(var item:AssetSoundItem in allSoundChannel)
				{
					if (item.assetItem === assetItem)
					{
						if ((item.loops == -1 || item.loops > 0) && item.paused == false)
						{
							out.push(item.soundChannel);
						}
					}
				}
			}
			return out;
		}
		
		/**
		 * 如果有超过32个对象播放就删除一个对象,腾出一个播放对象,腾出来
		 */
		private function maxPlayToDel(assetItem:AssetItem):void
		{
			var minTime:Number;
			var num:uint = 0;
			var tempTime:Number;
			var delChannel:SoundChannel;
			for each(var item:AssetSoundItem in allSoundChannel)
			{
				if (item.assetItem === assetItem)
				{
					tempTime = item.endTime - item.soundChannel.position;
					if(isNaN(minTime) ||minTime <= tempTime)
					{
						minTime = tempTime;
						delChannel = item.soundChannel;
					}
					num++;
				}
			}
			if(num > 31)
			{
				//删除最小的
				this.stopSoundChannel(delChannel);
				if(g.loader.isLog)
				{
					g.log.pushLog(this, LogType._Frame, "声音超过32个SoundChannel,剔除一个!");
				}
			}
			if(num > 32)
			{
				maxPlayToDel(assetItem);
			}
		}
		
		/**
		 * 停止播放一个assetItem的Sound资源内的的音乐
		 * @param assetItem
		 */
		public function stopAsset(assetItem:AssetItem):void
		{
			for each (var item:AssetSoundItem in allSoundChannel)
			{
				if (item.assetItem == assetItem)
				{
					stopSoundChannel(item.soundChannel);
				}
			}
		}
		
		/**
		 * 停止播放一个URL的音乐
		 * @param url			媒体文件的长度
		 * @return 
		 */
		public function stopURL(url:String):void
		{
			var item:AssetItem = g.loader.asset.asset.getAssetItem(url, false);
			if(item) stopAsset(item);
		}
		
		/**
		 * 停止播放一个assetItem的Sound资源内的的音乐
		 * @param assetItem
		 */
		public function stopAssetName(name:String):void
		{
			var assetItem:AssetItem = g.loader.asset.asset.getAssetItem(name);
			if(assetItem) stopAsset(assetItem);
		}
		
		/**
		 * 修改一个队列的声音大小
		 * @param	teamName
		 * @param	volume		如果volume为-1,直接后台不播放,停掉,那么开始播放的时候就不会有后续声音产生
		 */
		public function changeTeamVolume(name:String, volume:Number):void
		{
			if (name != "")
			{
				var transform:SoundTransform;
				if (!teamList.hasOwnProperty(name))
				{
					teamList[name] = new Dictionary(true);
				}
				teamVolume[name] = volume;
				for each(var item:AssetSoundItem in teamList[name])
				{
					if (item.soundChannel)
					{
						if (volume == -1)
						{
							stopSoundChannel(item.soundChannel);
						}
						else
						{
							transform = item.soundChannel.soundTransform;
							transform.volume = item.volume * volume;
							item.soundChannel.soundTransform = transform;
							item.transform = transform;
						}
					}
				}
			}
		}
		
		/**
		 * 获取队列声音的大小
		 * @param	teamName
		 * @return
		 */
		public function getTeamVolume(teamName:String):Number
		{
			if (teamName != "" && teamVolume.hasOwnProperty(teamName))
			{
				return teamVolume[teamName];
			}
			return 1;
		}
		
		/**
		 * 暂停队列的音效
		 * @param teamName	队列名称
		 * 
		 */
		public function pausedTeam(teamName:String):void
		{
			if (teamList[teamName] != null)
			{
				for each(var item:AssetSoundItem in teamList[teamName])
				{
					item.paused = true;
					item.position = item.soundChannel.position;
					item.soundChannel.stop();
					g.event.removeListener(item.soundChannel, Event.SOUND_COMPLETE, soundCompleteHandler);
				}
			}
		}
		
		/**
		 * 停止队列的声音
		 * @param teamName	队列名称
		 */
		public function stopTeam(teamName:String):void
		{
			if (teamList[teamName] != null)
			{
				for each(var item:AssetSoundItem in teamList[teamName])
				{
					stopAsset(item.assetItem);
					delete teamList[teamName][item.soundChannel];
				}
			}
		}
		
		/**
		 * 从音乐暂停处继续播放音乐
		 * @param teamName		队列名称
		 */
		public function playTeam(teamName:String):void
		{
			var channel:SoundChannel;
			var theFunction:Function;
			if (teamList[teamName] != null)
			{
				for (var oldSoundChannel:* in teamList[teamName])
				{
					var item:AssetSoundItem = allSoundChannel[oldSoundChannel];
					if(item.paused)
					{
						item.paused = false;
						g.event.removeListener(item.soundChannel, Event.SOUND_COMPLETE, soundCompleteHandler);
						delete allSoundChannel[oldSoundChannel];
						//play 的StartTime每次的时候都会从这个开始的
						if (item.isContinue)
						{
							channel = (item.assetItem.data as Sound).play(item.position);
						}
						else
						{
							if (item.loops == 0)
							{
								//停止播放,完成了任务
								item.assetItem = null;
								item.soundChannel = null;
								theFunction = item.onComplete;
								if (theFunction != null)
								{
									theFunction();
									item.onComplete = null;
								}
								continue;
							}
							else
							{
								if (item.loops != -1)
								{
									item.loops--;
								}
								channel = (item.assetItem.data as Sound).play(item.startTime);
							}
						}
						channel.soundTransform = item.transform;
						item.soundChannel = channel;
						allSoundChannel[channel] = item;
						if(item.endTime == -1)
						{
							g.event.addListener(channel, Event.SOUND_COMPLETE, soundCompleteHandler);
						}
						reSetTeam(oldSoundChannel, channel);
					}
				}
			}
		}
	}
}