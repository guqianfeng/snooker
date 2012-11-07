package data {
	
	import flash.display.MovieClip;
	import flash.display.*;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.ui.Mouse;
	import gs.TweenLite;
	import flash.text.TextFormat;
	import it.gotoandplay.smartfoxserver.SmartFoxClient;
	
	public class UserInfo extends Sprite {
		private var sfs:SmartFoxClient;
		
		public function UserInfo(_sfs:*) {
			// constructor code
			sfs = _sfs;
			btnclose.buttonMode = true;
			btnclose.addEventListener(MouseEvent.CLICK, onCloseButtonClickHandler);
			memoScore.addEventListener(MouseEvent.ROLL_OVER, onMemoMouseOverHandler);
			memoRank.addEventListener(MouseEvent.ROLL_OVER, onMemoMouseOverHandler);
			memoPrecision.addEventListener(MouseEvent.ROLL_OVER, onMemoMouseOverHandler);
			memoWin.addEventListener(MouseEvent.ROLL_OVER, onMemoMouseOverHandler);
			memoPower.addEventListener(MouseEvent.ROLL_OVER, onMemoMouseOverHandler);
			memoGold.addEventListener(MouseEvent.ROLL_OVER, onMemoMouseOverHandler);
			memoGoldRank.addEventListener(MouseEvent.ROLL_OVER, onMemoMouseOverHandler);
			memoGrade.addEventListener(MouseEvent.ROLL_OVER, onMemoMouseOverHandler);
			
			memoScore.addEventListener(MouseEvent.ROLL_OUT, onMemoRollOutHandler);
			memoRank.addEventListener(MouseEvent.ROLL_OUT, onMemoRollOutHandler);
			memoPrecision.addEventListener(MouseEvent.ROLL_OUT, onMemoRollOutHandler);
			memoWin.addEventListener(MouseEvent.ROLL_OUT, onMemoRollOutHandler);
			memoPower.addEventListener(MouseEvent.ROLL_OUT, onMemoRollOutHandler);
			memoGold.addEventListener(MouseEvent.ROLL_OUT, onMemoRollOutHandler);
			memoGoldRank.addEventListener(MouseEvent.ROLL_OUT, onMemoRollOutHandler);
			memoGrade.addEventListener(MouseEvent.ROLL_OUT, onMemoRollOutHandler);
			
			hide();
		}
		public function show(userData:UserData):void {
			//初始化
			this.txfUserName.text = unescape(sfs.getActiveRoom().getUser(userData.sysuserid).getVariable("name"));
			this.txfScore.text = "" + userData.score;
			this.txfRank.text = userData.rank + "/" + userData.totalUsers;
			this.txfWin.text = userData.winTimes + "/" + userData.lossTimes + "/" + userData.tieTimes;
			this.txfPrecision.text = userData.maxAngle * userData.gunUsedTimes / userData.gunTotalTimes + "度";
			this.txfPower.text = "" + userData.power;
			this.txfGrade.text = "" + userData.grade;
			this.txfGold.text = "" + userData.gold;
			this.txfGoldRank.text = userData.goldRank + "/" + userData.totalUsers;
			this.vip.visible = userData.userType == 1;//是否显示vip标记		
			this.visible = true;
		}
		public function hide():void {
			this.visible = false;
		}
		private function onCloseButtonClickHandler(event:MouseEvent):void {
			hide();
		}
		var tweenLite:TweenLite;
		private function onMemoRollOutHandler(event:MouseEvent):void {
			if (tweenLite) {
				tweenLite.clear();
				tweenLite = null;
				var smartTextField:SmartTextField = this.getChildByName("stf") as SmartTextField;
				if (smartTextField) {
					this.removeChild(smartTextField);
					smartTextField = null;
				}
			}
		}
		private function onMemoMouseOverHandler(event:MouseEvent):void {
			var mc:MovieClip = event.currentTarget as MovieClip;
			var memoName:String = mc.name;
			var position:Point = new Point(mouseX, mc.y);//箭头位置
			if (tweenLite == null) {
				if (memoName == "memoScore") {
					tweenLite = TweenLite.delayedCall(0.5, showMemo, [position, "用户积分"]);
				}else if (memoName == "memoRank") {
					tweenLite = TweenLite.delayedCall(0.5, showMemo, [position, "用户积分排名：前一个数是名次，后一个是该服务器总用户数"]);
				}else if (memoName == "memoPrecision") {
					tweenLite = TweenLite.delayedCall(0.5, showMemo, [position, "枪棒精度：指枪棒击出时的偏差角度。枪棒使用次数越多，精度越低，偏差角度越大。"]);
				}else if (memoName == "memoWin") {
					tweenLite = TweenLite.delayedCall(0.5, showMemo, [position, "历史成绩：第一个是胜局次数，第二个是负局次数，第三个是平局次数"]);
				}else if (memoName == "memoPower") {
					tweenLite = TweenLite.delayedCall(0.5, showMemo, [position, "最大击球力量"]);
				}else if (memoName == "memoGrade") {
					tweenLite = TweenLite.delayedCall(0.5, showMemo, [position, "用户等级"]);
				}else if (memoName == "memoGold") {
					tweenLite = TweenLite.delayedCall(0.5, showMemo, [position, "用户金币数"]);
				}else if (memoName == "memoGoldRank") {
					tweenLite = TweenLite.delayedCall(0.5, showMemo, [position, "用户财富排名"]);
				}
			}
		}
		private function showMemo(pos:Point, str:String):void {
			//显示提示文本
			var smartTextField:SmartTextField = this.getChildByName("stf") as SmartTextField;
			if (smartTextField) {
				this.removeChild(smartTextField);
			}
			var textFormat:TextFormat = new TextFormat();
			textFormat.font = "Arial";
			textFormat.size = 12;
			textFormat.color = 0xffffff;
			smartTextField = new SmartTextField(str, textFormat, 10, 200, 0, 1, 0xffffff);
			smartTextField.filters = [new GlowFilter(0x000000, 1, 5, 5, 1, 2, false, false)];
			smartTextField.name = "stf";
			smartTextField.x = pos.x;
			smartTextField.y = pos.y - smartTextField.height;
			this.addChild(smartTextField);
		}
	}	
}
