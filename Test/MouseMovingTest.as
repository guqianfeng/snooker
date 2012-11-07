package {
	import data.MouseMovingEvent;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import data.MyMath;
	public class MouseMovingTest extends Sprite {
		
		private var movingStopTest:MouseMovingEvent;

		public function MouseMovingTest():void {
			trace(Math.tan(MyMath.angleToRadian( -100)));
		
			movingStopTest = new MouseMovingEvent(200);
			movingStopTest.addEventListener(MouseMovingEvent.MOVING_STOP, onMovingStopHandler);
			movingStopTest.addEventListener(MouseMovingEvent.MOVING_START, onMovingStartHandler);
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMovingHandler);
		}
		private function onStageMouseMovingHandler(event:MouseEvent):void {
			movingStopTest.update({pos: new Point(event.stageX, event.stageY), name:"hello"});
		}
		private function onMovingStopHandler(event:Event):void {
			info("休息一下 " + movingStopTest.dataOfStop);
		}
		private function onMovingStartHandler(event:Event):void {
			info("开始移动 " + movingStopTest.dataOfStart);
		}
		private function info(text:String):void {
			txt.text = text + "\n" + txt.text;
		}
	}
}