package  
{
	import levels.*;
	
	public class PlayerData 
	{
		private static var _levels:ContinuousShuffledArray;
		
		public static function get levels():ContinuousShuffledArray {
			var levelClasses:Array = [TheEmpress, LuckySeven, SonicTheEdgehog, Newspaper, Blender, LittleFriends];
			if (_levels == null) {
				_levels = new ContinuousShuffledArray(levelClasses.length * 2);
				for each (var clazz:Class in levelClasses) {
					for each (var scenario:int in [0, 1, 2, 3, 4]) {
						_levels.push([clazz, scenario]);
					}
				}
				_levels.reset();
			}			
			return _levels;
		}
	}
}