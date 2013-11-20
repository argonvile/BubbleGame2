package levels.mean 
{

	public class TheEmpress extends LevelDetails
	{
		public static const name:String = "Empress";
		public static const scenarioBpms:Array = [51.3 - 10, 87.0 - 15, 167.6 - 20, 262.1 + 20, 322.8 + 20];
		// TODO: Bad quotas
		public static const quotaBpms:Array = [77, 141, 194, 328, 531];
		private var columnScrollArray:ShuffledArray = new ShuffledArray();
		public function TheEmpress(scenario:int) 
		{
			super(scenario);
			minScrollPixels = PlayState.bubbleHeight / 2;
			quickScrollPixels = PlayState.bubbleHeight / 2;
			
			initialRowCount = 0;
			initialScrollPixelCount = PlayState.bubbleHeight * 4;
			
			initialBubbleRatePct = 0.1;
			initialBubbleRateDuration = 3;
			
			if (scenario == 0) {
				bubbleColors = [0xffff0000, 0xff00ff00, 0xff0080ff, 0xff8000ff];
				maxBubbleRate = 100;
				columnCount = 6;
				initialScrollPixelCount = PlayState.bubbleHeight * 3;
			} else if (scenario == 1) {
				maxBubbleRate = 250;
				columnCount = 7;
				initialScrollPixelCount = PlayState.bubbleHeight * 3.5;
			} else if (scenario == 2) {
				maxBubbleRate = 600;
				columnCount = 8;
			} else if (scenario == 3) {
				maxBubbleRate = 1500;
				columnCount = 10;
			} else if (scenario == 4) {
				maxBubbleRate = 3600;
				columnCount = 12;
			}
			
			if (Math.random() < 0.5) {
				for (var i:int = 0; i < columnCount; i++) {
					columnScrollArray.push(i);
				}
			} else {
				for (var i:int = 0; i < columnCount; i++) {
					columnScrollArray.push(-1 - i);
				}
			}
			columnScrollArray.reset();
		}
		
		override public function init(playState:PlayState):void {
			super.init(playState);
			playState.scrollBubblesFunction = scrollBubbles;
		}

		public function scrollBubbles(scrollAmount:Number):void {
			var columnScroll:int = columnScrollArray.next() as int;
			var min:int = 0;
			var max:int = columnScroll;
			if (columnScroll >= 0) {
				min = 0;
				max = columnScroll;
			} else {
				min = -1 - columnScroll;
				max = columnCount - 1;
			}
			for (var columnIndex:int = min; columnIndex <= max; columnIndex++) {
				var bubblesInColumn:Array = new Array();
				var newBubbleX:Number = playState.leftEdge + columnIndex * PlayState.columnWidth;
				var newBubble:DefaultBubble = playState.insertBubbleInColumn(DefaultBubble, newBubbleX) as DefaultBubble;
				newBubble.init(this, newBubble.x, newBubble.y);
				newBubble.setBubbleColor(nextBubbleColor());
			}
		}
	}
}