package  
{
	public class RankedPicker 
	{
		private var _levels:ContinuousShuffledArray;
		private var _levelArrangements:ContinuousShuffledArray;
		private var _picked:Array;
		private static var instance:RankedPicker;
		
		public function RankedPicker() 
		{
			_levels = new ContinuousShuffledArray(PlayerData.levelClasses.length * 2);
			for each (var clazz:Class in PlayerData.levelClasses) {
				for each (var scenario:int in [0, 1, 2, 3, 4]) {
					var levelSummary:LevelSummary = new LevelSummary();
					levelSummary.levelClass = clazz;
					levelSummary.scenario = scenario;
					_levels.push(levelSummary);
				}
			}
			_levels.reset();
			
			_levelArrangements = new ContinuousShuffledArray(3);
			// 6-level arrangements
			_levelArrangements.push(new Arrangement(16, 0, 6, 0, 0));
			_levelArrangements.push(new Arrangement(32, 0, 6, 0, 0));
			_levelArrangements.push(new Arrangement(28, 1, 5, 0, 0));
			_levelArrangements.push(new Arrangement(28, 0, 5, 1, 0));
			_levelArrangements.push(new Arrangement(28, 0, 5, 0, 1));
			_levelArrangements.push(new Arrangement(24, 2, 4, 0, 0));
			_levelArrangements.push(new Arrangement(24, 0, 4, 2, 0));
			_levelArrangements.push(new Arrangement(24, 0, 4, 0, 2));
			_levelArrangements.push(new Arrangement(20, 3, 3, 0, 0));
			_levelArrangements.push(new Arrangement(20, 0, 3, 3, 0));
			_levelArrangements.push(new Arrangement(20, 0, 3, 0, 3));
			
			// 5-level arrangements
			_levelArrangements.push(new Arrangement(14, 0, 5, 0, 0));
			_levelArrangements.push(new Arrangement(28, 0, 5, 0, 0));
			_levelArrangements.push(new Arrangement(24, 0, 4, 0, 1));
			_levelArrangements.push(new Arrangement(20, 2, 3, 0, 0));
			_levelArrangements.push(new Arrangement(20, 0, 3, 2, 0));
			_levelArrangements.push(new Arrangement(20, 0, 3, 0, 2));
			
			// 4-level arrangements
			_levelArrangements.push(new Arrangement(12, 0, 4, 0, 0));
			_levelArrangements.push(new Arrangement(24, 0, 4, 0, 0));
			_levelArrangements.push(new Arrangement(20, 1, 3, 0, 0));
			_levelArrangements.push(new Arrangement(20, 0, 3, 1, 0));
			_levelArrangements.push(new Arrangement(20, 0, 3, 0, 1));
			
			// 3-level arrangements
			_levelArrangements.push(new Arrangement(10, 0, 3, 0, 0));
			_levelArrangements.push(new Arrangement(20, 0, 3, 0, 0));
			_levelArrangements.push(new Arrangement(20, 0, 0, 3, 0));
			
			_levelArrangements.reset();
		}
		
		private function _pick():Array {
			if (_picked != null) {
				return _picked;
			}
			_picked = new Array();
			var arrangement:Arrangement = _levelArrangements.next() as Arrangement;
			_pickSome(PlayerSave.getElo() / 1.3, arrangement.easy, arrangement.outOf);
			_pickSome(PlayerSave.getElo(), arrangement.normal, arrangement.outOf);
			_pickSome(PlayerSave.getElo() * 1.3, arrangement.hard, arrangement.outOf);
			_pickSome(PlayerSave.getElo(), arrangement.arbitrary, arrangement.arbitrary);
            _picked.sort(orderByDifficulty);
			var desc:String = "Picked: ";
			if (arrangement.easy > 0) desc += arrangement.easy + " easy, " ;
			if (arrangement.normal > 0) desc += arrangement.normal + " normal, " ;
			if (arrangement.hard > 0) desc += arrangement.hard + " hard, " ;
			if (arrangement.arbitrary > 0) desc += arrangement.arbitrary + " arbitrary, " ;
			desc += "out of " + arrangement.outOf;
			trace(desc);
			return _picked;
		}
		
		private function _pickSome(target:Number, pickCount:int, outOf:int):void {
			if (pickCount == 0) {
				return;
			}
			var array:Array = new Array();
			for (var j:int = 0; j < outOf; j++) {
				array.push(_levels.next());
			}
			array.sort(orderByDifficulty);
			var string:String = "";
			for (var j:int = 0; j < outOf; j++) {
				string += (array[j] as LevelSummary).getScenarioBpm() + " ";
			}
			trace(string);
			var minK:int = 0;
			var minDiff:Number = Number.MAX_VALUE;
			for (var k:int = 0; k + pickCount <= array.length; k++) {
				var diff:Number = pickCount * target;
				for (var j:int = k; j < k + pickCount; j++) {
					var levelSummary:LevelSummary = array[j];
					diff -= levelSummary.getScenarioBpm();
				}
				diff = Math.abs(diff);
				if (diff <= minDiff) {
					minDiff = diff;
					minK = k;
				} else {
					break;
				}
			}
			for (var j:int = minK; j < minK + pickCount; j++) {
				_picked.push(array[j]);
				trace("picked " + (array[j] as LevelSummary).getScenarioBpm());
			}
		}
		
		public static function pick():Array {
			if (instance == null) {
				instance = new RankedPicker();
			}
			return instance._pick();
		}
		
		public static function finishedPicking():void {
			if (instance == null) {
				instance = new RankedPicker();
			}
			instance._picked = null;
		}
		
		private static function orderByDifficulty(o0:LevelSummary, o1:LevelSummary):int {
			return o0.getScenarioBpm() - o1.getScenarioBpm();
		}
	}
}

internal class Arrangement {
	public var outOf:int;
	public var easy:int;
	public var normal:int;
	public var hard:int;
	public var arbitrary:int;
	
	public function Arrangement(outOf:int, easy:int, normal:int, hard:int, arbitrary:int) {
		this.outOf = outOf;
		this.easy = easy;
		this.normal = normal;
		this.hard = hard;
		this.arbitrary = arbitrary;
	}
}