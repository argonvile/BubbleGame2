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
			flxText = new FlxText(0, 0, 200, "ELO: " + BubbleColorUtils.roundTenths(PlayerSave.getElo()) + " (" + PlayerData.getDifficultyString(PlayerSave.getElo()) + ")");
			add(flxText);
		}
		
		private function startGame(levelSummary:LevelSummary):void {
			Mouse.hide();
			kill();
			var levelDetails:LevelDetails = new levelSummary.levelClass(levelSummary.scenario);
			levelDetails.levelDuration = levelSummary.duration;
			var playState:PlayState = new PlayState(RankedLevelSelect, levelDetails);
			var eloCalculator:EloCalculator = new EloCalculator(PlayerSave.getElo());
			var oldElo:Number = PlayerSave.getElo();
			var loseElo:Number = eloCalculator.loseElo(levelSummary.getScenarioBpm());
			var winElo:Number = eloCalculator.winElo(levelSummary.getScenarioBpm());
			PlayerSave.setElo(loseElo);
			if (loseElo < PlayerSave.getMinElo()) {
				PlayerSave.setMinElo(loseElo);
			}
			RankedPicker.finishedPicking();
			var playerRank:int = PlayerData.getDifficultyIndex(PlayerSave.getMaxElo());
			var minElo:Number = PlayerSave.getMinElo();
			var fromPct:Number = Math.max(0, (oldElo - minElo) / (PlayerData.difficultyCutoffs[playerRank] - minElo));
			playState.setWinCallback(rankedWin, [playState, fromPct, winElo]);
			playState.setLoseCallback(rankedLose, [playState, fromPct, loseElo]);
			FlxG.switchState(playState);
		}

		public static function rankedWin(playState:PlayState, fromPct:Number, newElo:Number):void {
			var fromRank:int = PlayerData.getDifficultyIndex(PlayerSave.getMaxElo());
			var toRank:int = PlayerData.getDifficultyIndex(Math.max(newElo, PlayerSave.getMaxElo()));
			var toPct:Number = Math.min(1, (newElo - PlayerSave.getMinElo()) / (PlayerData.difficultyCutoffs[fromRank] - PlayerSave.getMinElo()));
			PlayerSave.setElo(newElo);
			if (newElo > PlayerSave.getMaxElo()) {
				PlayerSave.setMaxElo(newElo);
			}
			playState.add(new RankChangeDialog(fromPct, toPct, fromRank, toRank, "Success!"));
			if (toPct == 1) {
				var playerRank:int = PlayerData.getDifficultyIndex(PlayerSave.getMaxElo());
				PlayerSave.setMinElo(PlayerData.difficultyCutoffs[playerRank - 1]);
			}
		}

		public static function rankedLose(playState:PlayState, fromPct:Number, newElo:Number):void {
			var fromRank:int = PlayerData.getDifficultyIndex(PlayerSave.getMaxElo());
			var toRank:int = PlayerData.getDifficultyIndex(Math.max(newElo, PlayerSave.getMaxElo()));
			var toPct:Number = (PlayerSave.getElo() - PlayerSave.getMinElo()) / (PlayerData.difficultyCutoffs[fromRank] - PlayerSave.getMinElo());
			playState.add(new RankChangeDialog(fromPct, toPct, fromRank, toRank, "Failure..."));
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