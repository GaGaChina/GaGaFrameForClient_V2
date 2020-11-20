package cn.wjj.data.file 
{
	/**
	 * 文件夹类型
	 * 
	 * @version 1.0.0
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 */
	public class GFileType 
	{
		/** 纯二进制内容 **/
		public static const byte:int = 0;
		/** AMF单个文件 **/
		public static const AMF:int = 1;
		/** AMF列表文件 **/
		public static const AMFList:int = 2;
		/** 图片文件 **/
		public static const bitmapData:int = 3;
		/** 图片文件 **/
		public static const bitmapDataItem:int = 4;
		/** 空白站位符 **/
		public static const blank:int = 7;
		/** 文件队列 **/
		public static const listBase:int = 8;
		/** 多语言内容 **/
		public static const language:int = 9;
		/** 二进制的GFile包中包结构 **/
		public static const packageBox:int = 10;
		/** 载入MP3的二进制 **/
		public static const MP3:int = 11;
		/** 载入MP3 Asset 对象 **/
		public static const MP3Asset:int = 12;
		/** AMFFileListConfig 列表文件 **/
		public static const AMFListConfig:int = 13;
		/** 辅助文件 **/
		public static const assist:int = 14;
		/** UI编辑器图形 **/
		public static const U2Info:int = 15;
		/** UI编辑器图形(自适应图片) **/
		public static const U2BitmapX:int = 16;
		/** 九宫格图形 **/
		public static const Grid9Info:int = 17;
		
		/** SWC文件内容 **/
		//public static var SWC:int = 9;
		
		public function GFileType() { }
	}
}