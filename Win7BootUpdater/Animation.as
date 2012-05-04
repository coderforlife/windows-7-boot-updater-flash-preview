package Win7BootUpdater
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Shape;
	import flash.display.Sprite;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	
	import flash.utils.ByteArray;
	import flash.net.URLRequest;
	
	// Supports the Event.COMPLETE, ProgressEvent.PROGRESS, and IOErrorEvent.IO_ERROR events
	
	public class Animation extends Sprite
	{
		public static const LoopFrame:uint = 61;
		public static const TotalFrames:uint = 105;
		public static const Width:uint = 200;
		public static const Height:uint = 200;
		public static const TotalHeight:uint = Height*TotalFrames;
		public static const FrameRate:uint = 15;
		
		private static var _def:Animation = null, _invalid:Animation = null;
		public static function get Default():Animation
		{
			if (!_def)
			{
				_def = new Animation();
				_def.LoadFromURL(new URLRequest(Main.ServerUrl + 'activity.png'));
			}
			return _def;
		}
		public static function get Invalid():Animation
		{
			if (_invalid == null) { _invalid = new InvalidAnimation(); }
			return _invalid;
		}
		
		private var _bytesLoaded:uint = 0, _bytesTotal:uint = 10000000; // bigger than imaginable
		public function get bytesLoaded():uint { return this._bytesLoaded; }
		public function get bytesTotal():uint  { return this._bytesTotal; }
		
		private var loader:Loader = null, image:Bitmap = null;
		private var _currentFrame:uint = 1;

		public function Animation()
		{
			super.x = (Preview.Width  - Width ) / 2;
			super.y = (Preview.Height - Height) / 2;
			
			var mask:Shape = Main.CreateRectangle(Width, Height, 0xFFFFFF);
			mask.x = 0;
			mask.y = 0;
			super.addChild(mask);
			super.mask = mask;
		}
		
		private function CreateLoader():Loader
		{
			this._bytesLoaded = 0;
			this.loader = new Loader();
			this.loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, this.LoadProgress);
			this.loader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.Loaded);
			this.loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.dispatchEvent);
			super.addChild(this.loader);
			return this.loader;
 		}
		private function LoadProgress(e:ProgressEvent):void
		{
			var li:LoaderInfo = e.target as LoaderInfo;
			this.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, this._bytesLoaded = li.bytesLoaded, this._bytesTotal = li.bytesTotal));
		}
		private function Loaded(e:Event):void
		{
			this.image = (e.target as LoaderInfo).content as Bitmap;
			this.image.x = 0;
			this.image.y = 0;
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
		public function LoadFromBytes(d:ByteArray):void { this.CreateLoader().loadBytes(d); }
		public function LoadFromURL(u:URLRequest):void  { this.CreateLoader().load(u); if (Main.UsingHalfQuality) { this.loader.scaleX = 2.0; this.loader.scaleY = 2.0; } }
		
		public function get complete():Boolean { return this.image != null; }
		
		public function get currentFrame():uint { return this._currentFrame; }
		public function set currentFrame(value:uint):void
		{
			if (value == TotalFrames + 1)
				value = LoopFrame;
			else if (value > TotalFrames)
				value = (value - LoopFrame) % (TotalFrames - LoopFrame) + LoopFrame - 1;
			if (value != this._currentFrame)
			{
				this._currentFrame = value;
				if (this.loader)
					this.loader.y = -(this._currentFrame - 1) * Height;
			}
		}
	}
}

class InvalidAnimation extends Win7BootUpdater.Animation
{
	private static var _invalid:flash.display.Shape = null;
	public function InvalidAnimation()
	{
		if (_invalid == null)
		{
			_invalid = Win7BootUpdater.Main.CreateRectangle(Width, Height, 0xFFFFFF, 10, 0xFF0000);
			_invalid.graphics.endFill();
			_invalid.graphics.drawPath(
				Vector.<int>   ([1,    2,             1,         2       ]),
				Vector.<Number>([0, 0, Width, Height, 0, Height, Width, 0])
			);
		}
		super.addChild(_invalid);
	}
	public override function get complete():Boolean { return true; }
}
