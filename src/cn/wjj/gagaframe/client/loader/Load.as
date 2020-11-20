package cn.wjj.gagaframe.client.loader
{
	
	import cn.wjj.g;
	
	/**
	 * 下载模块
	 * 可以新建一个队列，然后向这个队列里加入数据。
	 * this.addLoader(url,"初始化加载");
	 * 
	 * @version 0.6.5
	 * @author GaGa wjjhappy@Gmail.com
	 * @copy 王加静 www.5ga.cn
	 * @date 2011-12-01
	 */
	public class Load
	{
		/** 下载进程管理工具 **/
		internal var farm:Farm;
		/** 下载网速计算 **/
		internal var speed:LoadSpeed;
		/** 全新的资源管理模块 **/
		public var asset:AssetManage;
		/** [完全屏蔽请使用isLogError在开启]是否使用Log输出日志 **/
		public var isLog:Boolean = true;
		/** [绕开isLog]是否使用Log输出严重错误 **/
		public var isLogError:Boolean = true;
		/** 是否检查输出的OS的尺寸 **/
		public var config_checkSOSize:Boolean = true;
		/** 如果这个参数为true,Trace [2011年12月31日 下午 04:16:23 星期六 毫秒:040] 这样的时间,如果是false就是[2011/11/31 AM12:32:30] **/
		public var config_ShowTimeType:Boolean = false;
		/** 网速模块 : 是否计算Loader的下载速度 **/
		public var config_runSpeed:Boolean = true;
		/** 网速模块 : 自动删除多少时间之前的数据,毫秒 **/
		public var config_autoDelProgressTime:Number = 10000;
		/** 网速模块 : 通过几秒内的时间去计算网速,毫秒 **/
		public var config_useSpeedTime:Number = 10000;
		/** 抽取Class对象的时候是否从本地 **/
		public var config_getClassInRoot:Boolean = false;
		
		public function Load()
		{
			asset = new AssetManage();
			farm = new Farm()
			speed = new LoadSpeed();
		}
		
		/** 查看Loader下载是否在开启 **/
		public function isRuning():Boolean
		{
			return farm.isRuning();
		}
		
		/**
		 * 添加单个下载内容
		 * @param vars			可以使用data.XMLLoaderVars函数添加
		 * @param forceStart	true 就强行下载,不管有没有队列,也强制加入一个队列
		 * @return 
		 */
		public function addItem(url:String, forceStart:Boolean = false):Item
		{
			return farm.addItem(url, forceStart);
		}
		
		/** 通过字符串URL,或者Vars实例来获取队列 **/
		public function getItem(url:String):Item
		{
			return farm.getItem(url);
		}
		
		/** 添加一个队列,如果有这个队列名称就返回,没有就添加一个这个队列 **/
		public function addTeam(name:String):Team
		{
			return farm.addTeam(name);
		}
		
		/** 通过字符串队列名称获取队列 **/
		public function getTeam(name:String):Team
		{
			return farm.getTeam(name);
		}
		
		/**
		 * 当一个资源载入完毕的时候运行
		 * @param	info		资源Asset的名称
		 * @param	useName
		 * @param	method		资源下载完毕时要执行的函数.
		 */
		public function setAssetFinishRun(info:String, useName:Boolean = true, method:Function = null):Item
		{
			return asset.asset.assetFinishRun(info, useName, method);
		}
		
		/** 查询一个Item是否下载完毕 **/
		public function isCompleteItem(name:String):Boolean
		{
			if(getItem(name).state == ItemState.FINISH)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		
		/** 添加一个下载的队列 **/
		public function loadXMLConfig(teamName:String, xmlURL:String):LoadXMLConfig
		{
			var load:LoadXMLConfig = new LoadXMLConfig(teamName);
			load.loadXML(xmlURL);
			return load;
		}
		
		/** 获取下载速度 **/
		public function getSpeed():Number
		{
			return speed.getLoaderSpeed();
		}
	}
}