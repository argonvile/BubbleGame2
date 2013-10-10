package levels 
{
	public class FilmReel extends LevelDetails
	{
		private var bubbleIndex:int = 0;
		private var upcomingBubbleData:Array;
		
		public function FilmReel(scenario:int = 2) 
		{
			setSpeed(scenario < 2?scenario:scenario - 1);
			if (scenario == 0) {
				maxBubbleRate = 200;
				bubbleColors = [0xffffffff,0xff000000,0xffff0000,0xff0000ff];
				columnCount = 7;
				upcomingBubbleData = [
				2, 2, 1, 1, 1, 2, 2,
				2, 0, 1, 1, 1, 0, 2,
				2, 0, 1, 1, 1, 0, 2,
				];
			} else if (scenario == 1) {
				maxBubbleRate = 300;
				bubbleColors = [0xffffffff,0xff000000,0xffff0000,0xff0000ff,0xff00ff00];
				columnCount = 9;
				upcomingBubbleData = [
				2, 2, 2, 1, 1, 1, 2, 2, 2,
				2, 0, 2, 1, 1, 1, 2, 0, 2,
				2, 0, 0, 1, 1, 1, 0, 0, 2,
				];
			} else if (scenario == 2) {
				maxBubbleRate = 700;
				bubbleColors = [0xffffffff,0xff000000,0xffff0000,0xff0000ff,0xff00ff00];
				columnCount = 7;
				upcomingBubbleData = [
				2, 1, 1, 1, 1, 1, 2,
				2, 0, 1, 1, 1, 0, 2,
				2, 0, 1, 1, 1, 0, 2,
				2, 0, 1, 1, 1, 0, 2,
				];
			} else if (scenario == 3) {
				maxBubbleRate = 1300;
				bubbleColors = [0xffffffff,0xff000000,0xffff0000,0xff0000ff,0xff00ff00];
				columnCount = 9;
				upcomingBubbleData = [
				2, 2, 1, 1, 1, 1, 1, 2, 2,
				2, 0, 1, 1, 1, 1, 1, 0, 2,
				2, 0, 0, 1, 1, 1, 0, 0, 2,
				2, 0, 0, 1, 1, 1, 0, 0, 2,
				];
			} else if (scenario == 4) {
				maxBubbleRate = 3100;
				bubbleColors = [0xffffffff,0xff000000,0xffff0000,0xff0000ff,0xff00ff00];
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