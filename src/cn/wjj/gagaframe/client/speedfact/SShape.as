package cn.wjj.gagaframe.client.speedfact
{
	import flash.display.Shape;
	
	/**
	 * 仓库管理类,提供Shape的管理
	 * @author GaGa
	 */
	public class SShape extends Shape
	{
		/** 对象池 **/
		private static var __f:SpeedLib = new SpeedLib(100);
		/** 对象池强引用的最大数量 **/
		static public function get __m():uint {return __f.length;}
		/** 对象池强引用的最大数量 **/
		static public function set __m(value:uint):void {__f.length = value;}
		
		/** 初始化 Shape **/
		public function SShape():void { }
		
		/** 初始化 Shape **/
		public static function instance():SShape
		{
			var o:SShape = __f.instance() as SShape;
			if (o) return o;
			return new SShape();
		}
		
		/** 移除,清理,并回收 **/
		public function dispose():void
		{
			this.graphics.clear();
			if (this.parent) this.parent.removeChild(this);
			if (this.x != 0) this.x = 0;
			if (this.y != 0) this.y = 0;
			if (this.z != 0) this.z = 0;
			if (this.rotation != 0) this.rotation = 0;
			if (this.rotationX != 0) this.rotationX = 0;
			if (this.rotationY != 0) this.rotationY = 0;
			if (this.rotationZ != 0) this.rotationZ = 0;
			if (this.scaleX != 1) this.scaleX = 1;
			if (this.scaleY != 1) this.scaleY = 1;
			if (this.scaleZ != 1) this.scaleZ = 1;
			if (this.visible != true) this.visible = true;
			if (this.alpha != 1) this.alpha = 1;
			if (this.cacheAsBitmap != false) this.cacheAsBitmap = false;
			if (this.name != "") this.name = "";
			if (this.filters != null) this.filters = null;
			if (this.mask != null) this.mask = null;
			if (this.opaqueBackground  != null) this.opaqueBackground  = null;
			if (this.scale9Grid != null) this.scale9Grid = null;
			//if (o.transform != null) o.transform = null;
			__f.recover(this);
		}
	}
}