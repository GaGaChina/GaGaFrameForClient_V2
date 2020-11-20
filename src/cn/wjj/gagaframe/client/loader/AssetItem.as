package cn.wjj.gagaframe.client.loader
{
	
	/**
	 * 单独的资源的快速链接的配置.
	 * 
	 * @version 0.0.1
	 * @author GaGa wjjhappy@Gmail.com
	 * @copy 王加静 www.5ga.cn
	 */
	public class AssetItem
	{
		/** 资源名称 **/
		public var name:String = "";
		/** 资源实例化的对象 **/
		public var data:*;
		/** 资源是否为单例,只会场景内只会有一个对象,如果是类就在第一次调用new出来 **/
		public var isOnly:Boolean = false;
		/** 资源单例的时候,引用方式.true:强制引用,false:弱引用,方便air等版本卸载内存 **/
		public var isOnlyLink:Boolean = true;
		/** 这个资源的来源,就是原始文件的引用 **/
		public var file:Object = null;
		/** 取类的全名 **/
		public var config_className:String = "";
		
		public function AssetItem():void{}
	}
}