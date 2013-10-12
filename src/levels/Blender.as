package levels 
{
	public class Blender extends LevelDetails
	{
		public static const name:String = "Blender";
		private var shuffledColumnArray:ContinuousShuffledArray;
		private var playState:PlayState;
		private var easyPair:int = 0;
		
		public function Blender(scenario:int) 
		{
			bubbleColors = [0xffff2300,0xffffae00,0xff133aac,0xff00bd39,0xff7c07a9];
			setSpeed(scenario < 2?scenario:scenario - 1);
			var columnScrollCount:Number;
			if (scenario == 0) {
				maxBubbleRate = 90;
				columnCount = 6;
				columnScrollCount = 1;
			} else if (scenario == 1) {
				maxBubbleRate = 180;
				columnCount = 10;
				columnScrollCount = 3;
			} else if (scenario == 2) {
				maxBubbleRate = 360;
				columnCount = 9;
				columnScrollCount = 6;
			} else if (scenario == 3) {
				maxBubbleRate = 720;
				columnCount = 12;
				columnScrollCount = 3;
			} else if (scenario == 4) {
				maxBubbleRate = 1200;
				columnCount = 10;
				columnScrollCount = 1;
			}
			minScrollPixels = (columnScrollCount / columnCount) * PlayState.bubbleHeight * 2;
			shuffledColumnArray = new ContinuousShuffledArray(3);
			for (var i:int = 0; i < columnCount; i++) {
				shuffledColumnArray.push(i);
			}
			shuffledColumnArray.reset();
		}
		
		override public function update(elapsed:Number):void {
			if (elapsed < 7) {
				bubbleRate = 0;
			} else if (elapsed < 15) {
				bubbleRate = maxBubbleRate * 0.6;
			} else if (elapsed < 30) {
				bubbleRate = maxBubbleRate * 0.8;
			} else if (elapsed < 60) {
				bubbleRate = maxBubbleRate * 0.9;
			} else {
				bubbleRate = maxBubbleRate;
			}
			
			var justScrolledBubbles:Array = new Array();
			for each (var defaultBubble:DefaultBubble in playState.bubbles.members) {
				if (defaultBubble != null && defaultBubble.alive) {
					if (defaultBubble.state == 251) {
						justScrolledBubbles.push(defaultBubble);
					}
				}
			}
			playState.maybeAddConnectors(justScrolledBubbles);
		}
		
		override public function init(playState:PlayState):void {
			this.playState = playState;
			playState.scrollBubblesFunction = scrollBubbles;
			playState.newRowLocation = PlayState.bubbleHeight * 4;
		}
		
		public function scrollBubbles(scrollAmount:Number):void {
			var columnScrollCount:int = (scrollAmount / PlayState.bubbleHeight) * columnCount / 2;
			if (shuffledColumnArray.nextIndex - columnScrollCount < 1) {
				shuffledColumnArray.reset();
			}
			for (var j:int = 0; j < columnScrollCount; j++) {
				var positionMap:Object = playState.newPositionMap();
				var columnIndex:int = shuffledColumnArray.next() as int;
				var newBubbleX:Number = playState.leftEdge + columnIndex * PlayState.columnWidth;

				var bubblesInColumn:Array = new Array();
				for each (var bubble:DefaultBubble in playState.bubbles.members) {
					if (bubble != null && bubble.alive && bubble.x == newBubbleX) {
						bubblesInColumn.push(bubble);
					}
				}
				
				bubblesInColumn.sort(orderByY);
				var newBubble0:DefaultBubble = new DefaultBubble(this, newBubbleX, bubblesInColumn[0].y, nextBubbleColor());
				var newBubble1:DefaultBubble = new DefaultBubble(this, newBubbleX, bubblesInColumn[0].y, (easyPair++%4==0)?newBubble0.bubbleColor:nextBubbleColor());
				var i:int = 0;
				do {
					bubblesInColumn[i].y += PlayState.bubbleHeight;
					bubblesInColumn[i].quickApproach(PlayState.bubbleHeight);
					i++;
				} while (i < bubblesInColumn.length && bubblesInColumn[i - 1].y == bubblesInColumn[i].y);
				bubblesInColumn.unshift(newBubble1);
				i = 0;
				do {
					bubblesInColumn[i].y += PlayState.bubbleHeight;
					bubblesInColumn[i].quickApproach(PlayState.bubbleHeight + bubblesInColumn[i].quickApproachDistance);
					i++;
				} while (i < bubblesInColumn.length && bubblesInColumn[i - 1].y == bubblesInColumn[i].y);
				for each (var bubble:DefaultBubble in bubblesInColumn) {
					if (!bubble.isAnchor() && bubble.visible) {
						bubble.updateAlpha();
						bubble.killConnectors();
					}
				}
				playState.maybeAddConnectors(bubblesInColumn);
				playState.bubbles.add(newBubble0);
				playState.bubbles.add(newBubble1);
			}
		}
		
		private function orderByY(a:Bubble, b:Bubble):Number {
			return a.y - b.y;
		}
	}
}