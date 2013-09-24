package  
{
	import flash.geom.Rectangle;
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.FlxColor;

	public class Bubble extends FlxSprite
	{
		public var bubbleColor:int;
		public var lifespan:Number;
		
		public function Bubble(x:Number,y:Number,bubbleColor:int) 
		{
			super(x, y);
			loadGraphic(Embed.Microbe0, false, false, 50, 50, true);
			width = 17;
			height = 17;
			scale.x = 17 / 50;
			scale.y = 17 / 50;
			setOriginToCorner();
			this.bubbleColor = bubbleColor;
			var targetHsv:Object = FlxColor.RGBtoHSV(bubbleColor);
			for (var pixelX:int = 0; pixelX < _pixels.width; pixelX++) {
				for (var pixelY:int = 0; pixelY < _pixels.height; pixelY++) {
					var pixelRgb:uint = _pixels.getPixel32(pixelX, pixelY);
					var pixelHsv:Object = RGBtoHSV(pixelRgb);
					pixelHsv.hue = (targetHsv.hue + pixelHsv.hue) % 360;
					pixelRgb = FlxColor.HSVtoRGB(pixelHsv.hue, pixelHsv.saturation, pixelHsv.value, FlxColor.getAlpha(pixelRgb));
					_pixels.setPixel32(pixelX, pixelY, pixelRgb);
				}
			}
		}

		private static function RGBtoHSV(color:uint):Object {
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

		override public function update():void {
			super.update();
			if (isAnchor()) {
				alpha = 0.6;
			} else {
				alpha = 1.0;
			}
			if(lifespan <= 0) {
				return;
			}
			lifespan -= FlxG.elapsed;
			if(lifespan <= 0) {
				kill();
			}
		}
		
		public function isAnchor():Boolean {
			return y < 0;
		}
	}
}