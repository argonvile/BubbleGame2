package  
{
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
		
		protected var maxBubbleRate:Number = 300;
		protected var bubbleRate:Number = 300;
		protected var playState:PlayState;
		
		public function LevelDetails(scenario:int = 2) 
		{
			setSpeed(scenario < 2?scenario:scenario - 1);
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
			var nextBubble:Bubble;
			if (bubbleColor == 0) {
				nextBubble = new NullBubble(this, x, y);
			} else {
				nextBubble = new DefaultBubble(this, x, y, bubbleColor);
			}
			return nextBubble;
		}
		
		public function update(elapsed:Number):void {
			if (elapsed < 5) {
				bubbleRate = maxBubbleRate * 0.25;
			} else if (elapsed < 10) {
				bubbleRate = maxBubbleRate * 0.5;
			} else if (elapsed < 30) {
				bubbleRate = maxBubbleRate * 0.75;
			} else if (elapsed < 60) {
				bubbleRate = maxBubbleRate* 0.875;
			} else {
				bubbleRate = maxBubbleRate;
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