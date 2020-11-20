package cn.wjj.gagaframe.client.loader
{
	
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	/**
	 * 单独的资源的快速链接的配置.每一个SoundChannel会有一个对象
	 * 
	 * @version 0.0.1
	 * @author GaGa wjjhappy@Gmail.com
	 * @copy 王加静 www.5ga.cn
	 */
	public class AssetSoundItem
	{
		
		/** 声音的SoundChannel属性 **/
		public var soundChannel:SoundChannel;
		/** 声道的属性 **/
		public var transform:SoundTransform;
		/** 声音对象的对象引用 **/
		public var assetItem:AssetItem;
		/** 声音的大小 0 到 1 **/
		public var volume:Number = 1;
		/** 是否暂停 **/
		public var paused:Boolean = false;
		/** 暂停后继续播放是否重置为从头播放,flase:从头播,并且loops-1,true:继续播放结尾处,并且不修正loops **/
		public var isContinue:Boolean = false;
		/** 毫秒,声音播放的开始时间 **/
		public var startTime:Number = -1;
		/** 毫秒,声音播放的开始时间,-1就是没有设置这个值 **/
		public var endTime:Number = -1;
		/** 暂停播放的时候的时间 **/
		public var position:Number = -1;
		/** 声音播放的循环次数,-1就是无限循环 **/
		public var loops:Number = 1;
		/** 声音播放完成的时候调用 **/
		public var onComplete:Function;
		
		public function AssetSoundItem():void{}
	}
}