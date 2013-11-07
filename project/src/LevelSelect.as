package  
{
	import org.flixel.*;
	import flash.ui.Mouse;
	import org.flixel.plugin.photonstorm.FlxButtonPlus;

	public class LevelSelect extends FlxState
	{
		override public function create():void {
			var levelButton:LevelButton;
			
			var levelScenarios:Array = new Array();
			var i:int;
			for (i = 0; i < 6; i++) {
				levelScenarios.push(PlayerData.levels.next() as Array);
			}
			levelScenarios.sort(levelFunction);
			
			i = 0;
			for each (var topEdge:int in [25, 115]) {
				for each (var leftEdge:int in [15, 115, 215]) {
					var levelScenario:Array = levelScenarios[i++];
					levelButton = new LevelButton(leftEdge, topEdge, levelScenario[0], levelScenario[1], startGame, levelScenario);
					add(levelButton);
				}
			}
			
			var button:FlxButtonPlus;
			button = new FlxButtonPlus(5, 207, keyboardOptions, null, "Keyboard Settings", 150, 20);
			add(button);
			button = new FlxButtonPlus(165, 207, allLevels, null, "All Levels", 150, 20);
			add(button);
		}
		
		private function levelFunction(array0:Array, array1:Array):int {
			var class0:Class = array0[0];
			var scenario0:int = array0[1];
			var scenarioBpm0:Number = class0["scenarioBpms"][scenario0];
			var class1:Class = array1[0];
			var scenario1:int = array1[1];
			var scenarioBpm1:Number = class1["scenarioBpms"][scenario1];
			return scenarioBpm0 - scenarioBpm1;
		}
		
		private function startGame(clazz:Class, scenario:int):void {
			Mouse.hide();
			kill();
			var playState:PlayState = new PlayState(LevelSelect, new clazz(scenario));
			FlxG.switchState(playState);
		}

		override public function update():void {
			super.update();
			Mouse.show();
		}
				
		private function keyboardOptions():void {
			kill();
			FlxG.switchState(new KeyboardOptions());
		}
		
		private function allLevels():void {
			kill();
			FlxG.switchState(new AllLevelSelect());
		}
	}
}