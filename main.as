package {
	/*人人网API*/
    import com.renren.graph.*;
    import com.renren.graph.data.*;
    import com.renren.graph.event.*;
	import flash.geom.Point;
	
	import com.hexagonstar.util.debug.Debug;
	import fl.controls.Button;
	import flash.display.*;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import data.*;
	import data.UserData;
	import gs.TweenLite;
	import org.slg.Events.UserManagerEvent;
	import org.slg.UserManager.*;
	import it.gotoandplay.smartfoxserver.SmartFoxClient;
	import it.gotoandplay.smartfoxserver.data.*;
	import it.gotoandplay.smartfoxserver.SFSEvent;
	import flash.system.Security;
	import org.slg.Utils.*;
	import flash.utils.Timer;
	import gs.easing.Quart;
	import flash.ui.Keyboard;
	import flash.filters.GlowFilter;
	import flash.external.ExternalInterface;
	import com.adobe.serialization.json.JSON;
	import flash.text.TextField;
	import flash.utils.getDefinitionByName;
	
	
	public class main extends Sprite {
		
		private var login_mc:Login_mc;//登录界面模块
		private var alertBox:AlertBox;//提示框
		private var registerMc:Register;
		private var sfs:SmartFoxClient;
		private var login:Login;
		private var myCookie:Cookie;
		private var btnStartGame:Sprite;
		private var btnStartGameSingle:Sprite
		
		private var ipAddress:String;
		private var port:int = 9339;
		private var localDir:String;
		
		public function main() {
			Security.allowDomain("*");
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		//====================初始化============================
		private function init(event:Event):void {
			stage.scaleMode = StageScaleMode.NO_SCALE;//无缩放
            stage.align = StageAlign.TOP_LEFT;//舞台布局
            stage.frameRate = Config.FrameRate;//帧频

			//设置localDir
			ipAddress = Config.ipAddress;
			port = Config.port;
			
			var url:String = stage.loaderInfo.loaderURL;
			localDir = url.substr(0, url.lastIndexOf("/") + 1);
			
			//加入底层背景图片
			var backgroundBmp:Sprite = new background();
			backgroundBmp.x = 0; backgroundBmp.y = 0;
			this.addChild(backgroundBmp);
			
			//登录窗口
			/*
			showLoginMc();
			login_mc.btn_login.addEventListener(MouseEvent.CLICK, onBtnLoginClickHandler, false, 0, true);
			login_mc.btn_register.addEventListener(MouseEvent.CLICK, onBtnRegisterClickHandler, false, 0, true);
			setLoginMcTabIndex();
			*/
			
			//提示框
			alertBox = new AlertBox();
			alertBox.visible = false;
			alertBox.x = 0; alertBox.y = 0;
			addChild(alertBox);
			
			//SFS
			sfs = new SmartFoxClient(false);
			
			//登录类
			login = new Login(sfs, ipAddress, port);
			
			addMemoryMonitor();//内存使用检测器
						
			//设置确认框
			initConfirmBox();
			
			//设置滚动等待条
			initWaitingBar();
			
			//设置外部命令
			addExternalFunction();
			
			//读取Cookie
			//readCookie();
			setLoginEvent(true);

			//登录人人网
			addRenRenLoginBtn();
			
			//===============以下调试测试用，不能在人人网平台上测试，放到网上去时，需要把这些屏蔽掉======================
			
			renrenData = new Object();
			renrenData.name = "古千峰";
			renrenData.uid = 702857823;
			renrenData.headurl = "http://hdn101.rrimg.com/photos/hdn101/20090113/09/27/head_qiQv_9932d000001.jpg";
			renrenData.tinyurl = "http://hdn101.rrimg.com/photos/hdn101/20090113/09/27/tiny_L748_9932d000001.jpg";
			renrenData.sex = 1;
			renrenData.zidou = 0;
			login.connectServer(renrenData.uid, "1234567", "snooker", "lobby");//人人网登陆默认密码1234567			
		}
		
		//========================人人网登录======================
		private var renrenBtn:SimpleButton;
		private function addRenRenLoginBtn():void {
			renrenBtn = new loginRenren();
			renrenBtn.x = (stage.width - renrenBtn.width) / 2;
			renrenBtn.y = (stage.height - renrenBtn.height) / 2;
			this.addChild(renrenBtn)
			renrenBtn.addEventListener(MouseEvent.CLICK, onLoginRenrenHandler);
		}
		private function onLoginRenrenHandler(event:MouseEvent):void {
			renRen = new RenRen();
			renRen.initAPI(new RenRenSession());
			auth("popup");
		}
		private var renRen:RenRen;
		private function auth(method:String):void {
			renRen.addEventListener(RenRenEvent.AUTH_SUCCESS, onAuthSuccessHandler);
			renRen.addEventListener(RenRenEvent.AUTH_FAIL, onAuthFailHandler);
			//doubleTrace("开始登录人人网");
            var authType:Array = ["read_user_checkin","read_user_invitation", "read_user_status", "send_invitation", "send_message", "status_update", "publish_comment"];
			renRen.auth(method, authType.join(" "));//授权登录
		}
		private function onAuthSuccessHandler(event:RenRenEvent):void {
			//从人人网登录成功
			//doubleTrace("人人网登录成功");
			//doubleTrace(JSON.encode(event.data));
			renRen.addEventListener(RenRenEvent.USERS_GET_LOGGED_IN_USER_SUCCESS, onUserGetLoggedInUserSuccessHandler);
			renRen.addEventListener(RenRenEvent.USERS_GET_LOGGED_IN_USER_FAIL, onUserGetLoggedInUserFailHandler);
			renRen.users_getLoggedInUser();
		}
		private function onAuthFailHandler(event:RenRenEvent):void {
			//从人人网登录失败
			doubleTrace("人人网登录失败");
		}
		private function onUserGetLoggedInUserSuccessHandler(event:RenRenEvent):void {
			var renrenD:* = event.data;
			renRen.addEventListener(RenRenEvent.USERS_GET_INFO_SUCCESS, onUserInfoGetHandler);
			renRen.addEventListener(RenRenEvent.USERS_GET_INFO_FAIL, onUserInfoGetFailHandler);
			doubleTrace("用户ID: " + renrenD.uid);
			renRen.users_getInfo(renrenD.uid);			
		}
		private function onUserGetLoggedInUserFailHandler(event:RenRenEvent):void {
			doubleTrace("获取登录用户id失败");
		}
		private var renrenData:*;
		private function onUserInfoGetHandler(event:RenRenEvent):void {
			renrenData = event.data;
			doubleTrace("人人网用户信息获取成功");
			doubleTrace(JSON.encode(renrenData));
			renrenData.name = escape(renrenData.name);
			//登录入口========================================================
			//doubleTrace("escape用户名: " + escape(renrenData.name));
			login.connectServer(renrenData.uid, "1234567", "snooker", "lobby");//人人网登陆默认密码1234567
		}
		private function onUserInfoGetFailHandler(event:RenRenEvent):void {
			doubleTrace("人人网用户信息获取失败");
		}
		
		//======================================================================================================================================
		private function showStartGameButton(bl:Boolean = true ):void {
			//双人游戏模式
			if(!btnStartGame){
				btnStartGame = new BtnStartGame();
				btnStartGame.x = (700 - btnStartGame.width) / 2;
				btnStartGame.y = (550 - btnStartGame.height) / 2 + 50;
				this.addChild(btnStartGame);
				btnStartGame.name = "1";
				btnStartGame.addEventListener(MouseEvent.CLICK, onStartGameClickHandler);
				btnStartGame.buttonMode = true;
			}
			btnStartGame.visible = bl;
			
			//双人游戏模式
			if(!btnStartGameSingle){
				btnStartGameSingle = new BtnGameSingle();
				btnStartGameSingle.x = (700 - btnStartGameSingle.width) / 2;
				btnStartGameSingle.y = (550 - btnStartGame.height) / 2 - 50;
				this.addChild(btnStartGameSingle);
				btnStartGameSingle.name = "0";
				btnStartGameSingle.addEventListener(MouseEvent.CLICK, onStartGameClickHandler);
				btnStartGameSingle.buttonMode = true;
			}
			btnStartGameSingle.visible = bl;
		}
		//====================事件响应执行程序============================
		private var game_mode:int = -1;//游戏状态：0-单人，1-双人，-1-等待
		private function onStartGameClickHandler(event:MouseEvent):void {
			//doubleTrace("开始寻找对手");把新建游戏房间、加入用户的事情全部交给后台处理
			game_mode = int(event.currentTarget.name);
			if (game_mode == 0) {
				initSingleGame();//单人练习模式
			}
			else if (game_mode == 1) {
				initFightingGame();
			}
		}
		private function doubleTrace(msg:String):void {
			Debug.trace(sfs.myUserName + "->" + msg);
			trace(msg);
		}
		private var snookerGame:data.Snooker;
		private var opponentId:String;
		private function onExtensionResponseHandler(event:SFSEvent):void {
			var dat:Object = event.params.dataObj;
			var cmd:String = dat._cmd;
			if (cmd == "start") {
				//开始游戏
				doubleTrace("start");
				showWaitingBar(false);
				game_mode = int(dat.gameType);//再次确认game_mode

				var qiziSequenceStr:String = dat.qiziSequence;
				//trace("棋子序列: " + qiziSequenceStr);
				
				var player1userId:int = int(dat.p1i);
				var player1Name:String = dat.p1n;
				var player1playerId:int = int(dat.p1p);//房间中的序列号，只有1和2
				
				//获取复杂的用户数据				
				var player1Data:data.UserData = new data.UserData(dat, 1);
				
				if (game_mode == 1) {//双人游戏
					var whoseTurn:int = int(dat.whoseTurn);
					var totalTurn:int = int(dat.moveCount);
					var player2userId:int = int(dat.p2i);//用户1的userid，即登录时在服务器产生的流水号
					var player2Name:String = dat.p2n;
					var player2playerId:int = int(dat.p2p);
					var player2Data:data.UserData = new data.UserData(dat, 2);					
				}
				
				//设置用户的人人网属性
				if(renrenData) sfs.setUserVariables(renrenData);
				
				//setSFSEvent(false);//原来需要关闭侦听，后来因为有对手用户非法退出，需要保留侦听
				
				if (game_mode == 1)	{ //双人游戏
					snookerGame = new Snooker(player1Data, player2Data, stage, this, sfs, whoseTurn, totalTurn, player1userId, 
										player1playerId, player1Name, player2userId, player2playerId, player2Name, 
										qiziSequenceStr.split(","));
				} else if (game_mode == 0) {//单人游戏模式
					snookerGame = new Snooker(player1Data, null, stage, this, sfs, 1, 0, sfs.myUserId, 1, sfs.myUserName, 0, 0, "", 
										qiziSequenceStr.split(","), true);
				}
				snookerGame.addEventListener(SnookerEvent.GAME_OVER, onSnookerGameNormalGameOverHandler, false, 0, true);
				snookerGame.addEventListener(SnookerEvent.GAME_STOP, onSnookerGameStopHandler, false, 0, true);
			}
			
			//以下是客户端A向服务器发送prepareGame后，服务器匹配到对手B，并向B广播，需要B确认是否接受邀请
			if (cmd == "prepareGame_INVITE") {
				//B收到邀请
				if (game_mode == -1 || game_mode == 0) {
					//判断收到邀请的用户是否处于等待或者单机游戏状态
					opponentId = dat.opponent;
					var renrenName:String = unescape(sfs.getActiveRoom().getUser(opponentId).getVariable("name"));
					showConfirmBox(renrenName + Config.prepareGame_INVITE, "BtnAccept", "BtnRefuse", acceptInvitation, refuseInvitation, false);
				}
			}
			
			//以下是2种没有找到对手的情况，收到此两种错误时，用户仍旧在lobby大厅。
			if (cmd == "prepareGame_NOOPPONENT") {
				//A在lobby大厅里没有找到对手，提示询问：继续寻找，单机练习
				//此消息接受方是A
				game_mode = -1;
				showWaitingBar(false);
				showConfirmBox(Config.prepareGame_NOOPPONENT, "BtnKeepSeeking", "BtnSingle", initFightingGame, initSingleGame, false);
			}
			if (cmd == "refusedByOpponent") {
				//A被受邀方B拒绝，也作为没有找到对手提示：继续寻找，单机练习
				//此消息接收方是A
				game_mode = -1;
				showWaitingBar(false);
				showConfirmBox(Config.prepareGame_NOOPPONENT, "BtnKeepSeeking", "BtnSingle", initFightingGame, initSingleGame, false);
			}
			
			//以下是两种系统开房间错误的情况。收到此两种错误时，用户仍旧在lobby大厅。
			if (cmd == "prepareRoom_KO") {
				//doubleTrace("游戏准备失败");
				game_mode = -1;
				showWaitingBar(false);
				showConfirmBox(Config.prepareRoom_KO, "BtnKeepSeeking", "BtnSingle", initFightingGame, initSingleGame, false);
			}
			if (cmd == "prepareRoom_EXIST") {
				//doubleTrace("游戏房间已经存在");
				game_mode = -1;
				showWaitingBar(false);
				showConfirmBox(Config.prepareRoom_KO, "BtnKeepSeeking", "BtnSingle", initFightingGame, initSingleGame, false);
			}
			
			//以下是两种游戏开始后，有用户退出的情况处理
			if (cmd == "checkIfChangeUser_userExitFromRoom") {
				//游戏对方A退出游戏
				//这是第一种处理有对手退出的情况，即：对方隐形的退出游戏，如断线，或者关闭浏览器时没有提醒，导致退出游戏房间。
				//服务器在收到每轮打完检验是否切换用户的命令checkIfChangeUser时，查看游戏房间内的用户数，如果只有一个，则向客户端发送此消息。
				//收到此消息时，用户B在lobby大厅
				var username:String = dat.username as String;//未退出方B的username
				game_mode = -1;
				if (sfs.myUserName == username) {
					if (snookerGame) {
						showConfirmBox(Config.userUnloadBrower_OK, "BtnConfirm", "BtnCancel", initFightingGame, initSingleGame, false);
					}
				}
			}
			if (cmd == "userUnloadBrower_OK") {
				//游戏对方A退出游戏
				//这是第二种处理对手退出游戏的情况，即:显性退出，并且已经提示对方退出游戏的后果。
				//这又分两种情况：
				//1- 用户A按退出按钮退出，客户端向服务端发送"userExitGame"命令。服务端收到消息后，把A和B转到lobby，并向B发送广播。
				//2- 用户A关闭浏览器退出，客户端向服务器发送"userUnloadBrower"命令。服务端收到消息后，把A提出服务器，把B转到lobby，并向B发送广播。
				//收到此消息时，用户B在lobby大厅
				game_mode = -1;
				var username:String = dat.username as String;//未退出用户B的username
				if (sfs.myUserName == dat.username) {
					//返回的username是自己
					if (snookerGame) {
						//显示提示对话框
						showConfirmBox(Config.userUnloadBrower_OK, "BtnConfirm", "BtnCancel", initFightingGame, initSingleGame, false);
					}
				}
			}
			
			//以下是游戏正常结束，并决出胜负后的两种处理
			//1- A方按下继续按钮。向B广播还要继续玩。
			if (cmd == "opponentContinue") {
				//对方已经按下继续按钮了，这里消息接收方是B
				showWaitingBar(false);
				showConfirmBox(Config.opponentContinue, "BtnConfirm", "BtnCancel", continueWithSameOpponent, backToLobby, false);
			}
			
			//2- A不想再玩了，向B广播。
			if (cmd == "opponentExitToLobbyAfterFinishedGame") {
				//对方在游戏结束后退出，这里消息接收方是B
				//B收到此消息时，A和B都已经在lobby大厅了
				showWaitingBar(false);
				showConfirmBox(Config.opponentExitToLobbyAfterFinishedGame, "BtnConfirm", "BtnCancel", initFightingGame, initSingleGame, false);
			}
		}
		private function initSingleGame(temp:* = null):void {
			//开始单人游戏
			destroySnooker();
			closeConfirmBox();
			showWaitingBar(true, "游戏初始化，请稍等...");
			//开始单机游戏准备工作
			//从服务器获得“start"命令，以及用户信息
			sfs.sendXtMessage("SnookerRoom", "prepareSingle", {qiziCount: Config.qiziOriginalArray.length, userid: sfs.myUserName},"xml",sfs.getActiveRoom().getId() );//双人对战模式
		}
		private function initFightingGame(temp:* = null):void {
			//开始双人游戏
			destroySnooker();
			closeConfirmBox();
			showWaitingBar(true, "游戏初始化，正在寻找玩家...");
			//向后台发送prepareGame，只是寻找用户。该命令发出后，会得到服务器的返回：
			//prepareGame_NOOPPONENT: 没有找到对手
			//prepareGame_INVITE：找到对手，发送邀请
			sfs.sendXtMessage("SnookerRoom", "prepareGame", {qiziCount: Config.qiziOriginalArray.length},"xml",sfs.getActiveRoom().getId() );//双人对战模式
		}
		//===================================================================================================
		//===================================================================================================
		//登录处理
		//===================================================================================================
		//===================================================================================================
		private function setLoginEvent(bl:Boolean):void
		{
			if(login_mc) login_mc.logining.visible = !bl;
			if (bl)
			{
				login.addEventListener(UserManagerEvent.CONNECT_FAIL, onConnectFailHandler, false, 0, true);
				login.addEventListener(UserManagerEvent.CONNECT_LOST, onConnectLostHandler, false, 0, true);
				login.addEventListener(UserManagerEvent.ROOM_JOIN_FAIL, onRoomJoinErrorHandler, false, 0, true);
				login.addEventListener(UserManagerEvent.ROOM_JOIN, LoginSuccessHandler, false, 0, true);
				login.addEventListener(UserManagerEvent.LOGIN_FAIL, LoginErrorHandler, false, 0, true);
				if (login_mc) {
					login_mc.rememberpwd.addEventListener(Event.CHANGE, rememberChangeHandler, false, 0, true);
					stage.addEventListener(KeyboardEvent.KEY_DOWN,onStageKeyDownHandle, false, 0, true);
				}
			}
			else
			{
				login.removeEventListener(UserManagerEvent.CONNECT_FAIL, onConnectFailHandler);
				login.removeEventListener(UserManagerEvent.CONNECT_LOST, onConnectLostHandler);
				login.removeEventListener(UserManagerEvent.ROOM_JOIN_FAIL, onRoomJoinErrorHandler);
				login.removeEventListener(UserManagerEvent.ROOM_JOIN, LoginSuccessHandler);
				login.removeEventListener(UserManagerEvent.LOGIN_FAIL, LoginErrorHandler);
				if (login_mc) {
					login_mc.rememberpwd.removeEventListener(Event.CHANGE, rememberChangeHandler);
					stage.removeEventListener(KeyboardEvent.KEY_DOWN,onStageKeyDownHandle);
				}
			}
		}
		private function onBtnRegisterClickHandler(evt:MouseEvent):void
		{
			showRegisterMc();
			//TweenLite.to(login_mc, 0.3, { y:-stage.stageHeight, ease:Quart.easeOut, onComplete:showRegisterMc } );
		}
		private function showRegisterMc():void
		{
			if (!registerMc)
			{
				registerMc = new Register(localDir);
				registerMc.x = (700 - registerMc.width) / 2;
				registerMc.y = (550 - registerMc.height) / 2;
				registerMc.addEventListener(UserManagerEvent.REGISTER_ERROR, onRegisterErrorHandler);
				registerMc.addEventListener(UserManagerEvent.REGISTER_HIDE, onRegisterHideHandler);
				this.addChild(registerMc);
				registerMc.visible = true;
			}
			//registerMc.y = -stage.stageHeight;
			//TweenLite.to(registerMc, 0.3, { y:(stage.stageHeight - registerMc.height) / 2, ease:Quart.easeOut } );
		}
		private function onRegisterErrorHandler(evt:UserManagerEvent):void
		{
			showSystemAlert(evt.params.err);
		}
		private function onRegisterHideHandler(evt:UserManagerEvent):void
		{
			TweenLite.to(evt.currentTarget, 0.3, { y:stage.stageHeight, ease:Quart.easeOut, onComplete:function():void { showLoginMc() }} );
		}
		private function registerOKHandler(bl:Boolean):void
		{
			this.setChildIndex(alertBox, this.numChildren - 1);
			if (bl)
			{
				alertBox.showAlert("恭喜你，已经成功注册，按确认直接进入游戏", "系统提示", 1, registSuccessHandler, registerFailHandler);
			}
			else
			{
				alertBox.showAlert("很遗憾，您注册没有成功，请再次尝试", "系统提示", 1, registerFailHandler, registerFailHandler);
			}
		}
		private function registSuccessHandler():void
		{
			this.login_mc.txt_username.text = registerMc.first.txt_username.text;
			this.login_mc.txt_password.text = registerMc.first.txt_password1.text;
			//registerMc.y = -stage.stageHeight;
			registerMc.visible = false;
			//registerMc.clean();
			//registerMc.showFirstMc();
			showLoginMc();
		}
		private function registerFailHandler():void
		{
			//registerMc.clean();
			//registerMc.showFirstMc();
		}
		private function onStageKeyDownHandle(event:KeyboardEvent):void
		{
			if (event.keyCode == Keyboard.ENTER)
			{
				onBtnLoginClickHandler(null);
			}
		}
		private function onBtnLoginClickHandler(evt:MouseEvent):void
		{
			//开始登录时先记录下userName和passWord，在成功登录后再次修正
			login_mc.logining.visible = true;
			if (evt != null) 
			{
				evt.currentTarget.removeEventListener(MouseEvent.CLICK, onBtnLoginClickHandler);
			}
			var userName:String = escape(this.login_mc.txt_username.text);
			var passWord:String = escape(this.login_mc.txt_password.text);
			writeCookie(userName, passWord, this.login_mc.rememberpwd.selected);
			login.connectServer(userName, passWord, "snooker", "lobby");
		}
		private function onConnectFailHandler(evt:UserManagerEvent):void
		{
			showSystemAlert("服务器连接失败");
			setLoginBtnEvent();
		}
		private function onConnectLostHandler(evt:UserManagerEvent):void
		{
			showSystemAlert("与服务器断开连接");
			setLoginBtnEvent();
		}
		private function onRoomJoinErrorHandler(evt:UserManagerEvent):void
		{
			showSystemAlert("fangjian房间出错: " + evt.params.error);
			setLoginBtnEvent();
		}
		private function LoginErrorHandler(evt:UserManagerEvent):void
		{
			showSystemAlert("登录失败：" + evt.params);
			setLoginBtnEvent();
		}
		private function showSystemAlert(txt:String):void
		{
			this.setChildIndex(alertBox, this.numChildren - 1);
			alertBox.showAlert(txt, "系统提示", 0);
		}
		private function setLoginBtnEvent():void
		{
			//登录发生错误后，重新登陆，需要重新激活按钮事件
			login_mc.logining.visible = false;
			login_mc.btn_login.addEventListener(MouseEvent.CLICK, onBtnLoginClickHandler, false, 0, true);
		}
		private function LoginSuccessHandler(evt:UserManagerEvent):void
		{
			//登录完成
			//设置用户的人人网属性
			if (renrenData) {
				sfs.setUserVariables(renrenData);
				renrenBtn.visible = false;
				
				if(login_mc) login_mc.visible = false;
				doubleTrace("登录成功" + sfs.myUserId + ", 当前房间: " + sfs.getActiveRoom().getName() + ", 用户昵称: " + unescape(sfs.getActiveRoom().getUser(sfs.myUserId).getVariable("name")));
				//myUser = sfs.getActiveRoom().getUser(sfs.myUserId);
				setLoginEvent(false);
				setSFSEvent(true);

				showStartGameButton();//显示开始游戏按钮
			}
		}
		private function setSFSEvent(bl:Boolean):void {
			if (bl) {
				sfs.addEventListener(SFSEvent.onExtensionResponse, onExtensionResponseHandler, false, 0, true);
			}else {
				sfs.removeEventListener(SFSEvent.onExtensionResponse, onExtensionResponseHandler);
			}
		}
		//===================================================================================================
		//登录处理完毕
		//===================================================================================================
		
		//===================================================================================================
		//===================================================================================================
		//工具函数
		//===================================================================================================
		//===================================================================================================
		private function readCookie():void
		{
			myCookie = new Cookie("www.snooker.com", 24 * 60 * 60 * 1000);
			if(myCookie.contain("login"))
			{
				if(myCookie.get("login").flag=="1")
				{
					//需要记住密码
					this.login_mc.txt_username.text = myCookie.get("login").username;
					this.login_mc.txt_password.text = myCookie.get("login").password;
					this.login_mc.rememberpwd.selected = true;
				}
				else
				{
					this.login_mc.txt_username.text = myCookie.get("login").username;
					this.login_mc.rememberpwd.selected = false;					
				}
			}
		}
		private function rememberChangeHandler(evt:Event):void
		{
			writeCookie(this.login_mc.txt_username.text, this.login_mc.txt_password.text, evt.currentTarget.selected);
		}
		private function writeCookie(uname:String, pwd:String, f:Boolean):void
		{
			myCookie = new Cookie("www.snooker.com", 24 * 60 * 60 * 1000);
			if(f)
			{
				//记住密码
				if(myCookie.contain("login"))
				{
					myCookie.remove("login");
				}
				myCookie.put("login",{username:uname, password:pwd, flag:f?"1":"0"});
			}
			else
			{
				//清楚记住的密码
				if(myCookie.contain("login")) myCookie.remove("login");
			}
		}
		
		private function showLoginMc():void
		{
			if (!login_mc) {
				login_mc = new Login_mc();
				login_mc.ipaddress.text = ipAddress;
				login_mc.x = 0;// (stage.stageWidth - login_mc.width) / 2;
				login_mc.y = 0;// (stage.stageHeight - login_mc.height) / 2;
				addChild(login_mc);
			}
			login_mc.visible = true;
			//login_mc.y = -stage.stageHeight;
			//TweenLite.to(login_mc, 0.3, { y:(stage.stageHeight - login_mc.height) / 2, ease:Quart.easeOut } );
		}
		private function setLoginMcTabIndex():void
		{
			login_mc.txt_username.tabIndex = 1;
			login_mc.txt_password.tabIndex = 2;
		}
		private function addExternalFunction():void
		{
			//ExternalInterface.addCallback("showAlert", showSystemAlert);//用户外部调用提示信息框
			//ExternalInterface.addCallback("registerOK", registerOKHandler);
			ExternalInterface.addCallback("onUnloadBrower", onUnloadBrowerHandler);
			//ExternalInterface.addCallback("beforeUnloadBrower", beforeUnloadBrowerHandler);
		}
		//private var beforeUnloadRoomId:int;//在窗口关闭前就记录下房间号
		private function beforeUnloadBrowerHandler():void {
			//用户准备关闭浏览器
			//beforeUnloadRoomId = sfs.activeRoomId;
			//doubleTrace("beforeUnloadBrower: roomId = " + beforeUnloadRoomId);
			ExternalInterface.call("showAlert", game_mode);//告诉js游戏状态			
		}
		
		private function onUnloadBrowerHandler(temp:* = null):void {
			//用户关闭浏览器，在后台将用户踢下线
			//这种退出方式属于显性（主动）退出，即明知退出后果，仍旧要退出
			if(game_mode == 1 && sfs.getActiveRoom().getName() != "lobby") sfs.sendXtMessage("SnookerRoom", "userUnloadBrower", {},"xml", sfs.getActiveRoom().getId());//双人对战模式
		}
		private function onUserExitHandler(temp:* = null):void {
			//用户中途退出游戏，在后台将用户退回到lobby
			//这种退出方式属于隐性（被动）退出，即因为网络问题，或关闭浏览器时没有收到提示，导致退出
			if (game_mode == 1 && sfs.getActiveRoom().getName() != "lobby") sfs.sendXtMessage("SnookerRoom", "userExitGame", { }, "xml", sfs.getActiveRoom().getId());//双人对战模式
			closeConfirmBox();
			game_mode = -1;
			destroySnooker();
		}
		private function addMemoryMonitor():void {
			//增加内存使用监控器
			var memoryMonitor:MemoryMonitor = new MemoryMonitor(10, 0x00ff00, 100);
			memoryMonitor.x = 320;
			memoryMonitor.y = 530;
			this.addChild(memoryMonitor);
		}
		
		private function destroySnooker():void {
			if (snookerGame) {
				snookerGame.destroyObjects();
				snookerGame.removeEventListener(SnookerEvent.GAME_OVER, onSnookerGameNormalGameOverHandler);
				snookerGame.removeEventListener(SnookerEvent.GAME_STOP, onSnookerGameStopHandler);
				snookerGame = null;
			}
		}
		//确认窗口处理
		private var confirmBox:Sprite;
		//private var confirmFunction:Function;
		//private var cancelFunction:Function ;
		
		private function initConfirmBox():void {
			//确认框初始化
			confirmBox = new ConfirmBox();
			confirmBox.x = stage.width / 2;
			confirmBox.y = stage.height / 2;
			confirmBox.name = "confirmbox";
			confirmBox.visible = false;
			confirmBox.filters = new Array(new GlowFilter(0x000000, 1, 50, 50, 2, 2));
			confirmBox.addEventListener(MouseEvent.CLICK, onConfirmBoxClickHandler);
			this.addChild(confirmBox);
		}
		private function onConfirmBoxClickHandler(event:MouseEvent):void {
			doubleTrace("onConfirmBoxClickHandler: " + event.currentTarget.name);
		}
		private function showConfirmBox(string:String, 
										confirmBtnClassName:String, 
										cancelBtnClassName:String, 
										confirmFun:Function = null, 
										cancelFun:Function = null, 
										showCloseBtn:Boolean = false):void {
											
			if (confirmBox) TextField(confirmBox.getChildByName("txt")).text = string;
			if (showCloseBtn) {
				confirmBox.getChildByName("btnClose").visible = true;
				confirmBox.getChildByName("btnClose").addEventListener(MouseEvent.CLICK, onConfirmBoxCloseHandler, false, 0, true);
			}
			else {
				confirmBox.getChildByName("btnClose").visible = false;
				confirmBox.getChildByName("btnClose").removeEventListener(MouseEvent.CLICK, onConfirmBoxCloseHandler);				
			}
			
			var btn1:MovieClip = confirmBox.getChildByName("btn1") as MovieClip;
			var btn2:MovieClip = confirmBox.getChildByName("btn2") as MovieClip;
			
			if (btn1) { 
				btn1.removeEventListener(MouseEvent.CLICK, confirmFun);
				confirmBox.removeChild(btn1); 
				btn1 = null; 
			}
			var btnClass:Class = getDefinitionByName(confirmBtnClassName) as Class;
			btn1 = new btnClass();
			btn1.x = -115; btn1.y = -7.5;
			btn1.name = "btn1";
			btn1.buttonMode = true;
			btn1.addEventListener(MouseEvent.CLICK, confirmFun);
			confirmBox.addChild(btn1);
			
			if (btn2) { 
				btn2.removeEventListener(MouseEvent.CLICK, cancelFun);
				confirmBox.removeChild(btn2); 
				btn2 = null;
			}
			btnClass = getDefinitionByName(cancelBtnClassName) as Class;
			btn2 = new btnClass();
			btn2.x = 16.85; btn2.y = -7.5;
			btn2.name = "btn2";
			btn2.buttonMode = true;
			btn2.addEventListener(MouseEvent.CLICK, cancelFun);
			confirmBox.addChild(btn2);

			this.setChildIndex(confirmBox, this.numChildren - 1);
			confirmBox.visible = true;
		}
		private function onConfirmBoxCloseHandler(event:MouseEvent):void {
			closeConfirmBox();
		}
		
		private function closeConfirmBox(temp:* = null):void {
			confirmBox.visible = false;
		}
		
		//游戏正常决出胜负后处理
		private function onSnookerGameNormalGameOverHandler(event:SnookerEvent):void {
			//doubleTrace("GameOver");
			showConfirmBox(event.params.message as String, "BtnPlayagain", "BtnCancel", continueWithSameOpponent, backToLobby, false);
		}

		//游戏非正常退出
		private function onSnookerGameStopHandler(event:data.SnookerEvent):void {
			if (game_mode == 1) {
				//如果是从双人游戏退出
				showConfirmBox(Config.gameStopAlert, "BtnConfirm", "BtnCancel", onUserExitHandler, closeConfirmBox, false);
			}else if (game_mode == 0) {
				onSnookerGameNormalGameOverHandler(event);//如果是单人，则如同单人游戏结束一样的处理
			}
		}
		
		//战后处理函数
		private function continueWithSameOpponent(temp:* = null):void {
			//继续和刚才游戏者对战，游戏结束时，双方仍旧在游戏房间里面
			closeConfirmBox();
			showWaitingBar(true);
			destroySnooker();
			if (game_mode == 0) {
				initSingleGame();//重新开始单人游戏
			}else if (game_mode == 1) {
				//不换房间继续游戏
				//此命令发出后，会得到
				//1- "opponentContinue"：即有一方用户继续，需要等待另外一方确认
				//2- "start"：双方都确认了，开始游戏
				sfs.sendXtMessage("SnookerRoom", "restart", { } );
			}
		}
		private function backToLobby(temp:* = null):void {
			//A退回游戏大厅
			//A向服务器发送回到大厅的命令
			//服务器收到此命令后，首先向房间里的其他用户广播A要退出房间，并向被通知的用户B发出"opponentExitToLobbyAfterFinishedGame"消息
			//如果房间里只有A，就不广播了
			//然后服务器把A加入到lobby大厅
			if(game_mode == 1 && sfs.getActiveRoom().getName() != "lobby") sfs.sendXtMessage("SnookerRoom", "backToLobby", { } );
			closeConfirmBox();
			destroySnooker();
		}
		private function acceptInvitation(temp:* = null):void {
			//B收到邀请后，接受邀请
			//向服务器发送prepareRoom命令，即开房间。
			//这里，受邀方是开放的人，即妓女在妓院里面接客，嫖客向妓女A发出邀请，妓女A说OK，于是有妓女去准备房间。
			//该命令向服务器发出后，会遇到房间没开成功，或者房间已经存在的情况。比方：房间坏了，房间里面已经有人在搞了。
			sfs.sendXtMessage("SnookerRoom", "prepareRoom", { opponent:opponentId } );
			//这里的opponent是嫖客A，因为服务器需要知道A的名字，以及B的名字以便开房间
			destroySnooker();
			closeConfirmBox();
		}
		private function refuseInvitation(temp:* = null):void {
			//B收到邀请后，拒绝邀请
			//并向服务器发送resuseInvitation命令。
			//比方，妓女A收到B的邀请后，不喜欢做，于是拒绝
			//原来的邀请方被拒绝后，收到消息：refusedByOpponent
			sfs.sendXtMessage("SnookerRoom", "refuseInvitation", { opponent:opponentId } );
			//这里的opponent是嫖客A，因为服务器需要得到A的名字，并向A发送refusedByOpponent消息
			closeConfirmBox();
		}
		
		//进度条管理
		private var waitingBar:Sprite;
		private function initWaitingBar():void {
			waitingBar = new Waiting();
			waitingBar.x = 0;
			waitingBar.y = 0;
			this.addChild(waitingBar);
			showWaitingBar(false);
		}
		private function showWaitingBar( bl:Boolean = true, txt:String = ""):void {
			if (bl) {
				TextField(waitingBar.getChildByName("txt")).text = txt;
				waitingBar.visible = true;
				this.setChildIndex(waitingBar, this.numChildren - 1);
			}else {
				TextField(waitingBar.getChildByName("txt")).text = "";
				waitingBar.visible = false;
			}
		}
	}
}