package cn.wjj.data.file 
{
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	import cn.wjj.gagaframe.client.speedfact.SByte;
	import cn.wjj.tool.Version;
	import com.adobe.crypto.MD5;
	import flash.utils.Dictionary;
	
	/**
	 * 列表管理的基类
	 * 需要定义自己的名称,和一个path
	 * 
	 * @version 1.0.0
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 */
	public class GListBase extends GFileBase
	{
		/** 额外添加的版本号,本来是里面算出来的 **/
		public var addVer:String = "0.0.0";
		/** 文件内容 **/
		public var list:Vector.<GFileBase>;
		/** 名字映射文件对象, 名字和对象的关联 **/
		public var pathLib:Object;
		/** 名字映射文件对象, 名字和对象的关联 **/
		protected var md5Lib:Object;
		/** 名字映射文件对象, 名字和对象的关联 **/
		protected var nameLib:Object;
		/** 一个文件在包头里数据的起始偏移量 **/
		internal var headPosition:Dictionary;
		/** 一个文件在包体里数据的起始偏移量 **/
		internal var bodyPosition:Dictionary;
		
		public function GListBase():void
		{
			type = GFileType.listBase;
			list = new Vector.<GFileBase>;
			pathLib = g.speedFact.n_object()
			md5Lib = g.speedFact.n_object()
			nameLib = g.speedFact.n_object()
			headPosition = g.speedFact.n_dict();
			bodyPosition = g.speedFact.n_dict();
		}
		
		/**
		 * 给这个列表对象添加一个FileInfo文件对象
		 * @param	file
		 * @param	passMD5		是否绕过MD5校验,并添加MD5内容
		 * @return
		 */
		public function push(file:GFileBase, checkMD5:Boolean = true):Boolean
		{
			if (file.path == "")
			{
				throw new Error("写入文件必须有名字,方便索引使用");
				return false;
			}
			else if (checkMD5 && file.md5 == "")
			{
				throw new Error("文件必须有MD5值");
				return false;
			}
			else
			{
				if (pathLib.hasOwnProperty(file.path))
				{
					//new Error("Debug用");
					g.log.pushLog(this, LogType._ErrorLog, "库文件里已经添加过路径相同的文件,绕过!");
					return false;
				}
				if (checkMD5 && md5Lib.hasOwnProperty(file.md5))
				{
					//new Error("Debug用");
					g.log.pushLog(this, LogType._ErrorLog, "文件" + file.path + "已有MD5相同的文件" + getMD5(file.md5).path + ",但是已经添加这个文件");
				}
				file.parent = this;
				file.isBuilder = this.isBuilder;
				if(file.isBuilder && file.Robj && file.Robj.value)
				{
					file.Qobj = file.Robj.value;
					file.Robj.dispose();
					file.Robj = null;
				}
				list.push(file);
				pathLib[file.path] = file;
				if (checkMD5 && file.md5.length > 0) md5Lib[file.md5] = file;
				if (file.name.length > 0) nameLib[file.name] = file;
				addFileRun();
			}
			return true;
		}
		
		/** 不检查名称,路径,MD5的加入文件 **/
		public function superPush(file:GFileBase):Boolean
		{
			file.parent = this;
			file.isBuilder = this.isBuilder;
			if(file.isBuilder && file.Robj && file.Robj.value)
			{
				file.Qobj = file.Robj.value;
				file.Robj.dispose();
				file.Robj = null;
			}
			list.push(file);
			return true;
		}
		
		/**
		 * 从列表删除一个文件
		 * @param	file
		 */
		public function remove(file:GFileBase):void
		{
			var index:int = list.indexOf(file);
			if (index != -1)
			{
				list.splice(index, 1);
				if(file.path) delete pathLib[file.path];
				if(file.md5) delete md5Lib[file.md5];
				if(file.name) delete nameLib[file.name];
				delete headPosition[file];
				delete bodyPosition[file];
			}
		}
		
		/** 有新内容添加的时候执行方法 **/
		private function addFileRun():void
		{
			var itemMD5:String = "";
			ver = "0.0.0";
			for each (var item:GFileBase in list) 
			{
				itemMD5 += item.md5;
				ver = Version.mergeAuto(ver, item.ver, true);
			}
			md5 = MD5.hash(itemMD5);
		}
		
		/** [先设包头->在设包体]获取包头部分,不包含属性部分 **/
		override public function getHeadByte():SByte
		{
			var b:SByte = SByte.instance();
			b.writeUTF(name);
			b.writeUTF(assets);
			b.writeUTF(ver);
			b.writeUTF(path);
			b.writeUTF(md5);
			b.writeByte(compress);
			b.writeUnsignedInt(sourceLength);
			b.writeBoolean(autoLoader);
			b.writeBoolean(isRecover);
			//--------------------------额外版本号
			b.writeUTF(addVer);
			//--------------------------把内容的包头加入
			//文件对象
			var item:GFileBase;
			//内容
			var itemByte:SByte;
			//开始的位置
			var position:uint;
			//有多少个文件
			b.writeShort(list.length);//包数量
			for each (item in list) 
			{
				itemByte = item.getHeadByte();
				b.writeByte(item.type);//包类型
				b.writeShort(itemByte.length);//包头长度
				position = bodyPosition[item];//内容体偏移量
				b.writeUnsignedInt(position);
				b.writeBytes(itemByte);
			}
			return b;
		}
		
		/** [先设包头->在设包体]通过二进制设置文件头,不包含内容的其他部分 **/
		override public function setHeadByte(b:SByte, disposeByte:Boolean = false):void
		{
			name = b.readUTF();
			assets = b.readUTF();
			ver = b.readUTF();
			path = b.readUTF();
			md5 = b.readUTF();
			compress = b.readUnsignedByte();
			sourceLength = b.readUnsignedInt();
			autoLoader = b.readBoolean();
			if (GFileBase.globalAutoLoader == 1)
			{
				autoLoader = true;
			}
			else if (GFileBase.globalAutoLoader == -1)
			{
				autoLoader = false;
			}
			isRecover = b.readBoolean();
			//--------------------------额外版本号
			addVer = b._r_String();
			//--------------------------把内容的包头加入
			var length:uint = b.readUnsignedShort();
			/** 文件类型 **/
			var type:int;
			/** 包头长度 **/
			var headLength:int;
			/** 内容开始指针位 **/
			var bodyP:uint;
			/** 包头开始指针位 **/
			var headP:uint = b.position;
			/** 内容 **/
			//var itemByte:SByte;
			/** 文件对象 **/
			var item:GFileBase;
			for (var i:int = 0; i < length; i++) 
			{
				type = b.readByte();//包类型
				headLength = b.readUnsignedShort();
				bodyP = b.readUnsignedInt();
				//itemByte = SByte.instance();
				//b.readBytes(itemByte, 0, headLength);
				switch (type) 
				{
					case GFileType.AMF:
						item = new AMFFile();
						break;
					case GFileType.AMFList:
						item = new AMFFileList();
						break;
					case GFileType.bitmapData:
						item = new GBitmapData();
						break;
					case GFileType.bitmapDataItem:
						item = new GBitmapDataItem();
						break;
					case GFileType.blank:
						item = new GBlank();
						break;
					case GFileType.listBase:
						item = new GListBase();
						break;
					case GFileType.language:
						item = new GLanguage();
						break;
					case GFileType.packageBox:
						item = new GPackage();
						break;
					case GFileType.MP3Asset:
						item = new GMP3Asset();
						break;
					case GFileType.AMFListConfig:
						item = new AMFFileListConfig();
						break;
					case GFileType.assist:
						item = new GAssist();
						break;
					case GFileType.U2Info:
						item = new GU2Info();
						break;
					case GFileType.U2BitmapX:
						item = new GU2BitmapX();
						break;
					case GFileType.Grid9Info:
						item = new GGrid9Info();
						break;
					default:
						item = new GFileBase();
				}
				item.parent = this;
				item.isBuilder = this.isBuilder;
				
				//item.setHeadByte(itemByte, disposeByte);
				item.setHeadByte(b);
				headPosition[item] = headP;
				bodyPosition[item] = bodyP;
				headP = headP + 7 + headLength;
				if(b.position != headP)
				{
					b.position != headP;
				}
				list.push(item);
				pathLib[item.path] = item;
				if (item.md5.length > 0) md5Lib[item.md5] = item;
				if (item.name.length > 0) nameLib[item.name] = item;
			}
			if (disposeByte)
			{
				b.dispose();
			}
		}
		
		/** [先取包头->在取包体]写入包体的内容 **/
		override public function setBodyByte(b:SByte, disposeByte:Boolean = false):*
		{
			//长度
			var length:uint;
			//内容
			var itemByte:SByte;
			//包类型
			var type:int;
			//文件对象
			var item:GFileBase;
			//开始的位置
			var position:uint;
			for each (item in list) 
			{
				position = bodyPosition[item];
				if (position >=0 && position < b.length)
				{
					b.position = position;
					length = b.readUnsignedInt();
					itemByte = SByte.instance();
					b.readBytes(itemByte, 0, length);
					switch (item.compress) 
					{
						//case 0://0:不压缩
							//break;
						case 1://1.zlib:默认
							itemByte.uncompress();
							break;
						case 2://2.deflate:压缩(尽量别用)
							itemByte.uncompress("deflate");
							break;
						case 3://3.lzma也就是7z
							itemByte.uncompress("lzma");
							break;
					}
					item.setBodyByte(itemByte, disposeByte);
				}
				else
				{
					g.log.pushLog(this, LogType._ErrorLog, "二进制数据打包有问题,或没有先取包头部分");
				}
			}
			if (disposeByte)
			{
				b.dispose();
			}
			return this;
		}
		
		/** [先取包头->在取包体]把包体的内容输出 **/
		override public function getBodyByte():SByte
		{
			var b:SByte = SByte.instance();
			var itemByte:SByte;
			for each (var item:GFileBase in list)
			{
				bodyPosition[item] = b.position;
				itemByte = item.getBodyByte();
				itemByte.position = 0;
				switch (item.compress) 
				{
					case 0://0:不压缩
						break;
					case 1://1.zlib:默认
						itemByte.compress();
						break;
					case 2://2.deflate:压缩(尽量别用)
						itemByte.compress("deflate");
						break;
					case 3://3.lzma也就是7z
						itemByte.compress("lzma");
						break;
					default:
				}
				b._w_Uint32(itemByte.length);
				b.writeBytes(itemByte);
			}
			return b;
		}
		
		/** 把内容写入一个二进制或者文件流中 **/
		override public function writeBodyByte(body:*):void
		{
			var b:SByte;
			var p:uint = 0;
			for each (var item:GFileBase in list)
			{
				bodyPosition[item] = p;
				b = item.getBodyByte();
				b.position = 0;
				switch (item.compress) 
				{
					case 1://1.zlib:默认
						b.compress();
						break;
					case 2://2.deflate:压缩(尽量别用)
						b.compress("deflate");
						break;
					case 3://3.lzma也就是7z
						b.compress("lzma");
						break;
				}
				p += b.length + 4;
				body.writeUnsignedInt(b.length);
				body.writeBytes(b);
			}
		}
		
		/**
		 * 将item的内容添加到二进制末尾(对应特殊写入方式)
		 * @param	item
		 */
		public function writeItemByte(body:*, item:GFileBase):void
		{
			var position:uint = body.length;
			bodyPosition[item] = position;
			var itemByte:SByte = item.getBodyByte();
			itemByte.position = 0;
			switch (item.compress) 
			{
				case 1://1.zlib:默认
					itemByte.compress();
					break;
				case 2://2.deflate:压缩(尽量别用)
					itemByte.compress("deflate");
					break;
				case 3://3.lzma也就是7z
					itemByte.compress("lzma");
					break;
			}
			body.writeUnsignedInt(itemByte.length);
			body.writeBytes(itemByte);
		}
		
		/**
		 * 返回列表里是否全部已经下载完毕了
		 * @return 
		 */
		override public function get isComplete():Boolean
		{
			for each (var item:GFileBase in list) 
			{
				if (!item.isComplete) return false;
			}
			return true;
		}
		
		/** 摧毁这个对象 **/
		override public function dispose():void
		{
			super.dispose();
			if (list)
			{
				for each (var item:GFileBase in list) 
				{
					item.dispose();
				}
				list.length = 0;
				list = null;
			}
			pathLib = null;
			md5Lib = null;
			nameLib = null;
			headPosition = null;
			bodyPosition = null;
		}
		
		/** 摧毁obj的内容 **/
		override public function disposeObj():void
		{
			for each (var item:GFileBase in list) 
			{
				item.disposeObj();
			}
		}
		
		/**
		 * 获取地址前一段包含path的一个对象列表
		 * @param	path
		 * @return
		 */
		public function getPathFuzzy(path:String):Vector.<GFileBase>
		{
			var o:Vector.<GFileBase> = new Vector.<GFileBase>();
			var l:uint = path.length;
			for each (var item:GFileBase in list) 
			{
				if (item.path.substr(0, l) == path)
				{
					o.push(item);
				}
			}
			return o;
		}
		
		/** 按照URL获取一个文件 **/
		public function getPath(path:String):GFileBase
		{
			if (pathLib.hasOwnProperty(path)) return pathLib[path] as GFileBase;
			return null;
		}
		
		/** 获取一个Path路径的原始的二进制记录体,不包含前面的长度的,也不进行解压 **/
		public function getPathPosition(path:String):int
		{
			if (pathLib.hasOwnProperty(path))
			{
				var item:GFileBase = pathLib[path] as GFileBase;
				return bodyPosition[item];
			}
			return -1;
		}
		
		/** 通过md5返回一个文件 **/
		public function getMD5(str:String):GFileBase
		{
			if (md5Lib.hasOwnProperty(str)) return md5Lib[str] as GFileBase;
			return null;
		}
		
		/** 遍历重新计算版本号 **/
		public function reGetVer():void
		{
			this.ver = this.addVer;
			for each (var item:GFileBase in list) 
			{
				this.ver = Version.mergeAuto(item.ver, this.ver, true);
			}
		}
	}
}