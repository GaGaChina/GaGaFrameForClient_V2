package cn.wjj.gagaframe.client.event
{
	import cn.wjj.data.DictValue;
	
	/**
	 * 自动绑定二个引用对象,当一个发生变化的时候,另一个也会改变
	 */
	internal class AutoLinkItem
	{
		internal var setObj:DictValue;
		internal var setGroupName:String;
		internal var linkData:DictValue;
		internal var linkGropName:String;
		
		public function AutoLinkItem():void{}
	}
}