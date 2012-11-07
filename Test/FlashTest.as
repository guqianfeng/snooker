package  
{
	import data.FlashSprite;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author JackyGu
	 */
	public class FlashTest extends Sprite
	{
		private var fs:FlashSprite;
		public function FlashTest() {
			
			fs = new FlashSprite(this.mc2, 300, 0xffffff, 5, false);
			this.btnStart.addEventListener(MouseEvent.CLICK, onStart);
			this.btnStop.addEventListener(MouseEvent.CLICK, onStop);
		}
		private function onStart(event:MouseEvent):void {
			fs.restart();
		}
		private function onStop(event:MouseEvent):void {
			fs.stop();
		}
	}

}