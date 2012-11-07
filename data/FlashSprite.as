package data 
{
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import gs.TweenLite;
	import gs.TweenFilterLite;
	import gs.TweenMax;
	import gs.easing.Quad
	/**
	 * ...
	 * @author JackyGu
	 * 用于让sprite闪烁
	 */
	public class FlashSprite 
	{
		private var flashCount:int;
		private var flashTotal:int;
		private var glowFilter:GlowFilter;
		private var interval:Number;
		private var mc:Sprite;
		private var _times:int;
		public var isrunning:Boolean;//是否正在闪烁
		
		public function FlashSprite(sprite:Sprite, speed:int = 300, color:Number = 0xffffff, times:int = 0, autorun:Boolean = true) {
			//闪烁Sprite，times为次数，如果为0则永久闪烁, speed为闪烁速度
			_times = times;
			mc = sprite;
			sprite.filters = [new GlowFilter(color, 1, 10, 10, 2, 1)];
			interval = speed / 1000;
			glowFilter = GlowFilter(sprite.filters[0]);
			if (autorun) {
				start();
			}
		}
		private function flashSprite1():void {
			//由亮变暗
			if (flashCount < flashTotal || flashTotal <= 0) {
				TweenMax.to(mc, interval, {glowFilter: { blurX: 20, blurY: 20}, ease:Quad.easeOut, onComplete: flashSprite2 } );
				flashCount++;
			}
		}
		private function flashSprite2():void {
			//由暗变亮
			TweenMax.to(mc, interval, {glowFilter: { blurX: 10, blurY: 10}, ease:Quad.easeIn, onComplete:flashSprite1} );
		}
		public function stop():void {
			isrunning = false;
			mc.filters = null;
			flashTotal = 1;
			flashCount = flashTotal + 1;
		}
		public function start():void {
			restart();
		}
		public function restart():void {
			isrunning = true;
			flashTotal = _times;
			flashCount = 0;
			flashSprite1();
		}
	}

}