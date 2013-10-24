package levels 
{
	import org.flixel.*;
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.utils.getQualifiedClassName;
	import flash.geom.Matrix;

	public class DarkConnector extends DefaultConnector
	{
		private var darkGraphics:Array = new Array();
		public var dark:Number = 0; // 0 == not dark; 1 == fully dark
		
		override public function init(bubble0:Bubble, bubble1:Bubble, graphic:Class):void {
			super.init(bubble0, bubble1, graphic);
			
			var key:String;
			var colorTransform:ColorTransform = new ColorTransform();
			var bubbleColor:int = (bubble0 as DefaultBubble).bubbleColor;
			for (var i:int = 0; i <= 3; i++) {
				key = "connector " + getQualifiedClassName(graphic) + " " + bubbleColor.toString(16) + " dark" + i;
				
				colorTransform.redMultiplier = colorTransform.greenMultiplier = colorTransform.blueMultiplier = 1.0 - (i+1) / 4;
				colorTransform.redOffset = 32 * ((i+1)/4);
				colorTransform.greenOffset = colorTransform.blueOffset = 3 * ((i+1)/4);
				if (BitmapDataCache.getBitmap(key) == null) {
					var colorData:BitmapData = FlxG.createBitmap(85, 17, 0x00000000, true);
					var matrix:Matrix = new Matrix();
					matrix.scale(17 / 50, 17 / 50);
					colorData.draw(FlxG.addBitmap(graphic), matrix);
					DefaultBubble.shiftHueBitmapData(colorData, bubbleColor);
					var newData:BitmapData = FlxG.createBitmap(85, 17, 0x00000000, true);
					newData.draw(colorData, null, colorTransform);
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