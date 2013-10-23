package levels 
{
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.FlxColor;
	
	public class FogLayer extends FlxGroup
	{
		private var mainSprite:FlxSprite;
		private var elapsed:Number = 0;
		public var conicalNess:Number = 1.0;
		public var x0:Number = 8 + PlayState.columnWidth;
		public var x1:Number = 8 + PlayState.columnWidth * 2;
		public var x2:Number = 8 + PlayState.columnWidth * 3;
		public var x3:Number = 8 + PlayState.columnWidth * 4;
		
		public function FogLayer() 
		{
			mainSprite = new FlxSprite();
			mainSprite.makeGraphic(FlxG.width, FlxG.height, 0x00000000);
			add(mainSprite);
		}
		
		override public function update():void {
			super.update();
			elapsed += FlxG.elapsed;
			mainSprite.fill(0x00000000);
			var heightFactor:Number;
			var left:Number;
			var right:Number;
			var color:uint;
			var alpha:uint;
			for (var y:int = 0; y < FlxG.height; y += 2) {
				heightFactor = (FlxG.height - y) / FlxG.height;
				left = x1 - (x1 - x0) * (0.25 + heightFactor * 0.25 * conicalNess) * (Math.sin(y / 8.80 + 6.666 * elapsed) + Math.sin(y / 3.20 + 8.411 * elapsed) + 2) - heightFactor * PlayState.columnWidth * 0.5 * conicalNess;
				right = x2 + (x3 - x2) * (0.25 + heightFactor * 0.25 * conicalNess) * (Math.sin(y / 8.30 + 8.466 * elapsed) + Math.sin(y / 2.70 + 6.211 * elapsed) + 2) + heightFactor * PlayState.columnWidth * 0.5 * conicalNess;
				alpha = Math.min(255, (FlxG.height - y) * 4);
				color = FlxColor.getColor32(alpha, 240, 240, 240);
				mainSprite.drawLine(left, y, right, y, color, 1);
			}
			for (var y:int = 1; y < FlxG.height;y+=2) {
				heightFactor = (FlxG.height - y) / FlxG.height;
				left = x1 - PlayState.columnWidth * (0.125 + heightFactor * 0.125 * conicalNess) * (Math.sin(y / 3.72 + 6.620 * elapsed) + Math.sin(y / 4.87 + 8.420 * elapsed) + 2) - heightFactor * PlayState.columnWidth * 0.5 * conicalNess;
				right = x2 + PlayState.columnWidth * (0.125 + heightFactor * 0.125 * conicalNess) * (Math.sin(y / 3.22 + 8.420 * elapsed) + Math.sin(y / 4.37 + 6.220 * elapsed) + 2) + heightFactor * PlayState.columnWidth * 0.5 * conicalNess;
				alpha = Math.min(255, (FlxG.height - y) * 6);
				color = FlxColor.getColor32(alpha, 220, 220, 220);
				mainSprite.drawLine(left, y, right, y, color, 1);
			}
			mainSprite.dirty = true;
		}
	}
}