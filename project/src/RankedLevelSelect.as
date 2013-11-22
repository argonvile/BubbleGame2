package  
{
	import levels.BpmLevel;
	import org.flixel.*;
	import flash.ui.Mouse;
	import org.flixel.plugin.photonstorm.FlxButtonPlus;

	public class RankedLevelSelect extends FlxState
	{
		override public function create():void {
			var levelButton:LevelButton;
			
			var levelScenarios:Array = RankedPicker.pick();
			var i:int;
			
			i = 0;
			for each (var topEdge:int in [25, 115]) {
				for each (var leftEdge:int in [15, 115, 215]) {
					var levelSummary:LevelSummary = levelScenarios[i++];
					if (levelSummary != null) {
						levelButton = new LevelButton(leftEdge, topEdge, levelSummary, startGame, [levelSummary]);
						add(levelButton);
					}
				}
			}
			
			var flxText:FlxText;
			flxText = new FlxText(0, 0, 100, "ELO: " + BubbleColorUtils.roundTenths(PlayerSave.getElo()) + " ("+PlayerData.getDifficultyString(PlayerSave.getElo())+")");
			add(flxText);
		}
		
		private function startGame(levelSummary:LevelSummary):void {
			Mouse.hide();
			kill();
			var levelDetails:LevelDetails = new levelSummary.levelClass(levelSummary.scenario);
			levelDetails.levelDuration = levelSummary.duration;
			var playState:PlayState = new PlayState(RankedLevelSelect, levelDetails);
			var eloCalculator:EloCalculator = new EloCalculator(PlayerSave.getElo());
			PlayerSave.setElo(eloCalculator.loseElo(levelSummary.getScenarioBpm()));
			RankedPicker.finishedPicking();
			playState.setWinCallback(rankedWin, [eloCalculator.winElo(levelSummary.getScenarioBpm())]);
			FlxG.switchState(playState);
		}

		public static function rankedWin(newElo:Number):void {
			PlayerSave.setElo(newElo);
		}
		
		override public function update():void {
			super.update();
			Mouse.show();
			if (FlxG.keys.justPressed("ESCAPE")) {
				kill();
				FlxG.switchState(new MainMenu());
			}
		}
	}
}