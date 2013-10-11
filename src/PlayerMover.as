package  
{
	import org.flixel.FlxSprite;
	import org.flixel.*;

	public class PlayerMover 
	{
		private var playerSprite:FlxSprite;
		public var minX:int;
		public var maxX:int;
		private var columnCount:int;
		private var leftTimer:Number = 0;
		private var rightTimer:Number = 0;
		public var repeatDelay:Number = 0;
		public var repeatRate:Number = 0;
		
		public function PlayerMover(playerSprite:FlxSprite, leftEdge:int, columnCount:int) 
		{
			this.playerSprite = playerSprite;
			this.minX = leftEdge;
			this.maxX = leftEdge + PlayState.columnWidth * (columnCount - 1);
			this.columnCount = columnCount;
			repeatDelay = PlayerSave.getRepeatDelay();
			repeatRate = PlayerSave.getRepeatRate();
		}
		
		public function movePlayer(justPressedLeft:Boolean, justPressedRight:Boolean, justPressedDown:Boolean, justPressedUp:Boolean, pressedLeft:Boolean, pressedRight:Boolean) {
			if (justPressedLeft) {
				moveLeft();
			}
			if (justPressedRight) {
				moveRight();
			}
			if (justPressedDown) {
				playerSprite.x = minX + PlayState.columnWidth*(Math.floor(0.33333333 * (columnCount - 1)));
			}
			if (justPressedUp) {
				playerSprite.x = minX + PlayState.columnWidth*(Math.ceil(0.66666667 * (columnCount - 1)));
			}
			if (pressedLeft) {
				leftTimer += FlxG.elapsed;
				while (leftTimer > repeatDelay && leftTimer > repeatRate && playerSprite.x > minX) {
					moveLeft();
					leftTimer -= repeatRate;
				}
			} else {
				leftTimer = 0;
			}
			if (pressedRight) {
				rightTimer += FlxG.elapsed;
				while (rightTimer > repeatDelay && rightTimer > repeatRate && playerSprite.x < maxX) {
					moveRight();
					rightTimer -= repeatRate;
				}
			} else {
				rightTimer = 0;
			}
		}
		
		private function moveLeft() {
			playerSprite.x = Math.max(playerSprite.x - PlayState.columnWidth, minX);
		}
		
		private function moveRight() {
			playerSprite.x = Math.min(playerSprite.x + PlayState.columnWidth, maxX);
		}
		
		public function movePlayerFromInput():void {
			movePlayer(FlxG.keys.justPressed("LEFT"), FlxG.keys.justPressed("RIGHT"), FlxG.keys.justPressed("DOWN"), FlxG.keys.justPressed("UP"), FlxG.keys.pressed("LEFT"), FlxG.keys.pressed("RIGHT"));
		}
	}
}