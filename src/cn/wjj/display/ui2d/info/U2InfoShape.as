package cn.wjj.display.ui2d.info
{
	import cn.wjj.g;
	import cn.wjj.gagaframe.client.log.LogType;
	import cn.wjj.gagaframe.client.speedfact.SByte;
	
	/**
	 * 显示对象
	 * @author GaGa
	 */
	public class U2InfoShape extends U2InfoBase 
	{
		/** 注册点X,x为0的时候的x坐标 **/
		public var offsetX:Number = 0;
		/** 注册点Y,y为0的时候的y坐标 **/
		public var offsetY:Number = 0;
		/** 透明度偏移量,实际的是和这个相乘 **/
		public var offsetAlpha:Number = 1;
		/** 角度偏移量,0度的时候的角度(0-360范围) **/
		public var offsetRotation:Number = 0;
		/** 比例偏移量,比例为1的时候的比例 **/
		public var offsetScaleX:Number = 1;
		/** 比例偏移量,比例为1的时候的比例 **/
		public var offsetScaleY:Number = 1;
		
		/** 全部和绘画相关的数据 **/
		public var drog:Vector.<U2InfoBase>;
		
		public function U2InfoShape(parent:U2InfoBaseInfo):void
		{
			super(parent);
			this.type = U2InfoType.shape;
			drog = new Vector.<U2InfoBase>();
		}
		
		/** 获取这个对象的全部属性信息 **/
		override public function getByte():SByte 
		{
			var b:SByte = SByte.instance();
			b._w_Int32(int(offsetX * 1000));
			b._w_Int32(int(offsetY * 1000));
			var alpha:uint = uint(Number(offsetAlpha * 100));
			if (alpha > 100) alpha = 100;
			b._w_Uint8(alpha);
			b._w_Int32(int(offsetRotation * 1000));
			b._w_Int32(int(offsetScaleX * 1000));
			b._w_Int32(int(offsetScaleY * 1000));
			
			b._w_Int16(drog.length);
			for each (var item:U2InfoBase in drog) 
			{
				b._w_Int16(item.type);
				b._w_CByteArray(item.getByte());
			}
			return b;
		}
		
		/** 读取这个内容 **/
		override public function setByte(b:SByte):void
		{
			try
			{
				offsetX = b._r_Int32() / 1000;
				offsetY = b._r_Int32() / 1000;
				offsetAlpha = b._r_Uint8() / 100;
				offsetRotation = b._r_Int32() / 1000;
				offsetScaleX = b._r_Int32() / 1000;
				offsetScaleY = b._r_Int32() / 1000;
				
				var i:int = b._r_Uint16();
				var d:U2InfoBase;
				var db:SByte;
				var dType:uint = 0;
				while (--i > -1) 
				{
					dType = b._r_Uint16();
					switch (dType) 
					{
						case U2InfoType.drogRect:
							d = new U2InfoDrogRect(this.parent);
							break;
						default:
							g.log.pushLog(this, LogType._UserAction, "未找到对应类型 : " + dType);
							d = null;
					}
					db = b._r_CByteArray();
					if (d)
					{
						d.setByte(db);
						drog.push(d);
					}
				}
			}
			catch(e:Error)
			{
				g.log.pushLog(this, LogType._UserAction, "长度出错,版本不同");
			}
		}
		
		override public function dispose():void 
		{
			super.dispose();
			if (drog)
			{
				for each (var item:U2InfoBase in drog) 
				{
					item.dispose();
				}
				drog.length = 0;
				drog = null;
			}
		}
		
		/** 是否包含了显示对象 **/
		public function haveDisplay():Boolean
		{
			if (drog && drog.length)
			{
				return true;
			}
			return false;
		}
		
		/** 克隆一个对象 **/
		public function clone(parent:U2InfoBaseInfo):U2InfoShape
		{
			var o:U2InfoShape = new U2InfoShape(parent);
			o.offsetX = offsetX;
			o.offsetY = offsetY;
			o.offsetAlpha = offsetAlpha;
			o.offsetRotation = offsetRotation;
			o.offsetScaleX = offsetScaleX;
			o.offsetScaleY = offsetScaleY;
			for each (var item:U2InfoBase in drog) 
			{
				o.drog.push((item as Object).clone(parent));
			}
			return o;
		}
	}
}