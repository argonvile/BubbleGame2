package levels 
{
	import org.flixel.*;

	public class Relentless extends LevelDetails
	{
		public static const name:String = "Relentless";
		public static const scenarioBpms:Array = [56.6, 90.8, 95.7, 124.5, 136.9];
		private var pauseSpeed:Number = 0;
		
		public function Relentless(scenario:int)
		{
			super(scenario);
			bubbleColors = [0xffffffff, 0xffff7400, 0xff009999, 0xff1729b0, 0xff4dde00];
			if (scenario == 0) {
				bubbleColors = bubbleColors.slice(0, 4);
				maxBubbleRate = 124;
				columnCount = 9;
				pauseSpeed = 1.0;
				setSpeed(3);
			} else if (scenario == 1) {
				maxBubbleRate = 168;
				columnCount = 11;
				pauseSpeed = 0.72;
				setSpeed(0);
			} else if (scenario == 2) {
				maxBubbleRate = 240;
				columnCount = 9;
				pauseSpeed = 0.5;
				setSpeed(0);
			} else if (scenario == 3) {
				maxBubbleRate = 180;
				columnCount = 13;
				pauseSpeed = 1.0;
				setSpeed(-1);
			} else if (scenario == 4) {
				maxBubbleRate = 210;
				columnCount = 11;
				pauseSpeed = 0.85;
				setSpeed(-1);
			}
		}
		
		override public function prepareLevel():void {
			super.prepareLevel();
			playState.gameState = 100;
		}
		
		override public function update(elapsed:Number):void {
			super.update(elapsed);
			if (playState.gameState == 110 || playState.gameState == 120 || playState.gameState == 130) {
				playState.rowScrollTimer += rowScrollPixels() * playState.speedupFactor * pauseSpeed;
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