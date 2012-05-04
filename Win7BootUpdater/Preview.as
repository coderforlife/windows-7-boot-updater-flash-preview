package Win7BootUpdater {
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	
	import flash.net.URLRequest;
	import flash.utils.setTimeout;
	
	// Supports the Event.COMPLETE, ProgressEvent.PROGRESS and IOErrorEvent.IO_ERROR events
	
	public class Preview extends Sprite {
		public static const Width = 1024, Height = 768;
		
		public static function GetXMLColor(x:XMLList, def:uint):uint { return x.length() > 0 ? uint("0x"+x[0].toString()) : def; }
		
		private function FireCompleteEvent():void { this.dispatchEvent(new Event(Event.COMPLETE)); }
		private function FireProgressEvent():void { this.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, this.bytesLoaded, this.bytesTotal)); }

		private function AddAnimEvents(a:Animation):void
		{
			a.addEventListener(ProgressEvent.PROGRESS, this.AnimProgress);
			a.addEventListener(Event.COMPLETE, this.AnimComplete);
			a.addEventListener(IOErrorEvent.IO_ERROR, this.dispatchEvent);
		}

		private function AddAnimEventsPossibly(a:Animation):void
		{
			if (a.complete)
			{
				this.AnimProgress(new ProgressEvent(ProgressEvent.PROGRESS, false, false, a.bytesTotal, a.bytesTotal));
				this.AnimComplete(new Event(Event.COMPLETE));
			}
			else this.AddAnimEvents(a);
		}

		private var mc:MovieClip = null;
		private var anim:Animation = null;
		private var bgComplete:Boolean = false, bgLoadedBytes:uint = 0, bgTotalBytes:uint = 0;
		
		public function get bytesLoaded():uint  { return this.bgLoadedBytes + this.anim.bytesLoaded; }
		public function get bytesTotal():uint   { return this.bgTotalBytes  + this.anim.bytesTotal;  }
		public function get complete():Boolean  { return this.bgComplete    + this.anim.complete;    }
		public function get percLoaded():Number { return this.bytesLoaded   / this.bytesTotal;       }
		
		public function Preview(xml:XML, winload:Preview = null):void {
			// BackgroundColor
			super.addChild(Main.CreateRectangle(Width, Height, GetXMLColor(xml.BackgroundColor, 0)));
			
			// BackgroundImage
			var bg:XMLList = xml.BackgroundImage;
			if (bg.length() > 0)
			{
				this.bgTotalBytes = 1000000; // bigger than imaginable
				var l:Loader = new Loader();
				l.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, this.BGProgress);
				l.contentLoaderInfo.addEventListener(Event.COMPLETE, BGLoaded);
				l.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.dispatchEvent);
				if ("@cid" in bg[0])
				{
					l.load(Main.GetUrlRequestForPart('~'+bg[0].@cid));
					if (Main.UsingHalfQuality) { l.scaleX = 2.0; l.scaleY = 2.0; }
				}
				else
				{
					l.loadBytes(Base64.Decode(bg[0].toString()));
				}
				super.addChild(l);
			}
			else
			{
				this.bgComplete = true;
			}
			
			// Animation
			var anim:XMLList = xml.Animation;
			if (anim.length() > 0)
			{
				var _s:XMLList = anim[0].@source;
				var s:String = _s.length() > 0 ? s[0] : null;
				if (!s || s == "embedded")
				{
					this.anim = new Animation();
					if ("@cid" in anim[0])
						this.anim.LoadFromURL(Main.GetUrlRequestForPart('~'+anim[0].@cid));
					else
						this.anim.LoadFromBytes(Base64.Decode(anim[0].toString()));
				}
				else
				{
					this.anim = (s == "winload" && winload) ? winload.anim : ((s == "default") ? Animation.Default : Animation.Invalid);
				}
			}
			else
			{
				this.anim = (winload) ? winload.anim : Animation.Default;
			}
			this.AddAnimEventsPossibly(this.anim);
			super.addChild(this.anim);
			
			// Messages
			var msgs:XMLList = xml.Messages;
			if (msgs.length() > 0)
			{
				var msgBackColor:uint = GetXMLColor(msgs[0].BackgroundColor, 0);
				msgs = msgs[0].Message;
				var msg:Message;
				var out_msgs:Vector.<Message> = new Vector.<Message>(2, true);
				for each (var m:XML in msgs)
				{
					msg = new Message(m, msgBackColor);
					out_msgs[msg.id] = msg;
				}
				for each (msg in out_msgs)
					if (msg) super.addChild(msg);
			}
			
			// Check for early completion
			if (this.anim.complete && this.bgComplete)
				setTimeout(this.FireCompleteEvent, 1);
		}
		
		private function BGProgress(e:ProgressEvent):void { this.bgLoadedBytes = e.bytesLoaded; this.bgTotalBytes = e.bytesTotal; FireProgressEvent(); }
		private function BGLoaded(e:Event):void { this.bgComplete = true; if (this.anim.complete) FireCompleteEvent(); }
		
		private function AnimProgress(e:ProgressEvent):void { FireProgressEvent(); }
		private function AnimComplete(e:Event):void { if (this.bgComplete) FireCompleteEvent(); }
		
		private function ChangeFrame(e:Event):void
		{
			if (this.mc.currentFrame > Animation.TotalFrames)
				this.mc.gotoAndPlay(Animation.LoopFrame-1);
			else
				this.anim.currentFrame = this.mc.currentFrame;
		}
		
		public function Start(mc:MovieClip = null):void
		{
			if (mc != null) this.mc = mc;
			this.mc.addEventListener(Event.ENTER_FRAME, this.ChangeFrame);
			this.mc.removeChildren();
			this.mc.addChild(this);
		}
		public function Stop():void { this.mc.removeEventListener(Event.ENTER_FRAME, this.ChangeFrame); }
	}
}
