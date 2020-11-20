package cn.wjj.display.ui2d.info
{
	/**
	 * 文件夹类型
	 * 
	 * @version 1.0.0
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 */
	public class U2InfoType 
	{
		/** 第一个属性 **/
		public static const baseInfo:uint = 0;
		/** 场景属性 **/
		public static const baseStageInfo:uint = 1;
		/** 图层库 **/
		public static const baseGrid:uint = 2;
		/** 图层信息 **/
		public static const baseLayer:uint = 3;
		/** 图层库 **/
		public static const baseLayerLib:uint = 4;
		/** 幀信息 **/
		public static const baseFrame:uint = 5;
		/** 幀信息 显示对象 **/
		public static const baseFrameDisplay:uint = 7;
		/** 幀信息 位图 **/
		public static const baseFrameBitmap:uint = 8;
		/** 幀信息 Shape **/
		public static const baseFrameShape:uint = 9;
		/** 幀信息 Sprite **/
		public static const baseFrameSprite:uint = 10;
		/** 适量绘制 矩形 **/
		public static const bitmap:uint = 100;
		/** 适量绘制 矩形 **/
		public static const bitmapMovie:uint = 101;
		/** 适量绘制 矩形 **/
		public static const bitmapText:uint = 102;
		/** 适量绘制 矩形 **/
		public static const shape:uint = 103;
		/** 适量绘制 矩形 **/
		public static const sprite:uint = 104;
		
		/** 适量绘制 矩形 **/
		public static const drogRect:uint = 300;
		/** 适量绘制 圆角矩形 **/
		public static const drogRoundRect:uint = 301;
		/** 适量绘制 圆 **/
		public static const drogCircle:uint = 302;
		/** 适量绘制 椭圆 **/
		public static const drogEllipse:uint = 303;
		
		/** 碰撞范围信息 **/
		public static const collide:uint = 600;
		/** 碰撞范围 矩形 **/
		public static const collideRect:uint = 601;
		/** 碰撞范围 圆 **/
		public static const collideCircle:uint = 602;
		
		/** 声音信息 **/
		public static const sound:uint = 700;
		/** 形状范围 矩形 **/
		public static const contourRect:uint = 800;
		
		/** 迷你的位图数据 **/
		public static const bitmapX:uint = 900;
		
		/** 事件形 总管 **/
		public static const eventLib:uint = 1000;
		/** 事件形 PlayEvent **/
		public static const playEvent:uint = 1001;
		/** 事件形 EventBridge **/
		public static const eventBridge:uint = 1002;
		/** 事件形 鼠标事件 **/
		public static const mouseEvent:uint = 1003;
		
		public function U2InfoType() { }
	}
}