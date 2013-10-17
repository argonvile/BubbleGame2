package  
{
	import org.flixel.*;
	import flash.utils.getDefinitionByName;
	import flash.utils.getTimer;

	public class Embed 
	{
		[Embed(source = "../graphics/eyes0.png")] public static var Eyes0:Class;
		[Embed(source = "../graphics/guts-bg.png")] public static var GutsBg:Class;
		[Embed(source = "../graphics/guts-edge.png")] public static var GutsEdge:Class;
		[Embed(source = "../graphics/guts-fg.png")] public static var GutsFg:Class;
		[Embed(source = "../graphics/little-friends.png")] public static var LittleFriends:Class;
		[Embed(source = "../graphics/microbe0.png")] public static var Microbe0:Class;
		[Embed(source = "../graphics/microbe0-s.png")] public static var Microbe0S:Class;
		[Embed(source = "../graphics/microbe0-sw.png")] public static var Microbe0Sw:Class;
		[Embed(source = "../graphics/microbe0-se.png")] public static var Microbe0Se:Class;

		[Embed(source = "../sound/blipa0.mp3")] public static var SfxBlipA0:Class;
		[Embed(source = "../sound/blipa1.mp3")] public static var SfxBlipA1:Class;
		[Embed(source = "../sound/blipa2.mp3")] public static var SfxBlipA2:Class;
		[Embed(source = "../sound/blipa3.mp3")] public static var SfxBlipA3:Class;
		[Embed(source = "../sound/blipa4.mp3")] public static var SfxBlipA4:Class;
		[Embed(source = "../sound/blipa5.mp3")] public static var SfxBlipA5:Class;
		[Embed(source = "../sound/blipa6.mp3")] public static var SfxBlipA6:Class;
		[Embed(source = "../sound/blipa7.mp3")] public static var SfxBlipA7:Class;
		[Embed(source = "../sound/blipa8.mp3")] public static var SfxBlipA8:Class;
		[Embed(source = "../sound/blipa9.mp3")] public static var SfxBlipA9:Class;
		
		private static var sounds:Object = new Object();
		private static var soundStartTimes:Array = new Array();

		public static function play(EmbeddedSound:Class, volume:Number = 1.0, singular:Boolean = false, restartTime:int = 25, playbackSpeed:Number = 1.0):void {
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
		
		public static function playPopSound(poppedBubbleCount:Number):void {
			var tempBubbleNum:Number = Math.pow(poppedBubbleCount, 0.5);
			if (tempBubbleNum < 10) {
				var sfx:Class = getDefinitionByName("Embed_SfxBlipA" + int(tempBubbleNum)) as Class;
				play(sfx);
				return;
			}
			play(SfxBlipA9);
			return;
		}
	}
}