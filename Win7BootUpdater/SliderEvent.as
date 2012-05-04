package Win7BootUpdater {
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	public class SliderEvent extends Event {
		public static const CHANGE:String = "sliderChange";
		public static const STOP:String = "sliderEnd";
		public static const START:String = "sliderStart";
		
		public var percent:Number;
		public var value:int;
		
		public function SliderEvent(type:String, percent:Number, value:int, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			this.percent = percent;
			this.value = value;
		}
		
		public override function clone():Event {
			return new SliderEvent(this.type, this.percent, this.value, this.bubbles, this.cancelable);
		}
		
		public override function toString():String {
			return formatToString("SliderEvent", "percent", "value", "type", "bubbles", "cancelable");
		}
	}
}
