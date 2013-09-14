package  
{
	import org.flixel.*;

	public class Bubble extends FlxSprite
	{
		public var bubbleColor:int;
		
		public function Bubble(x:Number,y:Number,bubbleColor:int) 
		{
			super(x, y);
			makeGraphic(16, 16, bubbleColor);
			this.bubbleColor = bubbleColor;
		}
	}
}