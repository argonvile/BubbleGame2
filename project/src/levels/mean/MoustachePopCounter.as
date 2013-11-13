package levels.mean 
{
	public class MoustachePopCounter extends PopCounter
	{
		public function MoustachePopCounter(playState:PlayState) 
		{
			super(playState);
		}
		
		override public function popMatches(bubble:Bubble):void {
			if (bubble is DefaultBubble) {
				super.popMatches(bubble);
				return;
			}
			var bubblesToCheck:Array = new Array(bubble);
			var iBubblesToCheck:int = 0;
			
			do {
				var bubbleToCheck:MoustacheBubble = bubblesToCheck[iBubblesToCheck] as MoustacheBubble;
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
					var neighbor:MoustacheBubble = positionMap[position] as MoustacheBubble;
					if (neighbor != null) {
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
	}
}