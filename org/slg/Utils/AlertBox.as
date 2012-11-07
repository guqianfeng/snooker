package org.slg.Utils
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.display.SimpleButton;
	import org.slg.Utils.MemoryCleaner;
	import gs.TweenLite;
	import gs.easing.*;
	
	public class AlertBox extends MovieClip
	{
		private var type:int;
		private var myFunction:Function;
		private var CancelFunction:Function;
		
		public function showAlert(content:String, title:String = null, _type:int = 0, _functionOk:Function = null, _functionCancel:Function = null):void
		{
			type = _type;
			myFunction = _functionOk;
			CancelFunction = _functionCancel;
			this.visible = true;
			this.alpha = 0;
			TweenLite.to(this, 0.3, { alpha:1, ease:Linear.easeOut } );
			this.txt.text = content;
			this.txt.mouseEnabled = false;
			this.txt_title.text = title;
			this.txt_title.mouseEnabled = false;
			if (type == 0)
			{
				//无需确认的对话框
				btn_ok.visible = true;
				btn_cancel.visible = false;
				btn_ok.x = 474; btn_ok.y = 405;
			}
			else if (type == 1)
			{
				//需要确认的对话框
				btn_ok.visible = true;
				btn_cancel.visible = true;
				btn_ok.x = 422; btn_ok.y = 405;
				btn_cancel.x = 515; btn_cancel.y = 405;
			}
			setBtnEvent();
		}
		private function setBtnEvent(bl:Boolean = true):void
		{
			if (bl)
			{
				if (type == 1) 
					btn_cancel.addEventListener(MouseEvent.CLICK, onCancelBtnClickHandler, false, 0, true);
				btn_ok.addEventListener(MouseEvent.CLICK, onOkBtnClickHandler, false, 0, true);
				alert_close.addEventListener(MouseEvent.CLICK, onAlertCloseClickHandler, false, 0, true);
			}
			else
			{
				if (type == 1) 
					btn_cancel.removeEventListener(MouseEvent.CLICK, onCancelBtnClickHandler);
				btn_ok.removeEventListener(MouseEvent.CLICK, onOkBtnClickHandler);
				alert_close.removeEventListener(MouseEvent.CLICK, onAlertCloseClickHandler);
			}
		}
		private function onCancelBtnClickHandler(evt:MouseEvent):void
		{
			hide();
			if (CancelFunction != null) CancelFunction();
		}
		private function onOkBtnClickHandler(evt:MouseEvent):void
		{
			hide();
			if (myFunction != null)	myFunction();
		}
		private function onAlertCloseClickHandler(evt:MouseEvent):void
		{
			hide();
		}
		public function hide():void
		{
			TweenLite.to(this, 0.3, { alpha:0, ease:Linear.easeOut, onComplete:hideMe} );
		}
		private function hideMe():void
		{
			this.visible = false;
			setBtnEvent(false);
		}
		public function kill():void
		{
			MemoryCleaner.removeMc(this);
		}
	}
}