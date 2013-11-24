package  
{
	import org.flixel.*;
	
	public class MiscDialog extends FlxSprite
	{
		public function MiscDialog(x:Number=0, y:Number=0, width:Number=100,height:Number=100) 
		{
			super(x, y);
			makeGraphic(width, height, 0xff3665a3, true);
			emboss(this, 0, 0, width, height);
			emboss(this, 4, 4, width - 8, height - 8, true);
		}

		public static function emboss(target:FlxSprite, x:Number, y:Number, width:Number, height:Number, reverse:Boolean = false):void {
			var topColor:uint = 0x18ffffff;
			var botColor:uint = 0x40000000;
			if (reverse) {
				var temp:uint = topColor;
				topColor = botColor;
				botColor = temp;
			}
			target.drawLine(x, y, x + width, y, topColor);
			target.drawLine(x, y + 1, x, y + height, topColor);
			target.drawLine(x + width - 1, y + 1, x + width - 1, y + height, botColor);
			target.drawLine(x + 1, y + height - 1, x + width - 1, y + height - 1, botColor);
		}
	}
}