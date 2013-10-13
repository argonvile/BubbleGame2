package levels 
{
	public class SonicTheEdgehog extends LevelDetails
	{
		public static const name:String = "Sonic The Edgehog";
		private var bubbleIndex:int = 0;
		private var upcomingBubbleData:Array;
		
		public function SonicTheEdgehog(scenario:int) 
		{
			super(scenario);
			bubbleColors = [0xff4671d5,0xffffaa00,0xffffffff,0xffff0000,0xff4ae83a];
			if (scenario == 0) {
				maxBubbleRate = 200;
				bubbleColors = [0xff4671d5,0xffffaa00,0xffffffff,0xffff0000];
				columnCount = 7;
				upcomingBubbleData = [
				2, 2, 1, 1, 1, 2, 2,
				2, 0, 1, 1, 1, 0, 2,
				2, 0, 1, 1, 1, 0, 2,
				];
			} else if (scenario == 1) {
				maxBubbleRate = 300;
				columnCount = 9;
				upcomingBubbleData = [
				2, 2, 2, 1, 1, 1, 2, 2, 2,
				2, 0, 2, 1, 1, 1, 2, 0, 2,
				2, 0, 0, 1, 1, 1, 0, 0, 2,
				];
			} else if (scenario == 2) {
				maxBubbleRate = 700;
				columnCount = 7;
				upcomingBubbleData = [
				2, 1, 1, 1, 1, 1, 2,
				2, 0, 1, 1, 1, 0, 2,
				2, 0, 1, 1, 1, 0, 2,
				2, 0, 1, 1, 1, 0, 2,
				];
			} else if (scenario == 3) {
				maxBubbleRate = 1300;
				columnCount = 9;
				upcomingBubbleData = [
				2, 2, 1, 1, 1, 1, 1, 2, 2,
				2, 0, 1, 1, 1, 1, 1, 0, 2,
				2, 0, 0, 1, 1, 1, 0, 0, 2,
				2, 0, 0, 1, 1, 1, 0, 0, 2,
				];
			} else if (scenario == 4) {
				maxBubbleRate = 3100;
				columnCount = 9;
				upcomingBubbleData = [
				2, 1, 1, 1, 1, 1, 1, 1, 2,
				2, 1, 1, 1, 1, 1, 1, 1, 2,
				2, 1, 1, 1, 1, 1, 1, 1, 2,
				2, 0, 1, 1, 1, 1, 1, 0, 2,
				2, 0, 0, 1, 1, 1, 0, 0, 2,
				];
			}
		}
		
		override public function nextBubbleColor():int {
			var nextBubbleType:int = upcomingBubbleData[bubbleIndex];
			bubbleIndex = (bubbleIndex + 1) % upcomingBubbleData.length;
			if (nextBubbleType == 0) {
				return 0;
			} else if (nextBubbleType == 1) {
				return bubbleColors[int(Math.random() * 2)];
			} else {
				return super.nextBubbleColor();
			}
		}		
	}
}