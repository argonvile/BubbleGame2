package  
{
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.FlxColor;
	import flash.display.BitmapData;

	public class DefaultBubble extends Bubble
	{
		public var bubbleColor:int;
		private var regularGraphic:BitmapData;
		private var popGraphic:BitmapData;
		private const QUICK_APPROACH_DURATION:Number = 0.3;
		
		public function DefaultBubble(levelDetails:LevelDetails,x:Number,y:Number,bubbleColor:int) 
		{
			super(levelDetails, x, y);
			
			this.bubbleColor = bubbleColor;
			
			var key:String = "Microbe0 " + bubbleColor.toString(16);
			if (BitmapDataCache.getBitmap(key) == null) {
				var newData:BitmapData = FlxG.createBitmap(17, 17, 0x00000000, true);
				newData.draw(FlxG.addBitmap(Embed.Microbe0), new Matrix(17 / 50, 0, 0, 17 / 50, 0, 0));
				shiftHueBitmapData(newData, bubbleColor);
				newData.draw(FlxG.addBitmap(Embed.Eyes0));
				BitmapDataCache.setBitmap(key, newData);
			}
			regularGraphic = BitmapDataCache.getBitmap(key);
			
			var key:String = "popped Microbe0";
			if (BitmapDataCache.getBitmap(key) == null) {
				var newData:BitmapData = FlxG.createBitmap(17, 17, 0x00000000, true);
				newData.draw(FlxG.addBitmap(Embed.Microbe0), new Matrix(17 / 50, 0, 0, 17 / 50, 0, 0));
				whitenBitmapData(newData);
				newData.draw(FlxG.addBitmap(Embed.Eyes0));
				BitmapDataCache.setBitmap(key, newData);
			}
			popGraphic = BitmapDataCache.getBitmap(key);
			
			width = 17;
			height = 17;
			pixels = regularGraphic;
			updateAlpha();
		}
		
		public function loadPopGraphic():void {
			pixels = popGraphic;
			for each (var connector:DefaultConnector in connectors) {
				if (connector != null && connector.alive) {
					connector.loadPopGraphic();
				}
			}
		}
		
		public function loadRegularGraphic():void {
			pixels = regularGraphic;
			for each (var connector:DefaultConnector in connectors) {
				if (connector != null && connector.alive) {
					connector.loadRegularGraphic();
				}
			}
		}
		
		public static function whitenBitmapData(spritePixels:BitmapData, minValue:Number = 0.5,maxValue:Number=1.0):void {
			for (var pixelX:int = 0; pixelX < spritePixels.width; pixelX++) {
				for (var pixelY:int = 0; pixelY < spritePixels.height; pixelY++) {
					var pixelRgb:uint = spritePixels.getPixel32(pixelX, pixelY);
					var pixelHsv:Object = DefaultBubble.RGBtoHSV(pixelRgb);
					pixelHsv.saturation = 0;
					pixelHsv.value = minValue + (maxValue - minValue) * pixelHsv.value;
					pixelRgb = FlxColor.HSVtoRGB(pixelHsv.hue, pixelHsv.saturation, pixelHsv.value, FlxColor.getAlpha(pixelRgb));
					spritePixels.setPixel32(pixelX, pixelY, pixelRgb);
				}
			}
		}
		
		public static function shiftHueBitmapData(spritePixels:BitmapData, color:uint):void {
			if (color == 0xff000000) {
				return whitenBitmapData(spritePixels, 0.15, 0.5);
			} else if (color == 0xffffffff) {
				return whitenBitmapData(spritePixels, 0.5, 0.85);
			}
			var targetHsv:Object = FlxColor.RGBtoHSV(color);
			for (var pixelX:int = 0; pixelX < spritePixels.width; pixelX++) {
				for (var pixelY:int = 0; pixelY < spritePixels.height; pixelY++) {
					var pixelRgb:uint = spritePixels.getPixel32(pixelX, pixelY);
					var pixelHsv:Object = DefaultBubble.RGBtoHSV(pixelRgb);
					pixelHsv.hue = (targetHsv.hue + pixelHsv.hue) % 360;
					pixelRgb = FlxColor.HSVtoRGB(pixelHsv.hue, pixelHsv.saturation, pixelHsv.value, FlxColor.getAlpha(pixelRgb));
					spritePixels.setPixel32(pixelX, pixelY, pixelRgb);
				}
			}
		}
		
		public static function RGBtoHSV(color:uint):Object {
			var rgb:Object = FlxColor.getRGB(color);
			
			var cmax:Number = Math.max(rgb.red, rgb.green, rgb.blue);
			var cDiff:Number = cmax - Math.min(rgb.red, rgb.green, rgb.blue);
			var value:Number = cmax / 255;
			var saturation:Number = cmax == 0 ? 0 : cDiff / cmax;
			var hue:Number;
			if (rgb.red == cmax) {
				hue = (rgb.green - rgb.blue) / cDiff;
			} else if (rgb.green == cmax) {
				hue = 2 + (rgb.blue - rgb.red) / cDiff;
			} else {
				hue = 4 + (rgb.red - rgb.green) / cDiff;
			}
			hue /= 6;
			if (hue < 0) {
				hue++;
			}
			hue *= 360;
			return { hue:hue, saturation:saturation, value:value };
		}
		
		override public function isGrabbable(heldBubbles:FlxGroup, firstGrab:Boolean):Boolean {
			var heldBubble:Bubble = heldBubbles.getFirstAlive() as Bubble;
			if (heldBubble != null) {
				var heldDefaultBubble:DefaultBubble = heldBubble as DefaultBubble;
				if (heldDefaultBubble == null) {
					return false;
				}
				if (bubbleColor != heldDefaultBubble.bubbleColor) {
					return false;
				}
			}
			return super.isGrabbable(heldBubbles, firstGrab);
		}
	}
}