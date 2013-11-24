package  
{
	import org.flixel.FlxSave;
	public class PlayerSave 
	{
		public static var save:FlxSave;
		private static var loaded:Boolean = false;
		private static var repeatDelay:Number;
		private static var repeatRate:Number;
		private static var bubblesPerMinute:Number;
		private static var clearedNormalLevels:Object;
		private static var minElo:Number;
		private static var maxElo:Number;
		private static var elo:Number;
		
		public static function getMinElo():Number {
			return get("minElo") as Number;
		}
		
		public static function setMinElo(value:Number):void {
			set("minElo", value);
		}		
		
		public static function getMaxElo():Number {
			return get("maxElo") as Number;
		}
		
		public static function setMaxElo(value:Number):void {
			set("maxElo", value);
		}		
		
		public static function getElo():Number {
			return get("elo") as Number;
		}
		
		public static function setElo(value:Number):void {
			set("elo", value);
		}
		
		public static function getRepeatDelay():Number {
			return get("repeatDelay") as Number;
		}
		
		public static function setRepeatDelay(value:Number):void {
			set("repeatDelay", value);
		}
		
		public static function getRepeatRate():Number {
			return get("repeatRate") as Number;
		}
		
		public static function setRepeatRate(value:Number):void {
			set("repeatRate", value);
		}
				
		public static function getBubblesPerMinute():Number {
			return get("bubblesPerMinute") as Number;
		}
		
		public static function setBubblesPerMinute(value:Number):void {
			set("bubblesPerMinute", value);
		}
		
		private static function get(field:String):Object {
			if (loaded) {
				return save.data[field];
			} else {
				return PlayerSave[field];
			}
		}
		
		private static function set(field:String, value:Object):void {
			if (loaded) {
				save.data[field] = value;
			} else {
				PlayerSave[field] = value;
			}
		}
		
		public static function isClearedNormalLevel(scenarioClazz:Class, scenario:int):Boolean {
			var cnf:Object = get("clearedNormalLevels");
			return cnf[LevelButton.scenarioName(scenarioClazz, scenario)] == true;
		}
		
		public static function setClearedNormalLevel(scenarioClazz:Class, scenario:int):void {
			var cnf:Object = get("clearedNormalLevels");
			cnf[LevelButton.scenarioName(scenarioClazz, scenario)] = true;
			set("clearedNormalLevels", cnf);
		}
		
		public static function load():void {
			save = new FlxSave();
			loaded = save.bind("JurassicPopData");
			if (loaded) {
				if (save.data.repeatDelay == null) {
					save.data.repeatDelay = KeyboardOptions.REPEAT_DELAYS[2];
				}
				if (save.data.repeatRate == null) {
					save.data.repeatRate = KeyboardOptions.REPEAT_RATES[2];
				}
				if (save.data.bubblesPerMinute == null) {
					save.data.bubblesPerMinute = 150;
				}
				if (save.data.clearedNormalLevels == null) {
					save.data.clearedNormalLevels = new Object();
				}
				if (save.data.elo == null) {
					save.data.elo = 100;
				}
				if (save.data.minElo == null) {
					save.data.minElo = PlayerData.difficultyCutoffs[PlayerData.getDifficultyIndex(save.data.elo)];
				}
				if (save.data.maxElo == null) {
					save.data.maxElo = save.data.elo;
				}
			}
		}
	}
}