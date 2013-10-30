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
			}
		}
	}
}