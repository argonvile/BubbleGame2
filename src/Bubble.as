package  
{
	import flash.geom.Rectangle;
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.FlxColor;
	import flash.display.BitmapData;

	public class Bubble extends FlxSprite
	{
		public var bubbleColor:int;
		public var lifespan:Number;
		public var connectors:Array = new Array();
		
		public function Bubble(x:Number,y:Number,bubbleColor:int) 
		{
			super(x, y);
			loadGraphic(Embed.Microbe0, false, false, 50, 50, true);
			shiftHue(this, bubbleColor);
			width = 17;
			height = 17;
			scale.x = 17 / 50;
			scale.y = 17 / 50;
			setOriginToCorner();
			this.bubbleColor = bubbleColor;
		}
		
		public static function shiftHue(sprite:FlxSprite, color:uint):void {
			var targetHsv:Object = FlxColor.RGBtoHSV(color);
			var spritePixels:BitmapData = sprite.pixels;
			for (var pixelX:int = 0; pixelX < spritePixels.width; pixelX++) {
				for (var pixelY:int = 0; pixelY < spritePixels.height; pixelY++) {
					var pixelRgb:uint = spritePixels.getPixel32(pixelX, pixelY);
					var pixelHsv:Object = Bubble.RGBtoHSV(pixelRgb);
					pixelHsv.hue = (targetHsv.hue + pixelHsv.hue) % 360;
					pixelRgb = FlxColor.HSVtoRGB(pixelHsv.hue, pixelHsv.saturation, pixelHsv.value, FlxColor.getAlpha(pixelRgb));
					spritePixels.setPixel32(pixelX, pixelY, pixelRgb);
				}
			}
			sprite.pixels = spritePixels;
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
		
		override public function kill():void {
			super.kill();
			killConnectors();
		}
		
		public function killConnectors():void {
			for each (var connector:Connector in connectors) {
				if (connector != null && connector.alive) {
					connector.kill();
					if (connector.bubble0 != this) {
						connector.bubble0.removeConnector(connector);
					}
					if (connector.bubble1 != this) {
						connector.bubble1.removeConnector(connector);
					}
				}
			}
			connectors.length = 0;
		}
		
		public function removeConnector(connector:Connector):void {
			for (var i:int = 0; i < connectors.length; i++) {
				if (connectors[i] == connector) {
					connectors[i] = null;
				}
			}
		}
	}
}