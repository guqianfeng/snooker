package data 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import data.ClockTimer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	import flash.filters.GlowFilter;
	import gs.TweenLite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import com.hexagonstar.util.debug.Debug;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.events.IOErrorEvent;
	import gs.easing.*;
	import it.gotoandplay.smartfoxserver.SmartFoxClient;
	import flash.display.Loader;

	/**
	 * ...
	 * @author JackyGu
	 */
	public class AvatarBar extends MovieClip{
		private var restSecond:int;//余下秒数
		private var alertSecond:int;//开始报警的秒数
		private var ttlSecond:Number;//总计秒数
		
		private var ct:ClockTimer;
		private var timer:Timer;
		private var timerCenterX:Number = 50;
		private var timerCenterY:Number = 65;
		private var timerBackground:flash.display.Sprite;
		private var currScore:int = 0;
		private var txtScore:TextField;
		private var _changeScore:int;
		private var txtName:flash.text.TextField;
		private var netStatus:flash.display.MovieClip;
		public var userData:UserData;
		private var sfs:SmartFoxClient;
		private var playerId:int;
		
		public function AvatarBar(_sfs:*, _playerId:int, _name:String, _userData:UserData, _totalSecond:int = 30, _alertSecond:int = 10):void {
			//注imgBitmapData的宽和高必须为76x76
			//trace("设置计时器");
			sfs = _sfs;
			playerId = _playerId;
			userData = _userData;
			alertSecond = _alertSecond;
			ttlSecond = _totalSecond;
			this.name = _name;
			
			timer = new Timer(1000);

			//用户名
			txtName = new TextField();
			txtName.text = unescape(sfs.getActiveRoom().getUser(userData.sysuserid).getVariable("name"));
			txtName.x = ( 85 - txtName.textWidth) / 2;
			txtName.y = 5;
			txtName.setTextFormat(new TextFormat("宋体", 13, 0xffffff));
			txtName.height = txtName.textHeight * 3;
			txtName.width = txtName.textWidth * 2;
			this.addChild(txtName);
			
			//分数栏
			txtScore = new TextField();
			txtScore.text = String(currScore);
			txtScore.x = (85 - txtScore.textWidth) / 2;
			txtScore.y = 110;
			txtScore.width = txtScore.textWidth * 3;
			txtScore.height = txtScore.textHeight * 2;
			txtScore.setTextFormat(new flash.text.TextFormat("Arial", 20, 0xffffff, true));
			this.addChild(txtScore);
			
			timerBackground = new TimerMask();
			timerBackground.x = timerCenterX;
			timerBackground.y = timerCenterY;
			this.addChild(timerBackground);
			
			//任务栏
			var txtTask:flash.text.TextField = new TextField();
			txtTask.text = playerId == 1?"击红球":"击黑球";
			txtTask.x = (85 - txtTask.textWidth) / 2;
			txtTask.y = 150;
			txtTask.width = txtTask.textWidth * 3;
			txtTask.height = txtTask.textHeight * 2;
			txtTask.setTextFormat(new flash.text.TextFormat("Arial", 13, 0xffffff));
			this.addChild(txtTask);

			//设置计时器
			ct = new ClockTimer(ttlSecond, 65, 270, 0x000000);
			ct.x = timerCenterX;
			ct.y = timerCenterY;
			this.addChild(ct);

			//调用用户头像数据
			var headurl:String = sfs.getActiveRoom().getUser(userData.sysuserid).getVariable("headurl");
			loadHead(headurl);
		}
			
		private function loadHead(url:String):void {
			var load:Loader = new Loader();
			load.contentLoaderInfo.addEventListener(Event.COMPLETE, onHeadLoaded, false, 0, true);
			load.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onHeadLoadError, false, 0, true);
			load.load(new URLRequest(url));
		}
		private function onHeadLoaded(event:Event):void {
			Debug.trace("获得头像图片");
			var loader:Loader = event.target.loader as Loader;
			initAvatarBar(loader);
		}
		private function onHeadLoadError(event:IOErrorEvent):void {
			Debug.trace("找不到用户头像图片");
			//initAvatarBar(touxiang);
		}
		private function initAvatarBar(loader:Loader):void{
			//设置计时器蒙版
			var timerMask:Sprite = new TimerMask();
			timerMask.x = timerCenterX;
			timerMask.y = timerCenterY;
			this.addChild(timerMask);
			ct.mask = timerMask;
			
			//设置Avatar头像
			loader.width = 50;
			loader.height = 50;
			loader.x = timerCenterX - loader.width / 2;
			loader.y = timerCenterY - loader.height / 2;
			if(loader) this.addChild(loader);
			
			//Avatar头像蒙版，使得图片四角变得圆弧形，不同在做图片是加工
			var imgMask:Sprite = new TimerMask();
			imgMask.width = 51;
			imgMask.height = 51;
			imgMask.x = timerCenterX;
			imgMask.y = timerCenterY;
			this.addChild(imgMask);
			
			//添加网络状态标记
			netStatus = new NetStatus();
			netStatus.x = 10;
			netStatus.y = 110;
			this.addChild(netStatus);
			netStatus.gotoAndStop(2);//初始化时跳到黄灯
			
			loader.mask = imgMask;
		}
		private function initTimer():void {
			restSecond = ttlSecond;
			setTimerEvent();
			timerBackground.alpha = 1;
			timer.start();
		}
		public function startClock():void {
			//开始计时
			stopClock();
			initTimer();
			ct._start();
		}		
		private function setTimerEvent(bl:Boolean = true):void {
			if (bl) {
				if(!timer.hasEventListener(TimerEvent.TIMER)) timer.addEventListener(TimerEvent.TIMER, onTimerHandler);
			}else {
				if(timer.hasEventListener(TimerEvent.TIMER)) timer.removeEventListener(TimerEvent.TIMER, onTimerHandler);
			}
		}
		public function changeScore(score:int):void {
			//设置分数, score是增加或减少的分值
			_changeScore = score;
			//trace("add: " + changeScore + ", ttl: " + currScore);
			this.addEventListener(Event.ENTER_FRAME, onEnterFrameHandler);
		}
		private function onEnterFrameHandler(event:Event):void {
			var varScore:int = int(txtScore.text);
			if (varScore < _changeScore) {
				//分数增加
				txtScore.text = String(varScore + 1);
			}else if (varScore > _changeScore) {
				//分数减少
				txtScore.text = String(varScore - 1);
			}else if (varScore == _changeScore) {
				currScore = _changeScore;
				this.removeEventListener(Event.ENTER_FRAME, onEnterFrameHandler);
			}
			txtScore.x = (85 - txtScore.textWidth) / 2;
			var textFormat:flash.text.TextFormat = new flash.text.TextFormat("Arial", 20, 0xffffff, true);
			txtScore.setTextFormat(textFormat);
		}
		private function onTimerHandler(event:TimerEvent):void {
			//trace(restSecond);
			restSecond--;
			if (restSecond < alertSecond) {
				alert();
			}else {
				timerBackground.alpha = 1;
			}
			if (restSecond < -1) {
				//trace("停下");
				stopClock();
				dispatchEvent(new SnookerEvent(SnookerEvent.TIME_OVER, { } ));
			}
		}
		public function stopClock():void {
			setTimerEvent(false);
			timerBackground.alpha = 0;//不计时的时候不显示边框
			timer.stop();
			ct._stop();			
		}
		private function alert():void {
			flash();
			//播放倒计时声音
		}
		private function flash():void {
			//闪烁提醒
			timerBackground.alpha = 1;
			TweenLite.to(timerBackground, 1, {alpha:0.05 } );
		}
		public function get score():int {
			return currScore;
		}
		public function showRoundTrip(dat:Number):void {
			//Debug.trace(txtName.text + "网速: " + String(dat));
			if (dat <= 50) netStatus.gotoAndStop(5);//网速较好，显示绿灯
			else if (dat > 50 && dat <= 200) netStatus.gotoAndStop(4);//网速一般显示黄灯
			else if (dat > 200 && dat <= 400) netStatus.gotoAndStop(3);//网速最慢，显示红灯
			else if (dat > 400 && dat <= 700) netStatus.gotoAndStop(2);//网速最慢，显示红灯
			else if (dat > 700 && dat <= 1000) netStatus.gotoAndStop(1);//网速最慢，显示红灯
			else if (dat > 1000) netStatus.gotoAndStop(6);
		}
	}

}