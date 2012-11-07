package data 
{
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author JackyGu
	 */
	public class SmartTextField extends MovieClip{
		private var textField:TextField;
		public function SmartTextField( text:String = "", textFormat:TextFormat = null, cornerWidth:Number = 10, middleWidth:Number = 100, middleHeight:Number = 0, lineWidth:Number = 1, lineColor:Number = 0x000000) {
			//cornerWidth：四个角的半径
			//middleWidth：中间文本框的宽度
			//middleHeight：中间文本框的高度，如果为0，则可以根据文本内容自适应高度
			textField = new TextField();
			textField.defaultTextFormat = textFormat;
			textField.text = text;
			textField.name = "textField";
			textField.multiline = true;
			textField.selectable = false;
			textField.wordWrap = true;
			textField.x = cornerWidth;
			textField.y = cornerWidth - 2;
			textField.width = middleWidth;
			textField.maxChars = 10000;
			//trace("textWidth = " + textField.textWidth + ", textHeight = " + textField.textHeight + ", width = " + textField.width + ", height = " + textField.height);
			textField.height = textField.textHeight + Number(textFormat.size);
			if (middleHeight == 0) middleHeight = textField.textHeight;// + Number(textFormat.size) / 2;
			
			var lt:Sprite = new STF_LT();
			var rt:Sprite = new STF_RT();
			var lb:Sprite = new STF_LB();
			var rb:Sprite = new STF_RB();
			var up:Sprite = new STF_UP();
			var down:Sprite = new STF_DOWN();
			var left:Sprite = new STF_LEFT();
			var right:Sprite = new STF_RIGHT();
			var middle:Sprite = new STF_MIDDLE();
			var lineFrame:Shape = new Shape();
			lineFrame.graphics.lineStyle(lineWidth, lineColor, 1, true);
			lineFrame.graphics.drawRoundRect(0, 0, cornerWidth * 2 + middleWidth, cornerWidth * 2 + middleHeight, cornerWidth * 2, cornerWidth * 2);
			
			lt.width = cornerWidth; lt.height = cornerWidth;
			lt.x = 0; lt.y = 0;
			
			rt.width = cornerWidth; rt.height = cornerWidth;
			rt.x = cornerWidth + middleWidth; rt.y = 0;
			
			lb.width = cornerWidth; lb.height = cornerWidth;
			lb.x = 0; lb.y = cornerWidth + middleHeight;
			
			rb.width = cornerWidth; rb.height = cornerWidth;
			rb.x = cornerWidth + middleWidth; rb.y = cornerWidth + middleHeight;
			
			up.height = cornerWidth; up.width = middleWidth;
			up.x = cornerWidth; up.y = 0;
			
			down.height = cornerWidth; down.width = middleWidth;
			down.x = cornerWidth; down.y = cornerWidth + middleHeight;
			
			left.height = middleHeight; left.width = cornerWidth;
			left.x = 0; left.y = cornerWidth;
			
			right.height = middleHeight; right.width = cornerWidth;
			right.x = cornerWidth + middleWidth; right.y = cornerWidth;
			
			middle.width = middleWidth; middle.height = middleHeight;
			middle.x = cornerWidth; middle.y = cornerWidth;
			
			this.addChild(lt);
			this.addChild(rt);
			this.addChild(lb);
			this.addChild(rb);
			this.addChild(up);
			this.addChild(left);
			this.addChild(right);
			this.addChild(down);
			this.addChild(middle);
			this.addChild(lineFrame);
			
			this.addChild(textField);
		}
	}
}