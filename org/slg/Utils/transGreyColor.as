package org.slg.Utils
{
	/*	自己写的一个图像灰度转化类
	 * 	transColor(type)方法
	 * 	type值参考transFomula函数
	 */
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	
	public class transGreyColor extends MovieClip
	{
		private var transTypes:int = 12;
		private var bitmapdata:BitmapData;
		public function transGreyColor(bmd:BitmapData):void
		{
			//loadPic("12.jpg");
			bitmapdata = bmd.clone();
		}
		/*
		private function loadPic(file:String):void
		{
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, picLoadedHandler);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, picLoadedErrorHandler);
			loader.load(new URLRequest(file));
		}
		private function picLoadedHandler(evt:Event):void
		{
			var containerMc:MovieClip = new MovieClip();
			this.addChild(containerMc);
			var bitmap:Bitmap = evt.currentTarget.content as Bitmap;
			this.addChild(bitmap);
			for (var i:int = 1; i <= transTypes; i++)
			{
				var bmd:BitmapData = bitmap.bitmapData.clone();
				var bitmap2:Bitmap = new Bitmap(transColor(bmd, i));
				bitmap2.x = bitmap.width * i;;
				containerMc.addChild(bitmap2);
			}
		}
		private function picLoadedErrorHandler(evt:Event):void
		{
			trace("文件下载失败");
		}
		*/
		public function transColor(type:int):BitmapData
		{
			for (var i:int = 1; i <= bitmapdata.width; i++)
			{
				for (var j:int = 1; j <= bitmapdata.height; j++)
				{
					var pixelValue:uint = bitmapdata.getPixel32(i, j);
					var alphaValue:uint = pixelValue >> 24 & 0xFF;
					var red:uint = pixelValue >> 16 & 0xFF;
					var green:uint = pixelValue >> 8 & 0xFF;
					var blue:uint = pixelValue & 0xFF;
					bitmapdata.setPixel32(i, j, transFomula(red, green, blue, type));
				}
			}
			return bitmapdata;
		}
		private function transFomula(r:int, g:int, b:int, type:int):int
		{
			var greyColor:int;
			switch(type)
			{
				case 1://返回红色通道
					greyColor = r;
					break;
				case 2://返回绿色通道
					greyColor = g;
					break;
				case 3://返回蓝色通道
					greyColor = b;
					break;
				case 4://返回平均值
					greyColor = (r + g + b) / 3;
					break;
				case 5://返回最大值
					greyColor = Math.max(r, g, b);
					break;
				case 6://返回最小值
					greyColor = Math.min(r, g, b);
					break;
				case 7://返回最大最小的平均值
					greyColor = (Math.max(r, g, b) + Math.min(r, g, b)) / 2;
					break;
				case 8://按ITU-R BT.601标准
					greyColor = 0.299 * r + 0.587 * g + 0.114 * b;
					break;
				case 9://Photoshop灰度算法
					greyColor = 0.3 * r + 0.59 * g + 0.11 * b;
					break;
				case 10://ITU-R BT.709标准
					greyColor = 0.213 * r + 0.715 * g + 0.072 * b;
					break;
				case 11://ITU标准(ITU standard)
					greyColor = 0.222 * r + 0.707 * g + 0.071 * b;
					break;
				case 12://BT.601 Gamma 2.2的灰度公式
					greyColor == int((Math.pow(0.3 * r, 2.2) + Math.pow(0.59 * g, 2.2) + Math.pow(0.11 * b, 2.2)) ^ (1 / 2.2));
					break;
			}
			return greyColor + greyColor * 256 + greyColor * 256 * 256;
		}
	}
}