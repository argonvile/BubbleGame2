package  
{
	import org.flixel.*;
	import flash.display.BitmapData;
	import flash.geom.Matrix;

	public class PlayerSprite extends FlxGroup
	{
		private var _x:Number;
		private var _y:Number;
		private var monsterBg:FlxSprite;
		private var monsterArms:FlxSprite;
		public var heldBubbles:FlxGroup = new FlxGroup();
		private var monsterBgPixels:BitmapData;
		private var neutralArmPixels:BitmapData;
		private var holdingArmPixels:BitmapData;
		private var facingRight:Boolean = true;

		public function PlayerSprite(x:Number,y:Number) 
		{
			this._x = x;
			this._y = y;
			monsterBg = new FlxSprite(x, y);
			monsterBg.makeGraphic(40, 40, 0x00000000, true);
			var matrix:Matrix = new Matrix();
			matrix.scale(40 / 120, 40 / 120);
			monsterBgPixels = FlxG.createBitmap(40, 40, 0x00000000, true);
			monsterBgPixels.draw(FlxG.addBitmap(Embed.MonsterBody0), matrix);
			monsterBg.pixels = monsterBgPixels;
			monsterBg.dirty = true;
			monsterBg.offset.x = 40 / 2 - PlayState.columnWidth / 2 - 1;
			monsterBg.offset.y = 40 / 2 - PlayState.bubbleHeight / 2;
			neutralArmPixels = FlxG.createBitmap(40, 40, 0x00000000, true);
			neutralArmPixels.draw(FlxG.addBitmap(Embed.MonsterArms0), matrix);
			holdingArmPixels = FlxG.createBitmap(40, 40, 0x00000000, true);
			holdingArmPixels.draw(FlxG.addBitmap(Embed.MonsterArms1), matrix);
			
			monsterArms = new FlxSprite(x, y);
			monsterArms.pixels = neutralArmPixels;
			
			monsterArms.offset.x = monsterBg.offset.x;
			monsterArms.offset.y = monsterBg.offset.y;
			add(monsterBg);
			add(heldBubbles);
			add(monsterArms);
		}
		
		public function set x(newX:int):void
		{
			_x = newX;
			monsterBg.x = _x;
			monsterArms.x = _x;
		}
		
		public function get x():int
		{
			return _x;
		}
		
		public function set y(newY:int):void
		{
			_y = newY;
			monsterBg.y = _y;
			monsterArms.y = _y;
		}
		
		public function get y():int
		{
			return _y;
		}
		
		public function getMidpoint(point:FlxPoint = null):FlxPoint
		{
			if(point == null)
				point = new FlxPoint();
			point.x = _x + PlayState.columnWidth*0.5;
			point.y = _y + PlayState.bubbleHeight*0.5;
			return point;
		}
		
		override public function update():void {
			super.update();
			var holding:Boolean = false;
			for each (var bubble:Bubble in heldBubbles.members) {
				if (bubble != null && bubble.alive) {
					if (bubble.isHeld()) {
						holding = true;
						break;
					}
				}
			}
			if (holding) {
				if (monsterArms.pixels != holdingArmPixels) {
					monsterArms.pixels = holdingArmPixels;
					monsterArms.dirty = true;
				}
			} else {
				if (monsterArms.pixels != neutralArmPixels) {
					monsterArms.pixels = neutralArmPixels;
					monsterArms.dirty = true;
				}
			}
		}
	}

}