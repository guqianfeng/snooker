package data 
{
	import fl.motion.easing.Back;
	import flash.display.Loader;
	import flash.display.SimpleButton;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.display.Stage;
	import data.Config;
	import flash.events.IOErrorEvent;
	import flash.filters.GlowFilter;
	import flash.net.URLRequest;
	import flash.text.engine.FontPosture;
	import it.gotoandplay.smartfoxserver.SmartFoxClient;
	import it.gotoandplay.smartfoxserver.data.User;
	import flash.display.Shape;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.geom.Matrix;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.media.SoundTransform;
	import com.hexagonstar.util.debug.Debug;
	import flash.geom.Point;
	import it.gotoandplay.smartfoxserver.SFSEvent;
	import com.adobe.serialization.json.JSON;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.display.MovieClip;
	import gs.TweenLite;
	import flash.text.TextField;
	import flash.utils.getDefinitionByName;
	import flash.display.StageScaleMode;
	import gs.easing.Linear;
	import gs.easing.Bounce;
	import flash.ui.Mouse;
	
	//Box2D
	import Box2D.Collision.*;
	import Box2D.Dynamics.*;
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.*
	import Box2D.Common.Math.b2Vec2;
	/**
	 * ...
	 * @author JackyGu
	 * 登录后的主程序，单人游戏盒双人游戏都用这个类
	 */
	public class Snooker extends Sprite {
		
		//简单数据类型
		private var isScaning:Boolean;//正在瞄准
		private var isStartMoving:Boolean = false;
		private var laobanReadyInBox:Boolean;//老板已经在洞里
		private var startMovingLaobanBall:Boolean = false;//移动球
		private var isCrossWithSmallBall:Boolean;
		private var laobanBallPositionValidate:Boolean = true;//老板球位置是否合法
		private var ifChangeUser:Boolean = true;
		private var ifPunish:Boolean = false;
		private var isSingle:Boolean;
		private var placingPunishBall:Boolean = false;//是否正在放置罚子
		//private var punishedBallPlaced:Boolean = false;//罚子已经放好
		private var punishPlaceAvailable:Boolean = false;
		
		private var whoseTurn:int;
		private var totalTurn:int;
		private var player1userId:int;
		private var player2userId:int;
		private var player1playerId:int;
		private var player2playerId:int;
		private var totalPunishedCount:int = 0;//一共罚子多少，用于编id号
		private var preCollisionBallId:int;//前次与母球碰撞的小球id

		private var b2worldScale:Number = 30;
		private var precision:Number;//枪棒精度
		private var shootPower:Number;
		private var hitRangeAngle:Number;//击打的范围角度

		private var player1Name:String;
		private var player2Name:String;
		private var punishQiziName:String;

		private var _mouseX:Number;
		private var _mouseY:Number;//用于从对方接收对方当前鼠标位置

		//复杂数据类型
		//父类传过来的，不可删除
		private var container:Sprite;
		private var sfs:SmartFoxClient;
		private var myStage:Stage;
		
		//自己产生的类型，退出时需要清除
		private var moveLaobanTimer:Timer;
		private var roundTripTimer:Timer;
		private var showInfoMcTimer:Timer;
		
		private var shootFrom:Point;
		private var previousLaobanPosition:Point;
		private var previousMousePosition:Point;
		
		private var mediaEffect:MediaEffect;
		
		private var holeArray:Array; 
		private var inBoxBallsArray:Array;//进洞球的数组
		private var tunneledBallArray:Array;//飞出桌面球的数组
		private var qiziSequence:Array;//棋子的随机序列
		
		private var board:Sprite;
		private var laobanMoveArea:Sprite;
		private var gun:Sprite;//当前回合的枪棒
		//private var gameOverMc:Sprite;
		private var hitRangeFan:Sprite;
		private var infoMc:Sprite;
		private var punishQiziSprite:Sprite;//罚子的sprite
		
		private var speaker:MovieClip;

		private var laobanFlashSprite:FlashSprite;
		private var punishPlaceAlert:FlashSprite;

		private var scanLine:Shape;
		private var jiao:Shape;
		
		private var currAvatar:AvatarBar;
		private var opponentAvatar:AvatarBar;

		private var b2world:b2World;
		private var laobanBall:b2Body;

		private var contactListener:MyContactListener;
		private var physicalHandler:PhysicalHandler;

		private var userInfo:UserInfo;
		
		private var user1Data:UserData;
		private var user2Data:UserData;
		private var myUserData:UserData;
		private var opponentUserData:UserData;
		
		private var closeFunction:Function = null;//关闭提示窗口时的回调函数
		
		private var mouseMovingEvent:MouseMovingEvent;
		private var pullGunEvent:MouseMovingEvent;
		private var punishPlaceEvent:MouseMovingEvent;

		private var startTime:Date;
		
		public function Snooker(_user1Data:UserData, _user2Data:UserData, _stage:Stage, _container:Sprite, _smartFoxClient:*, 
								_whoseTurn:int, _totalTurn:int, 
								_player1userId:int, _player1playerId:int, _player1Name:String, 
								_player2userId:int, _player2playerId:int, _player2Name:String, _qiziSequence:Array, 
								_isSingle:Boolean = false):void {
			sfs = _smartFoxClient;
			isSingle = _isSingle;
			user1Data = _user1Data;
			if (!isSingle) {
				user2Data = _user2Data;
				if (_user1Data.name == sfs.myUserName) {
					myUserData = _user1Data;
					opponentUserData = _user2Data;
				}else if (_user2Data.name == sfs.myUserName) {
					myUserData = _user2Data;
					opponentUserData = _user1Data;
				}
			}else {
				startTime = new Date();
				doubleTrace("开始时间：" + startTime.getTime());
				myUserData = _user1Data;
				opponentUserData = null;
			}
			//_isSingle为游戏类别，1=双人游戏(默认)，0-单人游戏
			precision = myUserData.gunUsedTimes / myUserData.gunTotalTimes;//枪棒陈旧度
			hitRangeAngle = myUserData.maxAngle * precision;
			//doubleTrace("hitRangeAngle = " + hitRangeAngle + ", gunType = " + myUserData.gunType + ", power = " + myUserData.power);
			myStage = _stage;
			container = _container;
			qiziSequence = _qiziSequence;
			whoseTurn = _whoseTurn;
			totalTurn = _totalTurn;
			
			player1userId = _player1userId;
			player1playerId = _player1playerId;
			player1Name = _player1Name;
			//如果是双人游戏
			if (!isSingle) {
				player2userId = _player2userId;
				player2playerId = _player2playerId;
				player2Name = _player2Name;
			}
			//doubleTrace("whoseTurn = " + whoseTurn + ", totalTurn = " + totalTurn + ", player1: userId = " + player1userId + ", playerId = " + player1playerId + ", name = " + player1Name + ", player2: userId = " + player2userId + ", playerId = " + player2playerId + ", name = " + player2Name);
			/* 注意层的关系，否则会有问题
			 * 从下至上的分层如下
			 * 0- 底层背景图片
			 * 1- 落袋盒子层
			 * 2- 台面图片层
			 * 3- 台面边框层，有Wall类生成可碰撞组
			 * 4- 透明感应层，用于感应鼠标事件
			 * 5- 球层，包括老板球和棋子球
			 * 6- 枪棒gun层
			 * 7- 瞄准线scanLine层
			*/
			//初始化棋子数据
			Config.randomQiziArray(qiziSequence);//将妻子序列Config.qiziArray按照棋子的随机顺序qiziSequence排列
			//doubleTrace("数组: " + Config.qiziArray.join("_"));
			
			//初始化台面
			initTable();
			
			//设置一个无重力的物理世界
			b2world = new b2World(new b2Vec2(0, 0), false);
			physicalHandler = new PhysicalHandler(b2world, container, b2worldScale);
			
			//初始化墙体
			physicalHandler.initWall();
			
			//初始化瞄准范围线，必须要放在透明鼠标感应层下方，否则会出现很多问题
			hitRangeFan = initHitRange();
			container.addChild(hitRangeFan);
			hitRangeFan.visible = false;
			
			//初始化透明鼠标感应层
			initMouseTouchLayer();
			
			//初始化用户状态图
			initAvatarBar();//如果单人游戏，无需显示时间条

			//初始化移动老板球时的界限层
			initHitArea();
			
			//初始化老板球和棋子球，注意必须在initMouseTouchLayer()和initHitAre()后面，否则棋子无法感应到鼠标
			physicalHandler.initBalls();//初始化球体
			laobanBall = physicalHandler.getBodyById(0);//获得老板球，也可以用physicalHandler.getBodyByName("laoban");
			
			//初始化枪棒
			initGun();
			
			//初始化瞄准线
			initScanLine();
			
			//initGameOverMc();
			
			//初始化用户信息窗口
			initUserInformation();

			initSpeaker();//声音开关
			mediaEffect = new MediaEffect();//音效控制
			
			if (!isSingle) setSFSEvent(true);
			else {
				setSFSEvent(false);
				sfs.addEventListener(SFSEvent.onExtensionResponse, onExtensionResponseHandler, false, 0, true);//因为单机需要侦听游戏结束的处理，需要保留此
			}
			
			moveLaobanTimer = new Timer(50, 0);
			
			roundTripTimer = new Timer(10000);//设置网络监测状态
			roundTripTimer.addEventListener(TimerEvent.TIMER, onRoundTripTimerHandler, false, 0, true);
			roundTripTimer.start();
			
			//setCollisionEvent();设定碰撞侦听处理
			contactListener = new MyContactListener(b2world);
			b2world.SetContactListener(contactListener);
			
			initBackBtn();
			initInfoMc();
			
			showFirstInfoMc();
			startTurn();//开始一个回合，主程序入口
			
		}
		private function setMovingLaobanTimer(bl:Boolean):void {
			//设置移动老板球同步的时间
			if (bl) {
				if (!moveLaobanTimer.hasEventListener(TimerEvent.TIMER)) {
					moveLaobanTimer.addEventListener(TimerEvent.TIMER, onMoveLaobanTimerHandler, false, 0, true);//**************这里需要优化
					moveLaobanTimer.start();
				}
			}else {
				if (moveLaobanTimer.hasEventListener(TimerEvent.TIMER)) {
					moveLaobanTimer.stop();
					moveLaobanTimer.removeEventListener(TimerEvent.TIMER, onMoveLaobanTimerHandler);
				}
			}
		}
		private function showFirstInfoMc():void {
			//开局显示提示内容
			if (isSingle) showInfoMc("练习模式");
			else {
				var hitBallColor:String = sfs.playerId == 1 ? "红子":"黑子";
				var jzhundu:String = int((1 - precision) * 10000) / 100 + "%";
				var str:String = "对战模式\n击打       " +  hitBallColor + "\n枪棒精度 " + jzhundu;
				showInfoMc(str);
			}
		}
		private function setSFSEvent(bl:Boolean):void {
			if (bl) {
				if(!isSingle){
					sfs.addEventListener(SFSEvent.onObjectReceived, onObjectReceiveHandler, false, 0, true);
					sfs.addEventListener(SFSEvent.onRoomVariablesUpdate, onRoomVariablesUpdateHandler, false, 0, true);
					sfs.addEventListener(SFSEvent.onExtensionResponse, onExtensionResponseHandler, false, 0, true);
					sfs.addEventListener(SFSEvent.onUserVariablesUpdate, onUserVariablesUpdateHandler, false, 0, true);
				}
				sfs.addEventListener(SFSEvent.onRoundTripResponse, onRoundTripResponseHandler, false, 0, true);
			}else {
				if(sfs.hasEventListener(SFSEvent.onObjectReceived)) sfs.removeEventListener(SFSEvent.onObjectReceived, onObjectReceiveHandler);
				if(sfs.hasEventListener(SFSEvent.onRoomVariablesUpdate)) sfs.removeEventListener(SFSEvent.onRoomVariablesUpdate, onRoomVariablesUpdateHandler);
				if(sfs.hasEventListener(SFSEvent.onExtensionResponse)) sfs.removeEventListener(SFSEvent.onExtensionResponse, onExtensionResponseHandler);
				if(sfs.hasEventListener(SFSEvent.onUserVariablesUpdate)) sfs.removeEventListener(SFSEvent.onUserVariablesUpdate, onUserVariablesUpdateHandler);
				if(sfs.hasEventListener(SFSEvent.onRoundTripResponse)) sfs.removeEventListener(SFSEvent.onRoundTripResponse, onRoundTripResponseHandler);
			}
		}
		private var backBtn:SimpleButton;
		private function initBackBtn():void {
			//加入返回按钮
			backBtn = new Back();
			backBtn.x = 540; backBtn.y = 2;
			container.addChild(backBtn);
			backBtn.addEventListener(MouseEvent.CLICK, onBackButtonClickHandler, false, 0, true);
		}
		private function initInfoMc():void {
			//初始化消息窗口
			if (!infoMc) infoMc = new InfoMc();
			infoMc.x = Config.tableX + Config.tableWidth / 2;
			infoMc.y = 0;
			//TextField(container.getChildByName("txt")).selectable = false;
			container.addChild(infoMc);
			infoMc.getChildByName("btnClose").visible = false;//隐藏关闭按钮
			showInfoMcTimer = new Timer(5000);//提示窗口显示秒数
			showInfoMcTimer.addEventListener(TimerEvent.TIMER, onShowInfoTimeHandler, false, 0, true);
		}
		private function onCloseBtnClickHandler(event:MouseEvent):void {
			hideInfoMc();
			if (closeFunction) closeFunction();
		}
		private function onShowInfoTimeHandler(event:TimerEvent):void {
			hideInfoMc();
			if(closeFunction) closeFunction();
		}
		private function showInfoMc(text:String, closeFun:Function = null):void {
			if (whoseTurn == 1) infoMc.y = 0;
			else infoMc.y = 462;
			setInfoMcVisible(true);
			showInfoMcTimer.start();
			TextField(infoMc.getChildByName("txt")).text = text;
			TweenLite.to(infoMc, 0.2, { scaleX:1, scaleY:1, ease:Linear.easeOut } );
			if (closeFun) closeFunction = closeFun;
			else closeFunction = null;
		}
		private function hideInfoMc():void {
			showInfoMcTimer.stop();
			TweenLite.to(infoMc, 0.2, { scaleX:0.05, scaleY:0.05, ease:Linear.easeIn, onComplete:setInfoMcVisible, onCompleteParams:[false] } );
		}
		private function setInfoMcVisible(bl:Boolean):void {
			if(bl) container.setChildIndex(infoMc, container.numChildren - 1);
			infoMc.visible = bl;
		}
		private function onBackButtonClickHandler(event:MouseEvent):void {
			dispatchEvent(new SnookerEvent(SnookerEvent.GAME_STOP, {message: Config.stopSingleGame}));
		}
		private function initTable():void {
			//加入一个发光层
			var glowLayer:Sprite = new GlowLayer();
			glowLayer.name = "glowlayer";
			glowLayer.x = Config.tableX;
			glowLayer.y = Config.tableY;
			glowLayer.width = Config.tableWidth;
			glowLayer.height = Config.tableWidth;
			glowLayer.filters = new Array(new GlowFilter(0x000000, 1, 50, 50, 2, 2));
			container.addChild(glowLayer);
			
			//加入四个落袋盒
			holeArray = new Array();
			for (var i:int = 0; i < 4; i++) {
				var hole:Sprite = new Hole();
				hole.x = Config.holePositionArray[i].x + Config.tableX;
				hole.y = Config.holePositionArray[i].y + Config.tableY;
				hole.name = "hole" + i;
				container.addChild(hole);
				holeArray.push(hole);
			}
			
			//加入台面图片层
			var table:Sprite = new Table();
			table.name = "table";
			table.x = Config.tableX;
			table.y = Config.tableY;
			container.addChild(table);
		}
		private function initUserInformation():void {
			//初始化用户信息层
			userInfo = new UserInfo(sfs);
			userInfo.x = Config.tableX + Config.tableWidth / 2;
			userInfo.y = Config.tableY + Config.tableWidth / 2;
			userInfo.filters = new Array(new GlowFilter(0x000000, 1, 5, 5, 1, 2, false, false));
			container.addChild(userInfo);
			userInfo.hide();
		}
		private function initMouseTouchLayer():void {
			//加入空层，用于感应鼠标事件
			board = new Board();
			board.x = 0;
			board.y = 0;
			board.width = 700;
			board.height = 550;
			container.addChild(board);
		}
		private function initHitArea():void {
			laobanMoveArea = new LaobanMoveArea();
			laobanMoveArea.x = Config.tableX + Config.tableWidth / 2;
			laobanMoveArea.y = Config.tableY + Config.tableWidth / 2;
			container.addChild(laobanMoveArea);
			showHitArea(false);
		}
		private function showHitArea(bl:Boolean):void {
			if(!isSingle){
				if (sfs.playerId == 1) laobanMoveArea.rotation = 0;
				else if (sfs.playerId == 2) laobanMoveArea.rotation = 180;
			}else {
				laobanMoveArea.rotation = 0;
			}
			//laobanMoveArea.visible = bl;
			if (bl) {
				if(gun.visible == isScaning) laobanMoveArea.visible = true;
				//当处于瞄准状态（即gun.visible=true && isScaning=true）或者当处于移动母球状态（即gun.visible=false && isScaning=false）时
			}else laobanMoveArea.visible = false;
		}
		private function initGun():void {
			var gunClass:Class = getDefinitionByName(user1Data.gunPictureClass) as Class
			
			var _gun:Sprite = new gunClass();
			_gun.name = String(user1Data.gunPictureClass + user1Data.name);
			_gun.cacheAsBitmap = true;
			_gun.filters = new Array(new GlowFilter(0x000000, 1, 5, 5, 0.3, 2, false, false));
			container.addChild(_gun);
			_gun.visible = false;
			//gunArray.push(_gun);
			
			if (!isSingle) {
				gunClass = getDefinitionByName(user2Data.gunPictureClass) as Class;
				_gun = new gunClass();
				_gun.name = String(user2Data.gunPictureClass + user2Data.name);
				_gun.cacheAsBitmap = true;
				_gun.filters = new Array(new GlowFilter(0x000000, 1, 5, 5, 0.3, 2, false, false));
				container.addChild(_gun);
				_gun.visible = false;
				//gunArray.push(_gun);
			}
		}
		private function initScanLine():void {
			scanLine = new Shape();
			container.addChild(scanLine);		
			jiao = new Shape();
			container.addChild(jiao);
			scanLine.visible = false;
			jiao.visible = false;
		}
		private function initAvatarBar():void {
			//设置Avatar头像控件
			var avatar1:AvatarBar = new AvatarBar(sfs, player1playerId, player1Name, user1Data, Config.turnSeconds, Config.alertSeconds);
			if (!isSingle) {
				//如果是对打
				avatar1.addEventListener(SnookerEvent.TIME_OVER, onClockOverHandler, false, 0, true);
				avatar1.addEventListener(MouseEvent.CLICK, onAvatarClickHandler, false, 0, true);
				if (sfs.playerId == player1playerId) avatar1.x = 0;//确保己方头像在左方，便于操作
				else avatar1.x = 600;
				avatar1.y = 40;
				container.addChild(avatar1);
				
				var avatar2:AvatarBar = new AvatarBar(sfs, player2playerId, player2Name, user2Data, Config.turnSeconds, Config.alertSeconds);
				avatar2.addEventListener(SnookerEvent.TIME_OVER, onClockOverHandler, false, 0, true);
				avatar2.addEventListener(MouseEvent.CLICK, onAvatarClickHandler, false, 0, true);
				if (sfs.playerId == player2playerId) avatar2.x = 0;
				else avatar2.x = 600;
				avatar2.y = 40;
				container.addChild(avatar2);
			}else {
				//如果是单练，无需添加avatar2，也不需要对avatar1进行时间控制
				avatar1.addEventListener(SnookerEvent.TIME_OVER, onClockOverHandler, false, 0, true);
				avatar1.addEventListener(MouseEvent.CLICK, onAvatarClickHandler, false, 0, true);
				avatar1.x = 0;
				avatar1.y = 30;
				container.addChild(avatar1);
				currAvatar = avatar1;
			}
		}
		private function onClockOverHandler(event:SnookerEvent):void {
			var avatar:AvatarBar = event.currentTarget as AvatarBar;
			//必须要等所有球停下后，计时器结束才能切换用户
			//doubleTrace("因为时间到，导致checkIfChangeUser");
			if(!isStartMoving && isMyTurn) sfs.sendXtMessage("SnookerRoom", "checkIfChangeUser", {type:"timeout"}, "xml", sfs.getActiveRoom().getId());
		}
		private function onAvatarClickHandler(event:MouseEvent):void {
			//trace("onAvatarClickHandler");
			var avatar:AvatarBar = event.currentTarget as AvatarBar;
			container.setChildIndex(userInfo, container.numChildren - 1);
			userInfo.show(avatar.userData as UserData);
		}
		private function get isMyTurn():Boolean {
			var re:Boolean;
			if (!isSingle) re = sfs.playerId == whoseTurn;
			else re = true;
			return re;
		}
		private function onPlayAgainClickHandler(event:MouseEvent):void {
			
		}
		private function onGotoLobbyClickHandler(event:MouseEvent):void {
			
		}
		
		private function startTurn():void {
			//开始新的击打
			doubleTrace("startTurn");
			setCurrentGun();
			if(scanLine) scanLine.graphics.clear();
			if (!isSingle) {
				//如果是双打
				var currUserId:String = whoseTurn == player1playerId ? player1Name:player2Name;//当前用户的ID，即人人网的uid，对应于AvatarBar的name也用这个uid
				var waitingUserId:String = whoseTurn == player1playerId ? player2Name:player1Name;//对手的ID，即人人网的uid
				
				currAvatar = container.getChildByName(currUserId) as AvatarBar;
				currAvatar.startClock();//开始计时
				
				opponentAvatar = container.getChildByName(waitingUserId) as AvatarBar;
				if (opponentAvatar) opponentAvatar.stopClock();//让对方停止
				
			}else {
				//如果是自己练习
				currAvatar = container.getChildByName(player1Name) as AvatarBar;
			}

			initInboxAndOutBoardBallsArray();
			setEnterFrameEvent(true);
			isScaning = true;//是否在瞄准
			isStartMoving = false;//是否开始移动球
			startMovingLaobanBall = false;//老板球是否开始移动
			//doubleTrace("2- whoseTurn = " + whoseTurn + ", totalTurn = " + totalTurn);
			if (!isSingle) {
				//设置鼠标移动事件控制
				mouseMovingEvent = new MouseMovingEvent(200);
				if(!mouseMovingEvent.hasEventListener(MouseMovingEvent.MOVING_STOP)) mouseMovingEvent.addEventListener(MouseMovingEvent.MOVING_STOP, onMovingStopHandler, false, 0, true);
				if(!mouseMovingEvent.hasEventListener(MouseMovingEvent.MOVING_START)) mouseMovingEvent.addEventListener(MouseMovingEvent.MOVING_START, onMovingStartHandler, false, 0, true);
				pullGunEvent = new MouseMovingEvent(200);
				if(!pullGunEvent.hasEventListener(MouseMovingEvent.MOVING_STOP)) pullGunEvent.addEventListener(MouseMovingEvent.MOVING_STOP, onPullGunStopHandler, false, 0, true);
				if(!pullGunEvent.hasEventListener(MouseMovingEvent.MOVING_START)) pullGunEvent.addEventListener(MouseMovingEvent.MOVING_START, onPUllGunStartHandler, false, 0, true);
				
				initMouseEvent(isMyTurn);
				resetLaobanBall(whoseTurn);//老板球定位，whoseTurn为1或2
			}else {
				initMouseEvent(true);
				resetLaobanBall(1);
			}
			//doubleTrace("3- whoseTurn = " + whoseTurn + ", totalTurn = " + totalTurn);
			showGun(new Point(myStage.mouseX, myStage.mouseY));//如果是当前玩家，初始化时枪棒定位
		}
		private function doubleTrace(msg:String):void {
			Debug.trace(sfs.myUserName + "->" + msg);
			trace(msg);
		}
		private function initInboxAndOutBoardBallsArray():void {
			inBoxBallsArray = new Array();
			tunneledBallArray = new Array();
		}
		private function setEnterFrameEvent(bl:Boolean = true):void {
			//doubleTrace("EnterFrameEvent事件 = " + bl);
			if (!this.hasEventListener(Event.ENTER_FRAME) && bl) this.addEventListener(Event.ENTER_FRAME, onEnterFrameHandler, false, 0, true);
			if (this.hasEventListener(Event.ENTER_FRAME) && !bl) this.removeEventListener(Event.ENTER_FRAME, onEnterFrameHandler);
		}
		private function spriteOfBody(body:b2Body):Sprite {
			return body.GetUserData() as Sprite;
		}
		private function initMouseEvent(bl:Boolean = true):void {
			var i;
			var ball:b2Body;
			if (bl) {
				myStage.addEventListener(MouseEvent.MOUSE_MOVE, onBoardMouseMoveHandler, false, 0, true);
				board.addEventListener(MouseEvent.MOUSE_DOWN, onBoardMouseDownHandler, false, 0, true);
				board.addEventListener(MouseEvent.MOUSE_UP, onBoardMouseUpHandler, false, 0, true);
				
				spriteOfBody(laobanBall).buttonMode = true;
				spriteOfBody(laobanBall).addEventListener(MouseEvent.ROLL_OVER, onLaobanMouseRollOverHandler, false, 0, true);
				spriteOfBody(laobanBall).addEventListener(MouseEvent.ROLL_OUT, onLaobanMouseRollOutHandler, false, 0, true);
				spriteOfBody(laobanBall).addEventListener(MouseEvent.MOUSE_DOWN, onLaobanBallMouseDownHandler, false, 0, true);
				spriteOfBody(laobanBall).addEventListener(MouseEvent.MOUSE_UP, onLaobanBallMouseUpHandler, false, 0, true);
				gun.addEventListener(MouseEvent.MOUSE_UP, onBoardMouseUpHandler, false, 0, true);
				for (ball = b2world.GetBodyList(); ball; ball = ball.GetNext()) {
					//仅仅针对于子球
					if (ball && ball.name && ball.id > 0) {
						//因为老板id=0，墙壁id=-1，所有ball.id>0代表子球
						//trace(ball.id + ": " + ball.name);
						//不含laobanBall，不含墙壁
						spriteOfBody(ball).addEventListener(MouseEvent.MOUSE_DOWN, onBoardMouseDownHandler, false, 0, true);
						spriteOfBody(ball).addEventListener(MouseEvent.MOUSE_UP, onBoardMouseUpHandler, false, 0, true);
					}
				}
			}else {
				myStage.removeEventListener(MouseEvent.MOUSE_MOVE, onBoardMouseMoveHandler);
				board.removeEventListener(MouseEvent.MOUSE_DOWN, onBoardMouseDownHandler);
				board.removeEventListener(MouseEvent.MOUSE_UP, onBoardMouseUpHandler);
				spriteOfBody(laobanBall).removeEventListener(MouseEvent.ROLL_OVER, onLaobanMouseRollOverHandler);
				spriteOfBody(laobanBall).removeEventListener(MouseEvent.ROLL_OUT, onLaobanMouseRollOutHandler);
				spriteOfBody(laobanBall).removeEventListener(MouseEvent.MOUSE_DOWN, onLaobanBallMouseDownHandler);
				spriteOfBody(laobanBall).removeEventListener(MouseEvent.MOUSE_UP, onLaobanBallMouseUpHandler);
				gun.removeEventListener(MouseEvent.MOUSE_UP, onBoardMouseUpHandler);
				for (ball = b2world.GetBodyList(); ball; ball = ball.GetNext()) {
					//仅仅针对于子球
					if (ball && ball.name && ball.id > 0) {
						spriteOfBody(ball).removeEventListener(MouseEvent.MOUSE_DOWN, onBoardMouseDownHandler);
						spriteOfBody(ball).removeEventListener(MouseEvent.MOUSE_UP, onBoardMouseUpHandler);
					}
				}
			}
		}
		private function onMovingStopHandler(event:Event):void {
			//鼠标移动停止
			var obj:Object = mouseMovingEvent.dataOfStop as Object;//获得鼠标停止时的位置等信息
			if(!isSingle && sfs.getActiveRoom().getName() != "lobby") sfs.setUserVariables(obj);//发送给对方用户
		}
		private function onPullGunStopHandler(event:Event):void {
			//拉枪棒暂停
			var obj:Object = pullGunEvent.dataOfStop as Object;
			if(!isSingle && sfs.getActiveRoom().getName() != "lobby") sfs.setUserVariables(obj);//发送给对方用户
		}
		private function onPUllGunStartHandler(event:Event):void {
			//开始拉动枪棒
			
		}
		private function onMovingStartHandler(event:Event):void {
			//鼠标移动开始
			
		}
		private function scaning(fromPos:Point, toPos:Point):void {
			//更新鼠标位置信息，等待鼠标移动停止后，向对方发送位置信息
			if (!isSingle) {
				mouseMovingEvent.update( { type: "scan", angle:hitRangeAngle, gunType:myUserData.gunType, px:toPos.x, py:toPos.y, mouseX:mouseX, mouseY:mouseY } );// isCrossWithBall:isCrossWithSmallBall?1:0 } );
			}
			_mouseX = mouseX;
			_mouseY = mouseY;
			gun.rotation = MyMath.radianToAngle(Math.atan2(toPos.y - fromPos.y, toPos.x - fromPos.x));
			drawRayAndHitRangeByGun(hitRangeAngle, myUserData.gunType);
		}
		private function initHitRange():Sprite {
			var range:Sprite = new Sprite();
			var shape:Shape = new Shape();
			shape.name = "hitrange";
			range.addChild(shape);
			range.addEventListener(MouseEvent.MOUSE_DOWN, onRangeMouseDownHandler);
			return range;
		}
		private function onRangeMouseDownHandler(event:MouseEvent):void {
			//如果鼠标点上了击打范围这个SPRITE，则传导到老板球点击事件处理
			onLaobanBallMouseDownHandler(event);
			
		}
		private function drawHitRange(fromPos:Point, toPos:Point, angle:Number, length:Number):void {
			//根据枪棒精度绘制击打的误差范围
			//trace("drawHitRange: "+ fromPos + "->" + toPos);
			var hitRangeLine:Shape = hitRangeFan.getChildByName("hitrange") as Shape;
			hitRangeLine.graphics.clear();
			hitRangeLine.graphics.lineStyle(0.5, 0xffffff, 0.3);
			
			hitRangeLine.graphics.moveTo(Math.cos(MyMath.angleToRadian(angle)) * Config.LaobanBallRadius, Math.sin(MyMath.angleToRadian(angle)) * Config.LaobanBallRadius);
			hitRangeLine.graphics.lineTo(length, length * Math.tan(MyMath.angleToRadian(angle)));
			hitRangeLine.graphics.moveTo(Math.cos(MyMath.angleToRadian(angle)) * Config.LaobanBallRadius, -Math.sin(MyMath.angleToRadian(angle)) * Config.LaobanBallRadius);
			hitRangeLine.graphics.lineTo(length, -length * Math.tan(MyMath.angleToRadian(angle)));
			hitRangeFan.x = fromPos.x;
			hitRangeFan.y = fromPos.y;
			hitRangeFan.rotation = MyMath.radianToAngle(Math.atan2(toPos.y - fromPos.y, toPos.x - fromPos.x));
			hitRangeFan.visible = true;
		}
		private function drawRay(from:Point, to:Point):void {
			//画射线
			scanLine.graphics.clear();
			scanLine.graphics.moveTo(from.x, from.y);
			if (isMyTurn) scanLine.graphics.lineStyle(0.5, 0xffffff, 0.8);
			else scanLine.graphics.lineStyle(0.5, 0xffffff, 0.5);
			scanLine.graphics.lineTo(to.x, to.y);
			//画圆圈
			if(isCrossWithSmallBall) scanLine.graphics.drawCircle(to.x, to.y, Config.LaobanBallRadius - 2);
		}
		private function pullGun(from:Point, to:Point):void {
			if (scanLine) scanLine.graphics.clear();
			hitRangeFan.visible = false;
			var xPos:Number = -(Math.abs(to.x - from.x) + Math.abs(to.y - from.y)) / 2;
			if (xPos <= -Config.maxGunPull) xPos = -Config.maxGunPull;
			var bang:Sprite = gun.getChildByName("gunBang") as Sprite;
			bang.x = xPos;
		}
		private function get laobanBallPos():Point {
			return MyMath.b2Vect2Point(laobanBall.GetPosition());
		}
		private function acturalPointOfBall(body:b2Body):Point {
			return MyMath.b2Vect2Point(body.GetPosition());
		}
		private function checkIfTargetBallBeforeGun(ball:b2Body):Boolean {
			//计算母球与目标球相切后，两个相切圆的圆心和母球位置会产生一个夹角，这个夹角两条边的直线方程
			//1- 以母球为原点，计算目标球当前位置的斜率，并通过atan计算角度
			var ballPos:Point = acturalPointOfBall(ball);
			var smallBallCurrentAnger:Number = MyMath.radianToAngle(Math.atan2(ballPos.y - laobanBallPos.y, ballPos.x - laobanBallPos.x));
			//2- 求母球和目标球相切时，母球中心和目标球中心的夹角
			var anger2:Number = MyMath.anger2(Config.LaobanBallRadius, Config.SmallBallRadius, laobanBallPos, ballPos);
			//3- 在目标球当前位置上下一个夹角的线
			var angerOfLine1:Number = smallBallCurrentAnger + anger2;//加一个角度
			var angerOfLine2:Number = smallBallCurrentAnger - anger2;//减一个角度
			//4- 根据母球位置和斜率，求两条直线的直线方程
			var k1:Number = Math.tan(MyMath.angleToRadian(angerOfLine1));
			var k2:Number = Math.tan(MyMath.angleToRadian(angerOfLine2));
			var a1:Number = laobanBallPos.y - k1 * laobanBallPos.x;
			var a2:Number = laobanBallPos.y - k2 * laobanBallPos.x;
			
			var pos2:uint = MyMath.Quadrant(laobanBallPos, ballPos);//目标球ball相对于老板球的位置
			//根据目标球与老板球所处的象限关系，决定以上两条线与哪条边框线相交
			var kk:Number;//外围线的方程
			var aa:Number;
			if (pos2 == 1) { kk = Config.k_1; aa = Config.a_1 }
			else if (pos2 == 2) { kk = Config.k_2; aa = Config.a_2 }
			else if (pos2 == 3) { kk = Config.k_3; aa = Config.a_3 }
			else if (pos2 == 4) { kk = Config.k_4; aa = Config.a_4 }
			
			//求line1，line2，和外围线组成的三角形相交产生的点
			var p1:Point = MyMath.lineCrossingPoint(k1, a1, kk, aa);
			var p2:Point = MyMath.lineCrossingPoint(k2, a2, kk, aa);
			var p3:Point = laobanBallPos;
			
			//判断当前鼠标位置是否位于三角形内
			var isInsideAngle:Boolean = MyMath.isInsideTriangle(p1, p2, p3, new Point(_mouseX, _mouseY));
			return isInsideAngle;
		}
		private function crossPoint(start:Point, end:Point):Point {
			//根据a和b两点坐标，计算和四条边的相交点，用来画出瞄准射线
			//瞄准线方程为：y=kx+a
			var k:Number = (end.y - start.y) / (end.x - start.x);
			var a:Number = end.y - k * end.x;

			var p:Point;
			var targetBall:b2Body;
			
			var crossPointArray:Array = new Array();//与子球相交点的数组
			var crossBallArray:Array = new Array();//与子球相交的球的数组
			var ball:b2Body;
			for (ball = b2world.GetBodyList(); ball; ball = ball.GetNext()) { 
				if (ball && ball.name && ball.id > 0) {
					//优化工作，首先，把桌面上可能在母球其击中范围内的棋子过滤出来
					var ballPos:Point = acturalPointOfBall(ball);//目标球位置
					var d:Number = MyMath.point2lineDistance(ballPos, k, a);
					var beforeGun:Boolean = checkIfTargetBallBeforeGun(ball);
					if (d <= Config.LaobanBallRadius + Config.SmallBallRadius && beforeGun) {
						//以上两句去掉，否则会出现鼠标和目标球处于不同象限时，无法画瞄准圈的问题
						//出现扫描线条件：鼠标位置和目标球之间的锐角，小于asin[(labanBallRadius+smallBallRadius)/目标球和老板球之间的距离]
						var pointArray:Array = MyMath.findPoint(Config.LaobanBallRadius, Config.SmallBallRadius, ballPos, k, a);//与目标球相交的点
						
						if (pointArray) {
							if (pointArray.length == 1) {
								crossPointArray.push(new Point(pointArray[0].x, pointArray[0].y));
								crossBallArray.push(ball);
							}else if (pointArray.length == 2) {
								crossPointArray.push(new Point(pointArray[0].x, pointArray[0].y));
								crossBallArray.push(ball);
								crossPointArray.push(new Point(pointArray[1].x, pointArray[1].y));
								crossBallArray.push(ball);
							}
						}
					}
				}
			}
			if (crossPointArray.length > 0){
				//如果与子球有相交点
				isCrossWithSmallBall = true;
				var nearestDis:Number = 10000000;
				for (var i:uint = 0; i < crossPointArray.length; i++) {
					//找到与start位置较近的一个点
					var dis:Number = MyMath.distance(crossPointArray[i], start);
					if (dis < nearestDis) {
						targetBall = crossBallArray[i];//目标球
						p = crossPointArray[i];//击打位置
						nearestDis = dis;
					}
				}
			}else{
				//如果没有和任何球相交，则和桌面边相交
				//上边框方程为：y=0+Config.tableY, 左边框方程为：x=0+Config.tableX，
				//下边框方程为：y=500+Config.tableY，右边框方程为：x=500+Config.tableX
				isCrossWithSmallBall = false;
				p = findTargetIfWithoutCross(start, end);
			}
			return p;
		}
		private function laobanBallEnabled(bl:Boolean):void {
			laobanBallPositionValidate = bl;
			var sprite:Sprite = spriteOfBody(laobanBall);
			if (bl) {
				if (laobanFlashSprite && laobanFlashSprite.isrunning) {
					laobanFlashSprite.stop();//如果从非法位置移到正藏位置，则停止闪烁
					laobanFlashSprite = null;
					sprite.filters = null;
				}
			}else {
				if(!laobanFlashSprite) laobanFlashSprite = new FlashSprite(sprite, 300, 0xff0000, 3);//在非法位置，保持红色闪烁
			}
		}
		private function shoot():void {
			//击打小球，这是回调函数onCompleted
			//doubleTrace("开始击球");
			initMouseEvent(false);//关闭侦听
			setEnterFrameEvent(true);
			var from:Point = shootFrom;
			var power:Number = shootPower; //力量
			if (Config.ifSound) mediaEffect.qiangbangjida.play(0, 0, new SoundTransform(shootPower / Config.maxGunPull * 10));//根据力量大小调整击球声音
			isStartMoving = true;//开始运动
			gun.visible = false;//隐藏枪棒
			var ballPos:Point = acturalPointOfBall(laobanBall);
			
			if (from.x != ballPos.x) {
				var vectorRate:Number = (from.y - ballPos.y) / (from.x - ballPos.x);
				var xPower:Number = Math.sqrt(power * power / (1 + vectorRate * vectorRate));
				var yPower:Number = xPower * Math.abs(vectorRate);
				if (vectorRate <= 0) {
					//鼠标位于主球的第一，三象限
					if (from.x - ballPos.x >= 0) {
						//鼠标位于主球的第一象限
						yPower = -yPower;
					}else {
						//鼠标位于主球的第三象限
						xPower = -xPower;
					}
				}else {
					//鼠标位于主球的底二、四象限
					if (from.x - ballPos.x >= 0) {
						//鼠标位于主球的第四象限
					}else {
						//鼠标位于主球的第二象限
						xPower = -xPower;
						yPower = -yPower;
					}
				}
				var vector:b2Vec2 = new b2Vec2(xPower, yPower);
				laobanBall.ApplyImpulse(vector, laobanBall.GetWorldCenter());
			}else {
				if (from.y < ballPos.y) laobanBall.ApplyImpulse(new b2Vec2(0, -power), laobanBall.GetWorldCenter());
				else laobanBall.ApplyImpulse(new b2Vec2(0, -power), laobanBall.GetWorldCenter());
			}
		}
		private function currentPowerRate():Number {
			//计算母球的当前速度是初始速度的百分比
			var ball:b2Body = laobanBall;
			var currentPower:Number = MyMath.distance(new Point(ball.GetLinearVelocity().x, ball.GetLinearVelocity().y), new Point(0, 0));// Math.sqrt(ball.velocity.x * ball.velocity.x + ball.velocity.y * ball.velocity.y);
			var r:Number = currentPower / shootPower;
			return 0.9 * r + 0.1;//确保最小的声音是原始声音的0.3
		}
		private function initSpeaker():void {
			//初始化声音控制按钮
			speaker = new Speaker();
			speaker.x = 10;
			speaker.y = 15;
			container.addChild(speaker);
			speaker.addEventListener(MouseEvent.CLICK, onSpeakerMouseClickHandler, false, 0, true);
			if (Config.ifSound) speaker.gotoAndStop(1);
			else speaker.gotoAndStop(2);
		}
		//====================事件响应执行程序============================
		private function onMoveLaobanTimerHandler(event:TimerEvent):void {
			previousMousePosition = new Point(myStage.mouseX, myStage.mouseY);
			if (physicalHandler.ifCollide(previousMousePosition, Config.LaobanBallRadius, Config.SmallBallRadius) 
				|| !ifInHitArea(previousMousePosition) || !ifInBoard(previousMousePosition)) {
				//如果老板球位置与小球冲突
				laobanBallEnabled(false);
			}else {
				laobanBallEnabled(true);
			}
		}
		private function onEnterFrameHandler(event:Event):void {
			b2world.Step(1 / 30, 10, 10);
			b2world.ClearForces();
			var ifStop:Boolean = true;
			var ball:b2Body;
			var sprite:Sprite;
			
			for (ball = b2world.GetBodyList(); ball; ball = ball.GetNext()) { 
				if (ball.GetUserData() is Sprite) {
					sprite = ball.GetUserData() as Sprite;
					sprite.x = ball.GetPosition().x * b2worldScale;
					sprite.y = ball.GetPosition().y * b2worldScale;
					sprite.rotation = MyMath.radianToAngle(ball.GetAngle());
				}
			}
			if (isStartMoving) {
				//先检测母球有没有与其他小球相撞，如果有，则发出声音
				if (contactListener.body1 && contactListener.body2) {
					if ((contactListener.body1.id == 0 && contactListener.body2.id != preCollisionBallId)  || 
						(contactListener.body2.id == 0 && contactListener.body1.id != preCollisionBallId)) {				//有新的碰撞
						if (Config.ifSound) mediaEffect.laobanhitqizi.play(0, 0, new SoundTransform(currentPowerRate() * 10));
						if (contactListener.body1.id == 0) preCollisionBallId = contactListener.body2.id;
						else if (contactListener.body2.id == 0) preCollisionBallId = contactListener.body1.id;
						//trace("母球发生新碰撞: " + preCollisionBallId);
					}
				}
				for (ball = b2world.GetBodyList(); ball; ball = ball.GetNext()) { 
					//侦听是否入袋
					if (ball && ball.name && ball.id >= 0) {
						//var currentVelocity:b2Vec2 = ball.GetLinearVelocity();
						//if (ball.id == 0) trace("老板球速度: " + MyMath.b2Vect2Point(currentVelocity));
						for (var j:int = 0; j < 4; j++) {
							if (isInHole(ball, holeArray[j])) {
								ball.SetActive(false);
								break;
							}
						}
						if(!ball.IsActive()) cleanBall(ball, holeArray[j]);
						else ifStop = ifStop && isStop(ball);// || isOutofBoard(ball)); 判断所有未进洞的小球停止
					}
				}
			}
			if (ifStop && isStartMoving) {
				//doubleTrace("所有都停下了");
				isStartMoving = false;
				setEnterFrameEvent(false);
				resetAllBallsPosition();//把所有球的位置信息精确到整数
				//checkTunneling();//检测是否有穿透，即打出棋盘
				//上传到服务器的位置，长度单位用像素
				if (!isSingle) {
					var ballPositionStr:String = JSON.encode(getBallsArray());
					//doubleTrace("==1== 发送stopball事件");
					sfs.sendXtMessage("SnookerRoom", "stopball", {playerId:sfs.playerId, positions:ballPositionStr}, "xml", sfs.getActiveRoom().getId() );//一方停止，需要在服务端检测所有球停止，才能切换用户，以保持同步
				}
				else {
					//单机用户直接打
					ifChangeUser = false;//如果无需换用户
					if (finishAllBalls()) {
						var endTime:Date = new Date();
						doubleTrace("结束时间: " + endTime.getTime());
						var ttlSeconds:int = (endTime.getTime() - startTime.getTime()) / 1000 / 60 / 24;
						sfs.sendXtMessage("SnookerRoom", "singleGameFinished", { seconds:String(ttlSeconds) } );//向后台发送单机游戏所用秒数
					}
					else startTurn();
				}
			}
		}
		private function finishAllBalls():Boolean {
			//是否已经将棋盘上的子全部打完
			var re:Boolean = false;
			var ballCount:int = 0;
			for (var ball:b2Body = b2world.GetBodyList(); ball; ball = ball.GetNext()) { 
				//侦听是否入袋
				if (ball && ball.name && ball.id > 0) {
					ballCount++;
				}
			}
			if (ballCount == 0) re = true;
			else re = false;
			return re;
		}
		private function onBoardMouseMoveHandler(event:MouseEvent):void {
			//鼠标移动事件，用于瞄准或者拉动枪棒
			var p:Point;
			if (whoseTurn != -1 && isMyTurn && !startMovingLaobanBall) {
				//不是移动老板球
				var stageX:Number = event.stageX;
				var stageY:Number = event.stageY;
				if (gun.visible && isScaning) {
					//瞄准
					p = new Point(stageX, stageY);
					scaning(laobanBallPos, p);
				}else if (gun.visible && !isScaning) {
					//瞄准后，拖动枪棒加力					
					myStage.addEventListener(Event.MOUSE_LEAVE, onMouseLeaveHandler, false, 0, true);//拉力时如果鼠标移出舞台，则重新瞄准
					if (!isSingle) {
						pullGunEvent.update( { type: "pullgun", px:stageX, py:stageY, from_x:shootFrom.x, from_y:shootFrom.y } );
					}
					pullGun(shootFrom, new Point(stageX, stageY));
				}
			}
		}
		private function onBoardMouseDownHandler(event:MouseEvent):void {
			//开始用力后拉枪棒
			//终止gun的移动，记录当前鼠标位置，作为击打点
			if (isMyTurn) {
				shootFrom = new Point(event.stageX, event.stageY);//shootFrom是准备用力后拉前鼠标按下的位置，用于确定母球击打的方向
				isScaning = false;//瞄准结束
				if (scanLine) scanLine.graphics.clear();
				hitRangeFan.visible = false;
			}else {
				initMouseEvent(false);
			}
		}
		private function onBoardMouseUpHandler(event:MouseEvent):void {
			//播放枪棒击打动作的缓动，缓动结束后击打
			//doubleTrace("onBoardMouseUpHandler");
			if (isMyTurn) {
				if (MyMath.distance(shootFrom, new Point(event.stageX, event.stageY)) > 6) {
					//如果鼠标只移动了极小的范围，就放开了鼠标则不算。这里的6代表6个像素，少于6个像素的移动不算
					var shootData:dataTransmission = new dataTransmission();
					shootData.gunXPower = -gun.getChildByName("gunBang").x;
					
					//根据枪棒精度调整母球前进的方向shootFrom值
					var rightAngle:Number = MyMath.getAngle(laobanBallPos, shootFrom);
					var randomAngle:Number = Math.random() * hitRangeAngle * 2 - hitRangeAngle;//随机取一个-4到4的角
					var finalAngle:Number = rightAngle + randomAngle;
					gun.rotation = finalAngle;
					
					//修正打击位shootFrom
					if (finalAngle == 90) {
						shootFrom.x = laobanBallPos.x;
						shootFrom.y = -100.0 + laobanBallPos.y;
					}
					else if (finalAngle == -90) {
						shootFrom.x = laobanBallPos.x;
						shootFrom.y = 100.0 + laobanBallPos.y;
					}
					else if ((finalAngle >= 0 && finalAngle < 90) || (finalAngle > -90 && finalAngle <= 0)) {  
						shootFrom.x = laobanBallPos.x + 100;
						shootFrom.y = laobanBallPos.y - 100 * Math.tan(MyMath.angleToRadian(finalAngle));
					}else if ((finalAngle > 90 && finalAngle <= 180) || (finalAngle >= -180 && finalAngle < -90)) {
						shootFrom.x = laobanBallPos.x - 100;
						shootFrom.y = laobanBallPos.y + 100 * Math.tan(MyMath.angleToRadian(finalAngle));
					}
					shootData.target = shootFrom;//鼠标抬起时，把击打的目标位置传给target
					shootData.maxPower = myUserData.power;
					shootData.type = "shoot";
					//发送击打动作
					//doubleTrace("发送击打动作");
					if(!isSingle) sfs.sendObject({targetX:shootData.target.x, targetY:shootData.target.y, maxPower:shootData.maxPower, gunXPower:shootData.gunXPower, type:shootData.type});
					shootAsData(shootData);
				}else {
					isScaning = true;
					hitRangeFan.visible = true;
				}
			}else {
				initMouseEvent(false);
			}
		}
		private function onLaobanMouseRollOverHandler(event:MouseEvent):void {
			showHitArea(true);
			setInfoMcVisible(false);
		}
		private function onLaobanMouseRollOutHandler(event:MouseEvent):void {
			if(!startMovingLaobanBall) showHitArea(false);//为了防止在拖动母球时快速移动，导致mouseRollOut事件触发，需要加一个判断
		}
		private function onLaobanBallMouseDownHandler(event:MouseEvent):void {
			//doubleTrace("onLaobanBallMouseDownHandler");
			if (isMyTurn && !startMovingLaobanBall && !isStartMoving) {
				//开始移动老板球
				previousLaobanPosition = laobanBallPos;
				showHitArea(true);
				
				setEnterFrameEvent(false);
				startMovingLaobanBall = true;
				spriteOfBody(laobanBall).startDrag();
				gun.visible = false;
				if (scanLine) scanLine.graphics.clear();
				hitRangeFan.visible = false;
				//开启定时器，发送老板球移动位置消息
				setMovingLaobanTimer(true);
			}else {
				initMouseEvent(false);
			}
		}
		private function onLaobanBallMouseUpHandler(event:MouseEvent):void {
			var sprite:Sprite;
			if (isMyTurn) {
				if (startMovingLaobanBall) {
					setEnterFrameEvent(false);
					if (laobanBallPositionValidate) {
						sprite = spriteOfBody(laobanBall);
						laobanBall.SetPosition(MyMath.Point2Vect2(new Point(sprite.x, sprite.y)));
					}else {
						//恢复到移动前位置
						sprite = spriteOfBody(laobanBall);
						sprite.x = previousLaobanPosition.x;
						sprite.y = previousLaobanPosition.y;
						laobanBall.SetPosition(MyMath.Point2Vect2(previousLaobanPosition));
						laobanBallEnabled(true);
					}
					if(!isSingle) sfs.sendObject( { type:"stopmovelaoban", px:sprite.x, py:sprite.y } );
					setMovingLaobanTimer(false);
					showHitArea(false);
					spriteOfBody(laobanBall).stopDrag();
					startMovingLaobanBall = false;
					showGun(new Point(myStage.mouseX, myStage.mouseY));
				}else {
					onBoardMouseUpHandler(event);
				}
			}else {
				initMouseEvent(false);
			}
		}
		
		private function onMouseLeaveHandler(event:Event):void {
			//trace("鼠标移出");
			if (isMyTurn) {
				isScaning = true;
				gun.getChildByName("gunBang").x = 0;
				myStage.removeEventListener(Event.MOUSE_LEAVE, onMouseLeaveHandler);//拉力时如果鼠标移出舞台，则重新瞄准
				initMouseEvent(isMyTurn);
			}
		}
		//======================SFS事件处理函数===========================
		private function onObjectReceiveHandler(event:SFSEvent):void {
			//doubleTrace("onObjectReceiveHandler");
			var sender:User = event.params.sender as User;
			var type:String = event.params.obj.type;
			if (sender.getId() != sfs.myUserId && !isMyTurn) {
				if (type == "shoot") {
					//doubleTrace("收到击打动作");
					var shootData:dataTransmission = new dataTransmission();
					shootData.target = new Point(event.params.obj.targetX, event.params.obj.targetY);
					shootData.gunXPower = event.params.obj.gunXPower as Number;
					shootData.maxPower = event.params.obj.maxPower as Number;
					shootData.type = event.params.obj.type as String;
					shootAsData(shootData);
				}
				if (type == "stopmovelaoban") {
					stopMoveLaobanBall(new Point(int(event.params.obj.px), int(event.params.obj.py)));
				}
			}
		}
		
		private function onRoundTripTimerHandler(event:TimerEvent):void {
			sfs.roundTripBench();
		}
		private function onRoundTripResponseHandler(event:SFSEvent):void {
			var pName:String = sfs.playerId == player1playerId ? player1Name : player2Name;
			var avatarBar:AvatarBar = container.getChildByName(pName) as AvatarBar;
			avatarBar.showRoundTrip(event.params.elapsed / 2);
			sfs.setUserVariables( { type:"RoundTrip", playerid:sfs.playerId, rt:event.params.elapsed / 2 } );
		}
		private function onUserVariablesUpdateHandler(event:SFSEvent):void {
			if (isSingle || sfs.getActiveRoom().getName() == "lobby") {
				//如果不是在游戏房中，不做检测
			}else {
				var changedVars:Array = event.params.changedVars;
				var sender:User = event.params.user as User;
				var px:Number;
				var py:Number;
				
				if (changedVars["rt"] != null || changedVars["playerid"] != null) {
					if(sender.getVariable("type") == "RoundTrip") {
						//对双方都有影响的属性变化
						//如果用户id和联网速度有变化时，运行以下代码
						var pId:int = event.params.user.getVariable("playerid");
						var pName:String = pId == player1playerId ? player1Name : player2Name;
						var dat:Number = event.params.user.getVariable("rt") as Number;
						var avartaBar:AvatarBar = container.getChildByName(pName) as AvatarBar;
						avartaBar.showRoundTrip(dat);
					}
				}
				if (sender.getId() != sfs.myUserId && !isMyTurn) {
					//只对对方对方用户产生影响，对自己不产生影响
					if (changedVars["px"] != null || changedVars["py"] != null) {
						if (sender.getVariable("type") == "scan") {
							//处于瞄准
							px = event.params.user.getVariable("px");
							py = event.params.user.getVariable("py");
							_mouseX = event.params.user.getVariable("mouseX");
							_mouseY = event.params.user.getVariable("mouseY");
							var angle:Number = event.params.user.getVariable("angle");
							var gunType:int = event.params.user.getVariable("gunType");
							
							//doubleTrace("angle = " + angle + ", gunType = " + gunType);
							//isCrossWithSmallBall = event.params.user.getVariable("isCrossWithBall") == 1;
							//通过Tween来模拟枪棒移动，并且在缓动过程中，调用drawRayAndHitRange函数画瞄准线
							TweenLite.to(gun, 0.25, { rotation:MyMath.radianToAngle(Math.atan2(py - laobanBallPos.y, px - laobanBallPos.x)), 
													ease:Linear.easeNone, onUpdate: drawRayAndHitRangeByGun, onUpdateParams: [angle, gunType] } );
						}
						if (sender.getVariable("type") == "pullgun") {
							//处于拉枪棒
							var from_x:Number = Number(event.params.user.getVariable("from_x"));
							var from_y:Number = Number(event.params.user.getVariable("from_y"));
							var to_x:Number = Number(event.params.user.getVariable("px"));
							var to_y:Number = Number(event.params.user.getVariable("py"));
							var from:Point = new Point(from_x, from_y);
							var to:Point = new Point(to_x, to_y);
							pullGun(from, to);
						}
						if (sender.getVariable("type") == "punishPlace") {
							//处于放置罚子
							doubleTrace("收到punishPlace变量变化");
							punishQiziName = event.params.user.getVariable("name");
							px = event.params.user.getVariable("px");
							py = event.params.user.getVariable("py");
							//if (!placingPunishBall) {
							if (!punishQiziSprite) {
								//如果接受消息方没有处在观看对方放罚子状态，则根据对方罚的子，在己方棋盘上添加一个sprite
								addPunishQiziSprite(punishQiziName, px, py);
								placingPunishBall = true;
							}
							else {
								//如果罚子已经生成，则在对方暂停后，重新移动位置时，收到此消息，通过缓动放置棋子
								//if (punishQiziSprite) 
								TweenLite.to(punishQiziSprite, 0.2, { x:px, y:py, ease:Linear.easeNone } );
							}
						}
					}
				}
			}
		}
		
		private function drawRayAndHitRangeByGun(_angle:Number, _gunType:int):void {
			//根据枪棒的旋转角度确定目标位，专门用于接收端的枪棒瞄准线处理
			//trace("枪棒角度: " + gun.rotation + ", Tan值: " + Math.tan(MyMath.angleToRadian(gun.rotation)));
			var target:Point;
			var gunAngle:Number = gun.rotation;
			var xx:Number = 100.0;
			var yy:Number;
			var yyy:Number = xx * Math.tan(MyMath.angleToRadian(gun.rotation));
			if (gunAngle == -90 || gunAngle == 90) {
				target = new Point(0, 100);
			}else if ((gunAngle > 90 && gunAngle <= 180) || (gunAngle >= -180 && gunAngle <= -90)) {
				yy = laobanBallPos.y - yyy;
				xx = laobanBallPos.x - xx;
			}else {
				yy = laobanBallPos.y + yyy;
				xx = xx + laobanBallPos.x;
			}
			target = new Point(xx, yy);
			drawRayAndHitRange(laobanBallPos, target, _angle, _gunType);
		}
		private function drawRayAndHitRange(fromPos:Point, toPos:Point, _angle:Number, _gunType:int) {
			//把drawRay和drawHitRange两个函数合并，这里参数toPos是指鼠标位置
			var endPoint:Point = crossPoint(fromPos, toPos);//终点
			if (endPoint) {
				var anger:Number = Math.atan2(toPos.y - fromPos.y, toPos.x - fromPos.x);
				var xx:Number = fromPos.x + Math.cos(anger) * Config.LaobanBallRadius;
				var yy:Number = fromPos.y + Math.sin(anger) * Config.LaobanBallRadius;
				if (_gunType == 1) {
					//画瞄准线
					showScanLines();
					drawRay(new Point(xx, yy), endPoint);
					drawHitRange(fromPos, endPoint, _angle, MyMath.distance(fromPos, endPoint));
				}else if (_gunType == 2) {
					//画瞄准线和反射线
					//????????????????????????????????????
				}else if (_gunType == 0) {
					showScanLines(false);
				}
			}
		}
		private function showScanLines(bl:Boolean = true):void {
			if(scanLine) scanLine.visible = bl;
			if(jiao) jiao.visible = bl;
			if (hitRangeFan) hitRangeFan.visible = bl;
		}
		private function get currentUserName():String {
			//获取当前用户的中文名字，保存在用户属性中
			var userId:String = whoseTurn == player1playerId ? player1Name:player2Name;
			return sfs.getActiveRoom().getUser(userId).getVariable("name");
		}
		private function onExtensionResponseHandler(event:SFSEvent):void {
			var dat:Object = event.params.dataObj;
			var cmd:String = dat._cmd;
			if (cmd == "gameFinished") {
				var re:int = int(dat.result);
				var txt:String = "";
				if (re == 1) txt = unescape(sfs.getActiveRoom().getUser(player1Name).getVariable("name")) + " 胜";
				else if (re == 2) txt = unescape(sfs.getActiveRoom().getUser(player2Name).getVariable("name")) + " 胜";
				else if (re == 3) txt = "平   局";
				txt = txt + "\n" + Config.ifContinueText;
				dispatchEvent(new SnookerEvent(SnookerEvent.GAME_OVER, { message:txt } ));			
			}
			if (cmd == "checkIfChangeUser_OK") {
				//doubleTrace("result = " + dat.result + ", punished = " + dat.punished + ", whoseTurn = " + dat.whoseTurn + ", totalTurn = " + dat.moveCount);
				
				if (int(dat.result) == 1) {
					//切换用户
					ifChangeUser = true;
					if (int(dat.punished) == 1) ifPunish = true;
					else ifPunish = false;
					if (scanLine) scanLine.graphics.clear();
					whoseTurn = int(dat.whoseTurn);
					totalTurn = int(dat.moveCount);
					//doubleTrace("切换用户: whoseTurn = " + whoseTurn + ", totalTurn = " + totalTurn);
					if (ifPunish) {
						currAvatar.stopClock();
						opponentAvatar.stopClock();
						if (isMyTurn) {
							showInfoMc("对方母球进洞，请放置罚子");
							startPunishBallPlacement();
						}else {
							//显示等待对方放置罚子
							showInfoMc("母球进洞，等待对方放置罚子");
						}
					}else {
						//不罚子，直接击球
						showInfoMc("换由 " + currentUserName + "击球");
						startTurn();//如果没有罚子，则直接开始
					}
				}else {
					//不切换用户
					//doubleTrace("不切换用户: whoseTurn = " + whoseTurn + ", totalTurn = " + totalTurn);
					ifPunish = false;
					ifChangeUser = false;
					startTurn();
				}
			}
			if (cmd == "punishQiziPlaced_OK") {
				//当从服务器传来罚子放置完成后，在双方棋盘上放置罚子，才开始游戏
				var pName:String = dat.name;
				var pId:int = int(dat.id);
				var pX:int = int(dat.px);
				var pY:int = int(dat.py);
				//punishedBallPlaced = true;
				totalPunishedCount = pId - Config.qiziArray.length;
				
				if (!isMyTurn) {
					//如果不是自己放罚子，则播放从当前位置到最终位置的缓动。如果是自己放子，则无需缓动，直接放置
					//首先要判断是否生成了punishQiziSprite，如果罚子方mouseDown太快，导致被罚子方的punishQiziSprite还没有来得及生成就收到这个命令，就坏了
					if (!punishQiziSprite) {
						addPunishQiziSprite(pName, pX, pY);
					}
					TweenLite.to(punishQiziSprite, 0.1, { x:pX, y:pY, ease:Linear.easeNone, onComplete:placePunishedQizi, onCompleteParams:[pName, pId, new Point(pX, pY)] } );
				}
				else {
					placePunishedQizi(pName, pId, new Point(pX, pY));
				}
					
			}
			if (cmd == "singleGameFinished_OK") {
				//如果单机游戏结束，向后台发布命令
				var ttlSeconds:int = int(dat.seconds);
				var getScore:int = int(dat.score);
				var getGold:int = int(dat.gold);
				if(int(dat.isQuickest) == 1) user1Data.quickestSingle = ttlSeconds;//设定个人最快速度
				var message:String = Config.finishSingleGame + "\n本次用时: " + ttlSeconds + " 秒\n个人最快：" + user1Data.quickestSingle + "秒\n获得积分：" + getScore + "，获得金币：" + getGold;
				dispatchEvent(new SnookerEvent(SnookerEvent.GAME_OVER, { message: message} ));
				
			}
		}
		
		private function startPunishBallPlacement():void {
			//罚球方开始罚球
			placingPunishBall = true;//开始放置罚子
			punishPlaceEvent = new MouseMovingEvent(200);//位置监控的时间间隔为200毫秒
			if(!punishPlaceEvent.hasEventListener(MouseMovingEvent.MOVING_STOP)) punishPlaceEvent.addEventListener(MouseMovingEvent.MOVING_STOP, onPunishMouseStopHandler, false, 0, true);
			if(!punishPlaceEvent.hasEventListener(MouseMovingEvent.MOVING_START)) punishPlaceEvent.addEventListener(MouseMovingEvent.MOVING_START, onPunishMouseStartHandler, false, 0, true);
			if (whoseTurn == player1playerId) punishBall(Config.BlackPart);//如果当前用户是玩家1，则放置黑球
			else if (whoseTurn == player2playerId) punishBall(Config.RedPart);//如果当前用户是玩家2，则放置红球
		}
		private function punishBall(part:int):void {
			//罚子，罚子一方可以定位
			//从数组中随机抽取一个棋子名称
			var punishQiziArray:Array = new Array();
			for (var i:uint = 0; i < Config.qiziArray.length; i++) {
				var tempName:String = Config.qiziArray[i];
				if (part == Config.RedPart && tempName.substr(0,3) == "red") {
					punishQiziArray.push(tempName);
				}else if (part == Config.BlackPart && tempName.substr(0, 5) == "black") {
					punishQiziArray.push(tempName);
				}
			}
			punishQiziName = punishQiziArray[int(Math.random() * (punishQiziArray.length - 1))];//随机取一个名字
			totalPunishedCount++;
			addPunishQiziSprite(punishQiziName, mouseX, mouseY);
			Mouse.hide();
			punishQiziSprite.startDrag();
			//doubleTrace("得到罚子机会，罚子：" + punishQiziName);
			if (!myStage.hasEventListener(MouseEvent.MOUSE_MOVE)) myStage.addEventListener(MouseEvent.MOUSE_MOVE, onPunishMouseMoveHandler);
			punishQiziSprite.addEventListener(MouseEvent.MOUSE_DOWN, onPunishMouseDownHandler);
		}
		private function addPunishQiziSprite(classname:String, px:Number, py:Number):void {
			var punishQiziClass:Class = getDefinitionByName(classname) as Class;
			punishQiziSprite = new punishQiziClass();
			punishQiziSprite.x = px;
			punishQiziSprite.y = py;
			punishQiziSprite.name = "punishSprite";
			punishQiziSprite.scaleX = Config.SmallBallRadius / Config.SmallBallOriginalRadius;
			punishQiziSprite.scaleY = Config.SmallBallRadius / Config.SmallBallOriginalRadius;
			container.addChild(punishQiziSprite);
		}
		private function onPunishMouseStopHandler(event:Event):void {
			//移动罚子暂停
		}
		private function onPunishMouseStartHandler(event:Event):void {
			//移动罚子开始
			var obj:Object = punishPlaceEvent.dataOfStop as Object;//记录最终位置
			if(!isSingle && sfs.getActiveRoom().getName() != "lobby") sfs.setUserVariables(obj);//发送给对方用户
		}
		private function onPunishMouseMoveHandler(event:MouseEvent):void {
			var pos:Point = new Point(event.stageX, event.stageY);
			//检测位置是否合法，允许在棋盘上如何一个角落放置罚子
			if (ifInBoard(pos) && ifOutOfHole(pos) && !physicalHandler.ifCollide(pos, Config.SmallBallRadius, Config.SmallBallRadius)) {
				if (punishPlaceAlert && punishPlaceAlert.isrunning) {
					punishPlaceAlert.stop();
					punishPlaceAlert = null;
					punishQiziSprite.filters = null;
				}
				punishQiziSprite.x = event.stageX;
				punishQiziSprite.y = event.stageY;
				punishPlaceEvent.update( { type: "punishPlace", px:event.stageX, py:event.stageY, name: punishQiziName } );
				punishPlaceAvailable = true;
			}else {
				//发红光显示非法位置
				if (!punishPlaceAlert) punishPlaceAlert = new FlashSprite(punishQiziSprite, 300, 0xff0000, 3);
				punishPlaceAvailable = false;
			}
		}
		private function ifOutOfHole(position:Point):Boolean {
			//不在四个洞之内
			var re:Boolean = true;
			for (var i:uint = 0; i < holeArray.length; i++) {
				var hole:Sprite = holeArray[i] as Sprite;
				var distance:Number = MyMath.distance(position, new Point(hole.x, hole.y));
				if (distance <= Config.holeRadius) {
					re = false;
					break;
				}
			}
			return re;
		}
		private function onPunishMouseDownHandler(event:MouseEvent):void {
			//确定好罚子位置后，落子
			if (punishPlaceAvailable) {
				myStage.removeEventListener(MouseEvent.MOUSE_MOVE, onPunishMouseMoveHandler);
				punishQiziSprite.removeEventListener(MouseEvent.MOUSE_UP, onPunishMouseDownHandler);
				punishQiziSprite.stopDrag();
				var id:int = Config.qiziArray.length + totalPunishedCount;
				//向服务器发送完成罚子消息，让服务器通知双方罚子放置的位置以及名称
				//doubleTrace("前whoseTurn = " + whoseTurn + ", 前totalTurn = " + totalTurn);
				sfs.sendXtMessage("SnookerRoom", "punishQiziPlaced", { name: punishQiziName, id:String(id), px:String(mouseX), py:String(mouseY) } );
			}
		}
		private function placePunishedQizi(name:String, id:int, pos:Point):void {
			//放置罚子
			Mouse.show();
			var newBall:b2Body = physicalHandler.addQiziBallByName(name, id, pos);//在物理世界中加入一个罚子
			//new FlashSprite(newBall.GetUserData() as flash.display.Sprite, 300, 0xffffff, 3);//闪烁
			if (punishQiziSprite) {
				punishQiziSprite.filters = null;
				punishQiziSprite.visible = false;
				container.removeChild(punishQiziSprite);//对于放罚子的一方，会有用于移动的sprite存在于桌面上，需要清除。
				punishQiziSprite = null;
			}
			placingPunishBall = false;//结束放置罚子
			ifChangeUser = false;
			var ballPositionStr:String = JSON.encode(getBallsArray());
			//必须通过发送双方同步消息stopball，才能继续进行，不能直接使用startTurn。否则会出问题。2012-10-6改
			sfs.sendXtMessage("SnookerRoom", "stopball", {playerId:sfs.playerId, positions:ballPositionStr}, "xml", sfs.getActiveRoom().getId() );//一方停止，需要在服务端检测所有球停止，才能切换用户，以保持同步
		}
		private function onRoomVariablesUpdateHandler(event:SFSEvent):void {
			var changedVars:Array = event.params.changedVars;
			for (var v:String in changedVars) {
				if (v == "stopballs") {
					var stopballs:int = event.params.room.getVariable("stopballs");
					//doubleTrace("==2== stopballs的房间属性变化 = " + stopballs);
					if (stopballs == 2) {
						//doubleTrace("5- whoseTurn = " + whoseTurn + ", totalTurn = " + totalTurn);
						var isSyn:Boolean = false;
						var ifSyn:int = event.params.room.getVariable("synBalls");
						if (ifSyn == 0) {
							//doubleTrace("游戏双方不同步");
							//重新调整位置，然后
							var synPosition:String = event.params.room.getVariable("synPosition") as String;//获取同步位置数据
							if(synPosition != null) var synPosArray:Array = JSON.decode(synPosition) as Array;//转成数组
							if (synchronizePosition(synPosArray)) {
								//doubleTrace("同步成功");
								isSyn = true;
							}
						}
						else {
							//doubleTrace("数据已同步");
							isSyn = true;
						}
						if (isSyn) {
							var allBallsArray:Array = new Array();
							var ball:b2Body;
							for (ball = b2world.GetBodyList(); ball; ball = ball.GetNext()) { 
								if (ball && ball.name && ball.id > 0) allBallsArray.push(ball.name);
							}
							//向后台发送是否切换用户
							//doubleTrace("因为同步导致checkIfChangeUser");
							//doubleTrace("6- whoseTurn = " + whoseTurn + ", totalTurn = " + totalTurn);
							//doubleTrace("isMyTurn = " + isMyTurn + ", isPunish = " + ifPunish);
							if (isMyTurn) {
								if (ifPunish) {
									//如果是放罚子，说明已经切换好用户了，直接告诉后台不用切换用户
									//doubleTrace("发送checkIfChangeUser::nochange命令");
									sfs.sendXtMessage("SnookerRoom", "checkIfChangeUser", { type:"nochange" } );
								}else {
									//如果不是罚子，则发后台询问正常切换
									//doubleTrace("发送checkIfChangeUser::normalchange命令");
									sfs.sendXtMessage("SnookerRoom", "checkIfChangeUser", { type:"normalchange", allballs: allBallsArray.join(","), inbox:inBoxBallsArray.join(","), tunneled:tunneledBallArray.join(",") } );
								}
							}
						}
					}
				}
				if (v == "player1Score") {
					var player1Score:int = event.params.room.getVariable("player1Score");
					if (whoseTurn == 1) currAvatar.changeScore(player1Score);
				}
				if (v == "player2Score") {
					var player2Score:int = event.params.room.getVariable("player2Score");
					if (whoseTurn == 2) currAvatar.changeScore(player2Score);
				}
			}
		}
		//====================辅助函数============================
		private function resetAllBallsPosition():void {
			//用Box2d时无需使用此函数
			var ball:b2Body;
			var px;
			var py;
			for (ball = b2world.GetBodyList(); ball; ball = ball.GetNext()) {
				if (ball && ball.name && ball.id >= 0) {
					var p:Point = acturalPointOfBall(ball);
					px = Math.round(p.x);
					py = Math.round(p.y);
					if (px <= Config.tableX + Config.tableFrameWidth + Config.SmallBallRadius 
						|| px >= Config.tableX + Config.tableWidth - Config.tableFrameWidth - Config.SmallBallRadius
						|| py <= Config.tableY + Config.tableFrameWidth + Config.SmallBallRadius 
						|| py >= Config.tableY + Config.tableWidth - Config.tableFrameWidth - Config.SmallBallRadius) {
						doubleTrace(ball.name + ": " + new Point(px, py));
					}
					ball.SetPosition(MyMath.Point2Vect2(new Point(px, py)));
				}
			}
		}
		private function checkTunneling():void {
			//穿透检验,返回发生穿透的球的数组
			var ball:b2Body;
			var ballPos:Point;
			for (ball = b2world.GetBodyList(); ball; ball = ball.GetNext()) {
				ballPos = acturalPointOfBall(ball);
				if (ballPos.x < Config.tableX || ballPos.x > Config.tableX + Config.tableWidth || ballPos.y < Config.tableY || ballPos.y > Config.tableY + Config.tableWidth) {
					//球在棋盘外
					if (!arrayContain(inBoxBallsArray, ball.name)) tunneledBallArray.push(ball.name);//如果在inBoxballArray已经存在，则不入tunneledBallArray
					if (ball && ball.name && ball.id > 0) {
						b2world.DestroyBody(ball);
						//如果不是老板球，则把球放回棋盘
						//改变规则->只扣分，不罚球
						//ball.px = Config.tableX + Config.tableWidth / 2;
						//ball.py = Config.tableY + Config.tableWidth / 2;
					}
				}
			}
		}
		private function arrayContain(array:Array, item:Object):Boolean {
			//检验数组array中是否有item元素
			var re:Boolean = false;
			for (var i:int = 0; i < array.length; i++) {
				if (array[i] == item) {
					re = true;
					break;
				}
			}
			return re;
		}
		private function setCurrentGun():void {
			var otherGun:Sprite;
			if (isSingle) {
				gun = container.getChildByName(user1Data.gunPictureClass + user1Data.name) as Sprite;
				gun.visible = true;
			}else {
				if (whoseTurn == 1) {
					doubleTrace("显示: " + user1Data.gunPictureClass + user1Data.name + ", 隐藏: " + user2Data.gunPictureClass + user2Data.name);
					gun = container.getChildByName(user1Data.gunPictureClass + user1Data.name) as Sprite;
					gun.visible = true;
					otherGun = container.getChildByName(user2Data.gunPictureClass + user2Data.name) as Sprite;
					otherGun.visible = false;
				}else {
					doubleTrace("显示: " + user1Data.gunPictureClass + user2Data.name + ", 隐藏: " + user2Data.gunPictureClass + user1Data.name);
					gun = container.getChildByName(user2Data.gunPictureClass + user2Data.name) as Sprite;
					gun.visible = true;
					otherGun = container.getChildByName(user1Data.gunPictureClass + user1Data.name) as Sprite;
					otherGun.visible = false;
				}
			}
		}
		private function showGun(target:Point):void {
			//target是显示枪棒时指向的目标，这种函数方式有利于网络操作
			setCurrentGun();
			
			container.setChildIndex(gun, container.numChildren - 1);
			gun.x = laobanBallPos.x;
			gun.y = laobanBallPos.y;
			gun.visible = true;
			if (isMyTurn) gun.alpha = 1;
			else gun.alpha = 0.5;
			gun.rotation = MyMath.radianToAngle(Math.atan2(target.y - laobanBallPos.y, target.x - laobanBallPos.x));
		}
		private function resetLaobanBall(side:int = 1):void {
			//重置老板球，和球棒
			laobanReadyInBox = false;//初始化时老板球没进洞
			spriteOfBody(laobanBall).visible = true;
			laobanBall.SetActive(true);
			physicalHandler.resetLaobanBall(side);
			gun.getChildByName("gunBang").x = 0;
		}
		
		private function isInHole(ball:b2Body, hole:Sprite):Boolean {
			var re:Boolean = false;
			if (ball && ball.name) {
				var r:Number = spriteOfBody(ball).width / 2;//半径
				var ballPos:Point = acturalPointOfBall(ball);//当前小球位置
				var distance:Number = MyMath.distance(ballPos, new Point(hole.x, hole.y));// Math.sqrt((ball.px - hole.x) * (ball.px - hole.x) + (ball.py - hole.y) * (ball.py - hole.y));
				if (distance <= Config.holeRadius - r) {
					//设洞的半径为R, 球的半径为r。如果distance<=R-r，必定掉入洞
					re = true;
				}
				else if (distance <= Config.holeRadius - 3 && distance > Config.holeRadius - r) {
					//如果distance <= R - 3且distance > R-r，看速度如果够快，即大于MinSpeed时，可以不入洞
					//var minSpeed:Number = Config.passHoleMinSpeed * (Config.holeRadius - 3 - distance) / (r - 3);
					var v:b2Vec2 = ball.GetLinearVelocity();
					if (Math.sqrt(v.x * v.x + v.y * v.y) > Config.passHoleMinSpeed) {
						re = false;//不掉洞
					}else {
						re = true;//掉洞
					}
				}else if (distance > Config.holeRadius - 3) {
					re = false;//不掉
				}
			}
			return re;
		}
		private function stopBall(ball:b2Body):void {
			//使小球静止
			ball.SetLinearVelocity(new b2Vec2(0, 0));
			//ball.SetLinearDamping(0);
			//ball.SetAngularDamping(0);
			//ball.SetAngularVelocity(0);
		}
		private function cleanBall(ball:b2Body, hole:Sprite):void {
			//清除落袋得球，只是隐藏显示，并不是真正删除
			putBallIntoBox(ball, hole);
			if (ball && ball.name && ball.id > 0) {
				//如果不是老板球
				//stopBall(ball);
				physicalHandler.removeBall(ball);
			}else if(ball && ball.name && ball.id == 0){
				//如果是老板球，隐藏不显示，并且取消碰撞
				spriteOfBody(laobanBall).visible = false;
			}
		}
		private function putBallIntoBox(ball:b2Body, hole:Sprite):void {
			//将落袋的球放入盒子中
			if (ball && ball.name && ball.id > 0) {
				inBoxBallsArray.push(ball.name);
				//stopBall(ball);
				var boxcontainer:Sprite = hole.getChildByName("boxcontainer") as Sprite;//盒子容器，宽高为70
				var skin:Sprite = clone(spriteOfBody(ball)) as Sprite;//因为ball马上将被删除，而ball的sprite引用也将被删除，所以在这里，需要克隆一个新的sprite
				skin.x = Math.random() * 30 + 20;//从20-50
				skin.y = Math.random() * 30 + 20;
				skin.scaleX = Config.SmallBallRadius / Config.SmallBallOriginalRadius;
				skin.scaleY = Config.SmallBallRadius / Config.SmallBallOriginalRadius;
				skin.rotation = Math.random() * 180;//任意旋转角度，更加自然
				if (Config.ifSound) mediaEffect.inBox.play(0, 0, new SoundTransform(5));
				//trace("把球" + ball.name + "放入" + hole.name + "(" + skin.x + "," + skin.y + ")");
				boxcontainer.addChild(skin);
			}else if (ball && ball.id == 0) {
				if (!laobanReadyInBox) {
					inBoxBallsArray.push(ball.name);
					stopBall(ball);
					if (Config.ifSound) mediaEffect.inBox.play(0, 0, new SoundTransform(7));
					laobanReadyInBox = true;
				}
			}
		}
		private function shootAsData(shootObj:dataTransmission):void {
			//收到击球数据包后，根据数据包击球
			initMouseEvent(false);
			if (scanLine) scanLine.graphics.clear();
			hitRangeFan.visible = false;
			
			shootFrom = shootObj.target;
			showGun(shootObj.target);
			gun.getChildByName("gunBang").x = -shootObj.gunXPower;//拉升
			shootPower = shootObj.gunXPower / Config.maxGunPull * shootObj.maxPower;//通过拉升的距离来确定击打力量
			var bang:Sprite = gun.getChildByName("gunBang") as Sprite;
			TweenLite.to(bang, 0.2, { x:5,onComplete:shoot } );
		}
		private function onSpeakerMouseClickHandler(event:MouseEvent):void {
			if (Config.ifSound) {
				speaker.gotoAndStop(2);
				Config.ifSound = false;
			}else {
				speaker.gotoAndStop(1);
				Config.ifSound = true;
			}
		}
		private function clone(mc:Sprite):Sprite {
			//克隆棋子
            var getmc:Sprite = new Sprite();
			mc.cacheAsBitmap = true;
            var getbitMap:BitmapData = new BitmapData (mc.width, mc.height, true, 0x00000000);
			getbitMap.draw(mc, new Matrix(1, 0, 0, 1, 14, 14));//注意因为ball的sprite注册点在中间，所以用一个Matrix对象调整位置
            var getbits:Bitmap = new Bitmap(getbitMap, "auto", true);
            getmc.addChild(getbits);
            return getmc;
        }
		/*
		private function moveLaobanBall(p:Point):void {
			//移动母球
			startMovingLaobanBall = true;
			if (gun.visible) gun.visible = false;
			if (scanLine.graphics) scanLine.graphics.clear();
			hitRangeFan.visible = false;
			spriteOfBody(laobanBall).x = p.x;
			spriteOfBody(laobanBall).y = p.y;
			setEnterFrameEvent(false);
			//注意老板球的放置范围
		}
		*/
		private function stopMoveLaobanBall(p:Point):void {
			//只用于被击打方
			setEnterFrameEvent(true);
			setMovingLaobanTimer(false);
			showHitArea(false);
			startMovingLaobanBall = false;
			spriteOfBody(laobanBall).x = p.x;
			spriteOfBody(laobanBall).y = p.y;
			laobanBall.SetPosition(MyMath.Point2Vect2(p));
			gun.visible = true;
			showGun(p);
		}
		private function synchronizePosition(posArray:Array):Boolean {
			//玩家之间的位置同步
			//从服务器上传回的位置的单位是像素,不是米。
			//doubleTrace("**开始同步位置**");
			var removableBallArray:Array = new Array();
			var addableBallArray:Array = new Array();
			var ball:b2Body;
			var matching:Boolean;
			var i:uint;
			//首先检测当前棋盘上的子是否会多于服务器发来的同步数据
			for (ball = b2world.GetBodyList(); ball; ball = ball.GetNext()) {
				matching = false;
				if (ball && ball.name && ball.id > 0) {
					for (var j:uint = 0; j < posArray.length; j++) {
						if (ball.id == posArray[j].id) {
							ball.SetPosition(MyMath.Point2Vect2(new Point(posArray[j].x, posArray[j].y)));
							matching = true;
							break;
						}
					}
					if (!matching) removableBallArray.push(ball);//如果同步中没有本机的球，则清除
					}
			}
			if (removableBallArray.length > 0) {
				//如果有不同步的球，且棋盘上的球多于服务器上发来的信息
				for (i = 0; i < removableBallArray.length; i++) {
					physicalHandler.removeBall(removableBallArray[i]);
				}
			}
			
			//其次，检测服务器发来的同步数据是否会多于当前棋盘上的子
			for (i = 0; i < posArray.length; i++) {
				var id:int = posArray[i].id;
				var x:int = posArray[i].x;
				var y:int = posArray[i].y;
				matching = false;
				for (var ball:b2Body = b2world.GetBodyList(); ball; ball = ball.GetNext()) { 
					if (ball && ball.name && ball.id > 0) {
						if (ball.id == id) {
							matching = true;
							break
						}
					}
				}
				if (!matching) addableBallArray.push( { id:id, px:x, py:y } );
			}
			if (addableBallArray.length > 0) {
				//在棋盘上增加子
				for (i = 0; i < addableBallArray.length; i++) {
					physicalHandler.addQiziBallById(addableBallArray[i].id, new Point(addableBallArray[i].px, addableBallArray[i].py));
				}
			}
			return true;
		}
		private function ifInHitArea(checkPoint:Point):Boolean {
			var re:Boolean;
			var xx:Number = checkPoint.x;
			var yy:Number = checkPoint.y;
			
			var radio:int = Config.smallHoleRadius + Config.LaobanBallRadius - 1;
			if (whoseTurn == 1) {
				//在南方
				if ((yy >= Config.downLineY && yy <= Config.downLineY + Config.LaobanBallRadius && xx >= Config.leftLineX && xx <= Config.rightLineX) 
					|| MyMath.distance(checkPoint, Config.lbHole) <= radio || MyMath.distance(checkPoint, Config.rbHole) <= radio) re = true;
				else re = false;
			}else if (whoseTurn == 2) {
				//北方
				if ((yy >= Config.upLineY - Config.LaobanBallRadius && yy <= Config.upLineY && xx >= Config.leftLineX && xx <= Config.rightLineX) 
					|| MyMath.distance(checkPoint, Config.ltHole) <= radio || MyMath.distance(checkPoint, Config.rtHole) <= radio) re = true;
				else re = false;
			}
			return re;
		}
		private function printAllBallsPosition():String {
			var str:String = "";
			var ball:b2Body;
			for (ball = b2world.GetBodyList(); ball; ball = ball.GetNext()) { 
				if (ball && ball.name && ball.id > 0)
					//老板球不算
					str = str + acturalPointOfBall(ball);
			}
			//doubleTrace(str);
			return str;
		}
		private function getBallsArray():Array {
			//将所有球的位置信息和每个球的名字转入一个独立数组
			var arr:Array = new Array();
			var ball:b2Body;
			var ballPos:Point;
			for (ball = b2world.GetBodyList(); ball; ball = ball.GetNext()) {
				if (ball && ball.name && ball.id >= 0) {
					ballPos = acturalPointOfBall(ball);
					arr.push({x:Math.round(ballPos.x), y:Math.round(ballPos.y), id:ball.id});
				}
			}
			return arr;
		}
		private function ifInBoard(checkPoint:Point):Boolean {
			//判断是否在棋盘中
			var re:Boolean;
			if (checkPoint.y >= Config.tableFrameWidth + Config.tableY && checkPoint.y <= Config.tableWidth + Config.tableY - Config.tableFrameWidth 
				&& checkPoint.x >= Config.tableX + Config.tableFrameWidth && checkPoint.x <= Config.tableX + Config.tableWidth - Config.tableFrameWidth) re = true;
			else re = false;
			return re;
		}
		private function isStop(ball:b2Body):Boolean {
			//判断粒子是否停止运动
			//判断是否静止，注意不能为0来判断，必须设一个很小的数字。
			var vel:b2Vec2 = ball.GetLinearVelocity();
			var v:Number = Math.sqrt(vel.x * vel.x + vel.y * vel.y);
			if (v <= Config.stopMinVelocityDiff) {
				stopBall(ball);
				return true;
			}
			else 
				return false;
		}
		private function isOutofBoard(ball:b2Body):Boolean {
			//判断粒子是否出界
			//改用box2d后，不会发生穿透，因此，无需这个判断了
			//如果小球发生穿透，就以stage边界作为判断停止依据
			var ballPos:Point = acturalPointOfBall(ball);
			if ( ballPos.x < Config.tableX || ballPos.y < Config.tableY || ballPos.x > Config.tableX + Config.tableWidth || ballPos.y > Config.tableY + Config.tableWidth) {
				ball.SetPosition(new b2Vec2(0, 0));
				return true;
			}else return false;
		}
		
		private function findTargetIfWithoutCross(start:Point, end:Point):Point {
			//如果没有与任何目标球相交，则寻找与台边的交点
			var k:Number = (end.y - start.y) / (end.x - start.x);
			var a:Number = end.y - k * end.x;
			
			var p:Point;
			var leftWall:int = Config.tableX + Config.tableFrameWidth;
			var upWall:int = Config.tableY + Config.tableFrameWidth;
			var rightWall:int = Config.tableX + Config.tableWidth - Config.tableFrameWidth;
			var bottomWall:int = Config.tableY + Config.tableWidth - Config.tableFrameWidth;
			
			var leftPoint:Point = new Point(leftWall, leftWall * k + a);//瞄准线和左边框相交于(0,a)
			var upPoint:Point = new Point( (upWall - a) / k, upWall);//瞄准线和上边框相较于(-a/k,0)
			var rightPoint:Point = new Point(rightWall, rightWall * k + a);//与右边框相交点
			var bottomPoint:Point = new Point((bottomWall - a) / k, bottomWall);//与下边框相交点
			
			if (end.x < start.x && end.y < start.y) {
				//第二象限
				if (leftPoint.x == leftWall && leftPoint.y >= upWall) p = leftPoint;
				else if (upPoint.y == upWall) p = upPoint;
			}else if (end.x > start.x && end.y < start.y) {
				//第一象限
				if (rightPoint.x == rightWall && rightPoint.y >= upWall) p = rightPoint;
				else if (upPoint.y == upWall) p = upPoint;
			}else if (end.x > start.x && end.y > start.y) {
				//第四象限
				if (rightPoint.x == rightWall && rightPoint.y <= bottomWall) p = rightPoint;
				else if (bottomPoint.y == bottomWall) p = bottomPoint;
			}else if (end.x < start.x && end.y > start.y) {
				//第三象限
				if (leftPoint.x == leftWall && leftPoint.y <= bottomWall) p = leftPoint;
				else if (bottomPoint.y == bottomWall) p = bottomPoint;
			}
			return p;
		}
		
		public function destroyObjects():void {
			//清除对象
			setEnterFrameEvent(false);
			initMouseEvent(false);
			setSFSEvent(false);
			
			setMovingLaobanTimer(false);
			moveLaobanTimer = null;

			roundTripTimer.stop();
			roundTripTimer.removeEventListener(TimerEvent.TIMER, onRoundTripTimerHandler);
			roundTripTimer = null;
			
			showInfoMcTimer.stop();
			showInfoMcTimer.removeEventListener(TimerEvent.TIMER, onShowInfoTimeHandler);
			showInfoMcTimer = null;
			
			for (var i:int = 0; i < 4; i++) {
				removeChildByName("hole" + i, container);
			}
			
			removeChildByName("glowlayer", container);
			removeChildByName("table", container);
			
			trace("===1===");
			container.removeChild(board);
			board = null;
			
			container.removeChild(laobanMoveArea);
			laobanMoveArea = null;

			var gun1:Sprite = container.getChildByName(user1Data.gunPictureClass + user1Data.name) as Sprite;
			if (gun1) {
				container.removeChild(gun1);
				gun1 = null;
			}
			if (!isSingle) {
				var gun2:Sprite = container.getChildByName(user2Data.gunPictureClass + user2Data.name) as Sprite;
				if (gun2) {
					container.removeChild(gun2);
					gun2 = null;
				}
			}
			trace("===2===");
			if (gun) {
				gun = null;
			}
			
			if (scanLine) {
				container.removeChild(scanLine);
				scanLine = null;
			}
			if (hitRangeFan) {
				container.removeChild(hitRangeFan);
				hitRangeFan = null;
			}
			if (infoMc) {
				container.removeChild(infoMc);
				infoMc = null;
			}
			if (punishQiziSprite) {
				container.removeChild(punishQiziSprite);
				punishQiziSprite = null;
			}
			trace("===3===");
			container.removeChild(jiao);
			jiao = null;
			trace("===3.2===");
			container.removeChild(currAvatar);
			currAvatar = null;
			trace("===3.4===");
			if (!isSingle) container.removeChild(opponentAvatar);
			opponentAvatar = null;
			trace("===3.6===");
			container.removeChild(speaker);
			speaker = null;
			
			trace("===4===");
			backBtn.removeEventListener(MouseEvent.CLICK, onBackButtonClickHandler);
			container.removeChild(backBtn);
			backBtn = null;
			
			if (laobanFlashSprite) laobanFlashSprite = null;
			if (punishPlaceAlert) punishPlaceAlert = null;
			
			trace("===5===");
			MemoryCleaner.removeArray(holeArray);
			MemoryCleaner.removeArray(inBoxBallsArray);
			MemoryCleaner.removeArray(tunneledBallArray);
			MemoryCleaner.removeArray(qiziSequence);
			
			trace("===6===");
			
			if (userInfo) userInfo = null;
			if (user1Data) user1Data = null;
			if (user2Data) user2Data = null;
			if (myUserData) myUserData = null;
			if (opponentUserData) opponentUserData = null;
			if (closeFunction) closeFunction = null;
			if (mouseMovingEvent) mouseMovingEvent = null;
			if (pullGunEvent) pullGunEvent = null;
			if (punishPlaceEvent) punishPlaceEvent = null;
			
			trace("===7===");
			shootFrom = null;
			previousLaobanPosition = null;
			previousMousePosition = null;

			trace("===8===");
			mediaEffect = null;
			
			physicalHandler.destroy();
			physicalHandler = null;
			
			trace("===9===");
			contactListener = null;
			b2world = null;
			
			MemoryCleaner.clean();
		}
		private function removeChildByName(_name:String, __container:Sprite):void {
			var sprite:Sprite = __container.getChildByName(_name) as Sprite;
			if(sprite) __container.removeChild(sprite);
			sprite = null;
		}
	}
}