package  
{
	import flash.display.BitmapData;

	public class BitmapDataCache 
	{
		private static var instance:Object = new Object();
		
		public function BitmapDataCache() 
		{
		}
		
		public static function getBitmap(key:String):BitmapData {
			return instance[key];
		}
		
		public static function setBitmap(key:String, data:BitmapData):void {
			instance[key] = data;
		}
	}
}