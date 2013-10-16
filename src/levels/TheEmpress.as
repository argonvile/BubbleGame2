package levels 
{

	public class TheEmpress extends LevelDetails
	{
		public static const name:String = "The Empress";
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
				for each (var bubble:DefaultBubble in playState.bubbles.members) {
					if (bubble != null && bubble.alive && bubble.x == newBubbleX) {
						bubblesInColumn.push(bubble);
					}
				}
				
				bubblesInColumn.sort(orderByY);
				if (bubblesInColumn.length == 0) {
					continue;
				}
				var newBubble:DefaultBubble = new DefaultBubble(this, newBubbleX, bubblesInColumn[0].y, nextBubbleColor());
				var i:int = 0;
				do {
					bubblesInColumn[i].y += PlayState.bubbleHeight;
					bubblesInColumn[i].quickApproach(PlayState.bubbleHeight);
					i++;
				} while (i < bubblesInColumn.length && bubblesInColumn[i - 1].y == bubblesInColumn[i].y);
				for each (var bubble:DefaultBubble in bubblesInColumn) {
					if (!bubble.isAnchor() && bubble.visible) {
						bubble.updateAlpha();
						bubble.killConnectors();
					}
				}
				playState.maybeAddConnectors(bubblesInColumn);
				playState.bubbles.add(newBubble);
			}
		}
		
		private function orderByY(a:Bubble, b:Bubble):Number {
			return a.y - b.y;
		}
	}
}