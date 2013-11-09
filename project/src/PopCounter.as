package  
{
	public class PopCounter 
	{
		private var positionMap:Object;
		private var poppedBubbles:Array = new Array();
		private var p:PlayState;
		
		public function PopCounter(playState:PlayState) 
		{
			this.p = playState;
			this.positionMap = playState.newPositionMap();
		}
		
		public function popMatches(bubble:Bubble):void {
			var bubblesToCheck:Array = new Array(bubble);
			var iBubblesToCheck:int = 0;
			
			do {
				var bubbleToCheck:DefaultBubble = bubblesToCheck[iBubblesToCheck] as DefaultBubble;
				if (bubbleToCheck == null) {
					break;
				}
				positionMap[p.hashPosition(bubbleToCheck.x, bubbleToCheck.y)] = null;
				for each (var position:String in [
					p.hashPosition(bubbleToCheck.x, bubbleToCheck.y - PlayState.bubbleHeight),
					p.hashPosition(bubbleToCheck.x + PlayState.columnWidth, bubbleToCheck.y - PlayState.bubbleHeight/2),
					p.hashPosition(bubbleToCheck.x + PlayState.columnWidth, bubbleToCheck.y + PlayState.bubbleHeight/2),
					p.hashPosition(bubbleToCheck.x, bubbleToCheck.y + PlayState.bubbleHeight),
					p.hashPosition(bubbleToCheck.x - PlayState.columnWidth, bubbleToCheck.y + PlayState.bubbleHeight/2),
					p.hashPosition(bubbleToCheck.x - PlayState.columnWidth, bubbleToCheck.y - PlayState.bubbleHeight/2)
				]) {
					var neighbor:DefaultBubble = positionMap[position] as DefaultBubble;
					if (neighbor != null && neighbor.bubbleColor == bubbleToCheck.bubbleColor) {
						positionMap[position] = null;
						bubblesToCheck.push(neighbor);
					}
				}
			} while (++iBubblesToCheck < bubblesToCheck.length);
			
			if (iBubblesToCheck >= 4) {
				for each(var bubble:Bubble in bubblesToCheck) {
					poppedBubbles.push(bubble);
				}
			}			
		}
		
		public function shouldPop():Boolean {
			return poppedBubbles.length > 0;
		}
		
		public function getPoppedBubbles():Array {
			return poppedBubbles;
		}
		
		public function shouldPopBubble(bubble:Bubble):Boolean {
			for each (var otherBubble:Bubble in poppedBubbles) {
				if (bubble == otherBubble) {
					return true;
				}
			}
			return false;
		}
	}
}