package
{
	import org.flixel.*;
	[SWF(width="640", height="480", backgroundColor="#000000")]
 
	public class Main extends FlxGame
	{
		public function Main()
		{
			super(320, 240, MainMenu, 2, 60, 60);
			PlayerSave.load();
			FlxG.debug = true;
		}
	}
}