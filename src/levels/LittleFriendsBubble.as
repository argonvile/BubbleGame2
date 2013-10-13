package levels 
{
	import org.flixel.*;
	import flash.geom.Matrix;
	import flash.display.BitmapData;
	
	public class LittleFriendsBubble extends Bubble
	{
		public function LittleFriendsBubble(levelDetails:LevelDetails, x:Number, y:Number) 
		{
			super(levelDetails, x, y);
			var foo:Number = 17;
			var key:String = "LittleFriends";
			if (BitmapDataCache.getBitmap(key) == null) {
				var newData:BitmapData = FlxG.createBitmap(foo, foo, 0x00000000, true);
				newData.draw(FlxG.addBitmap(Embed.LittleFriends), new Matrix(foo / 50, 0, 0, foo / 50, 0, 0));
				BitmapDataCache.setBitmap(key, newData);
			}
			pixels = BitmapDataCache.getBitmap(key);
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