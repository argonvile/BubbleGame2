package levels.cosmetic 
{
	import org.flixel.*;
	
	public class BlindSide extends LevelDetails
	{
		private var darkOnRate:Number = 0.25;
		private var darkOffRate:Number = 4;
		private var halfDarkAmount:Number = 0.75;
		private var blindColumnCount:int = 3;
		
		public static const name:String = "BlindSide";
		public static const scenarioBpms:Array = [57.4 + 10, 104.7 + 15, 109.9 + 20, 164, 221.3];
		// TODO: Bad quotas
		public static const quotaBpms:Array = [109, 156, 189, 249, 311];
		
		public function BlindSide(scenario:int) 
		{
			super(scenario);
			bubbleColors = [0xffff00ff, 0xffff5050, 0xffffff00, 0xff00ee00, 0xff3366ff];
			if (scenario == 0) {
				bubbleColors = bubbleColors.splice(1);
				maxBubbleRate = 230;
				columnCount = 7;
				blindColumnCount = 2;
				darkOnRate = 4;
			} else if (scenario == 1) {
				maxBubbleRate = 307;
				columnCount = 9;
				blindColumnCount = 3;
			} else if (scenario == 2) {
				bubbleColors = bubbleColors.splice(1);
				maxBubbleRate = 546;
				columnCount = 9;
				blindColumnCount = 5;
				darkOnRate = 2;
			} else if (scenario == 3) {
				maxBubbleRate = 546;
				columnCount = 13;
				blindColumnCount = 7;
			} else if (scenario == 4) {
				bubbleColors = bubbleColors.splice(1);
				maxBubbleRate = 546;
				columnCount = 13;
				blindColumnCount = 9;
				darkOnRate = 1;
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
			connector.update();
		}
		
		override public function bubbleVanished(bubble:Bubble):void {
			var lowestDarkBubble:DarkBubble;
			for each (var bubble:Bubble in playState.bubbles.members) {
				if (bubble != null && bubble.alive && bubble is DarkBubble) {
					var darkBubble:DarkBubble = bubble as DarkBubble;
					if (darkBubble.y < -PlayState.bubbleHeight) {
						// not visible;
						continue;
					}
					if (darkBubble.dark < 0.125) {
						darkBubble.dark = 0;
					} else if (lowestDarkBubble == null) {
						lowestDarkBubble = darkBubble;
					} else if (Math.round(darkBubble.dark*4) > Math.round(lowestDarkBubble.dark*4)) {
						lowestDarkBubble = darkBubble;
					} else if (Math.round(darkBubble.dark*4) == Math.round(lowestDarkBubble.dark*4)) {
						if (darkBubble.y > lowestDarkBubble.y) {
							lowestDarkBubble = darkBubble;
						} else if (darkBubble.y == lowestDarkBubble.y) {
							if (darkBubble.x > lowestDarkBubble.x) {
								lowestDarkBubble = darkBubble;
							}
						}
					}
				}
			}
			if (lowestDarkBubble != null) {
				lowestDarkBubble.dark = 0;
				for each (var darkConnector:DarkConnector in lowestDarkBubble.connectors) {
					if (darkConnector != null) {
						darkConnector.dark = 0;
					}
				}
			}
		}
		
		override public function nextBubble(x:Number, y:Number):Bubble {
			var bubbleColor:int = nextBubbleColor();
			var darkBubble:DarkBubble = playState.addBubble(DarkBubble) as DarkBubble;
			darkBubble.init(this, x, y);
			darkBubble.setBubbleColor(bubbleColor);
			if (playState.leftEdge + PlayState.columnWidth * (columnCount - blindColumnCount) <= darkBubble.x) {
				darkBubble.dark = 1.0;
			}
			return darkBubble;
		}
		
		override public function update(elapsed:Number):void {
			super.update(elapsed);
			if (playState.gameState == 100) {
				for each (var bubble:Bubble in playState.bubbles.members) {
					if (bubble != null && bubble.alive && bubble is DarkBubble) {
						var darkBubble:DarkBubble = bubble as DarkBubble;
						if (playState.leftEdge + PlayState.columnWidth * (columnCount - blindColumnCount) <= darkBubble.x) {
							// should go dark
							darkBubble.dark = Math.min(1.0, darkBubble.dark + FlxG.elapsed * darkOnRate);
						} else {
							darkBubble.dark = Math.max(0, darkBubble.dark - FlxG.elapsed * darkOffRate);
						}
					}
				}
				for each (var connector:Connector in playState.connectors.members) {
					if (connector != null && connector.alive && connector is DarkConnector) {
						var darkConnector:DarkConnector = connector as DarkConnector;
						if (playState.leftEdge + PlayState.columnWidth * (columnCount - blindColumnCount) <= darkConnector.x) {
							// should go dark
							darkConnector.dark = Math.min(1.0, darkConnector.dark + FlxG.elapsed * darkOnRate);
						} else if (playState.leftEdge + PlayState.columnWidth * (columnCount - blindColumnCount - .5) <= darkConnector.x) {
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

}