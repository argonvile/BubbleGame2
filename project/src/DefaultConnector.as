package  
{
	import flash.utils.getQualifiedClassName;
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.FlxColor;
	import flash.geom.Matrix;
	import flash.display.BitmapData;

	public class DefaultConnector extends Connector
	{
		protected var regularGraphic:BitmapData;
		protected var popGraphic:BitmapData;
		
		public function DefaultConnector()
		{
			super();
		}
		
		public static function loadConnectorGraphic(bubbleColor:uint, graphic:Class):BitmapData {
			var key:String = "connector " + getQualifiedClassName(graphic) + " " + bubbleColor.toString(16);
			if (BitmapDataCache.getBitmap(key) == null) {
				var newData:BitmapData = FlxG.createBitmap(51, 17, 0x00000000, true);
				newData.draw(FlxG.addBitmap(graphic), new Matrix(17 / 50, 0, 0, 17 / 50, 0, 0));
				BubbleColorUtils.shiftHueBitmapData(newData, bubbleColor);
				BitmapDataCache.setBitmap(key, newData);
			}
			return BitmapDataCache.getBitmap(key);
		}
		
		override public function init(bubble0:Bubble, bubble1:Bubble, graphic:Class):void {
			super.init(bubble0, bubble1, graphic);
			x = (bubble0.x + bubble1.x) / 2;
			y = (bubble0.y + bubble1.y) / 2;
			var bubbleColor:int = bubble0["bubbleColor"];
			regularGraphic = loadConnectorGraphic(bubbleColor, graphic);
			var key:String = "popped connector " + getQualifiedClassName(graphic);
			var targetColor:uint = 0xffffffff;
			var targetHsv:Object = FlxColor.RGBtoHSV(bubbleColor);
			if (targetHsv.saturation == 0 && targetHsv.value >= 0.50) {
				key = "dark" + key;
				targetColor = 0xff444444;
			}
			if (BitmapDataCache.getBitmap(key) == null) {
				var newData:BitmapData = FlxG.createBitmap(51, 17, 0x00000000, true);
				newData.draw(FlxG.addBitmap(graphic), new Matrix(17 / 50, 0, 0, 17 / 50, 0, 0));
				BubbleColorUtils.shiftHueBitmapData(newData, targetColor);
				BitmapDataCache.setBitmap(key, newData);
			}
			popGraphic = BitmapDataCache.getBitmap(key);
			
			_pixels = regularGraphic;
			width = frameWidth = 17;
			height = frameHeight = 17;
			resetHelpers();
			addAnimation("default", [0, 1, 2], 4, true);
			play("default");
			_curFrame = Math.random() * 3;
		}

		override public function update():void {
			super.update();
		}
		
		public function loadPopGraphic():void {
			_pixels = popGraphic;
			dirty = true;
		}
		
		public function loadRegularGraphic():void {
			_pixels = regularGraphic;
			dirty = true;
		}
		
		public function isPopGraphic():Boolean {
			return _pixels == popGraphic;
		}
		
		public function isRegularGraphic():Boolean {
			return _pixels == regularGraphic;
		}
	}
}