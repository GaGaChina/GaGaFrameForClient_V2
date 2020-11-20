package cn.wjj.display.ui2d.engine 
{
	/**
	 * 根据路径设置类型
	 * @author GaGa
	 */
	public class EnginePathType 
	{
		
		public function EnginePathType() { }
		
		/** 通过路径来获取路径资源的类型 **/
		public static function getPathType(path:String):int
		{
			var type:int = 0;
			if (path)
			{
				if (path.substr(-3, 3) == ".u2")
				{
					type = 1;
				}
				else
				{
					var s:String = path.substr( -4, 4);
					if (s == ".jpg")
					{
						type = 2;
					}
					else if (s == ".png")
					{
						type = 3;
					}
					else
					{
						type = 99;
					}
				}
			}
			return type;
		}
		
	}

}