package data 
{
	import flash.geom.Point;
	/**
	 * ...
	 * @author Jacky Gu
	 */
	public class dataTransmission extends Object{
		//public var playerId:uint;
		public var target:Point;//目标位置
		public var gunXPower:Number;//枪棒x位置，用于计算力量，最大为Config.maxGunPull，最小为0
		public var maxPower:Number;//最大力量
		public var type:String = "shoot";
		
		public function dataTransmission():void {
		}
	}

}