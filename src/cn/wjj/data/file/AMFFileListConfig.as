package cn.wjj.data.file 
{
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	import cn.wjj.gagaframe.client.speedfact.SByte;
	
	/**
	 * 
	 * Path为md5码
	 * 这个配置列表的内容,n : 名称 p : 添加路径
	 * 
	 * @version 1.0.0
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 */
	public class AMFFileListConfig extends GFileBase
	{
		
		/** 这个配置文件里包含的数据对象 **/
		public var amfListName:Array = new Array();
		public var amfListPath:Array = new Array();
		/** 抽取子对象所用的方法 **/
		public var getItemMethod:Function;
		
		public function AMFFileListConfig():void
		{
			type = GFileType.AMFListConfig;
		}
		
		/** 写入包体的内容 **/
		override public function setBodyByte(b:SByte, disposeByte:Boolean = false):*
		{
			var o:Object = b.readObject();
			if (isBuilder)
			{
				sourceByte = b;
			}
			else if (disposeByte)
			{
				b.dispose();
			}
			obj = o;
			amfListName = o.n;
			amfListPath = o.p;
			return o;
		}
		
		/** 把包体的内容输出 **/
		override public function getBodyByte():SByte
		{
			if (isBuilder && sourceByte)
			{
				return sourceByte;
			}
			var b:SByte = SByte.instance();
			if(obj == null)
			{
				obj = new Object();
			}
			obj.n = amfListName;
			obj.p = amfListPath;
			b.writeObject(obj);
			b.position = 0;
			return b;
		}
		
		/** 为列表添加一个amf对象 **/
		public function pushItem(name:String, path:String):void
		{
			amfListName.push(name);
			amfListPath.push(path);
		}
		
		/**
		 * 通过子对象的md5来获取到AMFFile
		 * @param	md5
		 * @return
		 */
		public function getItem(filename:String):Object
		{
			if (this.parentPackage)
			{
				var path:String = this.parentPackage.path.substr(0, this.path.length - 5) + "/" + filename + ".amf";
				var item:GFileBase;
				if (getItemMethod != null)
				{
					item = getItemMethod(path);
				}
				if (item == null || !(item is GFileBase))
				{
					var p:GListBase = this.parent;
					item = p.getPath(path);
					while(!item && p.parent)
					{
						p = p.parent;
						item = p.getPath(path);
					}
				}
				if (item && item is GFileBase)
				{
					return (item.parent as Object).getPathObjRun(item);
				}
			}
			else
			{
				g.log.pushLog(this, LogType._ErrorLog, "List对象必须被父级包围");
			}

			return null;
		}
		
		/**
		 * 将里面的全部的对象数据用name的方式,添加到obj里
		 * @param	obj
		 */
		public function setAlltoObj(obj:Object):void
		{
			var l:uint = amfListName.length;
			for (var i:int = 0; i < l; i++) 
			{
				try
				{
					obj[amfListName[i]] = getItem(amfListPath[i]);
				}
				catch(e:Error)
				{
					g.log.pushLog(this, LogType._ErrorLog, this.name + "提取文件:" + amfListName[i] + "失败");
				}
			}
		}
		
		/** 要设置的信息 **/
		private var asynObj:Object;
		/** 处理完毕回调 **/
		private var asynComplete:Function;
		/** 已经处理到什么地方了 **/
		private var asynI:int;
		
		public function asynSetAlltoObj(obj:Object, complete:Function):void
		{
			var l:uint = amfListName.length;
			if (l)
			{
				asynI = 0;
				this.asynObj = obj;
				this.asynComplete = complete;
				g.status.process.pushMethod(asynDo, l, asynOk);
			}
			else if (complete != null)
			{
				complete();
			}
		}
		
		/** 异步处理运行函数 **/
		private function asynDo():void
		{
			try
			{
				asynObj[amfListName[asynI]] = getItem(amfListPath[asynI]);
			}
			catch(e:Error)
			{
				g.log.pushLog(this, LogType._ErrorLog, this.name + "提取文件:" + amfListName[asynI] + "失败");
			}
			asynI++;
		}
		
		/** 异步处理完成 **/
		private function asynOk():void
		{
			if (asynComplete != null)
			{
				asynComplete();
				asynComplete = null;
			}
			if (asynObj) asynObj = null;
		}
		
		/**
		 * 将这个对象以内容形式输出Object对象
		 * @return 
		 */
		public function getAllObj():Object
		{
			var o:Object = new Object();
			setAlltoObj(o);
			return o;
		}
	}
}