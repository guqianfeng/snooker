package  {
	
	import flash.display.MovieClip;
	import data.SmartTextField;
	import flash.filters.GlowFilter;
	import flash.filters.GradientGlowFilter;
	import flash.text.TextFormat;
	
	public class SmartTextFieldDemo extends MovieClip {
		
		
		public function SmartTextFieldDemo() {
			// constructor code
			var textFormat:TextFormat = new TextFormat();
			textFormat.font = "Arial";
			textFormat.size = 14;
			textFormat.color = 0x000000;
			textFormat.bold = true;
			
			var stf:SmartTextField = new SmartTextField("fdsafasdfa", textFormat, 10, 200, 0, 2, 0x000000);
			stf.x = 100;
			stf.y = 100;
			stf.filters = [new GlowFilter(3,45)];
			this.addChild(stf);
			
			//stf.setText("中华人民共和国中华人民共，和国中华人民共和国中华。人民共和国中华人，民共和国古千峰古千峰古千峰古千峰古千峰古千峰");
		}
	}
	
}
