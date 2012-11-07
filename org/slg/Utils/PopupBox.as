package org.slg.Utils
{
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**可以伸缩的对话框
	 * ...
	 * @author ...
	 */
	public class PopupBox extends MovieClip
	{
		private var txtField:TextField;
		
		public function PopupBox():void
		{
			txtField = new TextField();
			txtField.width = 180;
			txtField.multiline = true;
			txtField.wordWrap = true;
			txtField.selectable = false;
			txtField.textColor = 0xcccccc;
			txtField.setTextFormat(new TextFormat("宋体", 13, 0xcccccc));
			txtField.x = 29;
			txtField.y = -70;
			this.addChild(txtField);
		}
		public function showMessage(txt:String):void
		{
			txtField.text = txt;
			txtField.height = txtField.textHeight + 10;//根据txt求高度
			this.middle.height = txtField.height - 15;
			this.middle.y = -this.bottom.height;
			this.top.y = this.middle.y - this.middle.height;
			this.txtField.y = top.y - 10;
			txtField.text = txt;
		}
		public function move(x:int, y:int):void
		{
			this.x = x;
			this.y = y;
		}
	}
	
}