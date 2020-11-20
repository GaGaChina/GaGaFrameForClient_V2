package cn.wjj.display.ui2d {
	
	import cn.wjj.display.ui2d.info.U2InfoBase;
	import flash.display.IBitmapDrawable;
	
	/**
	 * 对象基类
	 * @author GaGa
	 */
	public interface IU2Base extends IBitmapDrawable
	{
		/** 移除,清理,并回收 **/
		function dispose():void;
		
		/** 对象里包含的数据 **/
		function get data():U2InfoBase;
		/** 对象里包含的数据 **/
		function set data(o:U2InfoBase):void;
		
		function get smoothing():Boolean;
		function set smoothing(value:Boolean):void;
		
		function get x():Number;
		function set x(value:Number):void;
		
		function get y():Number;
		function set y(value:Number):void;
		
		function get width():Number;
		function set width(value:Number):void;
		
		function get height():Number;
		function set height(value:Number):void;
		
		function get rotation():Number;
		function set rotation(value:Number):void;
		
		function get alpha():Number;
		function set alpha(value:Number):void;
		
		function get scaleX():Number;
		function set scaleX(value:Number):void;
		
		function get scaleY():Number;
		function set scaleY(value:Number):void;
		
		/**
		 * [效率更快]设置这个对象的位置基本属性
		 * @param	x			X轴坐标
		 * @param	y			Y轴坐标
		 * @param	rotation	角度
		 * @param	alpha		透明度
		 * @param	scaleX		X轴缩放
		 * @param	scaleY		Y轴缩放
		 */
		function setSizeInfo(x:Number = 0, y:Number = 0, alpha:Number = 1, rotation:Number = 0, scaleX:Number = 1, scaleY:Number = 1):void;
		
		/** 本对象和子集对象是否播放 **/
		function setPlay(value:Boolean, core:int = -1):void;
		
		/** 是否正在播放 **/
		function getPlayThis():Boolean;
		/** 是否正在播放 **/
		function setPlayThis(value:Boolean, core:int = -1):void;
		/** 子对象是否正播放 **/
		function setPlayChild(value:Boolean, core:int = -1):void;
		
		/** 速率,加速的时候使用 **/
		function get speed():Number;
		/** 速率,加速的时候使用 **/
		function set speed(value:Number):void;
		
		/**
		 * 将播放头移到影片剪辑的指定帧并停在那里
		 * @param	scene			层名称或帧ID
		 * @param	playChild		子对象是否播放
		 * @param	core			是否修正下核心时间
		 */
		function gotoStop(scene:* = null, playChild:Boolean = false, core:int = -1):void;
		
		/**
		 * 播放那一帧,循环几次,播放完毕后执行函数
		 * @param frame			播放的标签或第几帧
		 * @param loop			循环的次数.
		 * @param method		播放完毕后触发函数
		 * @param overLabel		播放完毕后播放那个区间
		 * @param stopBegin		播放完毕后是停留在开始,还是停留在最后幀,如果设置overPlayLabel就忽略这个参数
		 */
		function gotoPlay(scene:*, loop:int = 0, method:Function = null, overLabel:String = "", stopBegin:Boolean = true, playChild:Boolean = true, core:int = -1):void;
		/**
		 * 调整到播放某一个时间点,循环几次,播放完毕后执行函数
		 * @param time			毫秒
		 * @param loop			循环的次数.
		 * @param method		播放完毕后触发函数
		 * @param overLabel		播放完毕后播放那个区间
		 * @param stopBegin		播放完毕后是停留在开始,还是停留在最后幀,如果设置overLabel就忽略这个参数
		 * @param playChild		子对象是否播放
		 * @param core			内核时间
		 */
		function playTime(time:uint, loop:int = 0, method:Function = null, overLabel:String = "", stopBegin:Boolean = true, playChild:Boolean = true, core:int = -1):void;
		/**
		 * 播放那一帧,循环几次,播放完毕后执行函数
		 * @param	time		毫秒
		 * @param	playChild	是否播放子对象
		 * @param	core		内核时间
		 */
		function stopTime(time:uint, playChild:Boolean = false, core:int = -1):void
		/**
		 * 播放名称为labelName的几个幀的序列
		 * @param	label
		 * @param	loop		循环次数,0无限循环,1循环一次停止
		 * @param	method		播放完毕后触发函数
		 * @param	overLabel	播放完毕后播放那个区间
		 * @param	stopBegin	播放完毕后是停留在开始,还是停留在最后幀,如果设置overPlayLabel就忽略这个参数
		 * @param	playChild	子对象是否播放
		 * @param	core		内核时间
		 */
		function playLabel(label:String, loop:int = 0, method:Function = null, overLabel:String = "", stopBegin:Boolean = true, playChild:Boolean = true, core:int = -1):void;
	}
}