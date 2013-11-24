package  
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.ui.Mouse;
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.FlxButtonPlus;
	import org.flixel.plugin.photonstorm.FlxColor;

	public class LevelButton extends FlxButtonPlus
	{
		public function LevelButton(x:int,y:int,levelSummary:LevelSummary,callback:Function,params:Array) 
		{
			super(x, y, callback, params);
			var scenarioBpm:Number = levelSummary.getScenarioBpm();
			var difficultyIndex:int = PlayerData.getDifficultyIndex(scenarioBpm);
			width = 90;
			height = 80;
			var buttonNormal:FlxSprite = new FlxSprite(x, y);
			var hsv:Object = new Object();
			hsv.hue = Math.max(0, 120 - 120 * difficultyIndex / 11);
			hsv.saturation = 0.6;
			hsv.value = Math.max(0, Math.min(0.5, 0.5 * ((19 - difficultyIndex) / 8)));
			buttonNormal.makeGraphic(width, height, FlxColor.HSVtoRGB(hsv.hue, hsv.saturation, hsv.value), true);
			var bitmapData:BitmapData = FlxG.addBitmap(Embed.Screenshot90x44);
			var matrix:Matrix = new Matrix();
			matrix.translate(0, 12);
			buttonNormal.pixels.draw(bitmapData, matrix);
			var text:FlxText;
			text = new FlxText(0, 0, width, scenarioName(levelSummary.levelClass, levelSummary.scenario));
			buttonNormal.pixels.draw(text.pixels);
			// draw rating...
			matrix.identity();
			matrix.translate(width / 2 - 45, 68 - 12);
			var rankGraphic:RankGraphic = new RankGraphic(difficultyIndex);
			buttonNormal.pixels.draw(rankGraphic.pixels, matrix);
			MiscDialog.emboss(buttonNormal, 0, 0, width, height);
			add(buttonNormal);
			loadGraphic(buttonNormal, buttonNormal);
		}
		
		public static function scenarioName(clazz:Class, scenario:int):String {
			var romanNumerals:Array = ["I", "II", "III", "IV", "V"];
			return clazz["name"] + " " + romanNumerals[scenario];
		}
	}
}