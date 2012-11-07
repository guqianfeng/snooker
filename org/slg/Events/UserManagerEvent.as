package org.slg.Events
{
    import flash.events.*;

    public class UserManagerEvent extends Event
    {
        public var params:Object;
		public static const LOGIN_SUCCESS:String = "LoginSuccess";//
		public static const LOGIN_FAIL:String = "LoginFail";
		public static const CONNECT_FAIL:String = "ConnectFail";
		public static const CONNECT_LOST:String = "ConnectLost";
		public static const ROOM_JOIN:String = "RoomJoined";
		public static const ROOM_JOIN_FAIL:String = "RoomJoinFail";
		public static const SHOW_ALERT:String = "ShowAlert";
		public static const REGISTER_ERROR:String = "RegisterError";
		public static const REGISTER_HIDE:String = "HideRegister";
		
        public function UserManagerEvent(param1:String, param2:Object = null)
        {
            super(param1);
            this.params = param2;
        }

        override public function toString() : String
        {
            return formatToString("UserManagerEvent", "type", "bubbles", "cancelable", "eventPhase", "params");
        }

        override public function clone() : Event
        {
            return new UserManagerEvent(this.type, this.params);
        }

    }
}