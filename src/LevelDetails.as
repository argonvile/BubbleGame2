package  
{
	import flash.utils.getTimer;
	import org.flixel.*;

	public class LevelDetails 
	{
		public var popDelay:Number = 0.4;
		public var popPerBubbleDelay:Number = 0.1;
		public var dropDelay:Number = 0;
		public var dropPerBubbleDelay:Number = 0.03;
		public var grabDuration:Number = 0.22;
		public var throwDuration:Number = 0.11;
		public var columnCount:Number = 8;
		protected var bubbleColors:Array = [0xffff0000, 0xffffff00, 0xff00ff00, 0xff0080ff, 0xff8000ff];
		public var levelDuration:Number = 120; // 2 minutes
		public var minScrollPixels:Number = 1;
		public var minNewRowLocation:Number = -PlayState.bubbleHeight * 2.5;
		public var quickScrollPixels:Number = PlayState.bubbleHeight;
		protected var initialRowCount:Number = 6;
		protected var initialScrollPixelCount:Number = 0;
		
		protected var initialBubbleRatePct:Number = 0.1; 
		protected var initialBubbleRateDuration:Number = 0; // warmup period for certain unusual levels
		protected var maxBubbleRate:Number = 300;
		
		protected var bubbleRate:Number = 300;
		protected var playState:PlayState;
		
		public function LevelDetails(scenario:int = 2) 
		{
			setSpeed(scenario < 2?scenario:scenario - 1);
		}
		
		public function prepareLevel():void {
			playState.newRowLocation = initialRowCount * PlayState.bubbleHeight;
			
			var removedNullBubbles:Boolean = false;
			var newPoppableBubbles:Array = new Array();
			while (playState.newRowLocation > minNewRowLocation) {
				for (var i:int = 0; i < columnCount; i++) {
					var x:Number = playState.leftEdge + i * PlayState.columnWidth;
					var y:Number = (i % 2 == 0)?playState.newRowLocation:playState.newRowLocation - PlayState.bubbleHeight * .5;
					var nextBubble:Bubble = nextBubble(x, y);
					if (nextBubble is DefaultBubble && !nextBubble.isAnchor()) {
						newPoppableBubbles.push(nextBubble);
					}
				}
				playState.newRowLocation -= PlayState.bubbleHeight;
			}
			if (removedNullBubbles && (playState.gameState == 100 || playState.gameState == 130)) {
				playState.checkForDetachedBubbles();
			}			
			playState.maybeAddConnectors(newPoppableBubbles);
			for (var pixelsScrolled:Number = 0; pixelsScrolled < initialScrollPixelCount; pixelsScrolled+= minScrollPixels) {
				playState.scrollBubblesFunction.call(playState, minScrollPixels);
			}
			var positionMap:Object = playState.newPositionMap();
			for each (var bubble:Bubble in playState.bubbles.members) {
				if (bubble != null && bubble.alive) {
					bubble.resetQuickApproach();
				}
			}
			for each (var bubble:Bubble in playState.bubbles.members) {
				if (bubble != null && bubble.alive) {
					playState.maybeAddConnectorSingle(positionMap, bubble);
				}
			}
		}
		
		public function init(playState:PlayState):void {
			this.playState = playState;
		}
		
		/**
		 * (0-4) == (slow - fastest), (7) == lightning
		 */
		protected function setSpeed(speed:Number):void {
			var myFactor:Number = Math.pow(1.5, 2 - speed);
			popDelay *= myFactor;
			popPerBubbleDelay *= myFactor;
			dropDelay *= myFactor;
			dropPerBubbleDelay *= myFactor;
			grabDuration *= Math.sqrt(myFactor);
			throwDuration *= Math.sqrt(myFactor);
		}
		
		public function nextBubbleColor():int {
			var randomInt:int = Math.random() * bubbleColors.length;
			return bubbleColors[randomInt];
		}
		
		public function nextBubble(x:Number, y:Number):Bubble {
			var bubbleColor:int = nextBubbleColor();
			if (bubbleColor == 0) {
				var nextNullBubble:NullBubble = playState.addBubble(NullBubble) as NullBubble;
				nextNullBubble.init(this, x, y);
				if (!nextNullBubble.isAnchor()) {
					nextNullBubble.kill();
				}
				return nextNullBubble;
			} else {
				var nextDefaultBubble:DefaultBubble = playState.addBubble(DefaultBubble) as DefaultBubble;
				nextDefaultBubble.init(this, x, y);
				nextDefaultBubble.setBubbleColor(bubbleColor);
				return nextDefaultBubble;
			}
		}
		
		public function update(elapsed:Number):void {
			if (elapsed < initialBubbleRateDuration) {
				bubbleRate = maxBubbleRate * initialBubbleRatePct;
			} else if (elapsed >= (0.5 * levelDuration)) {
				bubbleRate = maxBubbleRate;
			} else {
				var pct:Number = (elapsed - initialBubbleRateDuration) / ((0.5 * levelDuration) - initialBubbleRateDuration);
				bubbleRate = (pct * 0.5 + 0.5) * maxBubbleRate;
			}
		}
		
		public function rowScrollPixels():Number {
			return FlxG.elapsed * ((bubbleRate * PlayState.bubbleHeight / columnCount) / 60);
		}
		
		public function bubbleVanished(bubble:Bubble):void {
		}
		
		public function bubblesFinishedPopping(bubbles:Array):void {
		}
	}
}