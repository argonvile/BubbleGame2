package  
{
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.FlxColor;
	import flash.display.BitmapData;

	public class ThermometerGraphic extends FlxGroup
	{
		private var x:Number;
		private var y:Number;
		private var mercurySprite:FlxSprite;
		private var playState:PlayState;
		private var midPoint:Number = 0;
		private var thermometerBubble:FlxSprite;
		private var bubbleText:FlxText;
		private var hundredths:Boolean = false;
		private var maxSpeed:Number = 100;
		
		private var lastChange:Number = 1000;
		private var eliminatedBubbleCount:Number = 0;
		
		public function ThermometerGraphic(x:Number,y:Number,playState:PlayState)
		{
			this.x = x;
			this.y = y;
			this.playState = playState;
			mercurySprite = new FlxSprite(x + 2, y + 2);
			mercurySprite.makeGraphic(8, 300, 0xff404444);
			add(mercurySprite);

			var thermometerSprite:FlxSprite = new FlxSprite(x, y, Embed.Thermometer);
			thermometerSprite.scale.x = thermometerSprite.scale.y = 0.4;
			thermometerSprite.setOriginToCorner();
			add(thermometerSprite);
			
			thermometerBubble = new FlxSprite(x + 12, y, Embed.ThermometerBubble);
			thermometerBubble.scale.x = thermometerBubble.scale.y = 0.7;
			thermometerBubble.setOriginToCorner();
			thermometerBubble.visible = false;
			add(thermometerBubble);
			
			bubbleText = new FlxText(x+15, 0, 50);
			bubbleText.setFormat("handwriting", 15, 0xff88ffff, "center");
			bubbleText.color = 0xff000000;
			bubbleText.angle = 18;
			bubbleText.visible = false;
			add(bubbleText);
			
			if (playState.levelDetails.levelQuota >= 801) {
				midPoint = playState.levelDetails.levelQuota - 400;
				hundredths = true;
			} else if (playState.levelDetails.levelQuota >= 401) {
				midPoint = playState.levelDetails.levelQuota - 200;
				hundredths = true;
			} else if (playState.levelDetails.levelQuota >= 101) {
				midPoint = playState.levelDetails.levelQuota - 50;
				hundredths = false;
			} else if (playState.levelDetails.levelQuota >= 41) {
				midPoint = playState.levelDetails.levelQuota - 20;
				hundredths = false;
			} else {
				midPoint = playState.levelDetails.levelQuota / 2;
			}
		}
		
		override public function update():void {
			super.update();
			
			if (playState.eliminatedBubbleCount != eliminatedBubbleCount) {
				eliminatedBubbleCount = playState.eliminatedBubbleCount;
				lastChange = 0;
			} else {
				lastChange += FlxG.elapsed;
			}
			
			var colorPct:Number = 1.5 - lastChange / playState.levelDetails.popPerBubbleDelay;
			colorPct = Math.max(0, Math.min(1, colorPct));
			
			mercurySprite.fill(FlxColor.getColor32(255, 128 + 90 * colorPct, 132 + 90 * colorPct, 132 + 90 * colorPct));
			var thermometerPct:Number;
			if (playState.eliminatedBubbleCount < midPoint) {
				thermometerPct = playState.eliminatedBubbleCount / (2 * midPoint);
			} else {
				thermometerBubble.visible = true;
				bubbleText.visible = true;
				thermometerPct = 0.5 + (playState.eliminatedBubbleCount - midPoint) / (2 * (playState.levelDetails.levelQuota - midPoint));
			}
			thermometerPct = Math.max(0, Math.min(1, thermometerPct));
			mercurySprite.y = y + 2 + (148 - 148 * thermometerPct);
			mercurySprite.y = mercurySprite.y + 1.5 - 1.5 * colorPct;
			var targetY:Number = Math.max(y + 12, mercurySprite.y) - 46;
			if (thermometerBubble.y - targetY > (maxSpeed * FlxG.elapsed)) {
				thermometerBubble.y -= (maxSpeed * FlxG.elapsed);
			} else {
				thermometerBubble.y = targetY;
			}
			bubbleText.y = thermometerBubble.y + 8;
			var number:Number = 36 + thermometerPct * 4;
			if (hundredths) {
				bubbleText.text = number.toFixed(2);
			} else {
				bubbleText.text = number.toFixed(1);
			}
		}
	}
}