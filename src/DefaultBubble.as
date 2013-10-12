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
		public var connectors:Array = new Array();
		private var regularGraphic:BitmapData;
		private var popGraphic:BitmapData;
		private var levelDetails:LevelDetails;
		private const QUICK_APPROACH_DURATION:Number = 0.3;
		
		public function DefaultBubble(levelDetails:LevelDetails,x:Number,y:Number,bubbleColor:int) 
		{
			super(x, y);
			this.levelDetails = levelDetails;
			
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

		override public function update():void {
			super.update();
			stateTime += FlxG.elapsed;
			if (state == 100) {
				var statePct:Number = Math.min(1, Math.pow(stateTime / levelDetails.grabDuration, 2.5));
				offset.x = statePct * ((x + width / 2) - (playerSprite.x + playerSprite.width / 2));
				offset.y = statePct * ((y + height / 2) - (playerSprite.y + playerSprite.height / 2));
			}
			if (state == 200) {
				var statePct:Number = Math.min(1, Math.pow(stateTime / levelDetails.throwDuration, 1.5));
				offset.x = (1 - statePct) * ((x + width / 2) - (playerSprite.x + playerSprite.width / 2));
				offset.y = (1 - statePct) * ((y + height / 2) - (playerSprite.y + playerSprite.height / 2));
				if (statePct >= 1.0) {
					state = 0;
				}
			}
			if (state == 250) {
				var statePct:Number = Math.pow(1 - Math.min(1, stateTime / levelDetails.grabDuration), 2.5);
				offset.x = 0;
				offset.y = quickApproachDistance * statePct;
				if (statePct == 0) {
					state = 251;
				}
				updateConnectorOffsets();
			} else if (state == 251) {
				state = 0;
			}
			updateAlpha();
		}
		
		override public function kill():void {
			super.kill();
			killConnectors();
		}
		
		override public function quickApproach(distance:Number):void {
			super.quickApproach(distance);
			updateConnectorOffsets();
		}
		
		private function updateConnectorOffsets():void {
			for each (var connector:Connector in connectors) {
				if (connector != null && connector.alive) {
					connector.offset.y = offset.y;
				}
			}			
		}
		
		public function killConnectors():void {
			for each (var connector:DefaultConnector in connectors) {
				if (connector != null && connector.alive) {
					connector.kill();
					if (connector.defaultBubble0 != this) {
						connector.defaultBubble0.removeConnector(connector);
					}
					if (connector.defaultBubble1 != this) {
						connector.defaultBubble1.removeConnector(connector);
					}
				}
			}
			connectors.length = 0;
		}
		
		public function removeConnector(connector:DefaultConnector):void {
			for (var i:int = 0; i < connectors.length; i++) {
				if (connectors[i] == connector) {
					connectors[i] = null;
				}
			}
		}
	}
}