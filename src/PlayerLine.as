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
			var l:Bubble = playState.lowestBubble();
			var lineTopY:Number;
			if (l == null) {
				// draw to top of screen
				x = playState.playerSprite.getMidpoint().x;
				lineTopY = 0;
			} else {
				// draw to bubble
				x = l.x - l.offset.x + l.width / 2 - l.offset.x;
				lineTopY = l.y - l.offset.y + l.height;
			}
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
			for (var drawY:int = lineTopY; drawY < playState.playerSprite.y; drawY++) {
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