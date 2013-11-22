package  
{
	public class Worlds 
	{
		public static var allWorlds:Array;
		
		public static function init():void {
			if (allWorlds == null) {
				Rndm.seed = 0xd0b1d1;
				var allLevels:Array = new Array();
				for each (var clazz:Class in PlayerData.levelClasses) {
					for each (var scenario:int in [0, 1, 2, 3, 4]) {
						var o:LevelSummary = new LevelSummary();
						o.levelClass = clazz;
						o.scenario = scenario;
						o.duration = [75, 90, 100, 115][Rndm.integer(0, 4)];
						allLevels.push(o);
					}
				}
				while (allLevels.length % 15 != 0) {
					var itemToRemove:int = int(Rndm.random() * allLevels.length);
					allLevels.splice(itemToRemove, 1);
				}
				allLevels.sort(orderByDifficulty);
				allWorlds = new Array();
				var worldLevels:Array = new Array();
				for (var i:int = 0; i < allLevels.length; i++) {
					worldLevels.push(allLevels[i]);
					if (i % 15 == 14) {
						allWorlds.push(worldLevels);
						semiShuffle(worldLevels);
						worldLevels = new Array();
					}
				}
				Rndm.seed = Math.random() * 0xffffff;
			}
		}
		
		private static function semiShuffle(array:Array):void {
			var shuffledArray:Array = new Array(array.length);
			for (var i:int = 0; i < shuffledArray.length; i++)
			{
				var randomPos:int = int(Rndm.random() * (array.length * 0.34));
				shuffledArray[i] = array.splice(randomPos, 1)[0];
			}
			for (var i:int = 0; i < shuffledArray.length; i++) {
				array[i] = shuffledArray[i];
			}
		}
		
		private static function orderByDifficulty(o0:LevelSummary, o1:LevelSummary):int {
			return o0.getScenarioBpm() - o1.getScenarioBpm();
		}
	}
}