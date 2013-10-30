package  
{
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import org.flixel.*;

	public class EkgGraphic extends FlxGroup
	{
		private var text:FlxText;
		private var sprites:Array = new Array();
		private var swipe:Number = 5;
		private var x:Number;
		private var y:Number;
		private var lineSprite:FlxSprite = new FlxSprite();
		private var seconds:int = -1;
		private var elapsed:Number = 0;
		
		public function EkgGraphic(x:Number,y:Number,seconds:Number) 
		{
			this.x = x;
			this.y = y;
			var ekgSprite:FlxSprite = new FlxSprite(x, y, Embed.Ekg);
			ekgSprite.scale.x = ekgSprite.scale.y = 0.4;
			ekgSprite.centerOffsets();
			ekgSprite.setOriginToCorner();
			add(ekgSprite);
			
			text = new FlxText(0, 0, 14);
			text.setFormat("digital", 23, 0xff88ffff, "right");
			for (var i:int = 0; i < 44;i+=2) {
				var sprite:FlxSprite;
				sprite = new FlxSprite(x + 6 + i, y + 3);
				sprite.makeGraphic(2, 23, 0x00000000, true);
				sprite.alpha = 0.25;
				add(sprite);
				sprites.push(sprite);
			}
			setSeconds(seconds);
			lineSprite = new FlxSprite(x + 7, y + 16);
			lineSprite.makeGraphic(2, 1, 0xccccffff);
			add(lineSprite);
		}
		
		public function setSeconds(seconds:Number):void {
			if (Math.floor(seconds) == this.seconds) {
				return;
			}
			this.seconds = Math.floor(seconds);
			var matrix:Matrix = new Matrix();
			var remaining:int = Math.min(599, Math.abs(seconds));
			text.text = String(Math.floor(remaining / 60));
			remaining %= 60;
			for each (var sprite:FlxSprite in sprites) {
				sprite.fill(0x00000000);
				sprite.pixels.draw(text.pixels, matrix);
				matrix.translate( -2, 0);
			}
			text.text = ":";
			matrix.identity();
			matrix.translate( 7, -1);
			for each (var sprite:FlxSprite in sprites) {
				sprite.pixels.draw(text.pixels, matrix);
				matrix.translate( -2, 0);
			}
			text.text = String(Math.floor(remaining / 10));
			remaining %= 10;
			matrix.identity();
			matrix.translate( 16, 0);
			for each (var sprite:FlxSprite in sprites) {
				sprite.pixels.draw(text.pixels, matrix);
				matrix.translate( -2, 0);
			}
			text.text = String(Math.floor(remaining));
			matrix.identity();
			matrix.translate( 29, 0);
			for each (var sprite:FlxSprite in sprites) {
				sprite.pixels.draw(text.pixels, matrix);
				sprite.dirty = true;
				matrix.translate( -2, 0);
			}			
		}
		
		override public function update():void {
			super.update();
			elapsed += FlxG.elapsed;
			for each (var sprite:FlxSprite in sprites) {
				if (Math.round((sprite.x - x - 6)/ 4) == Math.round(swipe / 4)) {
					sprite.alpha = 1.0;
				} else {
					sprite.alpha = Math.max(0.25, sprite.alpha - FlxG.elapsed);
				}
			}
			swipe += FlxG.elapsed * 44 * 2;
			lineSprite.x = swipe + x + 9;
			if (swipe < -3 || swipe > 42) {
				lineSprite.visible = false;
			} else {
				lineSprite.visible = true;
			}
			if (Math.floor(elapsed + 0.306) != Math.floor(elapsed + 0.306 - FlxG.elapsed)) {
				lineSprite.y = Math.floor(Math.random() * 3) + y + 15;
				swipe = -22;
			}
		}
	}

}