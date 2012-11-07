package data 
{
	import flash.display.Sprite;
	import flash.media.Sound;
	import flash.utils.getDefinitionByName;
	/**
	 * ...
	 * @author JackyGu
	 */
	public class MediaEffect extends Sprite{
		public var inBox:Sound;
		public var qiangbangjida:Sound;
		public var qizihit:Sound;
		public var laobanhitqizi:Sound;
		
		public function MediaEffect() {
			var aClass:Class;
			aClass = getDefinitionByName("inBox") as Class;
			inBox = new aClass();
			aClass = getDefinitionByName("qiangbangjida") as Class;
			qiangbangjida = new aClass();
			aClass = getDefinitionByName("qizihit") as Class;
			qizihit = new aClass();
			aClass = getDefinitionByName("laobanhitqizi") as Class;
			laobanhitqizi = new aClass();
		}
	}
}