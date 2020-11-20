package cn.wjj.gagaframe.client.factory
{
	import flash.display.Shape;
	
	/**
	 * 仓库管理类,提供Shape的管理
	 * @author GaGa
	 */
	public class FShape extends Shape
	{
		
		/** 初始化 Shape **/
		public function FShape():void { }
		
		/** 初始化 Shape **/
		public static function instance():FShape
		{
			return new FShape();
		}
		
		/** 移除,清理,并回收 **/
		public function dispose():void
		{
			if (this.parent) this.parent.removeChild(this);
			this.graphics.clear();
		}
	}
}