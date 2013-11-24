package  
{
	import org.flixel.FlxParticle;

	public class FadeParticle extends FlxParticle
	{
		private var initialLifespan:Number = 0;
		
		public function setLifespan(lifespan:Number):void {
			this.lifespan = lifespan;
			this.initialLifespan = lifespan;
		}
		
		override public function update():void {
			super.update();
			alpha = lifespan / initialLifespan;
		}
	}

}