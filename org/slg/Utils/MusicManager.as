package org.slg.Utils
{
	import flash.display.MovieClip;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import org.slg.Events.MusicEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	
	/**
	 * ...
	 * @author ...
	 */
	public class MusicManager extends EventDispatcher
	{
		private var musicArray:Array;
		private var currentId:int = 0;//当前播放的序号
		private var localDir:String;
		private var soundChannel:SoundChannel;
		private var xmlFileName:String = "list.xml";
		
		public function MusicManager(dir:String) 
		{
			musicArray = new Array();
			localDir = dir;
			loadMusicXML(localDir + xmlFileName);
		}
		
		private function loadMusicXML(xml:String):void
		{
            var loader:URLLoader = new URLLoader();
            loader.addEventListener(Event.COMPLETE, onMusicXmlLoadedHandler);
            loader.addEventListener(IOErrorEvent.IO_ERROR, this.onMusicXmlLoadFailed);
            loader.load(new URLRequest(xml));
		}
		private function onMusicXmlLoadedHandler(evt:Event):void
		{
            var musicXML:XML = new XML(evt.currentTarget.data);
			for each(var m:* in musicXML.Musics.music)
			{
				var obj:Object = new Object();
				obj.id = m.@id;
				obj.name = m.@name;
				obj.fileName = m.@fileName;
				musicArray.push(obj);
			}
			currentId = 0;
			dispatchEvent(new MusicEvent(MusicEvent.XML_LOAD_COMPLETE, musicArray));
		}
		private function onMusicXmlLoadFailed(evt:IOErrorEvent):void
		{
			
		}
		private function onSoundLoadedHandler(evt:Event):void
		{
			dispatchEvent(new MusicEvent(MusicEvent.START_LOADING_MUSIC, musicArray[currentId]));			
		}
		private function onSoundLoadedErrorHandler(evt:IOErrorEvent):void
		{
			playNext();
		}
		public function play(id:int = -1):void
		{
			//播放当前
			var sound:Sound = new Sound();
			sound.addEventListener(Event.COMPLETE, onSoundLoadedHandler);
			sound.addEventListener(IOErrorEvent.IO_ERROR, onSoundLoadedErrorHandler);
			var fileName:String
			if (id == -1)
				fileName = localDir + musicArray[currentId].fileName;
			else
				fileName = localDir + musicArray[id].fileName;
			sound.load(new URLRequest(fileName));
			soundChannel = sound.play(0, 1);
		}
		public function playByName(name:String):void
		{
			//播放当前
			var sound:Sound = new Sound();
			sound.addEventListener(Event.COMPLETE, onSoundLoadedHandler);
			sound.addEventListener(IOErrorEvent.IO_ERROR, onSoundLoadedErrorHandler);
			sound.load(new URLRequest(localDir + name));
			soundChannel = sound.play(0, 1);
		}
		public function playNext():void
		{
			soundChannel.stop();
			if (currentId < musicArray.length - 1)
			{
				currentId++;
			}
			else
			{
				currentId = 0;
			}
			play();
		}
		public function playPrevious():void
		{
			soundChannel.stop();
			if (currentId == 0)
			{
				currentId = musicArray.length - 1;
			}
			else
			{
				currentId--;
			}
			play();
		}
		public function stop():void
		{
			soundChannel.stop();
		}
		public static function playLibSound(className:String):void
		{
			var aClass:Class = ApplicationDomain.currentDomain.getDefinition(className) as Class;
			var sound:Sound = new aClass();
			sound.play(0, 1);
		}
	}
}