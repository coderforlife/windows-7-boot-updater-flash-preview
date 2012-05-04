package Win7BootUpdater
{
	import flash.display.MovieClip;
	import flash.display.Shape;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	
	import flash.net.URLRequest;
	import flash.net.URLLoader;

	import flash.utils.getTimer;
	
	import flash.system.Capabilities;

	public class Main extends MovieClip
	{
		public static const ServerUrl:String = "http://coderforlife/projects/win7boot/skins/";
		public static var Name:String;
		public static function GetUrlRequestForPart(part:String):URLRequest { return new URLRequest(Main.ServerUrl + "skin/" + Main.Name + "/?" + part); }
		
		private static var _half:Boolean = false;
		public static function get UsingHalfQuality():Boolean { return Main._half; }

		public static function CreateRectangle(w:Number, h:Number, bgColor:uint, lineWidth:Number = 0, lineColor:uint = 0x000000):Shape
		{
			var s:Shape = new Shape();
			s.graphics.beginFill(bgColor);
			if (lineWidth > 0)
				s.graphics.lineStyle(lineWidth, lineColor);
			s.graphics.drawRect(0, 0, w, h);
			return s;
		}

		public var winload:Preview, winresume:Preview;
		
		public function Main()
		{
			//this.stage.frameRate = Animation.FrameRate;
			
			var params:Object = this.root.loaderInfo.parameters;
			Main.Name = ("bs7" in params) ? params["bs7"] : "test-bg-new";
			Main._half = ("half" in params) && params["half"].toLowerCase() == "true";

			var ver:String = Capabilities.version, space:int = ver.indexOf(" ")+1;
			if (Number(ver.substring(space, ver.indexOf(",", space))) < 11)
			{
				setTimeout(this.BadVersion, 0);
			}
			else
			{
				var xmlLoader:URLLoader = new URLLoader();
				xmlLoader.addEventListener(Event.COMPLETE, XmlLoaded);
				xmlLoader.addEventListener(ProgressEvent.PROGRESS, XmlProgress);				
				xmlLoader.addEventListener(IOErrorEvent.IO_ERROR, Failed);
				xmlLoader.load(GetUrlRequestForPart("xml"));
			}
		}
				
		public function ShowError(txt:String):void { this.gotoAndStop("error"); this.ErrorMessage.text = txt; }
		public function Failed(e:IOErrorEvent):void { this.ShowError(e.text); }
		private function BadVersion():void { this.ShowError("Flash Player 11 or newer required"); }
		public function SetProgress(x:Number) { if (this.Bar) this.Bar.width = x*348; }
		public function AnimProgress(e:ProgressEvent):void { this.SetProgress(0.2 + this.winresume ? (0.4 * (this.winload.percLoaded + this.winresume.percLoaded)) : (0.8 * this.winload.percLoaded)); }
		private function XmlProgress(e:ProgressEvent):void { this.SetProgress(e.bytesLoaded * 0.2 / e.bytesTotal); }
		public function AnimLoaded(e:Event):void
		{
			trace("Animation Loaded: "+getTimer());
			if (this.winload.complete && (!this.winresume || this.winresume.complete))
				this.gotoAndStop("animator");
		}
		public function AddAnimEvents(p:Preview):void
		{
			p.addEventListener(Event.COMPLETE, this.AnimLoaded);
			p.addEventListener(IOErrorEvent.IO_ERROR, this.Failed);
			p.addEventListener(ProgressEvent.PROGRESS, this.AnimProgress);
		}
		private function XmlLoaded(e:Event):void
		{
			try
			{
				var bs:XML = new XML(e.target.data);
				if (bs.name() != "BootSkin7" || bs.@version != "1")
				{
					this.ShowError("Boot Skin could not be loaded (invalid file)");
					return;
				}
				
				trace('Loading started at '+getTimer());
				
				this.winload = new Preview(bs.Winload[0]);
				AddAnimEvents(this.winload);
				
				var wr:XMLList = bs.Winresume;
				if (wr.length() > 0)
					this.AddAnimEvents(this.winresume = new Preview(wr[0], this.winload));
				else
					this.winresume = null;
			}
			catch (err:Error)
			{
				trace(err.getStackTrace());
				this.ShowError(err.message);
			}
			
			trace('Finished loading XML at '+getTimer());
		}
	}
}