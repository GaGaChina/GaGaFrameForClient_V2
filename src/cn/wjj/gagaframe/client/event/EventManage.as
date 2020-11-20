package cn.wjj.gagaframe.client.event
{
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	import flash.events.KeyboardEvent;
	
	/**
	 * 管理场景里的全部事件.
	 * @langversion ActionScript 3.0
	 * @playerversion Flash 9
	 * @tiptext 管理场景里的全部事件
	 * @version 1.0
	 */
	public class EventManage
	{
		/** 循环ENTERFRAME监听 **/
		private var easyFrame:EasyEnterFrame;
		/** Flash里最快的频率监听Timer **/
		private var superFrame:SuperEnterFrame;
		/** 按照特定FPS运行的监听 **/
		private var fpsEnterFrame:FPSEnterFrame;
		/** 事件桥连接对象 **/
		internal var bridge:EventBridge;
		/** 数据监控层 **/
		internal var eventData:EventData;
		/** 自动设置 **/
		private var aotoLinkVar:AotoLinkVar;
		
		internal var listener:OtherEventListener;
		/** 键盘监听 **/
		private var eventKey:EventShortcutKey;
		
		public function EventManage()
		{
			listener = new OtherEventListener();
			easyFrame = new EasyEnterFrame();
			superFrame = new SuperEnterFrame();
			fpsEnterFrame = new FPSEnterFrame();
			bridge = new EventBridge();
			eventData = new EventData();
			aotoLinkVar = new AotoLinkVar();
			eventKey = new EventShortcutKey();
		}
		
		/**
		 * (弱引用)添加对象上的监听事件,拥有自动卸载,删除自己对象的功能
		 * @param o						对象
		 * @param type					监听事件
		 * @param method				监听函数
		 * @param useCapture			添加的监听是否在捕获阶段
		 * @param priority				
		 * @param useWeakReference		确定对侦听器的引用是强引用，还是弱引用
		 */
		public function addListener(o:Object, type:String, method:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			listener.addListener(o, type, method, useCapture, priority, useWeakReference);
		}
		
		/**
		 * 检查是否有某一项监听
		 * @param	o			对象
		 * @param	type		监听事件
		 * @param	method		监听函数
		 * @param	useCapture	冒泡行为
		 */
		public function hasListener(o:Object, type:String, method:Function, useCapture:Boolean = false):Boolean
		{
			return listener.hasListener(o, type, method, useCapture);
		}
		
		/**
		 * 删除对象上的监听事件
		 * @param	o	          对象
		 * @param	type         监听事件
		 * @param	listener     监听函数
		 */
		public function removeListener(o:Object, type:String, method:Function, useCapture:Boolean = false):void
		{
			listener.removeListener(o, type, method, useCapture);
		}
		
		/**
		 * 清除一个对象上的全部监听
		 * @param	obj
		 */
		public function removeListenerObj(o:Object):void
		{
			listener.removeListenerObj(o);
		}
		
		/**
		 * 清除一个监听函数的全部引用
		 * @param	obj
		 */
		public function removeListenerMethod(method:Function):void
		{
			listener.removeListenerMethod(method);
		}
		
		/**
		 * (弱引用)添加一个ENTER_FRAME事件.
		 * @param	listener			EnterFrame所要触发的函数,fucntion():void{}
		 * @param 	linkMethodObj		绑定,产生弱引用
		 */
		public function addEnterFrame(method:Function, link:* = null):void
		{
			if(method != null && method is Function)
			{
				easyFrame.add(method, link);
			}
			else
			{
				throw new Error("事件函数非法");
			}
		}
		
		/**
		 * 删除一个ENTER_FRAME事件
		 * @param method		监听函数
		 * @param link			绑定对象
		 * 
		 */
		public function removeEnterFrame(method:Function, link:* = null):void
		{
			if(method != null && method is Function)
			{
				easyFrame.remove(method, link);
			}
			else
			{
				throw new Error("事件函数非法");
			}
		}
		
		/**
		 * (弱引用)添加一个超快的ENTER_FRAME事件.
		 * @param method		(弱引用)EnterFrame所要触发的函数,fucntion():void{}
		 * @param link			对触发的函数和link绑定,产生弱引用
		 * 
		 */
		public function addSuperEnterFrame(method:Function, link:* = null):void
		{
			if(method != null && method is Function)
			{
				superFrame.add(method, link);
			}
			else
			{
				throw new Error("事件函数非法");
			}
		}
		
		/**
		 * 删除一个超快的ENTER_FRAME事件.
		 * @param	listener     监听函数
		 */
		public function removeSuperEnterFrame(method:Function, link:* = null):void
		{
			if(method != null && method is Function)
			{
				superFrame.remove(method);
			}
			else
			{
				throw new Error("事件函数非法");
			}
		}
		
		/**
		 * (强引用)添加一个FPS的监听.
		 * @param fps				FPS的数值
		 * @param method			(强引用)每到FPS的时候执行的函数
		 * @param autoUpdateUI		正对这个FPS是否自动刷新,如果全局的FPS禁止刷新,那么都会呗影响
		 * @param linkMethodObj		对触发的函数和linkMethodObj绑定,产生弱引用
		 */
		public function addFPSEnterFrame(fps:Number, method:Function, link:* = null):void
		{
			if(fps != 0 && method != null && method is Function)
			{
				this.fpsEnterFrame.add(fps, method, link);
			}
			else
			{
				throw new Error("参数非法");
			}
		}
		
		/**
		 * 删除一个FPS的监听.
		 * @param fps
		 * @param method
		 */
		public function removeFPSEnterFrame(fps:Number, method:Function, link:* = null):void
		{
			if(fps != 0 && method != null && method is Function)
			{
				this.fpsEnterFrame.remove(fps, method, link);
			}
			else
			{
				throw new Error("参数非法");
			}
		}
		
		/**
		 * (弱引用)添加事件桥
		 * @param	target	(弱引用)从那个对象添加的,方便删除管理
		 * @param	name	事件桥的名称
		 * @param	method	(弱引用)触发事件所要运行的函数 function(...args):void{}
		 */
		public function addEventBridge(target:Object, name:String, method:Function):void
		{
			if (target && name && method != null && method is Function)
			{
				bridge.add(target, name, method);
			}
			else
			{
				throw new Error("参数非法");
			}
		}
		
		/**
		 * 删除事件桥连接
		 * target,name,_function 都为空将会清除所有的事件桥事件
		 * @param	target		从那个对象添加的,方便删除管理
		 * @param	name		事件桥的名称
		 * @param	method		触发事件所要运行的函数 function(...args):void{}
		 */
		public function removeEventBridge(target:Object, name:String, method:Function):void
		{
			if (target && name && method != null && method is Function)
			{
				bridge.removeListener(target, name, method);
			}
			else
			{
				throw new Error("参数非法");
			}
		}
		
		/**
		 * 运行事件桥事件
		 * @param	name			触发的事件桥名称
		 * @param	...args			运行时候传递过去的值或参数
		 */
		public function runEventBridge(name:String, ...args):Array
		{
			args.unshift(name);
			return bridge.run.apply(null, args);
		}
		
		//------添加数据监听--------------------------------------------------------------------------------------------------------------------------
		
		/**
		 * (弱引用)监听一个数据源,当里面的冒值发生变化的时候就触发,这个特定函数
		 * @param linkData			(弱引用)数据源
		 * @param groupName
		 * @param method			(弱引用)
		 * @param linkMethodObj		(弱引用)对触发的函数和linkMethodObj绑定,产生弱引用
		 * @param isPrimitive		[由多监听修改]监听对象是否是一个普通属性,比如String,int,Number等
		 * 
		 */
		public function addEventData(linkData:Object, groupName:String, method:Function, linkMethodObj:* = null, isPrimitive:Boolean = true):void
		{
			eventData.addEventData(linkData, groupName, method, linkMethodObj, isPrimitive);
		}
		
		/**
		 * (弱引用)监听一个数据源,当里面的冒值发生变化的时候就触发,这个特定函数
		 * @param linkData			(弱引用)数据源
		 * @param groupName			可以为空,是当有数据变化时就执行
		 * @param method			(弱引用)对自动执行函数进行
		 * @param linkMethodObj		自动执行对象的弱引用的连接
		 * @param MostListener		是否多次监听同一个函数
		 * @param linkItem			是否自动赋值对象
		 */
		internal function addEventDataForFrame(linkData:Object, groupName:String, method:Function, linkMethodObj:*, item:AutoLinkItem, MostListener:Boolean = true):void
		{
			eventData.addEventData(linkData, groupName, method, linkMethodObj, MostListener, item);
		}
		
		/**
		 * 移除特定数据源的监听
		 * @param linkData
		 * @param method
		 * 
		 */
		public function removeEventData(linkData:Object, groupName:String, method:Function):void
		{
			eventData.removeEventData(linkData, groupName, method);
		}
		
		/**
		 * 移除特定数据源的监听
		 * @param linkData
		 * @param method
		 */
		internal function removeEventDataForFrame(item:AutoLinkItem):void
		{
			eventData.removeEventDataForFrame(item);
		}
		
		/**
		 * 当数据源变化的时候,调用这个函数可以触发数据源里有变化的值
		 * @param linkData
		 * @param groupName		触发某个特定地方的数据桥
		 */
		public function runEventData(linkData:Object, groupName:String = ""):void
		{
			eventData.runEventData(linkData, groupName);
		}
		
		//------添加自动赋值-------------------------------------------------------------------------------------------------------
		
		/**
		 * (弱引用)自动检测linkData.linkGropName的值是否变化,并且自动设置到setObj.setGroupName属性
		 * @param setObj			要设置的对象连接,不能是特定值,只能是连接
		 * @param setGroupName
		 * @param linkData			要设置的对象值,这个必须是连接,也不能是特定值.因为特定值是无法检测是否有变化的,不能是Display对象
		 * @param linkGropName
		 * 
		 */
		public function addAotoLinkVar(setObj:Object , linkData:Object, setGroupName:String = "", linkGropName:String = ""):void
		{
			aotoLinkVar.addAotoLinkVar(setObj, linkData, setGroupName, linkGropName);
		}
		
		/**
		 * 
		 * @param setObj
		 * @param linkData
		 * @param setGroupName
		 * @param linkGropName
		 * 
		 */
		public function removeAotoLinkVar(setObj:Object , linkData:Object, setGroupName:String = "", linkGropName:String = ""):void
		{
			aotoLinkVar.removeAotoLinkVar(setObj, linkData, setGroupName, linkGropName);
		}
		
		/**
		 * Keyboard.LEFT
		 * @param	keyCode
		 * @param	method
		 * @param	type
		 */
		public function addKeyCode(keyCode:int, method:Function, type:String = KeyboardEvent.KEY_UP):void
		{
			this.eventKey.add(method, type, false, 0, keyCode);
		}
		
		public function removeKeyCode(keyCode:int, method:Function, type:String = KeyboardEvent.KEY_UP):void
		{
			this.eventKey.remove(method, type, false, 0, keyCode);
		}
		
		public function addCharCode(charCode:int, method:Function, type:String = KeyboardEvent.KEY_UP):void
		{
			this.eventKey.add(method, type, true, 0, charCode);
		}
		
		public function removeCharCode(charCode:int, method:Function, type:String = KeyboardEvent.KEY_UP):void
		{
			this.eventKey.remove(method, type, true, 0, charCode);
		}
		
		/**
		 * 添加键盘监听事件
		 * @param	method		触发函数
		 * @param	type		类型
		 * @param	ischarCode
		 * @param	charCode
		 * @param	keyCode
		 * @param	ctrl
		 * @param	alt
		 * @param	shift
		 */
		public function addKey(method:Function, type:String = KeyboardEvent.KEY_UP, ischarCode:Boolean = false, charCode:uint = 0, keyCode:uint = 0, ctrl:Boolean = false, alt:Boolean = false, shift:Boolean = false):void
		{
			this.eventKey.add(method, type, ischarCode, charCode, keyCode, ctrl, alt, shift);
		}
		/**
		 * 删除关键帧监听
		 * @param	method
		 * @param	type
		 * @param	ischarCode
		 * @param	charCode
		 * @param	keyCode
		 * @param	ctrl
		 * @param	alt
		 * @param	shift
		 */
		public function removeKey(method:Function, type:String = KeyboardEvent.KEY_UP, ischarCode:Boolean = false, charCode:uint = 0, keyCode:uint = 0, ctrl:Boolean = false, alt:Boolean = false, shift:Boolean = false):void
		{
			this.eventKey.remove(method, type, ischarCode, charCode, keyCode, ctrl, alt, shift);
		}
	}
}