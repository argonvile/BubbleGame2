package  
{
	import flash.geom.Rectangle;
	import org.flixel.*;
	import flash.display.Graphics;
	
	public class PlayerLine extends FlxSprite
	{
		private var playState:PlayState;
		private var lineScroll:Number = 31536000;
		
		public function PlayerLine(playState:PlayState) {
			this.playState = playState;
			makeGraphic(2, FlxG.height, 0x00000000);
		}
		
		override public function update():void {
			super.update();
			lineScroll += FlxG.elapsed * 15;
		}
		
		public function finalUpdate():void {
			var lowestBubble:FlxSprite = playState.lowestBubble();
			if (lowestBubble == null) {
				lowestBubble = new FlxSprite(playState.playerSprite.x, -1);
				lowestBubble.makeGraphic(playState.playerSprite.width, 1);
			}
			x = lowestBubble.x - lowestBubble.offset.x + lowestBubble.width / 2 - lowestBubble.offset.x;
			fill(0x00000000);
			var color:uint = 0x66ffffff;
			var holdingBubble:Boolean = false;
			for each (var bubble:Bubble in playState.heldBubbles.members) {
				if (bubble != null && bubble.alive) {
					if (bubble is DefaultBubble) {
						color = DefaultBubble(bubble).bubbleColor & 0x66ffffff;
					}
					holdingBubble = true;
					break;
				}
			}
			for (var drawY:int = lowestBubble.y - lowestBubble.offset.y + lowestBubble.height; drawY < playState.playerSprite.y; drawY++) {
				if (holdingBubble) {
					if ((drawY + lineScroll) % 5 > 2) {
						pixels.fillRect(new Rectangle(0, drawY, 2, 1), color);
					}
				} else {
					if ((50000000 + drawY - lineScroll) % 5 < 2) {
						pixels.fillRect(new Rectangle(0, drawY, 2, 1), color);
					}
				}
			}
			dirty = true;
		}
	}

}