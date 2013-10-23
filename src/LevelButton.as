package  
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.ui.Mouse;
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.FlxButtonPlus;

	public class LevelButton extends FlxButtonPlus
	{
		public function LevelButton(x:int,y:int,clazz:Class,scenario:int,callback:Function,params:Array) 
		{
			super(x, y, callback, params);
			width = 90;
			height = 80;
			var buttonNormal:FlxSprite = new FlxSprite(x, y);
			buttonNormal.makeGraphic(width, height, 0xffbb4444, true);
			var bitmapData:BitmapData = FlxG.addBitmap(Embed.Screenshot90x44);
			var matrix:Matrix = new Matrix();
			matrix.translate(0, 12);
			buttonNormal.pixels.draw(bitmapData, matrix);
			var text:FlxText;
			var romanNumerals:Array = ["I", "II", "III", "IV", "V"];
			text = new FlxText(0, 0, width, clazz["name"] + " " + romanNumerals[scenario]);
			buttonNormal.pixels.draw(text.pixels);
			var scenarioBpm:Number = clazz["scenarioBpms"][scenario];
			text = new FlxText(0, 0, width, "Level: " + PlayerData.getDifficultyString(scenarioBpm));
			matrix.identity();
			matrix.translate(0, 56);
			buttonNormal.pixels.draw(text.pixels, matrix);
			buttonNormal.drawLine(0, 0, width, 0, 0x18ffffff);
			buttonNormal.drawLine(0, 1, 0, height, 0x18ffffff);
			buttonNormal.drawLine(width-1, 1, width-1, height, 0x18000000);
			buttonNormal.drawLine(1, height - 1, width - 1, height - 1, 0x18000000);
			add(buttonNormal);
			loadGraphic(buttonNormal, buttonNormal);
		}
	}
}