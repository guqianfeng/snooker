package org.slg.Utils
{
	import flash.accessibility.AccessibilityProperties;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.display.Loader;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import org.slg.Events.*;
	
	/**古千峰 2009/4/9
	 * 用于下载数组中的图片
	 * @author ...
	 */
	public class ArrayLoader extends EventDispatcher
	{
		private var loadArray:Array;//要下载文件的名字以及路径
		private var loadId:int = 0;
		private var resultArray:Array;//下载完成后的数组
		
		public function ArrayLoader(arr:Array = null):void
		{
			loadArray = arr;
			resultArray = new Array();
		}
		public function load():void
		{
			if (loadArray == null)
				dispatchEvent(new ArrayLoaderEvent(ArrayLoaderEvent.NO_ARRAY_DATA));
			else
				loadPic();//开始处理
		}
		private function loadPic():void
		{
			if (loadId < loadArray.length)
			{
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onPicLoadedHandler);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onPicLoadedFailHandler);
				var fileName:String = loadArray[loadId];
				loader.load(new URLRequest(fileName));
			}
			else
			{
				//下载完毕
				dispatchEvent(new ArrayLoaderEvent(ArrayLoaderEvent.COMPLETE, resultArray));
			}
		}
		private function onPicLoadedHandler(evt:Event):void
		{
			var result:*= evt.currentTarget.content;
			resultArray.push(result);
			loadId++;
			loadPic();
		}
		private function onPicLoadedFailHandler(evt:IOErrorEvent):void
		{
			dispatchEvent(new ArrayLoaderEvent(ArrayLoaderEvent.FAIL, loadId));
			resultArray.push(null);
			loadId++;
			loadPic();
		}
	}
	
}