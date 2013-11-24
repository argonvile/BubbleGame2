package  
{
	import flash.geom.Rectangle;
	import org.flixel.*;

	public class ExperienceBar extends FlxSprite
	{
		private static const INITIAL_DELAY:Number = 0.60;
		private static const TIME_TO_FILL:Number = 1.4;
		
		private var elapsed:Number = 0;
		public var fromPct:Number = 0.0;
		public var toPct:Number = 0.0;
		private var rankUpSound:FlxSound;
		public var onRankUp:Function;
		
		public function ExperienceBar(x:Number = 0, y:Number = 0, width:Number = 100, height:Number = 8)
		{
			super(x, y);
			makeGraphic(width, height, 0x44ffffff, true);
		}
		
		override public function destroy():void {
			super.destroy();
			if (rankUpSound != null) {
				rankUpSound.stop();
			}
		}
		
		override public function update():void {
			super.update();
			elapsed += FlxG.elapsed;
			if (elapsed >= INITIAL_DELAY && elapsed - FlxG.elapsed < INITIAL_DELAY) {
				// play initial sound effect
				if (toPct >= fromPct) {
					if (fromPct < 0.33) {
						rankUpSound = Embed.play(Embed.SfxRankUp0);
					} else if (fromPct < 0.66) {
						rankUpSound = Embed.play(Embed.SfxRankUp1);
					} else {
						rankUpSound = Embed.play(Embed.SfxRankUp2);
					}
				} else {
					if (fromPct < 0.33) {
						rankUpSound = Embed.play(Embed.SfxRankDown2);
					} else if (fromPct < 0.66) {
						rankUpSound = Embed.play(Embed.SfxRankDown1);
					} else {
						rankUpSound = Embed.play(Embed.SfxRankDown0);
					}
				}
			}
			var animationPct:Number = Math.max(0, Math.min(1, (elapsed - INITIAL_DELAY) / (Math.abs(toPct - fromPct) * TIME_TO_FILL)));
			if (animationPct == 1 && rankUpSound != null) {
				// stop sound effect
				rankUpSound.stop();
				rankUpSound = null;
				if (toPct == 1.0) {
					LagFreeFlxSound.play(Embed.SfxNewRank, 1.0, 50);
					if (onRankUp != null) {
						onRankUp.apply(null);
					}
				}
			}
			var currentPct:Number = fromPct + (toPct - fromPct) * animationPct;
			
			fill(0x44ffffff);
			drawLine(0, 0, width, 0, 0xff000000);
			drawLine(0, 1, 0, height, 0xff000000);
			drawLine(width - 1, 1, width - 1, height, 0xff000000);
			drawLine(1, height - 1, width - 1, height - 1, 0xff000000);
			pixels.fillRect(new Rectangle(1, 1, currentPct * (width - 2), height - 2), 0xffffffff);
		}
	}
}