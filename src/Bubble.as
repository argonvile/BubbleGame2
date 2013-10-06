package  
{
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.FlxColor;
	import flash.display.BitmapData;

	public class Bubble extends FlxSprite
	{
		public var bubbleColor:int;
		public var lifespan:Number = -1;
		public var connectors:Array = new Array();
		/**
		 * state
		 * 0 = normal
		 * 100 = grabbing
		 * 200 = throwing
		 * 300 = popping
		 */
		public var state:int = 0;
		private var playerSprite:FlxSprite;
		private var stateTime:Number = 0;
		private const GRAB_DURATION:Number = 0.22;
		private const THROW_DURATION:Number = 0.11;
		private var regularGraphic:BitmapData;
		private var popGraphic:BitmapData;
		
		public function Bubble(x:Number,y:Number,bubbleColor:int) 
		{
			super(x, y);
			
			this.bubbleColor = bubbleColor;
			
			var key:String = "Microbe0 " + bubbleColor.toString(16);
			if (BitmapDataCache.getBitmap(key) == null) {
				var newData:BitmapData = FlxG.createBitmap(17, 17, 0x00000000, true);
				newData.draw(FlxG.addBitmap(Embed.Microbe0), new Matrix(17 / 50, 0, 0, 17 / 50, 0, 0));
				newData.draw(FlxG.addBitmap(Embed.Eyes0));
				shiftHueBitmapData(newData, bubbleColor);
				BitmapDataCache.setBitmap(key, newData);
			}
			regularGraphic = BitmapDataCache.getBitmap(key);
			
			var key:String = "popped Microbe0";
			if (BitmapDataCache.getBitmap(key) == null) {
				var newData:BitmapData = FlxG.createBitmap(17, 17, 0x00000000, true);
				newData.draw(regularGraphic);
				whitenBitmapData(newData);
				BitmapDataCache.setBitmap(key, newData);
			}
			popGraphic = BitmapDataCache.getBitmap(key);
			
			width = 17;
			height = 17;
			pixels = regularGraphic;
		}
		
		public static function whitenBitmapData(spritePixels:BitmapData) {
			for (var pixelX:int = 0; pixelX < spritePixels.width; pixelX++) {
				for (var pixelY:int = 0; pixelY < spritePixels.height; pixelY++) {
					var pixelRgb:uint = spritePixels.getPixel32(pixelX, pixelY);
					var pixelHsv:Object = Bubble.RGBtoHSV(pixelRgb);
					pixelHsv.saturation = 0;
					pixelHsv.value = 1 - (1 - pixelHsv.value) / 2;
					pixelRgb = FlxColor.HSVtoRGB(pixelHsv.hue, pixelHsv.saturation, pixelHsv.value, FlxColor.getAlpha(pixelRgb));
					spritePixels.setPixel32(pixelX, pixelY, pixelRgb);
				}
			}
		}
		
		public static function shiftHueBitmapData(spritePixels:BitmapData, color:uint):void {
			var targetHsv:Object = FlxColor.RGBtoHSV(color);
			for (var pixelX:int = 0; pixelX < spritePixels.width; pixelX++) {
				for (var pixelY:int = 0; pixelY < spritePixels.height; pixelY++) {
					var pixelRgb:uint = spritePixels.getPixel32(pixelX, pixelY);
					var pixelHsv:Object = Bubble.RGBtoHSV(pixelRgb);
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

		override public function update():void {
			super.update();
			stateTime += FlxG.elapsed;
			if (state == 100) {
				var statePct:Number = Math.min(1, Math.pow(stateTime / GRAB_DURATION, 2.5));
				offset.x = statePct * ((x + width / 2) - (playerSprite.x + playerSprite.width / 2));
				offset.y = statePct * ((y + height / 2) - (playerSprite.y + playerSprite.height / 2));
			}
			if (state == 200) {
				var statePct:Number = Math.min(1, Math.pow(stateTime / THROW_DURATION, 1.5));
				offset.x = (1 - statePct) * ((x + width / 2) - (playerSprite.x + playerSprite.width / 2));
				offset.y = (1 - statePct) * ((y + height / 2) - (playerSprite.y + playerSprite.height / 2));
				if (statePct >= 1.0) {
					state = 0;
				}
			}
			if (isAnchor()) {
				alpha = 0.6;
			} else {
				alpha = 1.0;
			}
			if(lifespan <= 0) {
				return;
			}
			if(stateTime >= lifespan) {
				kill();
			}
			var popAnimState:int = (stateTime * 8) / lifespan;
			if (popAnimState == 0 || popAnimState == 2) {
				pixels = popGraphic;
			} else {
				pixels = regularGraphic;
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
		
		public function wasGrabbed(playerSprite:FlxSprite):void {
			state = 100;
			stateTime = 0;
			this.playerSprite = playerSprite;
		}
		
		public function wasThrown(playerSprite:FlxSprite):void {
			state = 200;
			stateTime = 0;
			this.playerSprite = playerSprite;
			offset.x = (x + width / 2) - (playerSprite.x + playerSprite.width / 2);
			offset.y = (y + height / 2) - (playerSprite.y + playerSprite.height / 2);
		}
		
		public function wasPopped(lifespan:Number):void {
			this.lifespan = lifespan;
			state = 300;
			stateTime = 0;
			for (var i:int = 0; i < connectors.length; i++) {
				if (connectors[i] != null) {
					connectors[i].wasPopped(lifespan);
				}
			}
		}
	}
}