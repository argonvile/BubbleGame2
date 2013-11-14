package  
{
	import org.flixel.plugin.photonstorm.FlxColor;
	import flash.display.BitmapData;
	
	public class BubbleColorUtils 
	{
		public static function shiftHueBitmapData(spritePixels:BitmapData, color:uint):void {
			var targetHsv:Object = FlxColor.RGBtoHSV(color);
			var saturationAdjustment:Number = targetHsv.saturation - 1.0;
			var valueAdjustment:Number = targetHsv.value - 0.5;
			for (var pixelX:int = 0; pixelX < spritePixels.width; pixelX++) {
				for (var pixelY:int = 0; pixelY < spritePixels.height; pixelY++) {
					var pixelRgb:uint = spritePixels.getPixel32(pixelX, pixelY);
					var pixelHsv:Object = BubbleColorUtils.RGBtoHSV(pixelRgb);
					pixelHsv.hue = (targetHsv.hue + pixelHsv.hue) % 360;
					pixelHsv.saturation = Math.min(1, Math.max(0, pixelHsv.saturation + saturationAdjustment));
					pixelHsv.value = Math.min(1, Math.max(0, pixelHsv.value + valueAdjustment));
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
	}
}