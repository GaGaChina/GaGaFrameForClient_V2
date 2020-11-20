package cn.wjj.data.file 
{
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.speedfact.SByte;
	import flash.utils.Dictionary;
	
	/**
	 * 基础文件文件,直接是二进制文件
	 * 更新流程,根据ver,path和更新目录找到更新文件url
	 * 下载更新文件,完毕后
	 * 剔除file内容.放入新内容.保存
	 * 把表头部分修改后保存副本.(双保险)
	 * 保存完毕后写入本文件.
	 * 
	 * @version 1.0.0
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 */
	public class GFileBase
	{
		/** 全局是否自动下载,0是不受参数控制,1是全局下载,-1全局不下载 **/
		public static var globalAutoLoader:int = 0;
		/** 全局回收,0是不受参数控制,1是全局回收,-1全局不回收 **/
		public static var globalRecover:int = 0;
		/** 文件类型 **/
		public var type:int;
		/** 文件名称,不包含扩展名 **/
		public var name:String = "";
		/** 方向关联assets名称 **/
		public var assets:String = "";
		/** 路径,相对于父级,使用http的/好分割 **/
		public var path:String = "";
		/** 是否压缩文件,0:不压缩,1.zlib:默认,2.deflate:压缩(尽量别用),3.lzma也就是7z **/
		public var compress:uint = 0;
		/** 原文件尺寸 **/
		public var sourceLength:uint = 0;
		/** 强引用对象 **/
		internal var Qobj:*;
		/** 弱引用对象 **/
		internal var Robj:Dictionary;
		/** 文件版本 **/
		public var ver:String = "";
		/** 压缩前的文件二进制MD5,文件夹用内容的MD5串一起在算MD5 **/
		public var md5:String = "";
		/** 是否预先载入,针对Image作用比较大 **/
		public var autoLoader:Boolean = false;
		/** 是否自动被回收,只限于可以被引用的对象 **/
		private var _isRecover:Boolean = true;
		/** 是否是在制作文件,制作文件的时候可以绕过回收 **/
		public var isBuilder:Boolean = false;
		/** 文件原始的二进制,也是包体二进制 **/
		public var sourceByte:SByte;
		/** 异步内容 **/
		public var asyncByte:SByte;
		/** 文件的父级管理类 **/
		public var parent:GListBase;
		/** 有没有被父级的文件包裹 **/
		public var parentPackage:GFileBase;
		
		/** 临时变量 **/
		internal static var _temp_o:*;
		
		public function GFileBase():void
		{
			type = GFileType.byte;
		}
		
		/** [先设包头->在设包体]获取包头部分,不包含属性部分 **/
		public function getHeadByte():SByte
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
			return b;
		}
		
		/** [先设包头->在设包体]通过二进制设置文件头,不包含内容的其他部分 **/
		public function setHeadByte(b:SByte, disposeByte:Boolean = false):void
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
			if (GFileBase.globalRecover == 1)
			{
				isRecover = true;
			}
			else if (GFileBase.globalRecover == -1)
			{
				isRecover = false;
			}
			if (disposeByte)
			{
				b.dispose();
			}
		}
		
		/** [先取包头->在取包体]写入包体的内容 **/
		public function setBodyByte(b:SByte, disposeByte:Boolean = false):*
		{
			b.position = 0;
			obj = b;
			if (isBuilder) sourceByte = b;
			return b;
		}
		
		/** [先取包头->在取包体]把包体的内容输出 **/
		public function getBodyByte():SByte
		{
			if (isBuilder && sourceByte)
			{
				sourceByte.position = 0;
				return sourceByte;
			}
			if (obj)
			{
				obj.position = 0;
				return obj;
			}
			else
			{
				return SByte.instance();
			}
		}
		
		/** 把内容写入一个二进制或者文件流中 **/
		public function writeBodyByte(body:*):void
		{
			body.writeBytes(this.getBodyByte());
		}
		
		/**
		 * [合并包头包体的]从这个对象里获取二进制数据
		 * @return 
		 */
		public function getByte():SByte
		{
			var o:SByte = SByte.instance();
			var body:SByte = getBodyByte();
			var head:SByte = getHeadByte();
			o.writeByte(type);
			o.writeUnsignedInt(head.length);
			o.writeBytes(head);
			switch (this.compress) 
			{
				case 1://1.zlib:默认
					body.compress();
					break;
				case 2://2.deflate:压缩(尽量别用)
					body.compress("deflate");
					break;
				case 3://3.lzma也就是7z
					body.compress("lzma");
					break;
			}
			o.writeBytes(body);
			o.position = 0;
			body.dispose();
			head.dispose();
			return o;
		}
		
		/**
		 * [合并包头包体的]通过设置这个对象的二进制,设置这个对象的信息
		 * @param byte
		 */
		public function setByte(b:SByte):*
		{
			b.position = 0;
			type = b.readByte();
			var headLength:uint = b.readUnsignedInt();
			var head:SByte = SByte.instance();
			var body:SByte = SByte.instance();
			b.readBytes(head, 0, headLength);
			b.readBytes(body);
			setHeadByte(head, true);
			switch (this.compress) 
			{
				case 1://1.zlib:默认
					body.uncompress();
					break;
				case 2://2.deflate:压缩(尽量别用)
					body.uncompress("deflate");
					break;
				case 3://3.lzma也就是7z
					body.uncompress("lzma");
					break;
			}
			return setBodyByte(body);
		}
		
		/** 数据是否准备完毕,image 类是需要异步解压的 **/
		public function get isComplete():Boolean
		{
			if (obj != null) return true;
			return false;
		}
		
		/** 获取文件 **/
		public function get obj():*
		{
			if (this.Qobj) return this.Qobj;
			if (this.Robj)
			{
				for (_temp_o in this.Robj) 
				{
					return _temp_o;
				}
			}
			return null;
		}
		
		/** 获取文件 **/
		public function set obj(value:*):void
		{
			if (this._isRecover && this.isBuilder == false)
			{
				if (this.Qobj != null) this.Qobj = null;
				if (value)
				{
					if (this.Robj == null)
					{
						this.Robj = g.speedFact.n_dictWeak();
						this.Robj[value] = null;
					}
					else
					{
						for (_temp_o in this.Robj) 
						{
							delete this.Robj[_temp_o];
						}
						this.Robj[value] = null;
					}
				}
				else if (this.Robj)
				{
					for (_temp_o in this.Robj) 
					{
						delete this.Robj[_temp_o];
					}
					g.speedFact.d_dictWeak(this.Robj);
					this.Robj = null;
				}
			}
			else
			{
				Qobj = value;
				if (this.Robj)
				{
					for (_temp_o in this.Robj) 
					{
						delete this.Robj[_temp_o];
					}
					g.speedFact.d_dictWeak(this.Robj);
					this.Robj = null;
				}
			}
		}
		/** 是否自动被回收,只限于可以被引用的对象 **/
		public function get isRecover():Boolean { return _isRecover; }
		/** 是否自动被回收,只限于可以被引用的对象 **/
		public function set isRecover(value:Boolean):void
		{
			var o:* = obj;
			this._isRecover = value;
			obj = o;
		}
		
		/** 摧毁这个对象 **/
		public function dispose():void
		{
			if (this.Qobj) this.Qobj = null;
			if (this.sourceByte) this.sourceByte = null;
			if (this.Robj)
			{
				for (_temp_o in this.Robj) 
				{
					delete this.Robj[_temp_o];
				}
				g.speedFact.d_dictWeak(this.Robj);
				this.Robj = null;
			}
			this.parent = null;
			this.parentPackage = null;
		}
		
		/** 摧毁obj的内容 **/
		public function disposeObj():void
		{
			if (this.Qobj) this.Qobj = null;
			if (this.sourceByte) this.sourceByte = null;
			if (this.Robj)
			{
				for (_temp_o in this.Robj) 
				{
					delete this.Robj[_temp_o];
				}
				g.speedFact.d_dictWeak(this.Robj);
				this.Robj = null;
			}
		}
	}
}