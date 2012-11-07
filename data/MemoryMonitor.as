package data 
{
	/**
	 * ...内存使用监控器
	 * @author JackyGu
	 */
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.system.System;
	
	public class MemoryMonitor extends Sprite{
		
		private var _txtField:TextField;
	    private var _dataTxtFormat : TextFormat;
		private var timer:Timer;
		
		public function MemoryMonitor(fontSize:uint = 8, fontColor:uint = 0xffffff, interval:Number = 100) {
			// txtField for data
			//trace("MemoryMonitor Initialized");
			_txtField = new TextField();
			_txtField.text = "MemoryMonitor Initialized";
			_dataTxtFormat = new TextFormat();			
			_dataTxtFormat.font = "Tahoma";
			_dataTxtFormat.color = fontColor;
			_dataTxtFormat.size = fontSize;
		
			//_dataTxt = new TextField();
			//_txtField.embedFonts = true;	
			//_txtField.multiline = true;
			_txtField.selectable = false;
			//_txtField.autoSize = TextFieldAutoSize.LEFT;
			_txtField.defaultTextFormat = _dataTxtFormat;
			
			this.addChild(_txtField);
			showTxtData(0);
			
			timer = new Timer(interval);
			timer.addEventListener(TimerEvent.TIMER, onTimerHandler);
			timer.start();
		}
		private function onTimerHandler(event:TimerEvent):void {
			//trace("onTimerHandler");
			showTxtData(System.totalMemory);
		}
		public function stop():void {
			timer.stop();
		}
		public function start():void {
			timer.start();
		}
		private function showTxtData (_memCurrentValue:uint): void 
		{
			//trace(calculateMB(_memCurrentValue));
			//_txtField.htmlText = "memory : <font color='#00CCFF'>" + calculateMB(_memCurrentValue) + " MB (" + calculateKB(_memCurrentValue) + " kb) </font>";
			this._txtField.text = "memory : " + calculateMB(_memCurrentValue) + " MB";
		}
        private function calculateMB(value: uint): Number 
        {
            // calculate MB rounding with two digits
            var newValue: Number = Math.round(value / 1024 / 1024 * 100);          
            return newValue / 100;
        }
		private function calculateKB(value: uint): uint 
        {
            return Math.round(value / 1024);
        }
	}

}