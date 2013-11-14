package levels.cosmetic 
{
	import org.flixel.plugin.photonstorm.FlxColor;
	import flash.display.BitmapData;
	
	public class VividBubble extends DefaultBubble
	{
		public var hueIndex:int;
		private var bubbleGraphics:Array;
		public var vividController:VividController;
			
		public function VividBubble() {
			super();
		}
		
		override public function init(levelDetails:LevelDetails, x:Number, y:Number):void {
			super.init(levelDetails, x, y);
		}
		
		public function initVivid(vividController:VividController):void {
			this.vividController = vividController;
			if (bubbleGraphics == null) {
				bubbleGraphics = new Array();
				for (var i:int = 0; i < VividController.COLOR_COUNT; i++) {
					var shiftedRgb:uint = FlxColor.HSVtoRGB(i * (360 / VividController.COLOR_COUNT), vividController.saturation, vividController.value);
					bubbleGraphics[i] = DefaultBubble.loadBubbleGraphic(shiftedRgb);
				}
			}
		}
		
		override public function setBubbleColor(bubbleColor:uint):void {
			super.setBubbleColor(bubbleColor);
			var hue:int = BubbleColorUtils.RGBtoHSV(bubbleColor).hue;
			hueIndex = hue / (360 / VividController.COLOR_COUNT);
		}
		
		override public function update():void {
			super.update();
			if (!isPopGraphic()) {
				regularGraphic = bubbleGraphics[Math.floor(hueIndex + vividController.vividFactor) % VividController.COLOR_COUNT];
				if (_pixels != regularGraphic) {
					_pixels = regularGraphic;
					dirty = true;
				}
			}
		}	
	}
}