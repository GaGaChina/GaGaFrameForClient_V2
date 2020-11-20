package cn.wjj.tool
{
	public class StringReplace
	{
		public function StringReplace() { }
		
		/**
		 * 设置自动替换的内容
		 * @param str
		 * @param replace		替换的文本内容
		 * @param replaceIn		为空就会替换为空字符串（不过最后一个为replace的时候会有问题）
		 * @return 
		 */
		public static function mateUseStr(str:String, replace:String, replaceIn:String):String
		{
			if (!replace || replace == replaceIn)
			{
				return str;
			}
			/** 原始文本长度 **/
			var l:int = str.length;
			var lr:int = replace.length;
			var li:int = replaceIn.length;
			for (var i:int = 0; i < l; i++)
			{
				//如果有被抓到的值
				if (str.substr(i, lr) == replace)
				{
					str = str.substr(0, i) + replaceIn + str.substr(i + lr);
					l = l - lr + li;
					i = i - lr + li;
				}
			}
			return str;
		}
		/**
		 * 匹配文本是否存在
		 * @param str
		 * @param replace		需要匹配的文本
		 * @param replaceIn		
		 * @return 
		 */
		public static function mateExistStr(str:String, replace:String, replaceIn:String):Boolean
		{
			if (!replace || replace == replaceIn)
			{
				return false;
			}
			/** 原始文本长度 **/
			var l:int = str.length;
			var lr:int = replace.length;
			for (var i:int = 0; i < l; i++)
			{
				//如果有被抓到的值
				if (str.substr(i, lr) == replace)
				{
					return true;
				}
			}
			return false;
		}
		
		/**
		 * 设置自动替换的内容,按匹配顺序用args的顺序
		 * @param str		替换的原始文本
		 * @param replace	替换的文本内容
		 * @param args		按顺序把被替换的东西填充
		 * @return 
		 */
		public static function mateUseArr(str:String, replace:String, args:Array):String
		{
			if (!replace || args == null || args.length == 0)
			{
				return str;
			}
			/** 原始文本长度 **/
			var l:int = str.length;
			var la:int = args.length;
			var lr:int = replace.length;
			var li:int;
			var replaceIn:String;
			/** 已经替换到的变量ID **/
			var argsId:int = 0;
			for (var i:int = 0; i < l; i++)
			{
				//如果有被抓到的值
				if (str.substr(i, lr) == replace)
				{
					if (la > argsId)
					{
						replaceIn = String(args[argsId]);
						li = replaceIn.length;
						str = str.substr(0, i) + replaceIn + str.substr(i + lr);
						l = l - lr + li;
						i = i - lr + li;
					}
					argsId++;
					if (la <= argsId)
					{
						return str;
					}
				}
			}
			return str;
		}
	}
}