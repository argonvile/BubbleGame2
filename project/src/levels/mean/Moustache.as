package levels.mean 
{
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.FlxColor;

	public class Moustache extends LevelDetails
	{
		public static const name:String = "Moustache";
		public static const scenarioBpms:Array = [48.5, 84.1, 116, 156.9, 229.2];
		private var moustachePct:Number = 0.33;
		private var moustacheColorCount:int = 99;
		
		public function Moustache(scenario:int) 
		{
			super(scenario);
			bubbleColors = new Array();
			bubbleColors[0] = 0xff999999;
			for (var i:int = 1; i < 4; i++) {
				var hue:Number = (i * 72 + scenario * 72)%360;
				var saturation:Number = 0.5;
				var value:Number = 0.95;
				bubbleColors[i] = FlxColor.HSVtoRGB(hue, saturation, value);
			}
			columnCount = 10;
			if (scenario == 0) {
				moustachePct = 0.4;
				maxBubbleRate = 181;
				bubbleColors = bubbleColors.slice(0, 3);
				moustacheColorCount = 2;
			} else if (scenario == 1) {
				moustachePct = 0.20;
				maxBubbleRate = 244;
			} else if (scenario == 2) {
				moustachePct = 0.33;
				maxBubbleRate = 393;
				moustacheColorCount = 2;
			} else if (scenario == 3) {
				moustachePct = 0.25;
				maxBubbleRate = 333;
				columnCount = 8;
			} else if (scenario == 4) {
				moustachePct = 0.15;
				maxBubbleRate = 650;
				columnCount = 12;
			}
		}
		
		public override function nextBubble(x:Number, y:Number):Bubble {
			var bubbleColorIndex:int = Math.random() * bubbleColors.length;
			var bubbleColor:uint = bubbleColors[bubbleColorIndex];
			if (Math.random() < moustachePct && bubbleColorIndex < moustacheColorCount) {
				var moustacheBubble:MoustacheBubble = playState.addBubble(MoustacheBubble) as MoustacheBubble;
				moustacheBubble.init(this, x, y);
				moustacheBubble.setBubbleColor(bubbleColor);
				return moustacheBubble;
			} else {
				var defaultBubble:DefaultBubble = playState.addBubble(DefaultBubble) as DefaultBubble;
				defaultBubble.init(this, x, y);
				defaultBubble.setBubbleColor(bubbleColor);
				return defaultBubble;
			}
		}
		
		public override function newPopCounter(playState:PlayState):PopCounter {
			return new MoustachePopCounter(playState);
		}
		
		public override function bubbleVanished(bubble:Bubble):void {
			if (bubble is MoustacheBubble) {
				var moustacheBubble:MoustacheBubble = bubble as MoustacheBubble;
				var defaultBubble:DefaultBubble = playState.addBubble(DefaultBubble) as DefaultBubble;
				defaultBubble.init(this, bubble.x, bubble.y);
				defaultBubble.setBubbleColor(moustacheBubble.bubbleColor);
				playState.maybeAddConnectors(new Array(defaultBubble));
			}
		}
		
		override public function maybeAddConnector(bubble:Bubble, bubbleS:Bubble, graphic:Class):void {
			if (Math.random() > 0.66) {
				super.maybeAddConnector(bubble, bubbleS, graphic);
			}
		}		
	}
}