package  
{
	import flash.ui.Mouse;
	import levels.*;
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.FlxButtonPlus;

	public class LevelSelect extends FlxState
	{
		private const romanNumerals:Array = ["I", "II", "III", "IV", "V"];
		private var codeChars:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
		private var code:String = "        "
		private var codeText:FlxText
		private var diffMode:Boolean = false;
		
		override public function create():void {
			var levelArray:Array = [TheEmpress, LuckySeven, SonicTheEdgehog, Newspaper, Blender, LittleFriends];
			var button:FlxButtonPlus;
			var text:FlxText;
			
			button = new FlxButtonPlus(5, 5, keyboardOptions, null, "Keyboard Settings", 150, 20);
			add(button);

			for (var j:int = 0; j < levelArray.length; j++) {
				text = new FlxText(5, 33 + 25*j, 150, levelArray[j]["name"]);
				text.alignment = "right";
				add(text);
				for (var i:int = 0; i < 5; i++) {
					button = new FlxButtonPlus(160 + 25 * i , 30 + 25*j, startGame, [levelArray[j], i], romanNumerals[i], 20, 20);
					add(button);
				}
			}
			codeText = new FlxText(0, 0, FlxG.width);
			add(codeText);
		}
		
		override public function update():void {
			super.update();
			Mouse.show();
			for (var i:int = 0; i < codeChars.length; i++) {
				if (FlxG.keys.justPressed(codeChars.charAt(i))) {
					code = code.substring(1) + codeChars.charAt(i);
				}
			}
			if (codeEntered("AVBPM")) {
				startGame(BpmLevel, 0);
			}
			if (codeEntered("AVDIFF")) {
				diffMode = true;
				codeText.text = "Variable Difficulty Mode Activated";
			}
		}
		
		private function codeEntered(expectedCode:String):Boolean {
			return code.substring(code.length - expectedCode.length, code.length) == expectedCode;
		}
		
		private function keyboardOptions():void {
			kill();
			FlxG.switchState(new KeyboardOptions());
		}
		
		private function startGame(clazz:Class, scenario:int):void {
			Mouse.hide();
			kill();
			var playState:PlayState = new PlayState(new clazz(scenario));
			if (diffMode) {
				playState.variableDifficultyMode = true;
			}
			FlxG.switchState(playState);
		}
	}

}