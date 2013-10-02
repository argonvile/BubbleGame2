package  
{
	import org.flixel.*;

	public class Connector extends FlxSprite
	{
		public var bubble0:Bubble;
		public var bubble1:Bubble;
		
		public function Connector(bubble0:Bubble=null, bubble1:Bubble=null)
		{
			this.bubble0 = bubble0;
			this.bubble1 = bubble1;
		}
		
		public function init(bubble0:Bubble, bubble1:Bubble):void {
			this.bubble0 = bubble0;
			this.bubble1 = bubble1;
		}
	}
}