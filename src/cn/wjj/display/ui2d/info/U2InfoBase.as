package cn.wjj.display.ui2d.info
{
	import cn.wjj.gagaframe.client.speedfact.SByte;
	/**
	 * U2Info的原始二进制数据
	 * @author GaGa
	 */
	public class U2InfoBase 
	{
		/** 绘制类型 **/
		public var type:int;
		/** 数据对象的父级引用 **/
		public var parent:U2InfoBaseInfo;
		
		public function U2InfoBase(parent:U2InfoBaseInfo):void
		{
			this.parent = parent;
		}
		
		/** 获取这个对象的全部属性信息 **/
		public function getByte():SByte
		{
			return SByte.instance();
		}
		
		/** 读取这个内容 **/
		public function setByte(b:SByte):void { }
		
		/** 移除,清理,并回收 **/
		public function dispose():void
		{
			parent = null;
		}
	}
}