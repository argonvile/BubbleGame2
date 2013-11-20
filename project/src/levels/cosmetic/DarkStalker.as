package levels.cosmetic 
{
	import org.flixel.*;

	public class DarkStalker extends LevelDetails
	{
		public static const name:String = "Darkstalker";
		public static const scenarioBpms:Array = [44.9, 102.7, 141.7, 205, 285.8];
		// TODO: Bad quotas
		public static const quotaBpms:Array = [77, 159, 193, 273, 413];
		private var fullDarkColumnCount:int;
		private var halfDarkColumnCount:int;
		private var darkOnRate:Number;
		private var darkOffRate:Number;
		private var halfDarkAmount:Number = 0.75;
		
		public function DarkStalker(scenario:int) {
			super(scenario);
			if (scenario == 0) {
				fullDarkColumnCount = 1;
				halfDarkColumnCount = 3;
				darkOnRate = 4;
				darkOffRate = 4;
				columnCount = 8;
				maxBubbleRate = 93;
			} else if (scenario == 1) {
				fullDarkColumnCount = 3;
				halfDarkColumnCount = 3;
				darkOnRate = 2;
				darkOffRate = 2;
				columnCount = 10;
				maxBubbleRate = 317;
			} else if (scenario == 2) {
				fullDarkColumnCount = 3;
				halfDarkColumnCount = 5;
				darkOnRate = 4;
				darkOffRate = 4;
				columnCount = 13;
				maxBubbleRate = 561;
			} else if (scenario == 3) {
				fullDarkColumnCount = 3;
				halfDarkColumnCount = 7;
				darkOnRate = 6;
				darkOffRate = 1.5;
				columnCount = 9;
				maxBubbleRate = 732;
			} else if (scenario == 4) {
				fullDarkColumnCount = 5;
				halfDarkColumnCount = 9;
				darkOnRate = 4;
				darkOffRate = 2;
				columnCount = 13;
				maxBubbleRate = 1139;
			}
		}
		
		override public function addConnector(defaultBubble:Bubble, defaultBubbleS:Bubble, graphic:Class):void {
			var connector:DarkConnector = playState.connectors.recycle(DarkConnector) as DarkConnector;
			connector.revive();
			connector.init(defaultBubble, defaultBubbleS, graphic);
			connector.offset.y = defaultBubble.offset.y;
			playState.connectors.add(connector);
			defaultBubble.connectors.push(connector);
			defaultBubbleS.connectors.push(connector);
			var darkBubble:DarkBubble = defaultBubble as DarkBubble;
			var darkBubbleS:DarkBubble = defaultBubbleS as DarkBubble;
			connector.dark = (darkBubble.dark + darkBubbleS.dark) / 2;
			if (Math.abs(connector.x - playState.playerSprite.x) < PlayState.columnWidth * (fullDarkColumnCount + 1) / 2) {
				connector.dark = 1.0;
			} else if (Math.abs(connector.x - playState.playerSprite.x) < PlayState.columnWidth * (halfDarkColumnCount + 1) / 2) {
				connector.dark = halfDarkAmount;
			}
			connector.update();
		}
		
		override public function nextBubble(x:Number, y:Number):Bubble {
			var bubbleColor:int = nextBubbleColor();
			var darkBubble:DarkBubble = playState.addBubble(DarkBubble) as DarkBubble;
			darkBubble.init(this, x, y);
			darkBubble.setBubbleColor(bubbleColor);
			if (Math.abs(darkBubble.x - playState.playerSprite.x) < PlayState.columnWidth * fullDarkColumnCount / 2) {
				darkBubble.dark = 1.0;
			} else if (Math.abs(darkBubble.x - playState.playerSprite.x) < PlayState.columnWidth * halfDarkColumnCount / 2) {
				darkBubble.dark = halfDarkAmount;
			}
			return darkBubble;
		}
		
		override public function update(elapsed:Number):void {
			super.update(elapsed);
			for each (var bubble:Bubble in playState.bubbles.members) {
				if (bubble != null && bubble.alive && bubble is DarkBubble) {
					var darkBubble:DarkBubble = bubble as DarkBubble;
					if (Math.abs(darkBubble.x - playState.playerSprite.x) < PlayState.columnWidth * fullDarkColumnCount / 2) {
						// should go dark
						darkBubble.dark = Math.min(1.0, darkBubble.dark + FlxG.elapsed * darkOnRate);
					} else if (Math.abs(darkBubble.x - playState.playerSprite.x) < PlayState.columnWidth * halfDarkColumnCount / 2) {
						// should go half dark
						if (darkBubble.dark > halfDarkAmount) {
							darkBubble.dark = Math.max(halfDarkAmount, darkBubble.dark - FlxG.elapsed * darkOffRate);
						} else if (darkBubble.dark < halfDarkAmount) {
							darkBubble.dark = Math.min(halfDarkAmount, darkBubble.dark + FlxG.elapsed * darkOnRate);
						}
					} else {
						darkBubble.dark = Math.max(0, darkBubble.dark - FlxG.elapsed * darkOffRate);
					}
				}
			}
			for each (var connector:Connector in playState.connectors.members) {
				if (connector != null && connector.alive && connector is DarkConnector) {
					var darkConnector:DarkConnector = connector as DarkConnector;
					if (Math.abs(darkConnector.x - playState.playerSprite.x) < PlayState.columnWidth * (fullDarkColumnCount + 1) / 2) {
						darkConnector.dark = Math.min(1.0, darkConnector.dark + FlxG.elapsed * darkOnRate);
					} else if (Math.abs(darkConnector.x - playState.playerSprite.x) < PlayState.columnWidth * (halfDarkColumnCount + 1) / 2) {
						// should go half dark
						if (darkConnector.dark > halfDarkAmount) {
							darkConnector.dark = Math.max(halfDarkAmount, darkConnector.dark - FlxG.elapsed * darkOffRate);
						} else if (darkBubble.dark < halfDarkAmount) {
							darkConnector.dark = Math.min(halfDarkAmount, darkConnector.dark + FlxG.elapsed * darkOnRate);
						}
					} else {
						darkConnector.dark = Math.max(0, darkConnector.dark - FlxG.elapsed * darkOffRate);
					}
				}
			}
		}
	}
}