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
			var levelArray:Array = [SonicTheEdgehog, Newspaper, Blender, LittleFriends];
			var button:FlxButtonPlus;
			var text:FlxText;
			
			button = new FlxButtonPlus(5, 5, keyboardOptions, null, "Keyboard Settings", 150, 20);
			add(button);

			for (var j:int = 0; j < levelArray.length; j++) {
				text = new FlxText(5, 33 + 25*j, 150, levelArray[j]["name"]);
				text.alignment = "right";
				add(text);
				for (var i:int = 0; i < 5; i++) {
					button = new FlxButtonPlus(160 + 25 * i , 30 + 25*j, filmReel, [levelArray[j], i], romanNumerals[i], 20, 20);
					add(button);
				}
			}
		}
		
		override public function update():void {
			super.update();
			Mouse.show();
		}
		
		private function keyboardOptions():void {
			kill();
			FlxG.switchState(new KeyboardOptions());
		}
		
		private function filmReel(clazz:Class, scenario:int):void {
			Mouse.hide();
			kill();
			FlxG.switchState(new PlayState(new clazz(scenario)));
		}
	}

}