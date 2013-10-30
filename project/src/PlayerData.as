package  
{
	import levels.*;
	
	public class PlayerData 
	{
		private static var _levels:ContinuousShuffledArray;
		public static const difficultyCutoffs:Array = [45, 60, 75, 88, 98, 109, 121, 135, 149, 164, 181, 200, 221, 244, 270, 299, 332, 369, 409, Number.MAX_VALUE];
		public static const difficultyStrings:Array = [".", "..", "...", "o", "oo", "ooo", "oooo", "ooooo", "O", "OO", "OOO", "OOOO", "OOOOO", "OOOOOO", "OOOOOOO", "@", "@@", "@@@", "@@@@", "@@@@@"]
		public static const levelClasses:Array = [BlindSide, DarkStalker, Relentless, TheEmpress, LuckySeven, SonicTheEdgehog, Newspaper, Blender, LittleFriends];
		
		public static function get levels():ContinuousShuffledArray {
			if (_levels == null) {
				var difficulties:Object = new Object();
				var difficultyString:String;
				for each (difficultyString in difficultyStrings) {
					difficulties[difficultyString] = 0;
				}
				_levels = new ContinuousShuffledArray(levelClasses.length * 2);
				for each (var clazz:Class in levelClasses) {
					for each (var scenario:int in [0, 1, 2, 3, 4]) {
						difficultyString = getDifficultyString(clazz["scenarioBpms"][scenario]);
						difficulties[difficultyString]++;
						_levels.push([clazz, scenario]);
					}
				}
				_levels.reset();
				for each (difficultyString in difficultyStrings) {
					trace(difficultyString + ": " + difficulties[difficultyString]);
				}
			}
			return _levels;
		}
		
		public static function getDifficultyIndex(adjustedBpm:Number):int {
			for (var i:int = 0; i < difficultyCutoffs.length; i++) {
				if (difficultyCutoffs[i] > adjustedBpm) {
					return i;
				}
			}
			return 0;
		}
		
		public static function getDifficultyString(adjustedBpm:Number):String {
			return difficultyStrings[getDifficultyIndex(adjustedBpm)];
		}
	}
}