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
			if(lifespan <= 0) {
				return;
			}
			lifespan -= FlxG.elapsed;
			if(lifespan <= 0) {
				kill();
			}
		}
	}
}