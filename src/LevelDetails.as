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
		public var columnCount:Number = 16;
		protected var bubbleRate:Number = 300;
		protected var bubbleColors:Array = [0xffff0000, 0xffffff00, 0xff00ff00, 0xff0080ff, 0xff8000ff];
		public var levelDuration:Number = 120; // 2 minutes
		
		public function LevelDetails() 
		{
		}
		
		/**
		 * (0-4) == (slow - fastest), (7) == lightning
		 */
		protected function setSpeed(speed:Number) {
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
		
		public function update(elapsed:Number):void {
		}
		
		public function rowScrollPixels():Number {
			return FlxG.elapsed * ((bubbleRate * PlayState.bubbleHeight / columnCount) / 60);
		}
	}
}