package org.slg.UserManager
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.geom.Matrix;
	import flash.display.Bitmap;
	import flash.geom.Point;
	import flash.display.BitmapData;
	import flash.filters.BitmapFilter;
	import flash.filters.DisplacementMapFilter;
	import flash.filters.DisplacementMapFilterMode;
	import flash.display.BitmapDataChannel;
	import flash.display.GradientType;
	import flash.display.SpreadMethod;
	import flash.events.MouseEvent;

	public class CheckCode extends Sprite 
	{
		private var _drawSprite:Sprite;
		private var _checkCode:String;
		private var txtField:TextField = new TextField();
		
		public function CheckCode() 
		{
			this.addEventListener(MouseEvent.CLICK, onThisClickHandler, false, 0, true);
			addCode();
		}
	  
		private function onThisClickHandler(evt:MouseEvent):void
		{
			addCode();
		}
		private function addCode():void
		{
			_drawSprite = new Sprite();
			var matrx:Matrix = new Matrix();
			matrx.createGradientBox(150, 20, 0, 0, 0);
			_drawSprite.graphics.beginGradientFill(GradientType.RADIAL, [0x470E03, 0xca0000], [1, 1], [0x00, 0xFF], matrx, SpreadMethod.REFLECT ); 
			_drawSprite.graphics.drawRect(0,0,250,22);
			txtField.width=75;
			txtField.height=22;
			txtField.textColor=0xFFFFFF;
			txtField.text = generateCheckCode(4);
		   
			var txtFmt:TextFormat = new TextFormat();
			txtFmt.bold = false;
			txtFmt.italic = false;
			txtFmt.align = "center";
			txtFmt.size = 18;
			txtFmt.color = 0xFAE9A9;
			txtField.setTextFormat(txtFmt);
		   
			_drawSprite.addChild(txtField);
			var bitmapData:BitmapData = new BitmapData(75, 22);
			bitmapData.draw(_drawSprite, new Matrix());
			var filter:BitmapFilter =new DisplacementMapFilter(bitmapData,new Point(2,2),BitmapDataChannel.RED,BitmapDataChannel.RED,Math.random()*5,-Math.random()*8,DisplacementMapFilterMode.WRAP);
			var bitmap=new Bitmap(bitmapData);
			addChild(bitmap);
		}
	   /* Generate four check code */
		private function generateCheckCode(numbers:uint = 4):String
		{
			var ran:Number;
			var number:uint;
			var code:String;
			var checkCode:String = "";
			for (var i:int = 0; i < numbers; i++)
			{
				ran = Math.random();
				number = int(ran * 10000);
				if(number % 2 == 0)
					code = String.fromCharCode(48 + (number % 10));
				else
					code = String.fromCharCode(65 + (number % 26));
				checkCode += code;
			}
			_checkCode = checkCode;
			return checkCode;
		}
		public function get checkCode():String
		{
			return _checkCode;
		}
	}
}
