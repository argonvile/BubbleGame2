package levels
{
	public class Newspaper extends LevelDetails
	{
		public static const name:String = "Newspaper";
		public function Newspaper(scenario:int) 
		{
			setSpeed(scenario);
			bubbleColors = [0xffff1e00, 0xff000000, 0xffffffff];
			if (scenario == 0) {
				// easy
				maxBubbleRate = 300;
				columnCount = 10;
			} else if (scenario == 1) {
				// normal 
				maxBubbleRate = 600;
				columnCount = 8;
			} else if (scenario == 2) {
				// hard
				maxBubbleRate = 1600;
				columnCount = 12;
			} else if (scenario == 3) {
				// aaron hard
				maxBubbleRate = 3200;
				columnCount = 16;
			} else if (scenario == 4) {
				// impossible
				maxBubbleRate = 3200;
				columnCount = 10;
			}
		}

		public override function update(elapsed:Number):void {
			super.update(elapsed);
		}
	}
}