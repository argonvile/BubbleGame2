package levels.boring 
{
	import org.flixel.*;
	
	public class Hyderabad extends LevelDetails
	{
		public static const name:String = "Hyderabad";
		public static const scenarioBpms:Array = [20.1, 47.9, 93.5, 169.0, 231.9];
		
		private var bubbleIndex:int = 0;
		private var upcomingBubbleData:Array;
		private var ringness:Number = 1.0;
		private var nextOdd:Boolean = true;
		private var nextColor:int = 0;
		
		public function Hyderabad(scenario:int) 
		{
			super(scenario);
			bubbleColors = [0xffc50080, 0xff1437ad, 0xff530fad, 0xffffe800, 0xff84f000];
			columnCount = 8;
			upcomingBubbleData = new Array();
			if (scenario == 0) {
				ringness = 0.95;
				columnCount = 8;
				bubbleColors = bubbleColors.slice(1);
				maxBubbleRate = 71;
			} else if (scenario == 1) {
				ringness = 0.86;
				columnCount = 11;
				maxBubbleRate = 151;
			} else if (scenario == 2) {
				ringness = 0.75;
				columnCount = 7;
				maxBubbleRate = 322;
			} else if (scenario == 3) {
				ringness = 0.70;
				columnCount = 7;
				maxBubbleRate = 686;
			} else if (scenario == 4) {
				ringness = 0.80;
				columnCount = 9;
				maxBubbleRate = 1460;
			}
			for (var i:int = 0; i < columnCount * 2; i++) {
				upcomingBubbleData.push(8);
			}
		}
		
		override public function nextBubbleColor():uint {
			var nextBubbleType:int = upcomingBubbleData[bubbleIndex];
			bubbleIndex++;
			if (bubbleIndex > columnCount) {
				bubbleIndex -= columnCount;
				upcomingBubbleData = upcomingBubbleData.slice(columnCount);
				if (upcomingBubbleData.length <= columnCount) {
					if (nextOdd) {
						for (var i:int = 0; i < columnCount * 2; i++) {
							upcomingBubbleData.push(8);
						}
						var randomOdd:int = int(Math.random() * int((columnCount - 1) / 2)) * 2 + 1;
						var center:int = columnCount + randomOdd;
						upcomingBubbleData[center] = 9;
						upcomingBubbleData[center - columnCount] = nextColor;
						upcomingBubbleData[center - 1] = nextColor;
						upcomingBubbleData[center + 1] = nextColor;
						upcomingBubbleData[center + columnCount - 1] = nextColor;
						upcomingBubbleData[center + columnCount] = nextColor;
						upcomingBubbleData[center + columnCount + 1] = nextColor;
					} else {
						for (var i:int = 0; i < columnCount * 3; i++) {
							upcomingBubbleData.push(8);
						}
						var randomEven:int = int(Math.random() * int((columnCount - 2) / 2)) * 2 + 2;
						var center:int = columnCount * 2 + randomEven;
						upcomingBubbleData[center] = 9;
						upcomingBubbleData[center - columnCount - 1] = nextColor;
						upcomingBubbleData[center - columnCount] = nextColor;
						upcomingBubbleData[center - columnCount + 1] = nextColor;
						upcomingBubbleData[center - 1] = nextColor;
						upcomingBubbleData[center + 1] = nextColor;
						upcomingBubbleData[center + columnCount] = nextColor;
					}
					nextOdd = !nextOdd;
					nextColor = (nextColor + 1) % bubbleColors.length;
				}
			}
			if (nextBubbleType == 9) {
				return 0;
			} else if (nextBubbleType < bubbleColors.length && Math.random() < ringness) {
				return bubbleColors[nextBubbleType];
			} else {
				return super.nextBubbleColor();
			}
		}
	}
}