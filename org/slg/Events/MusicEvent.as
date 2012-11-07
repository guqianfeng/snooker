package org.slg.Events
{
    import flash.events.*;

    public class MusicEvent extends Event
    {
        public var params:Object;
		public static const XML_LOAD_COMPLETE:String = "LoadedFinished";//
		public static const XML_LOAD_FAIL:String = "LoadedFail";//
		public static const START_LOADING_MUSIC:String = "StartLoading";//返回当前播放的参数

        public function MusicEvent(param1:String, param2:Object = null)
        {
            super(param1);
            this.params = param2;
        }

        override public function toString() : String
        {
            return formatToString("MusicEvent", "type", "bubbles", "cancelable", "eventPhase", "params");
        }

        override public function clone() : Event
        {
            return new MusicEvent(this.type, this.params);
        }
	}
}