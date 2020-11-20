package cn.wjj.gagaframe.client.shortcutkey
{
	public class ShortcutKeyItem
	{
		
		/** 是否按下 Alt 才触发 **/
		public var altKey:Boolean = false;
		/** 是否按下 Ctrl 才触发 **/
		public var ctrlKey:Boolean = false;
		/** 是否按下 Shift 才触发 **/
		public var shiftKey:Boolean = false;
		/** KeyLocation.LEFT (左边) / KeyLocation.RIGHT (左边) 或者 KeyLocation.STANDARD (标准键盘) / KeyLocation.NUM_PAD (数字键盘) **/
		public var keyLocation:Boolean = false;
		/** 包含按下或释放的键的字符代码值 **/
		public var charCode:uint;
		/** 按下或释放的键的键控代码值 **/
		public var keyCode:uint;
		/** 是否使用 keyCode 来判断 **/
		public var isUseKey:Boolean = false;
		
		public function ShortcutKeyItem():void{}
		
		/**
		 * 将一个Object转换为ShortcutKeyItem对象,以便使用代码提示.
		 * @param info
		 * @return 
		 */
		public static function getItem(info:Object):ShortcutKeyItem
		{
			if (info == null)
			{
				return null;
			}
			var item:ShortcutKeyItem = new ShortcutKeyItem();
			return item;
		}
		
		public static function getObject(item:ShortcutKeyItem):Object
		{
			if (item == null)
			{
				return null;
			}
			var temp:Object = new Object();
			temp.alt = item.altKey;
			temp.ctrl = item.ctrlKey;
			temp.shift = item.shiftKey;
			temp.location = item.keyLocation;
			temp.useKey = item.isUseKey;
			temp.useKey = item.isUseKey;
			return temp;
		}
		
		/**
		 * 对比另一个 ShortcutKeyItem 是否是一样的数据
		 * @param item
		 * @return 
		 */
		public function isEqual(item:ShortcutKeyItem):Boolean{
			if (this == item)
			{
				return true;
			}
			if (this.altKey != item.altKey)
			{
				return false;
			}
			if (this.ctrlKey != item.ctrlKey)
			{
				return false;
			}
			if (this.shiftKey != item.shiftKey)
			{
				return false;
			}
			if (this.keyLocation != item.keyLocation)
			{
				return false;
			}
			if (isUseKey)
			{
				if (this.keyCode != item.keyCode)
				{
					return false;
				}
			}
			else
			{
				if (this.charCode != item.charCode)
				{
					return false;
				}
			}
			return true;
		}
	}
}