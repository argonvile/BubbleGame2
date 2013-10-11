package  
{
	import flash.ui.Mouse;
	import levels.*;
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.FlxButtonPlus;

	public class LevelSelect extends FlxState
	{
		private const romanNumerals:Array = ["I", "II", "III", "IV", "V"];
		
		override public function create():void {
			var levelArray:Array = [SonicTheEdgehog, Newspaper];

			for (var j:int = 0; j < levelArray.length; j++) {
				var text:FlxText = new FlxText(5, 8 + 25*j, 150, levelArray[j]["name"]);
				text.alignment = "right";
				add(text);
				for (var i:int = 0; i < 5; i++) {
					var button:FlxButtonPlus = new FlxButtonPlus(160 + 25 * i , 5 + 25*j, filmReel, [levelArray[j], i], romanNumerals[i], 20, 20);
					add(button);
				}
			}
		}
		
		override public function update():void {
			super.update();
			Mouse.show();
		}
		
		private function filmReel(clazz:Class, scenario:int):void {
			Mouse.hide();
			kill();
			FlxG.switchState(new PlayState(new clazz(scenario)));
		}
	}

}