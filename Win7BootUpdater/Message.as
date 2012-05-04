package Win7BootUpdater
{
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class Message extends TextField
	{
		public var id:uint = 0;
		
		public function Message(xml:XML, backColor:uint)
		{
			this.id = uint(xml.@id)-1;
			
			var format:TextFormat = new TextFormat("Segoe UI",
				Number(xml.TextSize[0].toString()), Preview.GetXMLColor(xml.TextColor, 0xFFFFFF));
			format.align = TextFormatAlign.CENTER;
			
			super.x = 0;
			super.y = Number(xml.Position[0].toString());
			super.selectable = false;
			super.background = true;
			super.backgroundColor = backColor;
			//super.autoSize = TextFieldAutoSize.CENTER;
			super.text = xml.Text[0].toString();
			super.setTextFormat(format);
			super.width = Preview.Width;
			super.height = super.textHeight * 1.2;
		}
	}
}
