package levels 
{
	import org.flixel.*;

	public class LittleFriends extends LevelDetails
	{
		public static const name:String = "Little Friends";
		public static const scenarioBpms:Array = [36.6, 87.0, 167.6, 262.1 + 25, 322.8];
		private var shuffledArray:ShuffledArray;
		
		public function LittleFriends(scenario:int) 
		{
			super(scenario);
			bubbleColors = [0xff44ff00, 0xff22ffff, 0xffffff22, 0xffff0044];
			initialBubbleRateDuration = 5;
			initialBubbleRatePct = 0.25;
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
				maxBubbleRate = 1200;
				columnCount = 7;
				shuffledArray = new ShuffledArray( -1, -1, -1, -1, -1, -1, 0, 0, 0, 0, 1, 1, 1, 2);
			}
		}
		
		public override function nextBubble(x:Number, y:Number):Bubble {
			var next:int = shuffledArray.next() as int;
			if (next == -1) {
				var newLittleFriendsBubble:LittleFriendsBubble = playState.addBubble(LittleFriendsBubble) as LittleFriendsBubble;
				newLittleFriendsBubble.init(this, x, y);
				return newLittleFriendsBubble;
			} else {
				var newDefaultBubble:DefaultBubble = playState.addBubble(DefaultBubble) as DefaultBubble;
				newDefaultBubble.init(this, x, y);
				newDefaultBubble.setBubbleColor(bubbleColors[next]);
				return newDefaultBubble;
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
				if (neighbor != null && !neighbor.isAnchor() && neighbor.visible == true) {
					neighbor.visible = false;
					playState.eliminatedBubbleCount++;
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