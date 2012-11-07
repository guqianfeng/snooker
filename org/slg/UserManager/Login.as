package org.slg.UserManager
{
	import flash.display.SWFVersion;
	import flash.events.EventDispatcher;
	import flash.media.Video;
	import it.gotoandplay.smartfoxserver.SmartFoxClient;
	import it.gotoandplay.smartfoxserver.data.*;
	import it.gotoandplay.smartfoxserver.SFSEvent;
	import org.slg.Utils.MD51;
	import org.slg.Events.UserManagerEvent;
	import com.hexagonstar.util.debug.Debug;
	
	/**作者：古千峰
	 * 用于sfs的custom Login 登录类
	 * 有md5加密功能，以及获取随机码并且屏蔽\符号功能
	 * 并且实现按下登录后再连接服务器，而不是打开就连服务器方式
	 * 以后凡是用到sfs用户登录的地方都用此类
	 * 需要换的地方：sfs.myUserId, sfs.myUserName的值
	 * 该类只有一个公共方法: connectServer(user,pwd,zone, loginRoom)
	 * 此类一定需要后台代码支持
	 */
	public class Login extends EventDispatcher
	{
		private var ipAddress:String;
		private var port:int;
		private var userName:String;
		private var passWord:String;
		private var randomKeyError:Boolean = false;
		private var reConnect:Boolean = false;
		private var flagRegister:Boolean = false;
		private var randowKey_str:String = "";	
		private var mySFS:SmartFoxClient;
		private var zoneName:String;//登录区
		private var enterRoom:String;//登录后进入的房间
		
		public function Login(SFSClient:*, ip:String = "127.0.0.1", serverPort:int = 9339):void 
		{
			ipAddress = ip;
			port = serverPort;
			mySFS = SFSClient;
		}
		public function connectServer(user:String, pwd:String, zone:String, loginRoom:String):void
		{
			configSFS(true);
			enterRoom = loginRoom;
			userName = user;
			passWord = pwd;
			zoneName = zone;
			if (userName != "" && passWord != "")
			{
				if (!mySFS.isConnected)
				{
					mySFS.connect(ipAddress, port);
				}
				else
				{
					//trace("已连接服务器,重新login");
					reConnect = true;
					mySFS.disconnect();
				}
			}
		}
		public function configSFS(bl:Boolean=true):void
		{
			if(bl)
			{
				mySFS.addEventListener(SFSEvent.onConnection, onConnection);//
				mySFS.addEventListener(SFSEvent.onRoomListUpdate, onRoomListUpdate);//
				mySFS.addEventListener(SFSEvent.onJoinRoom, onJoinRoom);//
				mySFS.addEventListener(SFSEvent.onJoinRoomError, onJoinRoomErrorHandler);//
				mySFS.addEventListener(SFSEvent.onExtensionResponse, onExtensionResponseMain);//
				mySFS.addEventListener(SFSEvent.onRandomKey, onRandomKeyHandlerMain);//
				mySFS.addEventListener(SFSEvent.onConnectionLost, onConnectionLostHandle);//
			}
			else
			{
				mySFS.removeEventListener(SFSEvent.onConnection, onConnection);
				mySFS.removeEventListener(SFSEvent.onRoomListUpdate, onRoomListUpdate);
				mySFS.removeEventListener(SFSEvent.onJoinRoom, onJoinRoom);
				mySFS.removeEventListener(SFSEvent.onJoinRoomError, onJoinRoomErrorHandler);
				mySFS.removeEventListener(SFSEvent.onRandomKey, onRandomKeyHandlerMain);
				mySFS.removeEventListener(SFSEvent.onConnectionLost, onConnectionLostHandle);
			}
		}
		private function onConnection(event:SFSEvent):void
		{
			//trace("已连接服务器");
			if (event.params.success )
			{
				mySFS.getRandomKey();
			}
			else
			{
				dispatchEvent(new UserManagerEvent(UserManagerEvent.CONNECT_FAIL));
			}
		}
		
		private function onRandomKeyHandlerMain(event:SFSEvent):void
		{
			randowKey_str = event.params.key;

			if (removeString(randowKey_str))
			{
				loginUser();
			}
			else
			{
				randomKeyError = true;
				mySFS.disconnect();
			}
		}
		private function removeString(key:String):Boolean
		{
			var a:Array=new Array();
			var b1:Boolean=true;
			for (var ii3:int=0; ii3<key.length; ii3++)
			{
				a.push(key.slice(ii3,ii3+1));
			}
			for (var ii2:int=0; ii2<a.length; ii2++)
			{
				switch (a[ii2])
				{
					case "\\" :
						b1=false;
						break;
					case "\n" :
						b1=false;
						break;
					case "\b" :
						b1=false;
						break;
					case "\r" :
						b1=false;
						break;
					case "\t" :
						b1=false;
						break;
					case "\v" :
						b1=false;
						break;
					case "\f" :
						b1=false;
						break;
					case "\'" :
						b1=false;
						break;
						case "\"" :;
						b1=false;
						break;
					case "\^" :
						b1=false;
						break;
				}
			}
			return b1;
		}
		private function onConnectionLostHandle(event:*):void
		{
			//trace("已与服务器断开连接");
			//登录时断线重连
			if(randomKeyError || reConnect)
			{
				randomKeyError = false;
				reConnect = false;
				mySFS.connect(ipAddress, port);
			}
			else
			{
				dispatchEvent(new UserManagerEvent(UserManagerEvent.CONNECT_LOST));
			}
		}
		
		private function onExtensionResponseMain(event:SFSEvent):void
		{
			var type:String = event.params.type;
			var data1:Object = event.params.dataObj;
			if (data1._cmd=="logOK")
			{
				//============================================================================
				mySFS.myUserId = Number(data1.systemId);		//根据不同需要改Number(data1.systemId)或者data1.uid
				mySFS.myUserName = data1.userid;		//根据不同需要改
				//============================================================================
				mySFS.getRoomList();
				dispatchEvent(new UserManagerEvent(UserManagerEvent.LOGIN_SUCCESS));
			}
			if (data1._cmd=="logKO")
			{
				configSFS(false);
				dispatchEvent(new UserManagerEvent(UserManagerEvent.LOGIN_FAIL, unescape(data1.info)));
			}
		}
		private function loginUser():void
		{
			var s2:String = MD51.hash(randowKey_str + passWord);
			mySFS.login(zoneName, userName, s2);
		}
		private function onRoomListUpdate(event:SFSEvent):void
		{
			//成功登录后再次记录正确的用户名和密码，以便短线重新登录时使用
			mySFS.joinRoom(enterRoom);
		}
		private function onJoinRoom(event:SFSEvent):void
		{
			configSFS(false);
			dispatchEvent(new UserManagerEvent(UserManagerEvent.ROOM_JOIN, event.params));
		}
		private function onJoinRoomErrorHandler(event:SFSEvent):void
		{
			configSFS(false);
			dispatchEvent(new UserManagerEvent(UserManagerEvent.ROOM_JOIN_FAIL, event.params));
		}
	}
	
}