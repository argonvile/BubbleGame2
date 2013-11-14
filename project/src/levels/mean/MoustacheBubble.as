package levels.mean 
{
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.FlxColor;
	import flash.display.BitmapData;

	public class MoustacheBubble extends Bubble
	{
		public var bubbleColor:uint;
		protected var regularGraphic:BitmapData;
		protected var popGraphic:BitmapData;
		
		public function MoustacheBubble() 
		{
			countsTowardsQuota = false;
			width = frameWidth = 17;
			height = frameHeight = 17;
			resetHelpers();
			updateAlpha();
			addAnimation("default", [0, 1, 2, 3, 4], 4, true);
			play("default");
			_curFrame = Math.random() * 5;
		}
		
		override public function init(levelDetails:LevelDetails, x:Number, y:Number):void {
			super.init(levelDetails, x, y);
			_pixels = regularGraphic;
		}
		
		private function loadBubbleGraphics(bubbleColor:uint):BitmapData {
			var key:String;
			key = "Popped Moustache Microbe0 " + bubbleColor.toString(16);
			if (BitmapDataCache.getBitmap(key) == null) {
				var newData:BitmapData = FlxG.createBitmap(85, 17, 0x00000000, true);
				var matrix:Matrix = new Matrix();
				matrix.scale(17 / 50, 17 / 50);
				newData.draw(FlxG.addBitmap(Embed.Microbe0), matrix);
				BubbleColorUtils.shiftHueBitmapData(newData, bubbleColor);
				matrix.identity();
				var eyeData:BitmapData = FlxG.addBitmap(Embed.Eyes0);
				var moustacheData:BitmapData = FlxG.addBitmap(Embed.Moustache1);
				BubbleColorUtils.shiftHueBitmapData(moustacheData, 0xffffffff);
				for (var i:int = 0; i < 5;i++) {
					newData.draw(eyeData, matrix);
					newData.draw(moustacheData, matrix);
					matrix.translate(17, 0);
				}
				BitmapDataCache.setBitmap(key, newData);
			}
			popGraphic = BitmapDataCache.getBitmap(key);
			key = "Moustache Microbe0 " + bubbleColor.toString(16);
			if (BitmapDataCache.getBitmap(key) == null) {
				var newData:BitmapData = FlxG.createBitmap(85, 17, 0x00000000, true);
				var matrix:Matrix = new Matrix();
				matrix.scale(17 / 50, 17 / 50);
				newData.draw(FlxG.addBitmap(Embed.Microbe0), matrix);
				BubbleColorUtils.shiftHueBitmapData(newData, bubbleColor);
				matrix.identity();
				var eyeData:BitmapData = FlxG.addBitmap(Embed.Eyes0);
				var moustacheData:BitmapData = FlxG.addBitmap(Embed.Moustache1, false, true);
				for (var i:int = 0; i < 5;i++) {
					newData.draw(eyeData, matrix);
					newData.draw(moustacheData, matrix);
					matrix.translate(17, 0);
				}
				BitmapDataCache.setBitmap(key, newData);
			}
			return BitmapDataCache.getBitmap(key);
		}
		
		public function setBubbleColor(bubbleColor:uint):void {
			this.bubbleColor = bubbleColor;
			regularGraphic = loadBubbleGraphics(bubbleColor);
			if (_pixels != popGraphic) {
				_pixels = regularGraphic;
			}
			dirty = true;
		}
		
		public function isPopGraphic():Boolean {
			return _pixels == popGraphic;
		}
		
		override public function loadPopGraphic():void {
			_pixels = popGraphic;
			dirty = true;
			for each (var connector:DefaultConnector in connectors) {
				if (connector != null && connector.alive) {
					connector.loadPopGraphic();
				}
			}
		}
		
		public function isRegularGraphic():Boolean {
			return _pixels == regularGraphic;
		}
		
		override public function loadRegularGraphic():void {
			_pixels = regularGraphic;
			dirty = true;
			for each (var connector:DefaultConnector in connectors) {
				if (connector != null && connector.alive) {
					connector.loadRegularGraphic();
				}
			}
		}
		
		override public function isGrabbable(heldBubbles:FlxGroup, firstGrab:Boolean):Boolean {
			var heldBubble:Bubble = heldBubbles.getFirstAlive() as Bubble;
			if (heldBubble != null) {
				var heldMoustacheBubble:MoustacheBubble = heldBubble as MoustacheBubble;
				if (heldMoustacheBubble == null) {
					return false;
				}
				if (bubbleColor != heldMoustacheBubble.bubbleColor) {
					return false;
				}
			}
			return super.isGrabbable(heldBubbles, firstGrab);
		}
	}
}