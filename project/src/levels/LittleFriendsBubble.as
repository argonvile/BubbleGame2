package levels 
{
	import org.flixel.*;
	import flash.geom.Matrix;
	import flash.display.BitmapData;
	
	public class LittleFriendsBubble extends Bubble
	{
		public function LittleFriendsBubble() 
		{
			super();
			var key:String = "LittleFriends";
			if (BitmapDataCache.getBitmap(key) == null) {
				var newData:BitmapData = FlxG.createBitmap(85, 17, 0x00000000, true);
				var matrix:Matrix = new Matrix();
				matrix.scale(17 / 50, 17 / 50);
				newData.draw(FlxG.addBitmap(Embed.LittleFriends), matrix);
				BitmapDataCache.setBitmap(key, newData);
			}
			_pixels = BitmapDataCache.getBitmap(key);
			resetHelpers();
			width = frameWidth = 17;
			height = frameHeight = 17;
			addAnimation("default", [0, 1, 2, 3, 4], 4, true);
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
			if (heldBubble != null && !(heldBubble is LittleFriendsBubble)) {
				return false;
			}
			return super.isGrabbable(heldBubbles, firstGrab);
		}
	}
}