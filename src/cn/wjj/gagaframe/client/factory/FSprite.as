package cn.wjj.gagaframe.client.factory
{
	import cn.wjj.g;
	import flash.display.Sprite;
	
	/**
	 * 仓库管理类,提供Shape的管理
	 * @author GaGa
	 */
	public class FSprite extends Sprite
	{
		/** 初始化 Shape **/
		public function FSprite():void { }
		
		/** 初始化 Shape **/
		public static function instance():FSprite
		{
			return new FSprite();
		}
		
		/** 移除,清理,并回收 **/
		public function dispose():void
		{
			if (this.parent) this.parent.removeChild(this);
			this.graphics.clear();
			if (this.numChildren)
			{
				this.removeChildren();
			}
		}
	}
}