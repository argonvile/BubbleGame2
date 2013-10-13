package levels 
{
	import org.flixel.*;

	public class LittleFriends extends LevelDetails
	{
		public static const name:String = "Little Friends";
		private var shuffledArray:ShuffledArray;
		
		public function LittleFriends(scenario:int) 
		{
			super(scenario);
			bubbleColors = [0xff7ce700,0xff04819e,0xffffe800,0xffee6b9e];
			if (scenario == 0) {
				maxBubbleRate = 150;
				columnCount = 8;
				shuffledArray = new ShuffledArray(-1, -1, -1, 0, 0);
			} else if (scenario == 1) {
				maxBubbleRate = 300;
				columnCount = 8;
				shuffledArray = new ShuffledArray( -1, -1, -1, -1, 0, 0, 0, 1, 1);
			} else if (scenario == 2) {
				maxBubbleRate = 600;
				columnCount = 6;
				shuffledArray = new ShuffledArray( -1, -1, -1, -1, -1, -1, 0, 0, 0, 0, 1, 1);
			} else if (scenario == 3) {
				maxBubbleRate = 1200;
				columnCount = 12;
				shuffledArray = new ShuffledArray( -1, -1, -1, -1, -1, -1, 0, 0, 0, 0, 0, 1, 1, 2, 2, 3, 3);
			} else if (scenario == 4) {
				maxBubbleRate = 1800;
				columnCount = 7;
				shuffledArray = new ShuffledArray( -1, -1, -1, -1, -1, -1, 0, 0, 0, 0, 1, 1, 1, 2);
			}
		}
		
		public override function nextBubble(x:Number, y:Number):Bubble {
			var next:int = shuffledArray.next() as int;
			if (next == -1) {
				return new LittleFriendsBubble(this, x, y);
			} else {
				return new DefaultBubble(this, x, y, bubbleColors[next]);
			}
 		}
				
		override public function bubbleVanished(bubble:Bubble):void {
			var positionMap:Object = playState.newPositionMap();
			for each (var position:String in [
				playState.hashPosition(bubble.x, bubble.y - PlayState.bubbleHeight),
				playState.hashPosition(bubble.x + PlayState.columnWidth, bubble.y - PlayState.bubbleHeight/2),
				playState.hashPosition(bubble.x + PlayState.columnWidth, bubble.y + PlayState.bubbleHeight/2),
				playState.hashPosition(bubble.x, bubble.y + PlayState.bubbleHeight),
				playState.hashPosition(bubble.x - PlayState.columnWidth, bubble.y + PlayState.bubbleHeight/2),
				playState.hashPosition(bubble.x - PlayState.columnWidth, bubble.y - PlayState.bubbleHeight/2)
			]) {
				var neighbor:LittleFriendsBubble = positionMap[position] as LittleFriendsBubble;
				if (neighbor != null && !neighbor.isAnchor()) {
					neighbor.visible = false;
				}
			}			
		}
		
		override public function bubblesFinishedPopping(bubbles:Array):void {
			for each (var bubble:Bubble in playState.bubbles.members) {
				var littleFriendsBubble:LittleFriendsBubble = bubble as LittleFriendsBubble;
				if (littleFriendsBubble != null && littleFriendsBubble.visible == false) {
					littleFriendsBubble.kill();
				}
			}
		}
	}
}