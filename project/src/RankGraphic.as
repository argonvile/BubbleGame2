package  
{
	import org.flixel.*;
	import flash.geom.Matrix;

	public class RankGraphic extends FlxSprite
	{
		public function RankGraphic(difficultyIndex:int) {
			makeGraphic(90, 24, 0x00000000, true);
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
			var matrix:Matrix = new Matrix();
			for (var i:int = 0; i < positions.length; i += 2) {
				matrix.identity();
				matrix.scale(iconSize / ratingItem.width, iconSize / ratingItem.height);
				matrix.translate(45 - iconSize / 2 + 12 * positions[i], 12 - iconSize / 2 + 3 * positions[i + 1]);
				pixels.draw(ratingItem.pixels, matrix);
			}
			dirty = true;
		}
	}
}