package levels {
	import org.flixel.*;
	
	public class DumbLevel extends LevelDetails
	{
		public function DumbLevel(scenario:int=3) 
		{
			super(scenario);
			bubbleColors = [0xffff1e00];
			columnCount = 1;
		}
		
		override public function init(playState:PlayState):void {
			super.init(playState);
			playState.newRowLocation = PlayState.bubbleHeight * 2;
		}
	}
}