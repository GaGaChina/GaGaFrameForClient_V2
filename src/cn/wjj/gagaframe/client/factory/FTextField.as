package cn.wjj.gagaframe.client.factory
{
	import flash.text.TextField;
	
	/**
	 * 仓库管理类,提供Shape的管理
	 * @author GaGa
	 */
	public class FTextField extends TextField
	{
		/** 初始化 Shape **/
		public function FTextField():void
		{
			super();
		}
		
		/** 移除,清理,并回收 **/
		public function dispose():void
		{
			if (this.parent) this.parent.removeChild(this);
		}
		
		/**
		 * 创建新的 TextField 实例。在创建 TextField 实例后，调用父 DisplayObjectContainer 对象的 addChild() 或 addChildAt() 方法可将 TextField 实例添加到显示列表中。
		 * 文本字段的默认大小是 100 x 100 个像素。
		 */
		public static function instance():FTextField
		{
			return new FTextField();
		}
		
		/*
		if (o.x != 0) o.x = 0;
		if (o.y != 0) o.y = 0;
		if (o.z != 0) o.z = 0;
		if (o.rotation != 0) o.rotation = 0;
		if (o.rotationX != 0) o.rotationX = 0;
		if (o.rotationY != 0) o.rotationY = 0;
		if (o.rotationZ != 0) o.rotationZ = 0;
		if (o.width != 100) o.width = 100;
		if (o.height != 100) o.height = 100;
		if (o.scaleX != 1) o.scaleX = 1;
		if (o.scaleY != 1) o.scaleY = 1;
		if (o.scaleZ != 1) o.scaleZ = 1;
		if (o.visible != true) o.visible = true;
		if (o.alpha != 1) o.alpha = 1;
		if (o.cacheAsBitmap != false) o.cacheAsBitmap = false;
		if (o.name != "") o.name = "";
		if (o.text != "") o.text = "";
		if (o.htmlText != "") o.htmlText = "";
		if (o.alwaysShowSelection != false) o.alwaysShowSelection = false;
		if (o.antiAliasType != "advanced") o.antiAliasType = "advanced";
		if (o.autoSize != "none") o.autoSize = "none";
		if (o.condenseWhite != false) o.condenseWhite = false;
		if (o.border != false) o.border = false;
		if (o.borderColor != 0x000000) o.borderColor = 0x000000;
		if (o.background != false) o.background = false;
		if (o.backgroundColor != 0xFFFFFF) o.backgroundColor = 0xFFFFFF;
		if (o.displayAsPassword != false) o.displayAsPassword = false;
		if (o.embedFonts != false) o.embedFonts = false;
		if (o.gridFitType != "pixel") o.gridFitType = "pixel";
		if (o.maxChars != 0) o.maxChars = 0;
		if (o.mouseWheelEnabled != true) o.mouseWheelEnabled = true;
		if (o.multiline != false) o.multiline = false;
		if (o.restrict != null) o.restrict = null;
		if (o.selectable != true) o.selectable = true;
		if (o.sharpness != 0) o.sharpness = 0;
		if (o.textColor != 0x000000) o.textColor = 0x000000;
		if (o.thickness != 0) o.thickness = 0;
		if (o.type != "dynamic") o.type = "dynamic";
		if (o.useRichTextClipboard != false) o.useRichTextClipboard = false;
		if (o.wordWrap != false) o.wordWrap = false;
		if (o.filters != null) o.filters = null;
		if (o.mask != null) o.mask = null;
		if (o.opaqueBackground  != null) o.opaqueBackground  = null;
		if (o.scale9Grid  != null) o.scale9Grid  = null;
		o.defaultTextFormat = new TextFormat();
		 * 
		 **/
	}
}