package  
{
	import org.flixel.*;

	public class Bubble extends FlxSprite
	{
		/**
		 * state
		 * 0 = normal
		 * 100 = grabbing
		 * 200 = throwing
		 * 250 = quickly approaching
		 * 251 = just finished quickly approaching
		 * 300 = popping
		 */
		public var state:int = 0;
		public var stateTime:Number = 0;
		protected var playerSprite:FlxSprite;
		public var quickApproachDistance:Number;
		
		public function Bubble(x:Number,y:Number) 
		{
			super(x, y);
		}

		public function updateAlpha():void {
			if (isAnchor()) {
				alpha = 0.6;
			} else {
				alpha = 1.0;
			}		
		}
		
		public function isAnchor():Boolean {
			return y < 0;
		}
		
		public function wasGrabbed(playerSprite:FlxSprite):void {
			state = 100;
			stateTime = 0;
			this.playerSprite = playerSprite;
			offset.x = 0;
			offset.y = 0;
		}
		
		public function wasThrown(playerSprite:FlxSprite):void {
			state = 200;
			stateTime = 0;
			this.playerSprite = playerSprite;
			offset.x = (x + width / 2) - (playerSprite.x + playerSprite.width / 2);
			offset.y = (y + height / 2) - (playerSprite.y + playerSprite.height / 2);
		}
		
		public function quickApproach(distance:Number):void {
			this.quickApproachDistance = distance;
			state = 250;
			stateTime = 0;
			offset.x = 0;
			offset.y = distance;
		}
	}
}