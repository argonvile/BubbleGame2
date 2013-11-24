package  
{
	import org.flixel.*;
	
	public class LagFreeFlxSound extends FlxSound
	{
		private var offset:int;
		
		override public function play(ForceRestart:Boolean=false):void
		{
			_position = offset;
			super.play(ForceRestart);
		}
		
		public static function play(EmbeddedSound:Class, volume:Number=1, offset:int=0, looped:Boolean=false):LagFreeFlxSound {
			var loop:LagFreeFlxSound = FlxG.sounds.recycle(LagFreeFlxSound) as LagFreeFlxSound;
			loop.offset = offset;
			loop.loadEmbedded(EmbeddedSound, looped, true);
			loop.volume = volume;
			loop.play(false);
			return loop;
		}
	}
}