package levels.boring 
{
	import org.flixel.*;
	
	public class Shenyang extends LevelDetails
	{
		public static const name:String = "Shenyang";
		public static const scenarioBpms:Array = [78.5, 122.3, 162.6, 300.6, 418.9];
		private var bubbleIndex:int = 0;
		private var upcomingBubbleData:Array = new Array();
		
		public function Shenyang(scenario:int) 
		{
			super(scenario);
			columnCount = 8;
			
			bubbleColors = [0xff8f8f8f, 0xffff8800, 0xffffff00, 0xff00cc00, 0xff1240ab, 0xff7109aa];
			
			if (scenario == 0) {
				bubbleColors = bubbleColors.slice(1);
				columnCount = 7;
				maxBubbleRate = 130;
			} else if (scenario == 1) {
				bubbleColors = bubbleColors.slice(1);
				columnCount = 12;
				maxBubbleRate = 251;
			} else if (scenario == 2) {
				columnCount = 9;
				maxBubbleRate = 484;
			} else if (scenario == 3) {
				bubbleColors = bubbleColors.slice(1);
				columnCount = 8;
				maxBubbleRate = 931;
			} else if (scenario == 4) {
				columnCount = 11;
				maxBubbleRate = 1291;
			}
			
			for (var i:int = 0; i < columnCount; i++) {
				upcomingBubbleData.push(i % 2);
			}
			for (var i:int = 0; i < columnCount; i++) {
				upcomingBubbleData.push(i % 2 == 0 ? 1 : 3);
			}
			for (var i:int = 0; i < columnCount; i++) {
				upcomingBubbleData.push(4);
			}
		}
		
		override public function nextBubbleColor():uint {
			if (bubbleIndex >= upcomingBubbleData.length) {
				bubbleIndex = 0;
				bubbleColors.push(bubbleColors.shift());
				bubbleColors.push(bubbleColors.shift());
			}
			var nextBubbleType:int = upcomingBubbleData[bubbleIndex];
			bubbleIndex++;
			var result:uint;
			var which:int = int(Math.random() * 3);
			if (nextBubbleType == 0) {
				return bubbleColors[0];
			} else if (nextBubbleType == 1) {
				return bubbleColors[which + 2];
			} else if (nextBubbleType == 3) {
				return bubbleColors[1];
			} else if (nextBubbleType == 4) {
				return bubbleColors[which == 0 ? which : which + 2];
			}
			return 0;
		}
	}

}