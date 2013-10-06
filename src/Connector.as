package  
{
	import flash.utils.getQualifiedClassName;
	import org.flixel.*;
	import flash.geom.Matrix;
	import flash.display.BitmapData;

	public class Connector extends FlxSprite
	{
		public var lifespan:Number = -1;
		public var bubble0:Bubble;
		public var bubble1:Bubble;
		/**
		 * state
		 * 0 = normal
		 * 300 = popping
		 */
		public var state:int = 0;
		private var stateTime:Number = 0;
		private var regularGraphic:BitmapData;
		private var popGraphic:BitmapData;
		
		public function Connector(bubble0:Bubble=null, bubble1:Bubble=null)
		{
			this.bubble0 = bubble0;
			this.bubble1 = bubble1;
		}
		
		public function init(bubble0:Bubble, bubble1:Bubble, graphic:Class):void {
			this.bubble0 = bubble0;
			this.bubble1 = bubble1;
			x = (bubble0.x + bubble1.x) / 2;
			y = (bubble0.y + bubble1.y) / 2;
			var key:String = "connector " + getQualifiedClassName(graphic) + " " + bubble0.bubbleColor.toString(16);
			if (BitmapDataCache.getBitmap(key) == null) {
				var newData:BitmapData = FlxG.createBitmap(17, 17, 0x00000000, true);
				newData.draw(FlxG.addBitmap(graphic), new Matrix(17 / 50, 0, 0, 17 / 50, 0, 0));
				Bubble.shiftHueBitmapData(newData, bubble0.bubbleColor);
				BitmapDataCache.setBitmap(key, newData);
			}
			regularGraphic = BitmapDataCache.getBitmap(key);
			
			var key:String = "popped connector " + getQualifiedClassName(graphic);
			if (BitmapDataCache.getBitmap(key) == null) {
				var newData:BitmapData = FlxG.createBitmap(17, 17, 0x00000000, true);
				newData.draw(regularGraphic);
				Bubble.whitenBitmapData(newData);
				BitmapDataCache.setBitmap(key, newData);
			}
			popGraphic = BitmapDataCache.getBitmap(key);
			
			pixels = regularGraphic;
		}

		override public function update():void {
			super.update();
			stateTime += FlxG.elapsed;
			if(lifespan <= 0) {
				return;
			}
			var popAnimState:int = (stateTime * 8) / lifespan;
			if (popAnimState == 0 || popAnimState == 2) {
				pixels = popGraphic;
			} else {
				pixels = regularGraphic;
			}
		}
		
		public function wasPopped(lifespan:Number):void {
			this.lifespan = lifespan;
			state = 300;
			stateTime = 0;
		}		
	}
}