package levels.cosmetic 
{
	import org.flixel.*;
	
	public class Vivid extends LevelDetails
	{
		public static const name:String = "Vivid";
		public static const scenarioBpms:Array = [82.3, 112.3, 132.4, 193, 244.9];
		
		private var vividController:VividController = new VividController();
		private var minVividRate:Number;
		private var maxVividRate:Number;
		private var curveDuration:Number;
			
		public function Vivid(scenario:int) 
		{
			super(scenario);
			bubbleColors = [0xffff0000, 0xffccff00, 0xff00ff66, 0xff0066ff, 0xffcc00ff]
			if (scenario == 0) {
				maxBubbleRate = 172;
				columnCount = 9;
				minVividRate = 36;
				maxVividRate = 84;
				curveDuration = 16;
				vividController.saturation = 0.4;
				vividController.value = 0.95;
			} else if (scenario == 1) {
				maxBubbleRate = 352;
				columnCount = 8;
				minVividRate = 24;
				maxVividRate = 48;
				curveDuration = 12;
				vividController.saturation = 1.0;
				vividController.value = 0.9;
			} else if (scenario == 2) {
				maxBubbleRate = 406;
				columnCount = 12;
				minVividRate = 36;
				maxVividRate = 60;
				curveDuration = 16;
				vividController.saturation = 0.4;
				vividController.value = 0.95;
			} else if (scenario == 3) {
				maxBubbleRate = 575;
				columnCount = 9;
				minVividRate = 48;
				maxVividRate = 96;
				curveDuration = 24;
				vividController.saturation = 1.0;
				vividController.value = 0.9;
			} else if (scenario == 4) {
				maxBubbleRate = 818;
				columnCount = 10;
				minVividRate = 24;
				maxVividRate = 60;
				curveDuration = 20;
				vividController.saturation = 1.0;
				vividController.value = 0.85;
			}
		}
		
		override public function nextBubble(x:Number, y:Number):Bubble {
			var bubbleColor:int = nextBubbleColor();
			var nextDefaultBubble:VividBubble = playState.addBubble(VividBubble) as VividBubble;
			nextDefaultBubble.init(this, x, y);
			nextDefaultBubble.initVivid(vividController);
			nextDefaultBubble.setBubbleColor(bubbleColor);
			return nextDefaultBubble;
		}
		
		override public function addConnector(defaultBubble:DefaultBubble, defaultBubbleS:DefaultBubble, graphic:Class):void {
			var connector:VividConnector = playState.connectors.recycle(VividConnector) as VividConnector;
			connector.revive();
			connector.init(defaultBubble, defaultBubbleS, graphic);
			connector.offset.y = defaultBubble.offset.y;
			playState.connectors.add(connector);
			defaultBubble.connectors.push(connector);
			defaultBubbleS.connectors.push(connector);
			connector.update();
		}
		
		override public function update(elapsed:Number):void {
			super.update(elapsed);
			var vividPct:Number = (1 - Math.cos(elapsed * (2 * Math.PI / curveDuration))) / 2;
			vividController.vividFactor += (minVividRate + (maxVividRate - minVividRate) * vividPct) * (FlxG.elapsed / FlxG.timeScale);
		}
	}
}