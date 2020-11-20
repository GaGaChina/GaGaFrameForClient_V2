package cn.wjj.data.file 
{
	
	/**
	 * BitmapData的二进制转换类
	 * 
	 * 
	 * @version 1.0.0
	 * @author GaGa <wjjhappy@gmail.com>
	 * @copy 王加静 <www.5ga.cn>
	 * @date 2013-06-09
	 */
	public class GBitmapDataType
	{
		/** 压缩图片的方式,抽取BitmapData,然后ZIP压缩 **/
		public static const compressBitmapZip:int = 0;
		/** 压缩图片的方式,抽取BitmapData,然后7z压缩 **/
		public static const compressBitmap7z:int = 1;
		/** 把图片的原始二进制文件保存起来,直接用原始的品质 **/
		public static const compressByte:int = 2;
		/** 抽取BitmapData,然后用PNG普通模式压缩 **/
		public static const compressBytePNG:int = 3;
		/** 抽取BitmapData,然后走PNG快速压缩模式 **/
		public static const compressBytePNGSpeed:int = 4;
		/** 抽取BitmapData,然后走JPG的100%品质保存 **/
		public static const compressByteJPG100:int = 5;
		/** 抽取BitmapData,然后走JPG的95%品质保存 **/
		public static const compressByteJPG95:int = 6;
		/** 抽取BitmapData,然后走JPG的90%品质保存 **/
		public static const compressByteJPG90:int = 7;
		/** 抽取BitmapData,然后走JPG的85%品质保存 **/
		public static const compressByteJPG85:int = 8;
		/** 抽取BitmapData,然后走JPG的80%品质保存 **/
		public static const compressByteJPG80:int = 9;
		/** 抽取BitmapData,然后走JPG的75%品质保存 **/
		public static const compressByteJPG75:int = 10;
		/** 抽取BitmapData,然后走JPG的70%品质保存 **/
		public static const compressByteJPG70:int = 11;
		/** 抽取BitmapData,然后走JPG的60%品质保存 **/
		public static const compressByteJPG60:int = 12;
		/** 抽取BitmapData,然后走JPG的50%品质保存 **/
		public static const compressByteJPG50:int = 13;
		/** 抽取BitmapData,然后走JPG的40%品质保存 **/
		public static const compressByteJPG40:int = 14;
		/** 抽取BitmapData,然后走JPG的30%品质保存 **/
		public static const compressByteJPG30:int = 15;
		/** 抽取BitmapData,然后走JPG的20%品质保存 **/
		public static const compressByteJPG20:int = 16;
		/** 抽取BitmapData,然后走JPG的10%品质保存 **/
		public static const compressByteJPG10:int = 17;
		
		public function GBitmapDataType():void { }
	}
}