package Win7BootUpdater {
	import flash.utils.ByteArray;
	
	public class Base64 {
		private static const decodeChars:Vector.<int> = Vector.<int>([
			-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
			-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 62, -1, -1, -1, 63,
			52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -1, -1, -1, -1, -1, -1, -1,  0,  1,  2,  3,  4,  5,  6,
			 7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -1, -1, -1, -1, -1,
			-1, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48,
			49, 50, 51, -1, -1, -1, -1, -1
		]);
		public static function Decode(str:String):ByteArray {
			var c1:int, c2:int, c3:int, c4:int;
			var i:int = 0, len:int = str.length, out:ByteArray = new ByteArray();
			while (i < len) {
				do { // c1
					c1 = decodeChars[str.charCodeAt(i++) & 0xff];
				} while (i < len && c1 == -1);
				if (c1 == -1) { break; }
				do { // c2
					c2 = decodeChars[str.charCodeAt(i++) & 0xff];
				} while (i < len && c2 == -1);
				if (c2 == -1) { break; }
				out.writeByte((c1 << 2) | ((c2 & 0x30) >> 4));
				do { // c3
					c3 = str.charCodeAt(i++) & 0xff;
					if (c3 == 61) { out.position = 0; return out; }
					c3 = decodeChars[c3];
				} while (i < len && c3 == -1);
				if (c3 == -1) { break; }
				out.writeByte(((c2 & 0x0f) << 4) | ((c3 & 0x3c) >> 2));
				do { // c4
					c4 = str.charCodeAt(i++) & 0xff;
					if (c4 == 61) { out.position = 0; return out; }
					c4 = decodeChars[c4];
				} while (i < len && c4 == -1);
				if (c4 == -1) { break; }
				out.writeByte(((c3 & 0x03) << 6) | c4);
			}
			out.position = 0;
			return out;
		}
	}
}
