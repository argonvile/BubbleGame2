package  
{
	import flash.utils.getQualifiedClassName;
	import org.flixel.*;
	import flash.geom.Matrix;
	import flash.display.BitmapData;

	public class DefaultConnector extends Connector
	{
		public var defaultBubble0:DefaultBubble;
		public var defaultBubble1:DefaultBubble;
		private var regularGraphic:BitmapData;
		private var popGraphic:BitmapData;
		
		public function DefaultConnector(bubble0:DefaultBubble=null, bubble1:DefaultBubble=null)
		{
			super(bubble0, bubble1);
			this.defaultBubble0 = bubble0;
			this.defaultBubble0 = bubble1;
		}
		
		public function init(bubble0:DefaultBubble, bubble1:DefaultBubble, graphic:Class):void {
			this.defaultBubble0 = bubble0;
			this.defaultBubble1 = bubble1;
			x = (bubble0.x + bubble1.x) / 2;
			y = (bubble0.y + bubble1.y) / 2;
			var key:String = "connector " + getQualifiedClassName(graphic) + " " + bubble0.bubbleColor.toString(16);
			if (BitmapDataCache.getBitmap(key) == null) {
				var newData:BitmapData = FlxG.createBitmap(17, 17, 0x00000000, true);
				newData.draw(FlxG.addBitmap(graphic), new Matrix(17 / 50, 0, 0, 17 / 50, 0, 0));
				DefaultBubble.shiftHueBitmapData(newData, bubble0.bubbleColor);
				BitmapDataCache.setBitmap(key, newData);
			}
			regularGraphic = BitmapDataCache.getBitmap(key);
			
			var key:String = "popped connector " + getQualifiedClassName(graphic);
			if (BitmapDataCache.getBitmap(key) == null) {
				var newData:BitmapData = FlxG.createBitmap(17, 17, 0x00000000, true);
				newData.draw(FlxG.addBitmap(graphic), new Matrix(17 / 50, 0, 0, 17 / 50, 0, 0));
				DefaultBubble.whitenBitmapData(newData);
				BitmapDataCache.setBitmap(key, newData);
			}
			popGraphic = BitmapDataCache.getBitmap(key);
			
			pixels = regularGraphic;
		}

		override public function update():void {
			super.update();
		}
		
		public function loadPopGraphic():void {
			pixels = popGraphic;
		}
		
		public function loadRegularGraphic():void {
			pixels = regularGraphic;
		}
	}
}