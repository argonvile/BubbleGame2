package  
{
	public class ThreeColorBlitz extends LevelDetails
	{
		private var maxBubbleRate:Number = 300;
		
		public function ThreeColorBlitz() 
		{
			var whichScenario = 4;
			if (whichScenario == 0) {
				// easy
				setSpeed(0);
				maxBubbleRate = 300;
				columnCount = 10;
				bubbleColors = [0xffb600, 0x1437ad, 0xce0071];
			} else if (whichScenario == 1) {
				// normal 
				setSpeed(1);
				maxBubbleRate = 600;
				columnCount = 8;
				bubbleColors = [0xffb600, 0xff3900, 0xce0071];
			} else if (whichScenario == 2) {
				// hard
				setSpeed(2);
				maxBubbleRate = 1600;
				columnCount = 12;
				bubbleColors = [0xffb600, 0xb1009b, 0x4711ae];
			} else if (whichScenario == 3) {
				// aaron hard
				setSpeed(3);
				maxBubbleRate = 3200;
				columnCount = 16;
				bubbleColors = [0xffb600, 0x3515b0, 0x0c5aa6];
			} else if (whichScenario == 4) {
				// impossible
				setSpeed(4);
				maxBubbleRate = 3200;
				columnCount = 10;
				bubbleColors = [0xffb600, 0x0f4fa8, 0x00b25c];
			}
		}

		public override function update(elapsed:Number):void {
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
	}
}