package  
{
	public class NullBubble extends Bubble
	{
		override public function init(levelDetails:LevelDetails, x:Number, y:Number):void {
			super.init(levelDetails, x, y);
			visible = false;
		}
	}
}