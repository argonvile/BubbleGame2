package levels 
{
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import org.flixel.*;

	public class DarkBubble extends DefaultBubble
	{
		private var darkGraphics:Array = new Array();
		public var dark:Number = 0; // 0 == not dark; 1 == fully dark

		override public function setBubbleColor(bubbleColor:uint):void {
			super.setBubbleColor(bubbleColor);
			var key:String;
			var colorTransform:ColorTransform = new ColorTransform();
			for (var i:int = 0; i <= 3; i++) {
				key = "Microbe0 " + bubbleColor.toString(16) + " dark" + i;
				
				colorTransform.redMultiplier = colorTransform.greenMultiplier = colorTransform.blueMultiplier = 1.0 - (i+1) / 4;
				colorTransform.redOffset = 32 * ((i+1)/4);
				colorTransform.greenOffset = colorTransform.blueOffset = 3 * ((i+1)/4);
				if (BitmapDataCache.getBitmap(key) == null) {
					var colorData:BitmapData = FlxG.createBitmap(85, 17, 0x00000000, true);
					var matrix:Matrix = new Matrix();
					matrix.scale(17 / 50, 17 / 50);
					colorData.draw(FlxG.addBitmap(Embed.Microbe0), matrix);
					shiftHueBitmapData(colorData, bubbleColor);
					var newData:BitmapData = FlxG.createBitmap(85, 17, 0x00000000, true);
					newData.draw(colorData, null, colorTransform);
					matrix.identity();
					
					var eyeData:BitmapData = FlxG.addBitmap(Embed.Eyes0);
					for (var j:int = 0; j < 5; j++) {
						newData.draw(eyeData, matrix);
						matrix.translate(17, 0);
					}
					BitmapDataCache.setBitmap(key, newData);
				}
				darkGraphics[i] = BitmapDataCache.getBitmap(key);
			}
		}
		
		override public function update():void {
			super.update();
			var targetGraphic:int = Math.round(dark * 4) - 1;
			if (targetGraphic == -1) {
				// un-dark
				if (!isPopGraphic()) {
					loadRegularGraphic();
				}
			} else {
				if (!isPopGraphic()) {
					_pixels = darkGraphics[targetGraphic];
					dirty = true;
				}
			}
		}
	}
}