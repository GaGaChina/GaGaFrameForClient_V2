package cn.wjj.gagaframe.client.loader
{
	import cn.wjj.data.ObjectAction;
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	import cn.wjj.tool.Version;
	import flash.net.SharedObject;
	import flash.utils.Dictionary;
	
	/**
	 * 资源的文件形式管理模块
	 * 
	 * @version 0.0.1
	 * @author GaGa wjjhappy@Gmail.com
	 * @copy 王加静 www.5ga.cn
	 */
	public class AssetFileManage
	{
		/** 唯一的资源地址 **/
		internal var mySo:SharedObject;
		/** 下载的全部的File的文件,这个是内存中的对象 **/
		internal var libFile:Vector.<Object> = new Vector.<Object>();
		/** 为提升效率的更快的临时文件库,弱引用 **/
		internal var tempLib:Dictionary = new Dictionary(true);
		
		public function AssetFileManage():void { }
		
		/**
		 * 新建一个文件的Item,如果没有这个对象,就创建一个
		 * @param url
		 * @return 
		 */
		public function newFileItem(url:String, ver:String = ""):Object
		{
			var item:Object = getFileItem(url);
			if(item == null)
			{
				item = new Object();
				/** 这个资源的来源,这个是辅助查询用的 **/
				item.url = url;
				/** 文本, 二进制, Sound **/
				item.data = null;
				/** 资源版本 **/
				item.ver = ver;
				/** 是否缓存到磁盘 **/
				item.cacheSO = false;
				/** 是否缓存到内存 **/
				item.cacheMemory = true;
				/** 资源内容类型等等 **/
				item.type = "";
				/** 加载这个资源所用的框架ApiID,用这个来判断要不要检查尺寸 **/
				item.loadApiID = "";
				/** 是否每次下载都从服务器下载 **/
				item.autoReChange = false;
				tempLib[item] = item.url;
			}
			else if (ver != "" && Version.compare(ver , item.ver))
			{
				if(g.loader.isLog)
				{
					g.log.pushLog(this, LogType._Warning, "文件URL:" + url + ",内存重名,并进行版本更新!");
				}
				item.data = null;
				item.cacheSO = false;
				item.cacheMemory = true;
				item.ver = ver;
				item.getTimesToDel = -1;
			}
			return item;
		}
		
		/** 重新设置存储位置 **/
		internal function reSetItem(url:String):void
		{
			var item:Object = getFileItem(url);
			if(item)
			{
				//检查SO
				if(item.cacheSO)
				{
					setSharedObject();
					if(mySo && mySo.data.GaGaFrameClient.asset)
					{
						mySo.data.GaGaFrameClient.asset[item.url] = item;
					}
				}
				else
				{
					//删除SO中的缓存.
					delete mySo.data.GaGaFrameClient.asset[item.url];
				}
				//检查内存
				if(item.cacheMemory)
				{
					if(getFileItemInMemory(url) == null)
					{
						libFile.push(item);
					}
				}
				else
				{
					for (var key:String in libFile) 
					{
						if(libFile[key].url == url)
						{
							libFile.splice(int(Number(key)), 1);
						}
					}
				}
			}
		}
		
		/**
		 * 添加一个文件的资源,通过版本来更新
		 * @param fileItem
		 * 
		
		private function addFile(fileItem:Object):void
		{
			var temp:Object = getFileItemInMemory(fileItem.url);
			if(temp)
			{
				if(VersionCompare.compare(fileItem.ver , fileItem.ver))
				{
					if(f.loader.isLog)
					{
						f.log.pushLog(this, LogType._Warning, "添加的文件URL:" + fileItem.url + ",内存中重名,已经进行版本更新处理!");
					}
					//删除SO中的缓存.
					if(getFileItemInSO(fileItem.url))
					{
						delete mySo.data.GaGaFrameClient.asset[fileItem.url];
					}
					delete libFile[fileItem.url];
					pushFileItem(fileItem);
				}
				else
				{
					//frame.log.pushLog(this, frame.logType._Warning, "添加的文件URL:" + fileItem.url + ",内存中重名,添加失败!");
				}
				return;
			}
			temp = getFileItemInSO(fileItem.url);
			if(temp)
			{
				if(VersionCompare.compare(fileItem.ver , fileItem.ver))
				{
					if(f.loader.isLog)
					{
						f.log.pushLog(this, LogType._Warning, "文件URL:" + fileItem.url + ",OS资源重复,并进行版本更新处理!");
					}
					if (mySo && f.tool.obj.action.getGroupVar(mySo, "data.GaGaFrameClient.asset", false))
					{
						delete mySo.data.GaGaFrameClient.asset[fileItem.url];
					}
					pushFileItem(fileItem);
				}
				else
				{
					//frame.log.pushLog(this, frame.logType._Warning, "添加的文件URL:" + fileItem.url + ",OS资源重复,添加失败!");
				}
				return;
			}
			pushFileItem(fileItem);
		}
		 */
		
		/**
		 * 清理一个文件的资源,不会被资源管理类记录,但是对象还是存在,可能存在于tempLib
		 * 
		 * @param url
		 * @return 
		 */
		public function removeFileUrl(url:String, clearData:Boolean = false):void
		{
			var temp:Object;
			var key:String;
			for (key in libFile) 
			{
				if(libFile[key].url == url)
				{
					if(clearData)libFile[key].data = null;
					libFile.splice(int(key),1);
				}
			}
			if(getFileItemInSO(url))
			{
				delete mySo.data.GaGaFrameClient.asset[url];
			}
			delete libFile[url];
		}
		
		/** 添加资源 
		private function pushFileItem(item:Object):void
		{
			if(item.cacheMemory)
			{
				libFile[item.url] = item;
			}
			//if(item.cacheSO && frame.status.osType != "AIR" && frame.status.osType != "Android" && frame.status.osType != "IOS")
			if(item.cacheSO)
			{
				setSharedObject();
				if(mySo && mySo.data.GaGaFrameClient.asset)
				{
					mySo.data.GaGaFrameClient.asset[item.url] = item;
				}
			}
			else
			{
				if (mySo && f.tool.obj.action.getGroupVar(mySo, "data.GaGaFrameClient.asset", false))
				{
					delete mySo.data.GaGaFrameClient.asset[item.url];
				}
			}
			tempLib[item] = item.url;
		}**/
		
		/**
		 * 查询资源库,将对应的对象输出出来.
		 * 通过资源的URL获取一个资源,这个URL必须只有一个内部资源
		 * 这个方法比较适用于Image,Sound,XML,JSON,等一个URL就一个资源的,不适合SWFClass
		 * 
		 * @param url
		 * @return 
		 */
		public function getFileItem(url:String):Object
		{
			var temp:Object;
			temp = getFileItemInTemp(url);
			if (temp)
			{
				return temp;
			}
			//搜寻SharedObject对象
			temp = getFileItemInSO(url);
			if(temp)
			{
				if(g.loader.isLog)
				{
					g.log.pushLog(this, LogType._Frame, "通过 SharedObject 获取二进制内容 :" + url);
				}
				return temp;
			}
			//搜寻文件系统
			return null;
		}
		
		private function getFileItemInSO(url:String):Object
		{
			if (mySo && ObjectAction.getGroupVar(mySo, "data.GaGaFrameClient.asset", false))
			{
				if(mySo.data.GaGaFrameClient.asset.hasOwnProperty(url) && mySo.data.GaGaFrameClient.asset[url])
				{
					return mySo.data.GaGaFrameClient.asset[url];
				}
			}
			return null;
		}
		
		/**
		 * 从缓存中加载一个加载对象
		 * @param	url
		 * @return
		 */
		private function getFileItemInTemp(url:String):Object
		{
			for (var item:Object in tempLib) 
			{
				if (tempLib[item] == url)
				{
					return item;
				}
			}
			return null;
		}
		
		/**
		 * 检查内存中有没有这个对象
		 * @param	url
		 * @return
		 */
		private function getFileItemInMemory(url:String):Object
		{
			for (var item:Object in libFile) 
			{
				if (item.url == url)
				{
					return item;
				}
			}
			return null;
		}
		
		internal function setSharedObject():void
		{
			mySo = g.bridge.sharedObject;
		}
		
		/**
		 * 清除全部的强引用的内容
		 * 
		 */
		public function clearLibFile():void
		{
			libFile.length = 0;
		}
	}
}