package levels
{
	public class ThreeColorBlitz extends LevelDetails
	{
		public function ThreeColorBlitz(scenario:int=2) 
		{
			setSpeed(scenario);
			if (scenario == 0) {
				// easy
				maxBubbleRate = 300;
				columnCount = 10;
				bubbleColors = [0xffb600, 0x1437ad, 0xce0071];
			} else if (scenario == 1) {
				// normal 
				maxBubbleRate = 600;
				columnCount = 8;
				bubbleColors = [0xffb600, 0xff3900, 0xce0071];
			} else if (scenario == 2) {
				// hard
				maxBubbleRate = 1600;
				columnCount = 12;
				bubbleColors = [0xffb600, 0xb1009b, 0x4711ae];
			} else if (scenario == 3) {
				// aaron hard
				maxBubbleRate = 3200;
				columnCount = 16;
				bubbleColors = [0xffb600, 0x3515b0, 0x0c5aa6];
			} else if (scenario == 4) {
				// impossible
				maxBubbleRate = 3200;
				columnCount = 10;
				bubbleColors = [0xffb600, 0x0f4fa8, 0x00b25c];
			}
		}

		public override function update(elapsed:Number):void {
			super.update(elapsed);
		}
	}
}