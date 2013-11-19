package  
{
	import flash.ui.Mouse;
	import levels.*;
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.FlxButtonPlus;

	public class AllLevelSelect extends FlxState
	{
		private const romanNumerals:Array = ["I", "II", "III", "IV", "V"];
		private var codeChars:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
		private var code:String = "        "
		private var codeText:FlxText
		private var diffMode:Boolean = false;
		private var firstLevelIndex:int = 0;
		private var levelTexts:Array = new Array();
		private var levelButtons:Array = new Array();
		
		override public function create():void {
			var button:FlxButtonPlus;
			var text:FlxText;
			
			button = new FlxButtonPlus(5, 5, keyboardOptions, null, "Keyboard Settings", 150, 20);
			add(button);
			button = new FlxButtonPlus(165, 5, sixLevels, null, "Six Levels", 150, 20);
			add(button);

			for (var j:int = 0; j < 8; j++) {
				text = new FlxText(5, 33 + 25 * j, 150);
				text.alignment = "right";
				levelTexts[j] = text;
				add(text);
				var array:Array = new Array();
				levelButtons[j] = array;
				for (var i:int = 0; i < 5; i++) {
					button = new FlxButtonPlus(160 + 25 * i , 30 + 25 * j, null, null, "", 20, 20);
					button.textNormal.text = romanNumerals[i];
					button.textHighlight.text = romanNumerals[i];
					add(button);
					array[i] = button;
				}
			}
			scrollEm(0);
			codeText = new FlxText(0, 0, FlxG.width);
			add(codeText);
			var upButton:FlxButtonPlus = new FlxButtonPlus(300, 30, scrollEm, [-8], "-", 15, 20);
			add(upButton);
			var downButton:FlxButtonPlus = new FlxButtonPlus(300, 205, scrollEm, [8], "+", 15, 20);
			add(downButton);
		}
		
		private function scrollEm(number:Number):void {
			var button:FlxButtonPlus;
			var text:FlxText;
			firstLevelIndex += number;
			firstLevelIndex = Math.max(0, firstLevelIndex);
			firstLevelIndex = Math.min(PlayerData.levelClasses.length - 8, firstLevelIndex);
			for (var j:int = 0; j < 8; j++) {
				text = levelTexts[j];
				text.text = PlayerData.levelClasses[j + firstLevelIndex]["name"];
				for (var i:int = 0; i < 5; i++) {
					var array:Array = levelButtons[j];
					button = array[i];
					button.setOnClickCallback(startGame, [PlayerData.levelClasses[j + firstLevelIndex], i]);
				}
			}
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
			if (FlxG.keys.justPressed("ESCAPE")) {
				kill();
				FlxG.switchState(new MainMenu());
			}
		}
		
		private function codeEntered(expectedCode:String):Boolean {
			return code.substring(code.length - expectedCode.length, code.length) == expectedCode;
		}
		
		private function keyboardOptions():void {
			kill();
			FlxG.switchState(new KeyboardOptions(AllLevelSelect));
		}
		
		private function sixLevels():void {
			kill();
			FlxG.switchState(new LevelSelect());
		}
		
		private function startGame(clazz:Class, scenario:int):void {
			Mouse.hide();
			kill();
			var playState:PlayState = new PlayState(AllLevelSelect, new clazz(scenario));
			if (diffMode) {
				playState.variableDifficultyMode = true;
			}
			FlxG.switchState(playState);
		}
	}

}