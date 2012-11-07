package data
{
    import flash.events.*;

    public class SnookerEvent extends Event
    {
        public var params:Object;
		public static const TIME_OVER:String = "TimeOver";//事件到
		public static const AVATAR_CLICK:String = "Avatarclicked";
		public static const GAME_OVER:String = "GameOver_Normal";//正常决出胜负后的退出
		public static const GAME_STOP:String = "GameStop_Normal";//正常决出胜负后的退出
		
        public function SnookerEvent(param1:String, param2:Object = null)
        {
            super(param1);
            this.params = param2;
        }

        override public function toString() : String
        {
            return formatToString("SnookerEvent", "type", "bubbles", "cancelable", "eventPhase", "params");
        }

        override public function clone() : Event
        {
            return new SnookerEvent(this.type, this.params);
        }
	}
}