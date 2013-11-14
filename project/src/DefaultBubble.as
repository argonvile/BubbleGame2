package  
{
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import org.flixel.*;
	import flash.display.BitmapData;

	public class DefaultBubble extends Bubble
	{
		public var bubbleColor:uint;
		protected var regularGraphic:BitmapData;
		protected var popGraphic:BitmapData;
		
		public function DefaultBubble() 
		{
			var key:String = "popped Microbe0";
			if (BitmapDataCache.getBitmap(key) == null) {
				var newData:BitmapData = FlxG.createBitmap(85, 17, 0x00000000, true);
				var matrix:Matrix = new Matrix();
				matrix.scale(17 / 50, 17 / 50);
				newData.draw(FlxG.addBitmap(Embed.Microbe0), matrix);
				BubbleColorUtils.shiftHueBitmapData(newData, 0xffffffff);
				matrix.identity();
				var eyeData:BitmapData = FlxG.addBitmap(Embed.Eyes0);
				for (var i:int = 0; i < 5;i++) {
					newData.draw(eyeData, matrix);
					matrix.translate(17, 0);
				}
				BitmapDataCache.setBitmap(key, newData);
			}
			popGraphic = BitmapDataCache.getBitmap(key);
			
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
		
		public static function loadBubbleGraphic(bubbleColor:uint):BitmapData {
			var key:String = "Microbe0 " + bubbleColor.toString(16);
			if (BitmapDataCache.getBitmap(key) == null) {
				var newData:BitmapData = FlxG.createBitmap(85, 17, 0x00000000, true);
				var matrix:Matrix = new Matrix();
				matrix.scale(17 / 50, 17 / 50);
				newData.draw(FlxG.addBitmap(Embed.Microbe0), matrix);
				BubbleColorUtils.shiftHueBitmapData(newData, bubbleColor);
				matrix.identity();
				var eyeData:BitmapData = FlxG.addBitmap(Embed.Eyes0);
				for (var i:int = 0; i < 5;i++) {
					newData.draw(eyeData, matrix);
					matrix.translate(17, 0);
				}
				BitmapDataCache.setBitmap(key, newData);
			}
			return BitmapDataCache.getBitmap(key);
		}
		
		public function setBubbleColor(bubbleColor:uint):void {
			this.bubbleColor = bubbleColor;
			regularGraphic = loadBubbleGraphic(bubbleColor);
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
				var heldDefaultBubble:DefaultBubble = heldBubble as DefaultBubble;
				if (heldDefaultBubble == null) {
					return false;
				}
				if (bubbleColor != heldDefaultBubble.bubbleColor) {
					return false;
				}
			}
			return super.isGrabbable(heldBubbles, firstGrab);
		}
	}
}