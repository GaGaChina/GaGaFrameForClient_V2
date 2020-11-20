package cn.wjj.gagaframe.client.bridge
{
	import cn.wjj.data.ObjectAction;
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.net.SharedObject;
	import flash.text.TextField;
	import flash.utils.Dictionary;

	/**
	 * 对象桥,Flex中慎用,可能出现不跨域问题!
	 * @author GaGa
	 */
	public class ObjBridge
	{
		/** 这个swf的根目录,有些像2.0的_root **/
		public var root:*;
		/** Flash的Stage **/
		public var stage:Stage;
		/** SharedObject的名称 **/
		public var sharedName:String = "";
		/** 新的记录对象 **/
		private var objNoLink:Dictionary = new Dictionary(true);
		/** 有强制引用的对象 **/
		private var objLink:Dictionary = new Dictionary(false);
		/** 获取SO后存放的地方 **/
		private var so:SharedObject;
		
		/** 对象记录的桥梁.可以快速获取各种对象 **/
		public function ObjBridge() { }
		
		public function get sharedObject():SharedObject
		{
			if(so == null)
			{
				if(sharedName != "")
				{
					so = SharedObject.getLocal(sharedName);
					so.flush(10000000000);
					//建立框架存放地
					if(so.data.GaGaFrameClient == null)
					{
						so.data.GaGaFrameClient = new Object();
						so.flush();
					}
					//建立内容存放的地方
					if(so.data.GaGaFrameClient.asset == null)
					{
						so.data.GaGaFrameClient.asset = new Object();
						so.flush();
					}
				}
				else
				{
					g.log.pushLog(this, LogType._Warning, "无 sharedName 无法启用 SharedObject");
				}
			}
			return so;
		}
		
		/** 设置根目录,先入为主 **/
		public function set setRoot(o:*):void
		{
			if (root == null)
			{
				setRootDo(o);
			}
		}
		
		/** 重置获取_swfRoot,注意:这个方法是备用方法,使用的时候请谨慎 **/
		public function reSetRoot(o:*):void
		{
			if (o)
			{
				setRootDo(o);
			}
			else
			{
				root = null;
				stage = null;
			}
		}
		
		private function setRootDo(o:*):void
		{
			root = o;
			stage = root.stage;
			try
			{
				if (stage.loaderInfo.url.substr(0, 5) == "file:")
				{
					g.status.networkMode = false;
				}
				else
				{
					g.status.networkMode = true;
				}
				if(stage.loaderInfo.hasOwnProperty("loaderURL"))
				{
					var u:String = String(stage.loaderInfo.loaderURL);
					if(u)
					{
						var a:Array = u.split("/");
						g.status.rootURL = a[a.length - 1];
					}
				}
			}
			catch(e:Error)
			{
				g.log.pushLog(this, LogType._Frame, "获取网络和URL失败");
			}
		}
		
		/**
		 * 设置一个对象的全局名称
		 * @param	name		一个对象的全局名称,唯一
		 * @param	o			值
		 * @param	reSet		已经有的对象是否会覆盖,默认是不会被覆盖的
		 * @param	link		执行是否是强以引用,false是弱引用
		 */
		public function setObjByName(name:String, o:*, reSet:Boolean = false, link:Boolean = true):void
		{
			if(o == null)
			{
				g.log.pushLog(this, LogType._Frame, "值为空设置失败");
			}
			else
			{
				var bak:*;
				if(reSet == true)
				{
					bak = getObjByName(name, false);
					if(bak && bak != o)
					{
						delete objNoLink[bak];
						delete objLink[bak];
					}
					if(link)
					{
						if(objNoLink[o])
						{
							delete objNoLink[o];
						}
						objLink[o] = name;
					}
					else
					{
						if(objLink[o])
						{
							delete objLink[o];
						}
						objNoLink[o] = name;
					}
				}
				else
				{
					if(hasObjName(name))
					{
						g.log.pushLog(this, LogType._Frame, "对象池已有名:" + name + ",对象");
					}
					else
					{
						if(link)
						{
							objLink[o] = name;
						}
						else
						{
							objNoLink[o] = name;
						}
					}
				}
			}
		}
		
		/**
		 * 通过一个对象的名称获取这个对象
		 * @param	theName		一个对象的全局名称,唯一
		 * @param	isTrue		是否报错
		 * @return
		 */
		public function getObjByName(name:String, logErr:Boolean = true):*
		{
			if (name)
			{
				var o:*;
				for (o in objNoLink)
				{
					if (objNoLink[o] == name)
					{
						return o;
					}
				}
				for (o in objLink)
				{
					if (objLink[o] == name)
					{
						return o;
					}
				}
				if (logErr)
				{
					g.log.pushLog(this, LogType._Frame, "对象池无名:" + name + ",对象");
				}
			}
			return null;
		}
		
		/** 检查对象列表中是否有名称为 name 的对象了 **/
		public function hasObjName(name:String):Boolean
		{
			var o:* = getObjByName(name, false);
			if(o == null)
			{
				return false;
			}
			return true;
		}
		
		/** 删除一个全局名称,并取消这个全局名称下的对象关联连接 **/
		public function delObjByName(name:String):void
		{
			var obj:*;
			for(obj in objNoLink)
			{
				if(objNoLink[obj] == name)
				{
					delete objNoLink[obj];
					return;
				}
			}
			for(obj in objLink)
			{
				if(objLink[obj] == name)
				{
					delete objLink[obj];
					return;
				}
			}
		}
		
		//-------------------------------------------------------------------------
		/**
		 * 获得的记录对象
		 * @return 
		 */
		public function getNoLinkObj(group:String = ""):Object
		{
			var out:Object = new Object();
			var obj:*;
			for(obj in objNoLink)
			{
				if(group == "" || group.indexOf(".") != -1 || group == objNoLink[obj])
				{
					if(obj is DisplayObject)
					{
						out[objNoLink[obj]] = getDisplayInfo(obj as DisplayObject);
					}
					else
					{
						out[objNoLink[obj]] = obj;
					}
				}
			}
			if (group.indexOf(".") == -1)
			{
				return out;
			}
			return ObjectAction.getGroupVar(out, group, false);
		}
		
		/**
		 * 获取强制连接的对象
		 * @param	groupName	这个对象里的某一个数据
		 * @return
		 */
		public function getLinkObj(group:String = ""):Object
		{
			var out:Object = new Object();
			var obj:*;
			for(obj in objLink)
			{
				if(group == "" || group.indexOf(".") != -1 || group == objLink[obj])
				{
					if(obj is DisplayObject)
					{
						out[objLink[obj]] = getDisplayInfo(obj as DisplayObject);
					}
					else
					{
						out[objLink[obj]] = obj;
					}
				}
			}
			if (group.indexOf(".") == -1)
			{
				return out;
			}
			return ObjectAction.getGroupVar(out, group, false);
		}
		
		/**
		 * 获取显示对象列表
		 * @param d
		 * @return 
		 */
		private function getDisplayInfo(d:DisplayObject):Object
		{
			var o:Object = new Object();
			o.name = d.name;
			o.x = d.x;
			o.y = d.y;
			o.visible = d.visible;
			o.width = d.width;
			o.height = d.height;
			o.alpha = d.alpha;
			o.scaleX = d.scaleX;
			o.scaleY = d.scaleY;
			o.scaleZ = d.scaleZ;
			if(d is Bitmap)
			{
				o.type = "Bitmap";
			}
			else if(d is MovieClip)
			{
				o.type = "MovieClip";
			}
			else if(d is Sprite)
			{
				o.type = "Sprite";
			}
			else if(d is Shape)
			{
				o.type = "Shape";
			}
			else if(d is TextField)
			{
				o.type = "TextField";
				o.text = (d as TextField).text;
				o.textWidth = (d as TextField).textWidth;
				o.textHeight = (d as TextField).textHeight;
			}
			var c:DisplayObjectContainer;
			var l:int;
			o.child = new Object();
			if(d is DisplayObjectContainer)
			{
				var s:DisplayObject;
				c = d as DisplayObjectContainer;
				l = c.numChildren;
				while(--l > -1)
				{
					s = c.getChildAt(l);
					o.child[l + " : " + s.name] = getDisplayInfo(s);
				}
			}
			return o;
		}
	}
}