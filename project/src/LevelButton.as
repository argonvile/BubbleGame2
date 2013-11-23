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
			matrix.translate(0, 56);
			var itemCount:int = 0;
			var itemClass:Class;
			var positions:Array;
			if (difficultyIndex <= 2) {
				itemCount = difficultyIndex + 1;
				itemClass = Embed.RatingCircle;
			} else if (difficultyIndex <= 7) {
				itemCount = difficultyIndex - 2;
				itemClass = Embed.RatingStar;
			} else if (difficultyIndex <= 14) {
				itemCount = difficultyIndex - 7;
				itemClass = Embed.RatingSkull;
			} else {
				itemCount = difficultyIndex - 14;
				itemClass = Embed.RatingFireSkull;
			}
			switch(itemCount) {
				case 1: positions = [0, 0]; break;
				case 2: positions = [-1, 0, 1, 0]; break;
				case 3: positions = [-2, 0, 0, 0, 2, 0]; break;
				case 4: positions = [-3, 0, -1, 0, 1, 0, 3, 0]; break;
				case 5: positions = [-2, 1, -1, -1, 0, 1, 1, -1, 2, 1]; break;
				case 6: positions = [-3, 1, -2, -1, -1, 1, 1, 1, 2, -1, 3, 1]; break;
				case 7: positions = [-3, 1, -2, -1, -1, 1, 0, -1, 1, 1, 2, -1, 3, 1]; break;
			}
			var ratingItem:FlxSprite = new FlxSprite(0, 0, itemClass);
			var iconSize:Number = 18;
			for (var i:int = 0; i < positions.length;i+=2) {
				matrix.identity();
				matrix.scale(iconSize / ratingItem.width, iconSize / ratingItem.height);
				matrix.translate(width / 2 - iconSize/2 + 12 * positions[i], 68 - iconSize/2 + 3 * positions[i+1]);
				buttonNormal.pixels.draw(ratingItem.pixels, matrix);
			}
			
			buttonNormal.drawLine(0, 0, width, 0, 0x18ffffff);
			buttonNormal.drawLine(0, 1, 0, height, 0x18ffffff);
			buttonNormal.drawLine(width-1, 1, width-1, height, 0x18000000);
			buttonNormal.drawLine(1, height - 1, width - 1, height - 1, 0x18000000);
			add(buttonNormal);
			loadGraphic(buttonNormal, buttonNormal);
		}
		
		public static function scenarioName(clazz:Class, scenario:int):String {
			var romanNumerals:Array = ["I", "II", "III", "IV", "V"];
			return clazz["name"] + " " + romanNumerals[scenario];
		}
	}
}