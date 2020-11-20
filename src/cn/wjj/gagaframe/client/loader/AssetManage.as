package cn.wjj.gagaframe.client.loader
{
	/**
	 * 资源的中管理,可以管理文件资源,对象资源和声音资源
	 * 
	 * @version 0.0.5
	 * @author GaGa wjjhappy@Gmail.com
	 * @copy 王加静 www.5ga.cn
	 */
	public class AssetManage
	{
		/** 资源的文件形式管理模块 **/
		public var file:AssetFileManage;
		/** 对象资源的总管理类 **/
		public var asset:AssetItemManage;
		/** 声音资源调用和管理类 **/
		public var sound:AssetSoundManage;
		
		public function AssetManage():void
		{
			file = new AssetFileManage();
			asset = new AssetItemManage();
			sound = new AssetSoundManage();
		}
	}
}