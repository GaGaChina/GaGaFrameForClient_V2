package cn.wjj.display.ui2d.engine
{
	import cn.wjj.display.ui2d.info.U2InfoBase;
	import cn.wjj.display.ui2d.info.U2InfoEventBridge;
	import cn.wjj.display.ui2d.info.U2InfoPlayEvent;
	import cn.wjj.display.ui2d.info.U2InfoSound;
	import cn.wjj.display.ui2d.info.U2InfoType;
	import cn.wjj.display.ui2d.U2Layer;
	import cn.wjj.display.ui2d.U2Timer;
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.loader.AssetItem;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.utils.Dictionary;
	
	/**
	 * 处理动画信息
	 * 
	 * 
	 * @author GaGa
	 */
	public class EngineEvent 
	{
		
		public function EngineEvent() { }
		
		/**
		 * 运行(现在鼠标等事件使用的)
		 * @param	gfile
		 * @param	item
		 * @param	u2Time
		 * @param	useTime		
		 */
		public static function runItem(gfile:*, item:U2InfoBase, u2Time:U2Timer, cache:Dictionary):void
		{
			switch (item.type) 
			{
				case U2InfoType.sound:
					if ((item as U2InfoSound).useTime == false)
					{
						playSound(gfile, item as U2InfoSound, false, null, cache);
					}
					break;
				case U2InfoType.playEvent:
					if ((item as U2InfoPlayEvent).useTime == false && u2Time)
					{
						playPlayEvent(item as U2InfoPlayEvent, u2Time);
					}
					break;
				case U2InfoType.eventBridge:
					if ((item as U2InfoEventBridge).useTime == false)
					{
						playBridge(item as U2InfoEventBridge);
					}
					break;
			}
		}
		
		
		/**
		 * 播放Event内的声音
		 * @param	gfile			GFile的引用
		 * @param	s				声音数据的引用
		 * @param	disposeSound	是否卸载U2的时候自动停掉全部的声音
		 * @param	u2Time			U2Time的数据引用
		 * @return
		 */
		public static function playSound(gfile:*, s:U2InfoSound, disposeSound:Boolean, u2Time:U2Timer, cache:Dictionary):SoundChannel
		{
			var channel:SoundChannel;
			var o:AssetItem;
			if (s.checkTeam)
			{
				if (s.team && g.loader.asset.sound.getTeamVolume(s.team) > 0)
				{
					if (g.u2.u2UseDefGFile)
					{
						channel = g.dfile.playSound(s.path, s.team, s.start, s.end, s.loop, s.volume);
					}
					else
					{
						channel = g.gfile.playSound(gfile, s.path, s.team, s.start, s.end, s.loop, s.volume);
					}
					if (cache)
					{
						if (g.u2.u2UseDefGFile)
						{
							o = g.dfile.getPathObj(s.path) as AssetItem;
						}
						else
						{
							o = g.gfile.getPathObj(gfile, s.path, false) as AssetItem;
						}
						if (o && o.data is Sound)
						{
							cache[o.data] = g.time.frameTime.time;
						}
					}
				}
			}
			else
			{
				if (g.u2.u2UseDefGFile)
				{
					channel = g.dfile.playSound(s.path, s.team, s.start, s.end, s.loop, s.volume);
				}
				else
				{
					channel = g.gfile.playSound(gfile, s.path, s.team, s.start, s.end, s.loop, s.volume);
				}
				if (cache)
				{
					if (g.u2.u2UseDefGFile)
					{
						o = g.dfile.getPathObj(s.path) as AssetItem;
					}
					else
					{
						o = g.gfile.getPathObj(gfile, s.path, false) as AssetItem;
					}
					if (o && o.data is Sound)
					{
						cache[o.data] = g.time.frameTime.time;
					}
				}
			}
			if (channel && disposeSound && u2Time)
			{
				if (u2Time.soundLib == null)
				{
					u2Time.soundLib = new Dictionary(true);
				}
				u2Time.soundLib[channel] = true;
			}
			return channel;
		}
		
		/**
		 * 播放的处理
		 * @param	p
		 * @param	u2Time
		 */
		public static function playPlayEvent(p:U2InfoPlayEvent, u2Time:U2Timer):void
		{
			if (p.layerName == "")
			{
				if (p.gotoTime != -1)
				{
					if (p.playThis)
					{
						u2Time.playTime(p.gotoTime, p.loop, null, p.overLabel, p.stopBegin, p.playChild);
					}
					else
					{
						u2Time.stopTime(p.gotoTime, p.playChild);
					}
				}
				else if(p.playLabel)
				{
					u2Time.playLabel(p.playLabel, p.loop, null, p.overLabel, p.stopBegin, p.playChild);
					if(p.playThis == false)
					{
						u2Time.setPlayThis(false);
					}
				}
				else
				{
					u2Time.setPlayThis(p.playThis);
					u2Time.setPlayChild(p.playChild);
				}
			}
			else if (u2Time.listLength)
			{
				//找到这个图层,然后找到图层的信息
				var timer:U2Timer;
				for each (var u2Layer:U2Layer in u2Time.listLayer) 
				{
					if (u2Layer.layer.name == p.layerName)
					{
						timer = u2Layer.timer;
						break;
					}
				}
				if (timer)
				{
					if (p.gotoTime != -1)
					{
						if (p.playThis)
						{
							timer.playTime(p.gotoTime, p.loop, null, p.overLabel, p.stopBegin, p.playChild);
						}
						else
						{
							timer.stopTime(p.gotoTime, p.playChild);
						}
					}
					else if(p.playLabel)
					{
						timer.playLabel(p.playLabel, p.loop, null, p.overLabel, p.stopBegin, p.playChild);
						if(p.playThis == false)
						{
							timer.setPlayThis(false);
						}
					}
					else
					{
						timer.setPlayThis(p.playThis);
						timer.setPlayChild(p.playChild);
					}
				}
			}
		}
		
		/**
		 * 执行事件桥
		 * @param	b
		 */
		public static function playBridge(b:U2InfoEventBridge):void
		{
			var a:Array = new Array();
			a.push(b.eventName);
			for each (var item:* in b.listValue) 
			{
				a.push(item);
			}
			g.event.runEventBridge.apply(null, a);
		}
		
	}
}