package levels.mean 
{
	public class Blender extends LevelDetails
	{
		public static const name:String = "Blender";
		public static const scenarioBpms:Array = [47.1, 68.4, 114.3, 174.6, 273.0];
		// TODO: Bad quotas
		public static const quotaBpms:Array = [73, 125, 165, 273, 419];
		private var shuffledColumnArray:ContinuousShuffledArray;
		private var easyPair:int = 0;
		
		public function Blender(scenario:int) 
		{
			super(scenario);
			bubbleColors = [0xffff2300,0xffffae00,0xff133aac,0xff00bd39,0xff7c07a9];
			var columnScrollCount:Number;
			initialBubbleRatePct = 0;
			if (scenario == 0) {
				maxBubbleRate = 90;
				columnCount = 6;
				columnScrollCount = 1;
				initialBubbleRateDuration = 7;
			} else if (scenario == 1) {
				maxBubbleRate = 180;
				columnCount = 10;
				columnScrollCount = 3;
				initialBubbleRateDuration = 6;
			} else if (scenario == 2) {
				maxBubbleRate = 360;
				columnCount = 9;
				columnScrollCount = 6;
				initialBubbleRateDuration = 5;
			} else if (scenario == 3) {
				maxBubbleRate = 720;
				columnCount = 12;
				columnScrollCount = 3;
				initialBubbleRateDuration = 4;
			} else if (scenario == 4) {
				maxBubbleRate = 1200;
				columnCount = 10;
				columnScrollCount = 1;
				initialBubbleRateDuration = 3;
			}
			minScrollPixels = (columnScrollCount / columnCount) * PlayState.bubbleHeight * 2;
			shuffledColumnArray = new ContinuousShuffledArray(3);
			for (var i:int = 0; i < columnCount; i++) {
				shuffledColumnArray.push(i);
			}
			shuffledColumnArray.reset();
			initialRowCount = 4;
			initialScrollPixelCount = minScrollPixels;
		}
		
		override public function init(playState:PlayState):void {
			super.init(playState);
			playState.scrollBubblesFunction = scrollBubbles;
		}
		
		public function scrollBubbles(scrollAmount:Number):void {
			var columnScrollCount:int = (scrollAmount / PlayState.bubbleHeight) * columnCount / 2;
			if (shuffledColumnArray.nextIndex - columnScrollCount < 1) {
				shuffledColumnArray.reset();
			}
			var positionMap:Object = playState.newPositionMap();
			for (var j:int = 0; j < columnScrollCount; j++) {
				var columnIndex:int = shuffledColumnArray.next() as int;
				var newBubbleX:Number = playState.leftEdge + columnIndex * PlayState.columnWidth;

				for (var k:int = 0; k < 2;k++) {
					var newBubble:DefaultBubble = playState.insertBubbleInColumn(DefaultBubble, newBubbleX) as DefaultBubble;
					newBubble.init(this, newBubble.x, newBubble.y);
					newBubble.setBubbleColor(nextBubbleColor());
				}
			}
		}
	}
}