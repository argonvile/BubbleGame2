package levels 
{
	import org.flixel.*;
	import flash.geom.Matrix;
	import flash.display.BitmapData;
	
	public class BombBubble extends Bubble
	{
		public var detonated:Boolean = false;
		
		public function BombBubble() 
		{
			super();
			var key:String = "Bomb";
			if (BitmapDataCache.getBitmap(key) == null) {
				var newData:BitmapData = FlxG.createBitmap(51, 17, 0x00000000, true);
				var matrix:Matrix = new Matrix();
				matrix.scale(17 / 50, 17 / 50);
				newData.draw(FlxG.addBitmap(Embed.Bomb), matrix);
				BitmapDataCache.setBitmap(key, newData);
			}
			_pixels = BitmapDataCache.getBitmap(key);
			width = frameWidth = 17;
			height = frameHeight = 17;
			resetHelpers();
			addAnimation("default", [2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 0], 30, true);
			play("default");
			_curFrame = Math.random() * 5;
		}
		
		override public function isGrabbable(heldBubbles:FlxGroup, firstGrab:Boolean):Boolean {
			if (visible == false) {
				return false;
			}
			if (!firstGrab) {
				return false;
			}
			var heldBubble:Bubble = heldBubbles.getFirstAlive() as Bubble;
			if (heldBubble != null && !(heldBubble is BombBubble)) {
				return false;
			}
			return super.isGrabbable(heldBubbles, firstGrab);
		}
	}
}