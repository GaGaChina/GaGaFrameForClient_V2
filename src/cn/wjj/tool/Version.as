package cn.wjj.tool 
{
	/**
	 * 版本管理的一些应用
	 * @author GaGa
	 */
	public class Version
	{
		
		public function Version() { }
		
		/** 对某一个文件进行版本升级 **/
		public static function add(ver:String):String
		{
			var arr:Array = ver.split(".");
			var t:uint = 0;
			var c:uint = 0;
			var e:uint = 0;
			var l:uint = arr.length;
			if (l > 0)
			{
				if(l == 1)
				{
					t = uint(Number(arr[0]));
				}
				else if(l == 2)
				{
					t = uint(Number(arr[0]));
					c = uint(Number(arr[1]));
				}
				else
				{
					t = uint(Number(arr[0]));
					c = uint(Number(arr[1]));
					e = uint(Number(arr[2]));
				}
			}
			e++;
			if(e > 9999)
			{
				e = 0;
				c++;
				if(c > 999)
				{
					c = 0;
					t++;
				}
			}
			return t + "." + c + "." + e;
		}
		
		/**
		 * "1.2.0",ver1 > ver2 返回true , 一样也返回false
		 * 查询是否需要版本更新
		 * @param ver1	服务器版本
		 * @param ver2	本地版本
		 * @return 
		 */
		public static function compare(ver1:String , ver2:String):Boolean
		{
			var a1:Array = ver1.split(".");
			var a2:Array = ver2.split(".");
			var t1:uint = 0, c1:uint = 0, e1:uint = 0;
			var t2:uint = 0, c2:uint = 0, e2:uint = 0;
			var l:uint = a1.length;
			if (l > 0)
			{
				if (l == 1)
				{
					t1 = uint(Number(a1[0]));
				}
				else if (l == 2)
				{
					t1 = uint(Number(a1[0]));
					c1 = uint(Number(a1[1]));
				}
				else
				{
					t1 = uint(Number(a1[0]));
					c1 = uint(Number(a1[1]));
					e1 = uint(Number(a1[2]));
				}
			}
			l = a2.length;
			if (l > 0)
			{
				if (l == 1)
				{
					t2 = uint(Number(a2[0]));
				}
				else if (l == 2)
				{
					t2 = uint(Number(a2[0]));
					c2 = uint(Number(a2[1]));
				}
				else
				{
					t2 = uint(Number(a2[0]));
					c2 = uint(Number(a2[1]));
					e2 = uint(Number(a2[2]));
				}
			}
			if (t1 > t2)
			{
				return true;
			}
			else if (t1 == t2)
			{
				if (c1 > c2)
				{
					return true;
				}
				else if (c1 == c2)
				{
					if (e1 > e2)
					{
						return true;
					}
				}
			}
			return false;
		}
		
		/**
		 * 合并二个版本号,不会升级到999
		 * "1.2.0","1.2.0" = "2.4.0"
		 * 
		 * @param ver1
		 * @param ver2
		 * @return 
		 */
		public static function merge(ver1:String , ver2:String):String
		{
			return mergeAuto(ver1, ver2, false);
		}
		
		/**
		 * 合并二个版本号
		 * @param	ver1
		 * @param	ver2
		 * @param	auto999		是否升级到999版本
		 * @return
		 */
		public static function mergeAuto(ver1:String , ver2:String, auto999:Boolean):String
		{
			var a1:Array = ver1.split(".");
			var a2:Array = ver2.split(".");
			var t1:uint = 0, c1:uint = 0, e1:uint = 0;
			var t2:uint = 0, c2:uint = 0, e2:uint = 0;
			var l:uint = a1.length;
			if (l > 0)
			{
				if (l == 1)
				{
					t1 = uint(Number(a1[0]));
				}
				else if (l == 2)
				{
					t1 = uint(Number(a1[0]));
					c1 = uint(Number(a1[1]));
				}
				else
				{
					t1 = uint(Number(a1[0]));
					c1 = uint(Number(a1[1]));
					e1 = uint(Number(a1[2]));
				}
			}
			l = a2.length;
			if (l > 0)
			{
				if (l == 1)
				{
					t2 = uint(Number(a2[0]));
				}
				else if (l == 2)
				{
					t2 = uint(Number(a2[0]));
					c2 = uint(Number(a2[1]));
				}
				else
				{
					t2 = uint(Number(a2[0]));
					c2 = uint(Number(a2[1]));
					e2 = uint(Number(a2[2]));
				}
			}
			var t3:uint = t1 + t2;
			var c3:uint = c1 + c2;
			var e3:uint = e1 + e2;
			if (auto999)
			{
				if (e3 > 9999)
				{
					c3 += Math.floor(e3 / 9999);
					e3 = e3 % 9999;
				}
				if (c3 > 999)
				{
					t3 += Math.floor(c3 / 999);
					c3 = c3 % 999;
				}
			}
			return t3 + "." + c3 + "." + e3;
		}
	}
}