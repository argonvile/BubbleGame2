package  
{
	import org.flixel.*;
	import flash.utils.getTimer;

	public class Embed 
	{
		[Embed(source = "../graphics/eyes0.png")] public static var Eyes0:Class;
		[Embed(source = "../graphics/guts-bg.png")] public static var GutsBg:Class;
		[Embed(source = "../graphics/guts-edge.png")] public static var GutsEdge:Class;
		[Embed(source = "../graphics/guts-fg.png")] public static var GutsFg:Class;
		[Embed(source = "../graphics/microbe0.png")] public static var Microbe0:Class;
		[Embed(source = "../graphics/microbe0-s.png")] public static var Microbe0S:Class;
		[Embed(source = "../graphics/microbe0-sw.png")] public static var Microbe0Sw:Class;
		[Embed(source = "../graphics/microbe0-se.png")] public static var Microbe0Se:Class;

		[Embed(source = "../sound/blip0.mp3")] public static var SfxBlip0:Class;
		
		private static var sounds:Object = new Object();
		private static var soundStartTimes:Array = new Array();

		public static function play(EmbeddedSound:Class, volume:Number = 1.0, singular:Boolean = false, restartTime:int = 25):void {
			var sound:FlxSound;
			if (sounds[EmbeddedSound] == null) {
				sound = new FlxSound();
				sounds[EmbeddedSound] = sound;
				soundStartTimes[EmbeddedSound] = int.MIN_VALUE;
				sound.loadEmbedded(EmbeddedSound, false, false);
			} else {
				sound = sounds[EmbeddedSound];
			}
			if (getTimer() - soundStartTimes[EmbeddedSound] <= 25) {
				return;
			}
			if (singular) {
				sound.stop();
			} else {
				sound.autoDestroy = true;
				sound = new FlxSound();
				sounds[EmbeddedSound] = sound;
				sound.loadEmbedded(EmbeddedSound, false, false);
			}
			sound.volume = volume;
			sound.play(true);
			soundStartTimes[EmbeddedSound] = getTimer();
		}		
	}
}