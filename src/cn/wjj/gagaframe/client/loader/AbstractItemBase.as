package cn.wjj.gagaframe.client.loader
{
	import cn.wjj.g;
	
	/**
	 * 队列和任务的抽象类
	 * @author GaGa
	 */
	public class AbstractItemBase
	{
		protected var _onStart:Vector.<Function> = new Vector.<Function>;
		protected var _onError:Vector.<Function> = new Vector.<Function>;
		protected var _onComplete:Vector.<Function> = new Vector.<Function>;
		protected var _onAllComplete:Vector.<Function> = new Vector.<Function>;
		protected var _onProgress:Vector.<Function> = new Vector.<Function>;
		
		/** 实例化对象的个数,用于起名 **/
		protected static var objID:int;
		/** 状态 **/
		protected var _state:int = ItemState.INIT;
		/** 文件总大小 **/
		public var bytesTotal:int = 0;
		/** 文件已经下载字节数 **/
		public var bytesLoaded:int = 0;
		/** 添加的时间 **/
		public var addedTime:Number = 0;
		/** 开始的时间 **/
		public var startTime:Number = 0;
		/** 下载的速度 **/
		public var speed:Number = 0;
		
		public function AbstractItemBase():void{}
		
		internal function reSet(vars:*):void { }
		internal function get state():int { return _state; }
		internal function set state(value:int):void
		{
			switch(value)
			{
				case ItemState.START:
					runFunction(_onStart);
					break;
				case ItemState.PROGRESS:
					runFunction(_onProgress);
					break;
				case ItemState.FINISH:
					runFunction(_onComplete);
					break;
				case ItemState.COMPLETE:
					runFunction(_onAllComplete);
					break;
				case ItemState.ERROR:
					runFunction(_onError);
					break;
			}
			_state = value;
		}
		
		/** 状态切换的时候执行 **/
		protected function runFunction(method:Vector.<Function>):void
		{
			if(method && method.length)
			{
				var a:Array = g.speedFact.n_array();
				for each(var f:Object in method)
				{
					a.push(f)
				}
				for each(f in a)
				{
					f();
				}
				g.speedFact.d_array(a);
				//正在下载,并且完成后才需要删除
				if (method == _onProgress)
				{
					return;
				}
				method.length = 0;
			}
		}
		
		/** 清除记录的函数 **/
		private function clearMethod():void
		{
			_onStart.length = 0;
			_onError.length = 0;
			_onComplete.length = 0;
			_onAllComplete.length = 0;
			_onProgress.length = 0;
		}
		
		//---- 设置回调函数 -----------------------------------------------------------------
		/** 资源开始下载回调函数.可以为一个下载资源添加多个回调函数. **/
		public function onStart(method:Function):AbstractItemBase
		{
			return setStateMethod(ItemState.START, method);
		}
		/** 资源下载完毕的回调函数.可以为一个下载资源添加多个回调函数[唯一]. **/
		public function onComplete(method:Function):AbstractItemBase
		{
			return setStateMethod(ItemState.FINISH, method);
		}
		/** 预载/必载全部资源下载完毕的回调函数.可以为一个下载资源添加多个回调函数. **/
		public function onAllComplete(method:Function):AbstractItemBase
		{
			return setStateMethod(ItemState.COMPLETE, method);
		}
		/** 资源进行中的回调函数.可以为一个下载资源添加多个回调函数. **/
		public function onProgress(method:Function):AbstractItemBase
		{
			return setStateMethod(ItemState.PROGRESS, method);
		}
		/** 资源下载发生异常的回调函数.可以为一个下载资源添加多个回调函数. **/
		public function onError(method:Function):AbstractItemBase
		{
			return setStateMethod(ItemState.ERROR, method);
		}
		
		/** 删除资源开始下载回调函数. **/
		public function removeStart(method:Function):AbstractItemBase
		{
			return delStateMethod(ItemState.START, method);
		}
		/** 删除资源下载完毕的回调函数. **/
		public function removeComplete(method:Function):AbstractItemBase
		{
			return delStateMethod(ItemState.FINISH, method);
		}
		/** 删除资源下载完毕的回调函数. **/
		public function removeAllComplete(method:Function):AbstractItemBase
		{
			return delStateMethod(ItemState.COMPLETE, method);
		}
		/** 删除资源进行中的回调函数. **/
		public function removeProgress(method:Function):AbstractItemBase
		{
			return delStateMethod(ItemState.PROGRESS, method);
		}
		/** 删除资源下载发生异常的回调函数. **/
		public function removeError(method:Function):AbstractItemBase
		{
			return delStateMethod(ItemState.ERROR, method);
		}
		
		/**
		 * 为这个队列添加执行函数
		 * @param stateName
		 * @param method
		 */		
		private function setStateMethod(stateName:int, method:Function = null):AbstractItemBase
		{
			if (method != null)
			{
				var list:Vector.<Function>;
				switch(stateName)
				{
					case ItemState.START:
						list = _onStart;
						break;
					case ItemState.PROGRESS:
						list = _onProgress;
						break;
					case ItemState.FINISH:
						list = _onComplete;
						break;
					case ItemState.COMPLETE:
						list = _onAllComplete;
						break;
					case ItemState.ERROR:
						list = _onError;
						break;
				}
				if (list != null && list.indexOf(method) == -1)
				{
					list.push(method);
				}
			}
			return this;
		}
		
		/**
		 * 为这个队列删除执行函数
		 * @param stateName
		 * @param method
		 */		
		private function delStateMethod(stateName:int , method:Function = null):AbstractItemBase
		{
			if (method != null)
			{
				var list:Vector.<Function>;
				switch(stateName)
				{
					case ItemState.START:
						list = _onStart;
						break;
					case ItemState.PROGRESS:
						list = _onProgress;
						break;
					case ItemState.FINISH:
						list = _onComplete;
						break;
					case ItemState.COMPLETE:
						list = _onAllComplete;
						break;
					case ItemState.ERROR:
						list = _onError;
						break;
					default:
						
				}
				if (list != null)
				{
					var index:int = list.indexOf(method);
					if (index != -1)
					{
						list.splice(index, 1);
					}
				}
			}
			return this;
		}
		
		/**
		 * 删除这个队列
		 */
		public function dispose():void
		{
			clearMethod();
		}
	}
}