package cn.wjj.gagaframe.client.system
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import cn.wjj.g;
	import cn.wjj.time.TimeToString;
	
	public class ErrorBlue extends Sprite
	{
		private var close:Sprite;
		
		/** 错误的信息 **/
		private var info:Object;
		private var text:TextField;
		
		public function ErrorBlue(){}
		
		public function setInfo(info:Object):void
		{
			if(g.bridge.stage && info)
			{
				var stage:Stage = g.bridge.stage;
				this.graphics.clear();
				this.graphics.beginFill(0x0000FF, 1);
				this.graphics.lineStyle(0, 0, 0);
				this.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
				
				this.info = info;
				if(text == null)text = new TextField();
				var format:TextFormat = new TextFormat();
				format.size = 14;
				if(stage.stageWidth > 2000 || stage.stageHeight > 2000)
				{
					format.size = 24;
				}
				else if(stage.stageWidth > 1000 || stage.stageHeight > 1000)
				{
					format.size = 16;
				}
				format.bold = true
				format.color = 0xFFFFFF;
				text.defaultTextFormat = format;
				text.setTextFormat(format);
				text.type = TextFieldType.INPUT;
				text.multiline = true;
				text.wordWrap = true;
				text.x = 10;
				text.y = 10;
				text.width = stage.stageWidth - 20;
				text.height = stage.stageHeight - 20;
				var s:String = getErrorString();
				text.text = s;
				this.addChild(text);
				
				if(close == null)close = new Sprite();
				if(close.numChildren)close.removeChildren(0, close.numChildren - 1);
				close.graphics.clear();
				close.graphics.lineStyle(0, 0, 0);
				close.graphics.beginFill(0xFFFFFF);
				var w:uint = uint(stage.width / 10);
				var h:uint = uint(stage.height / 10);
				if(w < h)
				{
					w = h;
				}
				else
				{
					h = w;
				}
				close.graphics.drawRect(0, 0, w, h);
				var shape:Shape = new Shape();
				var mw:uint = int(h / 2);
				shape.graphics.lineStyle(uint(mw / 3), 0xFF0000, 1);
				shape.graphics.moveTo(0, 0);
				shape.graphics.lineTo(mw, mw);
				shape.graphics.moveTo(mw, 0);
				shape.graphics.lineTo(0, mw);
				shape.x = int((w - shape.width)/2);
				shape.y = int((h - shape.height)/2);
				close.addChild(shape);
				close.x = stage.stageWidth - close.width;
				close.y = 0;
				close.addEventListener(MouseEvent.CLICK, mouseDo);
				this.addChild(close);
				System.setClipboard(s);
			}
			else
			{
				dispose();
			}
		}
		
		/** 获取错误信息 **/
		private function getErrorString():String
		{
			var s:String = "";
			s += "ID : " + info.id + "\n";
			s += "RunTime : " + TimeToString.UseTimeToString(info.time) + "\n";
			s += "Time : " + TimeToString.NumberToMinTime(info.nt, true, true, "/", ":") + "\n";
			s += "Name : " + info.name + "\n";
			s += "Massage : " + info.msg + "\n";
			s += "Info : " + info.info + "\n";
			s += "System : " + g.jsonGetStr(info.dev) + "\n";
			return s;
		}
		
		private function mouseDo(e:MouseEvent):void
		{
			dispose();
		}
		
		private function dispose():void
		{
			info = null;
			if(text)
			{
				if(text.parent)text.parent.removeChild(text);
				text = null;
			}
			if(close)
			{
				close.removeEventListener(MouseEvent.CLICK, mouseDo);
				if(close.parent) close.parent.removeChild(close);
				close = null;
			}
			if(this.parent)this.parent.removeChild(this);
		}
	}
}