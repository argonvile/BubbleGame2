package levels.cosmetic 
{
	import org.flixel.plugin.photonstorm.FlxColor;
	import flash.display.BitmapData;
	
	public class VividConnector extends DefaultConnector
	{
		private var bubbleGraphics:Array = new Array();
		private var vividBubble0:VividBubble;
		
		override public function init(bubble0:Bubble, bubble1:Bubble, graphic:Class):void {
			super.init(bubble0, bubble1, graphic);
			vividBubble0 = bubble0 as VividBubble;
			for (var i:int = 0; i < VividController.COLOR_COUNT; i++) {
				var shiftedRgb:uint = FlxColor.HSVtoRGB(i * (360 / VividController.COLOR_COUNT), vividBubble0.vividController.saturation, vividBubble0.vividController.value);
				bubbleGraphics[i] = DefaultConnector.loadConnectorGraphic(shiftedRgb, graphic);
			}
		}
		
		override public function update():void {
			super.update();
			if (!isPopGraphic()) {
				regularGraphic = bubbleGraphics[Math.floor(vividBubble0.hueIndex + vividBubble0.vividController.vividFactor) % VividController.COLOR_COUNT];
				if (_pixels != regularGraphic) {
					_pixels = regularGraphic;
					dirty = true;
				}
			}
		}
	}
}