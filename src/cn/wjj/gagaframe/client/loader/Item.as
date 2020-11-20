package cn.wjj.gagaframe.client.loader
{
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	import flash.net.SharedObject;
	
	/***
	 * 下载资源用的Item，给农场,外界联系等等。
	 * 每个下载的资源
	 * 压缩这个二进制,测试使用的,经过测试,发现这个并没有压缩掉多少东西
	 * 
	 * 如果需要缓存就不删除,不缓存,取完数据会自己删除掉
	 */
	public class Item extends AbstractItemBase
	{
		/** Loader : 下载的优先级,这个值越大就说明队列越下下载 **/
		public var priority:int = 0;
		/** 目前尝试次数 **/
		public var numTries:int = 0;
		/** 是否是调用的时候才去下载,每调用的时候驻扎在后台去下载的对象,false:必载,true:预载 **/
		public var isGetToLoad:Boolean = false;
		/** 下载的文件信息对象 **/
		private var file:Object;
		/** 下载的实例列表 **/
		public var assetList:Vector.<AssetItem> = new Vector.<AssetItem>();
		
		public function Item(url:String):void
		{
			file = g.loader.asset.file.newFileItem(url);
		}
		
		/**
		 * 添加一个文件的调用资源 , name重复会被复用
		 * @param name						资源模块名称
		 * @param data						资源模块对应对象
		 * @param isOnly					资源模块是否是唯一的
		 * @param isOnlyLink				唯一后是否强制引用
		 * @param config_className			如果抽取类,那么类名
		 * @return 
		 * 
		 */
		public function addAsset(name:String, data:* = null, isOnly:Boolean = false, isOnlyLink:Boolean = false, config_className:String = ""):AssetItem
		{
			this.state = ItemState.INIT
			var o:AssetItem = g.loader.asset.asset.getAssetItem(name);
			if (o == null) o = g.loader.asset.asset.newAssetItem(name);
			o.data = null;
			o.isOnly = isOnly;
			o.isOnlyLink = isOnlyLink;
			o.config_className = config_className;
			o.file = file;
			pushAsset(o);
			return o;
		}
		
		private function pushAsset(asset:AssetItem):void
		{
			for each (var o:AssetItem in assetList) 
			{
				if(o == asset)
				{
					return;
				}
			}
			assetList.push(asset);
		}
		
		/** 文件里面的信息内容 **/
		public function get fileData():*
		{
			return file.data;
		}
		/** 文件里面的信息内容 **/
		public function set fileData(value:*):void
		{
			file.data = value;
			if(file.cacheSO)
			{
				if(g.bridge.sharedName)
				{
					SharedObject.getLocal(g.bridge.sharedName).flush();
				}
				else
				{
					if(g.loader.isLog)
					{
						g.log.pushLog(this, LogType._Warning, "使用资源管理类必须先定义好 g.bridge.sharedObjectName ,否则无法启用 SharedObject !");
					}
				}
			}
		}
		
		/** 获取第一个AssetItem,因为很多时候这个对象值有一个资源属性 **/
		public function get firstAsset():AssetItem
		{
			if(assetList.length)
			{
				return assetList[0];
			}
			return null;
		}
		
		/** 这个文件的类型,关系到载入的方式 **/
		public function get fileType():String
		{
			return file.type;
		}
		/** 这个文件的类型,关系到载入的方式 **/
		public function set fileType(value:String):void
		{
			file.type = value;
		}
		/** 文件的URL,这个不可改 **/
		public function get url():String
		{
			return file.url;
		}
		/** 文件的URL,这个不可改 **/
		internal function get loadApiID():String
		{
			return file.loadApiID;
		}
		/** 文件的URL,这个不可改 **/
		internal function set loadApiID(value:String):void
		{
			file.loadApiID = value;
		}
		/** 资源版本 **/
		public function get fileVer():String
		{
			return file.ver;
		}
		/** 资源版本 **/
		public function set fileVer(value:String):void
		{
			file.ver = value;
		}
		/** [网页模式生效]是否缓存到磁盘 **/
		public function get cacheSO():Boolean
		{
			return file.cacheSO;
		}
		/** [网页模式生效]是否缓存到磁盘 **/
		public function set cacheSO(value:Boolean):void
		{
			file.cacheSO = value;
		}
		/** 是否缓存到内存 **/
		public function get cacheMemory():Boolean
		{
			return file.cacheMemory;
		}
		/** 是否缓存到内存 **/
		public function set cacheMemory(value:Boolean):void
		{
			file.cacheMemory = value;
		}
		/** 是否每次下载都从服务器下载 **/
		public function get autoReChange():Boolean
		{
			return file.autoReChange;
		}
		/** 是否每次下载都从服务器下载 **/
		public function set autoReChange(value:Boolean):void
		{
			file.autoReChange = value;
		}
		
		/** Loader : 是否已经被农民选中 **/
		public function get inFarmer():Boolean
		{
			for each(var farmer:Farmer in g.loader.farm.farmerList)
			{
				if (farmer.item == this)
				{
					return true;
				}
			}
			return false;
		}
		
		/** 是否转换完毕,例如重新将函数加入,这样需要再次循环执行下 **/
		public function get isComplete():Boolean
		{
			//如果有二进制内容,或者内容对象都有内容,就OK啦
			if(file.data == null || file.data == "frame.bridge.swfRoot")
			{
				for each (var asset:AssetItem in assetList) 
				{
					if(asset.data == null)
					{
						return false;
					}
				}
			}
			return true;
		}
		/**
		 * 删除这个队列
		 */
		override public function dispose():void
		{
			g.loader.farm.delItem(this);
			super.dispose();
		}
		
		/** 数据添加完毕 **/
		public function start():void
		{
			state = ItemState.WAIT;
			g.loader.farm.start();
		}
	}
}