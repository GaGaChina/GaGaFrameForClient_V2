package cn.wjj
{
	import cn.wjj.gagaframe.client.bridge.ObjBridge;
	import cn.wjj.gagaframe.client.data.control.DataControl;
	import cn.wjj.gagaframe.client.data.manage.DataManage;
	import cn.wjj.gagaframe.client.display.Grid9Manage;
	import cn.wjj.gagaframe.client.display.U2Manage;
	import cn.wjj.gagaframe.client.event.EventManage;
	import cn.wjj.gagaframe.client.gfile.DefaultGFileManage;
	import cn.wjj.gagaframe.client.gfile.GFileManage;
	import cn.wjj.gagaframe.client.info.DataModel;
	import cn.wjj.gagaframe.client.language.LanguageManage;
	import cn.wjj.gagaframe.client.loader.Load;
	import cn.wjj.gagaframe.client.log.Log;
	import cn.wjj.gagaframe.client.log.LogType;
	import cn.wjj.gagaframe.client.speedfact.SpeedFact;
	import cn.wjj.gagaframe.client.system.Status;
	import cn.wjj.gagaframe.client.time.TimeObj;
	import cn.wjj.gagaframe.client.worker.WorkerManage;
	import cn.wjj.gagaframe.client.info.DataModel;
	import flash.system.Capabilities;
	
	/**
	 * GaGaFrameForClient 框架的入口
	 * GaGaFrameForClient 是 GaGaSystemFrame 整体框架的一部分,应用在客户端的开发上.
	 * 
	 * @version 4.0.0
	 * @author GaGa 15020055@qq.com
	 * @copy 王加静 www.5ga.cn
	 * @date 2011-11-04
	 */
	public class g
	{
		
import cn.wjj.crypto.CRC32;null is cn.wjj.crypto.CRC32;
import cn.wjj.data.CustomByteArray;null is cn.wjj.data.CustomByteArray;
import cn.wjj.data.DictLink;null is cn.wjj.data.DictLink;
import cn.wjj.data.DictValue;null is cn.wjj.data.DictValue;
import cn.wjj.data.file.AMFFile;null is cn.wjj.data.file.AMFFile;
import cn.wjj.data.file.AMFFileList;null is cn.wjj.data.file.AMFFileList;
import cn.wjj.data.file.AMFFileListConfig;null is cn.wjj.data.file.AMFFileListConfig;
import cn.wjj.data.file.FileSize;null is cn.wjj.data.file.FileSize;
import cn.wjj.data.file.GAssist;null is cn.wjj.data.file.GAssist;
import cn.wjj.data.file.GBitmapData;null is cn.wjj.data.file.GBitmapData;
import cn.wjj.data.file.GBitmapDataItem;null is cn.wjj.data.file.GBitmapDataItem;
import cn.wjj.data.file.GBitmapDataType;null is cn.wjj.data.file.GBitmapDataType;
import cn.wjj.data.file.GBlank;null is cn.wjj.data.file.GBlank;
import cn.wjj.data.file.GFileBase;null is cn.wjj.data.file.GFileBase;
import cn.wjj.data.file.GFileEvent;null is cn.wjj.data.file.GFileEvent;
import cn.wjj.data.file.GFileType;null is cn.wjj.data.file.GFileType;
import cn.wjj.data.file.GLanguage;null is cn.wjj.data.file.GLanguage;
import cn.wjj.data.file.GListBase;null is cn.wjj.data.file.GListBase;
import cn.wjj.data.file.GMP3Asset;null is cn.wjj.data.file.GMP3Asset;
import cn.wjj.data.file.GPackage;null is cn.wjj.data.file.GPackage;
import cn.wjj.data.file.GU2BitmapX;null is cn.wjj.data.file.GU2BitmapX;
import cn.wjj.data.file.GU2Info;null is cn.wjj.data.file.GU2Info;
import cn.wjj.data.ForeverSocket;null is cn.wjj.data.ForeverSocket;
import cn.wjj.data.ObjectAction;null is cn.wjj.data.ObjectAction;
import cn.wjj.data.ObjectArraySort;null is cn.wjj.data.ObjectArraySort;
import cn.wjj.data.ObjectClone;null is cn.wjj.data.ObjectClone;
import cn.wjj.data.ObjectPointer;null is cn.wjj.data.ObjectPointer;
import cn.wjj.data.ObjectUtil;null is cn.wjj.data.ObjectUtil;
import cn.wjj.data.SocketBata;null is cn.wjj.data.SocketBata;
import cn.wjj.data.socketHead.HeadEasy;null is cn.wjj.data.socketHead.HeadEasy;
import cn.wjj.data.XMLToObject;null is cn.wjj.data.XMLToObject;
import cn.wjj.display.DisplayPointColor;null is cn.wjj.display.DisplayPointColor;
import cn.wjj.display.DisplaySearch;null is cn.wjj.display.DisplaySearch;
import cn.wjj.display.FColorTransform;null is cn.wjj.display.FColorTransform;
import cn.wjj.display.filter.ColorTrans;null is cn.wjj.display.filter.ColorTrans;
import cn.wjj.display.filter.ColorTransHold;null is cn.wjj.display.filter.ColorTransHold;
import cn.wjj.display.filter.ColorTransType;null is cn.wjj.display.filter.ColorTransType;
import cn.wjj.display.filter.EasyFilter;null is cn.wjj.display.filter.EasyFilter;
import cn.wjj.display.filter.ImagesFilters;null is cn.wjj.display.filter.ImagesFilters;
import cn.wjj.display.speed.BitmapDataItem;null is cn.wjj.display.speed.BitmapDataItem;
import cn.wjj.display.speed.BitmapDataLib;null is cn.wjj.display.speed.BitmapDataLib;
import cn.wjj.display.speed.BitmapDisplayLib;null is cn.wjj.display.speed.BitmapDisplayLib;
import cn.wjj.display.speed.BitmapGridData;null is cn.wjj.display.speed.BitmapGridData;
import cn.wjj.display.speed.BitmapGridLib;null is cn.wjj.display.speed.BitmapGridLib;
import cn.wjj.display.speed.BitmapMovie;null is cn.wjj.display.speed.BitmapMovie;
import cn.wjj.display.speed.BitmapMovieData;null is cn.wjj.display.speed.BitmapMovieData;
import cn.wjj.display.speed.BitmapMovieDataFrameItem;null is cn.wjj.display.speed.BitmapMovieDataFrameItem;
import cn.wjj.display.speed.BitmapMovieLib;null is cn.wjj.display.speed.BitmapMovieLib;
import cn.wjj.display.speed.BitmapRotation;null is cn.wjj.display.speed.BitmapRotation;
import cn.wjj.display.speed.BitmapRotationData;null is cn.wjj.display.speed.BitmapRotationData;
import cn.wjj.display.speed.BitmapRotationDataItem;null is cn.wjj.display.speed.BitmapRotationDataItem;
import cn.wjj.display.speed.BitmapSprite;null is cn.wjj.display.speed.BitmapSprite;
import cn.wjj.display.speed.BitmapText;null is cn.wjj.display.speed.BitmapText;
import cn.wjj.display.speed.BitmapTextField;null is cn.wjj.display.speed.BitmapTextField;
import cn.wjj.display.speed.GaGaSpeed;null is cn.wjj.display.speed.GaGaSpeed;
import cn.wjj.display.speed.GetBitmapData;null is cn.wjj.display.speed.GetBitmapData;
import cn.wjj.display.speed.GridMovie;null is cn.wjj.display.speed.GridMovie;
import cn.wjj.gagaframe.client.bridge.ObjBridge;null is cn.wjj.gagaframe.client.bridge.ObjBridge;
import cn.wjj.gagaframe.client.data.control.DataControl;null is cn.wjj.gagaframe.client.data.control.DataControl;
import cn.wjj.gagaframe.client.data.control.SocketClient.SocketClient;null is cn.wjj.gagaframe.client.data.control.SocketClient.SocketClient;
import cn.wjj.gagaframe.client.data.manage.ClientToClient.ClientToClient;null is cn.wjj.gagaframe.client.data.manage.ClientToClient.ClientToClient;
import cn.wjj.gagaframe.client.data.manage.DataManage;null is cn.wjj.gagaframe.client.data.manage.DataManage;
import cn.wjj.gagaframe.client.data.manage.Distributor;null is cn.wjj.gagaframe.client.data.manage.Distributor;
import cn.wjj.gagaframe.client.display.U2Manage;null is cn.wjj.gagaframe.client.display.U2Manage;
import cn.wjj.gagaframe.client.event.EventItem;null is cn.wjj.gagaframe.client.event.EventItem;
import cn.wjj.gagaframe.client.event.EventManage;null is cn.wjj.gagaframe.client.event.EventManage;
import cn.wjj.gagaframe.client.event.EventShortcutKey;null is cn.wjj.gagaframe.client.event.EventShortcutKey;
import cn.wjj.gagaframe.client.event.EventShortcutKeyItem;null is cn.wjj.gagaframe.client.event.EventShortcutKeyItem;
import cn.wjj.gagaframe.client.factory.FBitmap;null is cn.wjj.gagaframe.client.factory.FBitmap;
import cn.wjj.gagaframe.client.factory.FShape;null is cn.wjj.gagaframe.client.factory.FShape;
import cn.wjj.gagaframe.client.factory.FSprite;null is cn.wjj.gagaframe.client.factory.FSprite;
import cn.wjj.gagaframe.client.factory.FTextField;null is cn.wjj.gagaframe.client.factory.FTextField;
import cn.wjj.gagaframe.client.shortcutkey.KeyManage;null is cn.wjj.gagaframe.client.shortcutkey.KeyManage;
import cn.wjj.gagaframe.client.shortcutkey.ShortcutKeyItem;null is cn.wjj.gagaframe.client.shortcutkey.ShortcutKeyItem;
import cn.wjj.gagaframe.client.speedfact.SBitmap;null is cn.wjj.gagaframe.client.speedfact.SBitmap;
import cn.wjj.gagaframe.client.speedfact.SByte;null is cn.wjj.gagaframe.client.speedfact.SByte;
import cn.wjj.gagaframe.client.speedfact.SpeedFact;null is cn.wjj.gagaframe.client.speedfact.SpeedFact;
import cn.wjj.gagaframe.client.speedfact.SpeedLib;null is cn.wjj.gagaframe.client.speedfact.SpeedLib;
import cn.wjj.gagaframe.client.speedfact.SShape;null is cn.wjj.gagaframe.client.speedfact.SShape;
import cn.wjj.gagaframe.client.speedfact.SSprite;null is cn.wjj.gagaframe.client.speedfact.SSprite;
import cn.wjj.time.TimeToString;null is cn.wjj.time.TimeToString;
import cn.wjj.tool.ArrayUtil;null is cn.wjj.tool.ArrayUtil;
import cn.wjj.tool.BigInt;null is cn.wjj.tool.BigInt;
import cn.wjj.tool.ClassParameter;null is cn.wjj.tool.ClassParameter;
import cn.wjj.tool.EncodeCode; null is cn.wjj.tool.EncodeCode;
import cn.wjj.tool.MathTools;null is cn.wjj.tool.MathTools;
import cn.wjj.tool.StringReplace;null is cn.wjj.tool.StringReplace;
import cn.wjj.tool.Version;null is cn.wjj.tool.Version;
import com.adobe.crypto.MD5;null is com.adobe.crypto.MD5;
import com.adobe.crypto.MD5Stream;null is com.adobe.crypto.MD5Stream;
import com.adobe.utils.IntUtil;null is com.adobe.utils.IntUtil;

		
		/** 获取到这个API的版本号 **/
		public static var id:String = "";
		/** 框架初始化的系统时间 **/
		public static var startTime:Number = 0;
		/** 框架的版本号 **/
		public static var ver:String = "2.0.0";
		
		/** 线程管理器 **/
		public static var worker:WorkerManage;
		/** 日志系统 **/
		public static var log:Log;
		/** 日志类型 **/
		public static var logType:LogType;
		/** 系统 **/
		public static var status:Status;
		/** 事件层 **/
		public static var event:EventManage;
		/** 时间控制 **/
		public static var time:TimeObj;
		/** 对象桥,Flex中慎用,可能出现不跨域问题! **/
		public static var bridge:ObjBridge;
		/** 下载 **/
		public static var loader:Load;
		/** 数据 **/
		public static var dataControl:DataControl;
		/** 数据 **/
		public static var dataManage:DataManage;
		/** 多语言包 **/
		public static var language:LanguageManage;
		/** 系统使用的对象池(框架使用) **/
		public static var speedFact:SpeedFact;
		/** U2对象 **/
		public static var u2:U2Manage;
		/** 九宫格对象 **/
		public static var grid9:Grid9Manage;
		/** GFile对象 **/
		public static var gfile:GFileManage;
		/** GFile对象 **/
		public static var dfile:DefaultGFileManage;
		/** 框架数据 **/
		public static var info:DataModel;
		
		public function g(e:Enforcer) { }
		/** 初始化框架 **/
		public static function init():void
		{
			if (id == "")
			{
				startTime	 = new Date().time;
				id			 = startTime.toString(36) + "." + int(Math.random() * 100000).toString(36) + int(Math.random() * 100000).toString(36);
				speedFact	 = new SpeedFact();
				worker		 = new WorkerManage();
				log			 = new Log();
				logType		 = new LogType();
				status		 = new Status();
				/**
				 * 根据用户的OS系统去设置用户的OS名称
				 * WIN 11,4,402,278  SWF系统运行
				 * AND 11,6,602,167 安卓
				 * IOS 11,6,602,169
				 */
				switch(Capabilities.version.substr(0, 3))
				{
					case "AND":
						status.os = "Android";
						break;
					case "IOS":
						status.os = "IOS";
						break;
					case "WIN":
						if (Capabilities.playerType == "Desktop")
						{
							status.os = "AIR";
						}
						else
						{
							status.os = "SWF";
						}
						break;
				}
				event		 = new EventManage();
				time		 = new TimeObj();
				bridge		 = new ObjBridge();
				loader		 = new Load();
				language	 = new LanguageManage();
				dataControl	 = new DataControl();
				dataManage	 = new DataManage();
				u2			 = new U2Manage();
				grid9		 = new Grid9Manage();
				gfile		 = new GFileManage();
				dfile		 = new DefaultGFileManage();
				info		 = new DataModel(new Object());
				log.pushLog(g, LogType._Frame, "GaGaFrame ID : " + id);
				log.pushLog(g, LogType._Frame, "System OS : " + status.os);
			}
		}
		
		/** JSON将一个Object对象转换为String **/
		public static function jsonGetStr(o:Object):String { return JSON.stringify(o); }
		/** JSON将一个String对象转换为Object **/
		public static function jsonGetObj(s:String):Object { return JSON.parse(s); }
		
		/**
		 * 更加快速的日志,和trace一样.
		 */
		public static function mlog(...args):void
		{
			log.pushMinLog(args);
		}
	}
}
class Enforcer{}