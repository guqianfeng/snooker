package data 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author JackyGu
	 */
	public class ClockTimer extends MovieClip{
		//计时器
		private var angle:Number = 0;
		private var r:Number;
		private var col:Number;
		private var startFrom:Number;
		private var timer:Timer;
		
		public function ClockTimer(ttlSecond:int, radius:Number, startAngle:Number = 270, color:Number = 0xff0000) {
			var anglePerTimer:Number = ttlSecond / 180;
			r = radius;
			col = color;
			startFrom = startAngle;
			
			timer = new Timer(anglePerTimer * 1000);
			timer.addEventListener(TimerEvent.TIMER, onTimerHandler);
		}
		public function _start():void {
			angle = 0;
			timer.start();
		}
		private function onTimerHandler(event:TimerEvent):void {
			DrawSector(this, 0, 0, r, angle, 270 + angle++, col);
		}
		public function _stop():void {
			timer.stop();
			this.graphics.clear();
		}
		private function DrawSector(mc:MovieClip, x:Number = 200, y:Number = 200, r:Number = 100, angle:Number = 27, startFrom:Number = 270, color:Number = 0xff0000):void{
			/*  
			* mc the movieclip: the container of the sector.  
			* x,y the center position of the sector  
			* r the radius of the sector  
			* angle the angle of the sector  
			* startFrom the start degree counting point : 270 top, 180 left, 0 right, 90 bottom ,  
			* it is counting from top in this example.   
			* color the fil lin color of the sector  
			*/  
			  
			/* start to fill the sector with the variable "color" if you want a sector without filling color ,  
			* please remove next line below.  
			*/  
			mc.graphics.beginFill(color,50); //remove this line to unfill the sector   
			/* the border of the secetor with color 0xff0000 (red) , you could replace it with any color  
			* you want like 0x00ff00(green) or 0x0000ff (blue).  
			*/  
			mc.graphics.lineStyle(0, color);   
			mc.graphics.moveTo(x,y);   
			angle=(Math.abs(angle)>360)?360:angle;   
			var n:Number=Math.ceil(Math.abs(angle)/45);   
			var angleA:Number=angle/n;   
			angleA=angleA*Math.PI/180;   
			startFrom=startFrom*Math.PI/180;   
			mc.graphics.lineTo(x+r*Math.cos(startFrom),y+r*Math.sin(startFrom));   
			for (var i = 1; i <= n; i++) {
				startFrom += angleA; 
				var angleMid = startFrom - angleA / 2;
				var bx = x + r / Math.cos(angleA / 2) * Math.cos(angleMid);
				var by = y + r / Math.cos(angleA / 2) * Math.sin(angleMid);   
				var cx = x + r * Math.cos(startFrom);
				var cy = y + r * Math.sin(startFrom);   
				mc.graphics.curveTo(bx, by, cx, cy);   
			}   
			if(angle!=360)   
			mc.graphics.lineTo(x,y);   
			  
			mc.graphics.endFill(); // if you want a sector without filling color , please remove this line.   
		}   		
	}

}