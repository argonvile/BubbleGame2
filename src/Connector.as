package  
{
	import org.flixel.*;

	public class Connector extends FlxSprite
	{
		public var bubble0:Bubble;
		public var bubble1:Bubble;
		
		public function Connector() 
		{
		}
		
		public function init(bubble0:Bubble, bubble1:Bubble, graphic:Class):void {
			this.bubble0 = bubble0;
			this.bubble1 = bubble1;
		}
	}
}