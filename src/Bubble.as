package  
{
	import org.flixel.*;

	public class Bubble extends FlxSprite
	{
		public var bubbleColor:int;
		public var lifespan:Number;
		
		public function Bubble(x:Number,y:Number,bubbleColor:int) 
		{
			super(x, y);
			makeGraphic(16, 16, bubbleColor);
			this.bubbleColor = bubbleColor;
		}
		
		override public function update():void {
			super.update();
			if (isAnchor()) {
				alpha = 0.6;
			} else {
				alpha = 1.0;
			}
			if(lifespan <= 0) {
				return;
			}
			lifespan -= FlxG.elapsed;
			if(lifespan <= 0) {
				kill();
			}
		}
		
		public function isAnchor():Boolean {
			return y < 0;
		}
	}
}