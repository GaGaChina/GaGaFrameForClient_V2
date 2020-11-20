package cn.wjj.display.filter 
{
	import flash.geom.ColorTransform;
	
	/**
	 * 颜色调整的类型
	 * 
	 * @author GaGa
	 */
	public class ColorTransType 
	{
		/** [00000]空类型 **/
		public static const normal:ColorTransform = new ColorTransform();
		/** 高亮,变白 **/
		public static const light:ColorTransform = new ColorTransform(0.75, 0.75, 0.75, 1, 63, 63, 63);
		
		
		/** [001000]暗色通道 **/
		public static const blackLevel0:ColorTransform = new ColorTransform(0, 0, 0);
		/** [001001]暗色通道 **/
		public static const blackLevel1:ColorTransform = new ColorTransform(0.1, 0.1, 0.1);
		/** [001002]暗色通道,最暗 **/
		public static const blackLevel2:ColorTransform = new ColorTransform(0.2, 0.2, 0.2);
		/** [001003]暗色通道,中等偏暗 **/
		public static const blackLevel3:ColorTransform = new ColorTransform(0.3, 0.3, 0.3);
		/** [001004]暗色通道,中等偏淡 **/
		public static const blackLevel4:ColorTransform = new ColorTransform(0.4, 0.4, 0.4);
		/** [001005]暗色通道,中等偏淡 **/
		public static const blackLevel5:ColorTransform = new ColorTransform(0.5, 0.5, 0.5);
		/** [001006]暗色通道,最淡 */
		public static const blackLevel6:ColorTransform = new ColorTransform(0.6, 0.6, 0.6);
		/** [001007]暗色通道,最淡 */
		public static const blackLevel7:ColorTransform = new ColorTransform(0.7, 0.7, 0.7);
		/** [001008]暗色通道,最淡 */
		public static const blackLevel8:ColorTransform = new ColorTransform(0.8, 0.8, 0.8);
		/** [001009]暗色通道,最淡 */
		public static const blackLevel9:ColorTransform = new ColorTransform(0.9, 0.9, 0.9);
		/** [002001]红色通道 **/
		public static const redLevel1:ColorTransform = new ColorTransform(1, 0.1, 0.1);
		/** [002002]红色通道 **/
		public static const redLevel2:ColorTransform = new ColorTransform(1, 0.2, 0.2);
		/** [002003]红色通道 **/
		public static const redLevel3:ColorTransform = new ColorTransform(1, 0.3, 0.3);
		/** [002004]红色通道 **/
		public static const redLevel4:ColorTransform = new ColorTransform(1, 0.4, 0.4);
		/** [002005]红色通道 **/
		public static const redLevel5:ColorTransform = new ColorTransform(1, 0.5, 0.5);
		/** [002006]红色通道 **/
		public static const redLevel6:ColorTransform = new ColorTransform(1, 0.6, 0.6);
		/** [002007]红色通道 **/
		public static const redLevel7:ColorTransform = new ColorTransform(1, 0.7, 0.7);
		/** [002008]红色通道 **/
		public static const redLevel8:ColorTransform = new ColorTransform(1, 0.8, 0.8);
		/** [002009]红色通道 **/
		public static const redLevel9:ColorTransform = new ColorTransform(1, 0.9, 0.9);
		
		/** 测试使用的 **/
		public static const red:ColorTransform = new ColorTransform(1, 0.5, 0.5);
		/** 测试使用的 **/
		public static const demo:ColorTransform = new ColorTransform(2, 1, 0.2);
		
		public function ColorTransType() { }
		
		public static function getType(id:uint):ColorTransform
		{
			switch (id) 
			{
				case 0:
					return normal;
				case 1000:
					return blackLevel0;
				case 1001:
					return blackLevel1;
				case 1002:
					return blackLevel2;
				case 1003:
					return blackLevel3;
				case 1004:
					return blackLevel4;
				case 1005:
					return blackLevel5;
				case 1006:
					return blackLevel6;
				case 1007:
					return blackLevel7;
				case 1008:
					return blackLevel8;
				case 1009:
					return blackLevel9;
				case 2001:
					return redLevel1;
				case 2002:
					return redLevel2;
				case 2003:
					return redLevel3;
				case 2004:
					return redLevel4;
				case 2005:
					return redLevel5;
				case 2006:
					return redLevel6;
				case 2007:
					return redLevel7;
				case 2008:
					return redLevel8;
				case 2009:
					return redLevel9;
			}
			return normal;
		}
		
		public static function getId(t:ColorTransform):uint
		{
			switch (t) 
			{
				case normal:
					return 0;
				case blackLevel0:
					return 1000;
				case blackLevel1:
					return 1000;
				case blackLevel2:
					return 1002;
				case blackLevel3:
					return 1003;
				case blackLevel4:
					return 1004;
				case blackLevel5:
					return 1005;
				case blackLevel6:
					return 1006;
				case blackLevel7:
					return 1007;
				case blackLevel8:
					return 1008;
				case blackLevel9:
					return 1009;
				case redLevel1:
					return 2001;
				case redLevel2:
					return 2002;
				case redLevel3:
					return 2003;
				case redLevel4:
					return 2004;
				case redLevel5:
					return 2005;
				case redLevel6:
					return 2006;
				case redLevel7:
					return 2007;
				case redLevel8:
					return 2008;
				case redLevel9:
					return 2009;
			}
			return 0;
		}
	}
}