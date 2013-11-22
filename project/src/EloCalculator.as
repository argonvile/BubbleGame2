package  
{
	public class EloCalculator 
	{
		private static var STANDARD_DEVIATION:Number = 40;
		private var elo:Number;
		
		public function EloCalculator(elo:Number) {
			this.elo = elo;
		}
		
		public function winElo(difficulty:Number):Number {
			return elo + kValue() * (1 - expectedResult(difficulty));
		}
		
		private function kValue():Number {
            if (elo < 125) {
                return 24;
            } else if (elo < 250) {
                return 18;
            } else {
                return 12;
            }
		}
		
        private function expectedResult(difficulty:Number):Number {
            var stdDevDiff:Number = (elo - difficulty) / STANDARD_DEVIATION;
            return cndf(stdDevDiff);
        }
		
		public function loseElo(difficulty:Number):Number {
            return elo + kValue() * (0 - expectedResult(difficulty));
		}
		
		private static function cndf(x:Number):Number {
            var k:Number = 1 / (1 + 0.2316419 * Math.abs(x));
            var d:Number = 1.330274429 * k - 1.821255978;
            d = d * k + 1.781477937;
            d = d * k - 0.356563782;
            d = d * k + 0.319381530;
            d = d * k;
            d = 0.398942280401 * Math.exp(-0.5 * x * x) * d;
            return x < 0 ? d : 1 - d;
		}
	}
}