package data {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author JackyGu
	 * 用于检测MouseMove时间中鼠标移动，何时结束，何时开始，以及位置
	 */
	public class MouseMovingEvent extends EventDispatcher{
		private var timer:Timer;
		private var array:Array;
		private var object:Object;
		private var status:int;//状态，0-动，1-停
		
		public var dataOfStop:Object;//停止时的位置等信息
		public var dataOfStart:Object;//开始移动时的位置等信息
		
		public static const MOVING_STOP:String = "MOVING_STOP";
		public static const MOVING_START:String = "MOVING_START";
		
		public function MouseMovingEvent(interval:Number) {
			//interval为检测时间段
			array = new Array();
			timer = new Timer(interval, 0);
			timer.addEventListener(TimerEvent.TIMER, onTimerHandler);
			status = 1;
			timer.start();
		}
		public function update(_data:Object):void {
			//data为检测内容，如表示鼠标位置的stageX, stageY
			//扩展功能，可以比较任何对象
			if (status == 1) {
				status = 0;
				timer.start();
				dataOfStart = _data;
				dispatchEvent(new Event(MOVING_START));
			}else {
				object = _data;
			}
		}
		private function onTimerHandler(event:TimerEvent):void {
			if (array.length > 3) array.pop();
			array.unshift(object);
			if (isSame(array[0], array[1]) && !isSame(array[1], array[2])) {
				dataOfStop = array[0];
				timer.stop();
				status = 1;
				dispatchEvent(new Event(MOVING_STOP));
			}
		}
		public static function isSame(obj1:Object, obj2:Object):Boolean {
			var b1:ByteArray = new ByteArray();
			var b2:ByteArray = new ByteArray();
			b1.writeObject(obj1);
			b2.writeObject(obj2);
			
			// compare the lengths first
			var size:uint = b1.length;
			if (b1.length == b2.length) {
				b1.position = 0;
				b2.position = 0;
				// then the bits
				while (b1.position < size) {
					var v1:int = b1.readByte();
					if (v1 != b2.readByte()) {
						return false;
					}
				}
			}
			if (b1.toString() == b2.toString()) {
				return true;
			}
			return false;
		}
	}
}