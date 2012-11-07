package org.slg.Utils
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import caurina.transitions.*;
	import flash.text.TextField;
	import fl.controls.ComboBox;
	
	public class myTween extends MovieClip
	{
		private var transitionBox:ComboBox;
		public function myTween():void
		{
			initComboBox();
			this.btn.addEventListener(MouseEvent.CLICK, onStartBtnClickHandler);
		}
		private function onStartBtnClickHandler(evt:MouseEvent):void
		{
			this.box.visible = true;
			Tweener.addTween(this.box, { y:int(txt_value.text), time:int(txt_time.text), transition:this.transitionBox.selectedItem.label, onComplete:tweenComplete } );
			Tweener.addTween(this.pic, { alpha:Number(txt_alpha.text), time:int(txt_time.text), transition:this.transitionBox.selectedItem.label, onComplete:tweenComplete } );
		}
		private function tweenComplete():void
		{
			Tweener.removeTweens(this.box);
			Tweener.addTween(this.box, { y:50, time:int(txt_time.text), transition:this.transitionBox.selectedItem.label} );
			Tweener.addTween(this.pic, { alpha:1, time:int(txt_time.text), transition:this.transitionBox.selectedItem.label} );
		}
		private function initComboBox():void
		{
			transitionBox = new ComboBox();
			this.addChild(transitionBox);
			transitionBox.x = 218;
			transitionBox.y = 11;
			transitionBox.width = 130;
			transitionBox.addItem( {label:"linear" } );
			transitionBox.addItem( {label:"easeInsine" } );
			transitionBox.addItem( {label:"easeInCubic" } );
			transitionBox.addItem( {label:"easeInQuint" } );
			transitionBox.addItem( {label:"easeIncirc" } );
			transitionBox.addItem( {label:"easeInBack" } );
			transitionBox.addItem( {label:"easeOutSine" } );
			transitionBox.addItem( {label:"easeOutCubic" } );
			transitionBox.addItem( {label:"easeOutQuint" } );
			transitionBox.addItem( {label:"easeOutCirc" } );
			transitionBox.addItem( {label:"easeOutBack" } );
			transitionBox.addItem( {label:"easeInOutSine" } );
			transitionBox.addItem( {label:"easeInOutCubic" } );
			transitionBox.addItem( {label:"easeInOutQuint" } );
			transitionBox.addItem( {label:"easeInOutCirc" } );
			transitionBox.addItem( {label:"easeInOutBack" } );
			transitionBox.addItem( {label:"easeOutInSine" } );
			transitionBox.addItem( {label:"easeOutInCubic" } );
			transitionBox.addItem( {label:"easeOutInQuint" } );
			transitionBox.addItem( {label:"easeOutInCirc" } );
			transitionBox.addItem( {label:"easeOutInBack" } );
			transitionBox.addItem( {label:"easeInQuad" } );
			transitionBox.addItem( {label:"easeInQuart" } );
			transitionBox.addItem( {label:"easeInExpo" } );
			transitionBox.addItem( {label:"easeInElastic" } );
			transitionBox.addItem( {label:"easeInBounce" } );
			transitionBox.addItem( {label:"easeOutQuad" } );
			transitionBox.addItem( {label:"easeOutQuart" } );
			transitionBox.addItem( {label:"easeOutExpo" } );
			transitionBox.addItem( {label:"easeOutElastic" } );
			transitionBox.addItem( {label:"easeInOutQuad" } );
			transitionBox.addItem( {label:"easeInOutQuart" } );
			transitionBox.addItem( {label:"easeInOutExpo" } );
			transitionBox.addItem( {label:"easeInOutElastic" } );
			transitionBox.addItem( {label:"easeInOutBounce" } );
			transitionBox.addItem( {label:"easeOutInQuad" } );
			transitionBox.addItem( {label:"easeOutInQuart" } );
			transitionBox.addItem( {label:"easeOutInExpo" } );
			transitionBox.addItem( {label:"easeOutInElastic" } );
			transitionBox.addItem( {label:"easeOutInBounce" } );
		}
	}
}