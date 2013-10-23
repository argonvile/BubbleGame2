package levels 
{
	import org.flixel.*;

	public class FogColumn extends LevelDetails
	{
		private var fogLayer:FogLayer;
		private var bottomWidth:Number;
		
		public function FogColumn(scenario:int) 
		{
			super(scenario);
		}
		
		override public function prepareLevel():void {
			super.prepareLevel();
			fogLayer = new FogLayer();
			playState.add(fogLayer);

			fogLayer.conicalNess = 4; // 0 = narrow, 4 = wide
			bottomWidth = 0.5; // 0 = narrow, 2 = 2 columns wide

			fogLayer.x0 = playState.playerSprite.x + PlayState.columnWidth * 0.5 - PlayState.columnWidth * bottomWidth;
			fogLayer.x1 = playState.playerSprite.x + PlayState.columnWidth * 0.5 - PlayState.columnWidth * bottomWidth / 2;
			fogLayer.x2 = playState.playerSprite.x + PlayState.columnWidth * 0.5 + PlayState.columnWidth * bottomWidth / 2;
			fogLayer.x3 = playState.playerSprite.x + PlayState.columnWidth * 0.5 + PlayState.columnWidth * bottomWidth;
		}
		
		override public function update(elapsed:Number):void {
			super.update(elapsed);
			var currentX:Number = fogLayer.x0;
			var targetX:Number = playState.playerSprite.x + PlayState.columnWidth * 0.5 - PlayState.columnWidth * bottomWidth;
			var movementFactor:Number = 0;
			if (targetX - currentX > 1) {
				movementFactor = Math.min(3, ((targetX - currentX) / PlayState.columnWidth)) * 1.5;
			} else if (targetX - currentX < -1) {
				movementFactor = Math.max(-3, ((targetX - currentX) / PlayState.columnWidth)) * 1.5;
			}
			fogLayer.x0 += FlxG.elapsed * PlayState.columnWidth * movementFactor;
			fogLayer.x1 += FlxG.elapsed * PlayState.columnWidth * movementFactor;
			fogLayer.x2 += FlxG.elapsed * PlayState.columnWidth * movementFactor;
			fogLayer.x3 += FlxG.elapsed * PlayState.columnWidth * movementFactor;
		}
	}
}