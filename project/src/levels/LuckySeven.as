package levels 
{
	import org.flixel.*;
	
	public class LuckySeven extends LevelDetails
	{
		public static const name:String = "Lucky Seven";
		public static const scenarioBpms:Array = [41.9, 77.0, 177.8, 259.1, 319.2 - 25];
		private var changedBubbles:Array = new Array();
		private var targetColors:Object = new Object();
		private var generatedBubbleCount:int = 0;
		private var popCounts:Object = new Object();
		
		public function LuckySeven(scenario:int) 
		{
			setSpeed(scenario + 1);
			minNewRowLocation = -PlayState.bubbleHeight * 8.5;
			bubbleColors = [0xffff0000, 0xffff8800, 0xffffff00, 0xff00cc00, 0xff1240ab, 0xff7109aa];
			avgChainLength = 6;
			
			if (scenario == 0) {
				maxBubbleRate = 300;
				columnCount = 10;
				minScrollPixels = PlayState.bubbleHeight * 1;
			} else if (scenario == 1) {
				maxBubbleRate = 500;
				columnCount = 9;
				minScrollPixels = PlayState.bubbleHeight * 1;
			} else if (scenario == 2) {
				maxBubbleRate = 800;
				columnCount = 8;
				minScrollPixels = PlayState.bubbleHeight * 2;
			} else if (scenario == 3) {
				maxBubbleRate = 1300;
				columnCount = 7;
				minScrollPixels = PlayState.bubbleHeight * 2;
			} else if (scenario == 4) {
				maxBubbleRate = 2100;
				columnCount = 9;
				minScrollPixels = PlayState.bubbleHeight * 3;
			}
			
			for (var i:int = 0; i < bubbleColors.length - 1; i++) {
				targetColors[bubbleColors[i]] = bubbleColors[i + 1];
			}
			targetColors[bubbleColors[bubbleColors.length - 1]] = bubbleColors[0];
		}
		
		override public function prepareLevel():void {
			generatedBubbleCount = 0;
			super.prepareLevel();
		}
		
		override public function nextBubbleColor():int {
			if (generatedBubbleCount < columnCount * 4) {
				return bubbleColors[(generatedBubbleCount++ % columnCount) % bubbleColors.length];
			} else {
				return super.nextBubbleColor();
			}
		}

		override public function update(elapsed:Number):void {
			super.update(elapsed);
			if (playState.gameState == 140) {
				// changing colors...
				var positionMap:Object;
				for (var i:int = 0; i < changedBubbles.length; i++) {
					if (changedBubbles[i] == null) {
						continue;
					}
					if ((i + 1) * dropPerBubbleDelay + dropDelay < playState.stateTime) {
						var poppedBubble:DefaultBubble = changedBubbles[i];
						poppedBubble.setBubbleColor(targetColors[poppedBubble.bubbleColor]);
						poppedBubble.killConnectors();
						if (positionMap == null) {
							positionMap = playState.newPositionMap();
						}
						playState.maybeAddConnectorSingle(positionMap, poppedBubble);
						Embed.playPopSound(playState.comboSfxCount);
						playState.comboSfxCount += 0.3;
						changedBubbles[i] = null;
					}
				}
				if (playState.stateTime >= playState.stateDuration) {
					var otherBubbles:Array = playState.heldBubbles.members.concat(playState.suspendedBubbles);
					for each (var heldBubble:DefaultBubble in otherBubbles) {
						if (heldBubble != null && heldBubble.alive) {
							if (popCounts[heldBubble.bubbleColor] >= 7) {
								heldBubble.setBubbleColor(targetColors[heldBubble.bubbleColor]);
							}
						}
					}
					changedBubbles.length = 0;
					// if the player triggered a drop event, transition to state 120...
					playState.checkForDetachedBubbles();
					if (playState.gameState == 140) {
						if (playState.suspendedBubbles.length > 0) {
							// if the player has suspended bubbles, transition to the "paused state"
							playState.changeState(130, throwDuration);
						} else {
							// otherwise, transition to state 100
							playState.changeState(100);
						}
					}
				}
			}
		}
		
		override public function bubblesFinishedPopping(bubbles:Array):void {
			popCounts = new Object();
			for each (var bubble:DefaultBubble in bubbles) {
				if (popCounts[bubble.bubbleColor] == null) {
					popCounts[bubble.bubbleColor] = 0;
				}
				popCounts[bubble.bubbleColor]++;
			}
			var colorsToTarget:Array = new Array();
			for each (var bubble:DefaultBubble in playState.bubbles.members) {
				if (bubble != null && bubble.alive && bubble.visible && !bubble.isAnchor()) {
					if (popCounts[bubble.bubbleColor] >= 7) {
						changedBubbles.push(bubble);
					}
				}
			}
			if (changedBubbles.length > 0) {
				changedBubbles.sort(playState.orderByPosition);
				playState.changeState(140, dropDelay + dropPerBubbleDelay * changedBubbles.length);
			}
		}
	}
}