package levels 
{
	import org.flixel.*;

	public class Relentless extends LevelDetails
	{
		public static const name:String = "Relentless";
		public static const scenarioBpms:Array = [50, 90, 126, 190, 252];
		private var period:Number = 5.0;
		
		public function Relentless(scenario:int)
		{
			bubbleColors = [0xffffffff, 0xffff7400, 0xff009999, 0xff1729b0, 0xff4dde00];
			if (scenario == 0) {
				bubbleColors = bubbleColors.slice(0, 4);
				maxBubbleRate = 65;
				columnCount = 9;
				period = 1.25;
				setSpeed(2);
			} else if (scenario == 1) {
				maxBubbleRate = 99;
				columnCount = 11;
				period = 2.5;
				setSpeed(2);
			} else if (scenario == 2) {
				maxBubbleRate = 139;
				columnCount = 9;
				period = 5.0;
				setSpeed(2);
			} else if (scenario == 3) {
				maxBubbleRate = 209;
				columnCount = 13;
				period = 10.0;
				setSpeed(3);
			} else if (scenario == 4) {
				maxBubbleRate = 280;
				columnCount = 11;
				period = 20.0;
				setSpeed(3);
			}
		}
		
		override public function prepareLevel():void {
			super.prepareLevel();
			playState.gameState = 100;
		}
		
		override public function update(elapsed:Number):void {
			bubbleRate = (-Math.sin((elapsed / period) * Math.PI)+1) * maxBubbleRate
			if (playState.gameState == 110 || playState.gameState == 120 || playState.gameState == 130) {
				playState.rowScrollTimer += rowScrollPixels() * playState.speedupFactor;
				playState.scrollBg();
				if (playState.rowScrollTimer > minScrollPixels) {
					var scrollAmount:Number = Math.floor(playState.rowScrollTimer / minScrollPixels) * minScrollPixels;
					// scroll all the bubbles down a little
					playState.scrollBubblesFunction.call(this, scrollAmount);
					playState.rowScrollTimer -= scrollAmount;
				}
			}
		}
	}
}