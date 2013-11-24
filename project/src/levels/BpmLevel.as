package levels 
{
	import flash.events.TextEvent;
	import org.flixel.*;
	
	public class BpmLevel extends LevelDetails
	{
		public static const name:String = "BPM Level";
		public static const scenarioBpms:Array = [600, 700, 800, 900, 100];
		public static const quotaBpms:Array = [6000, 7000, 8000, 9000, 1000];
		private var splitStartTime:Number = 0;
		private var averages:Array = new Array();
		private var permaText:String = "";
		private var text:FlxText;
		private var textBg:FlxSprite;
		private var poppedBubbleCount:int = 0;
		private var trialDuration:Number = 45;
		private var trialCount:Number = 8;
		
		public function BpmLevel(scenario:int) 
		{
			super(scenario);
			setSpeed(7);
			maxBubbleRate = 0;
			columnCount = 9;
			levelDuration = trialDuration * trialCount;
		}
		
		override public function init(playState:PlayState):void {
			super.init(playState);
			levelQuota = 99999;
		}
		
		override public function bubbleVanished(bubble:Bubble):void {
			poppedBubbleCount++;
		}
		
		override public function bubblesFinishedDropping(bubbles:Array):void {
			poppedBubbleCount += bubbles.length;
		}
		
		override public function update(elapsed:Number):void {
			var maxY:Number = 0;
			for each (var bubble:Bubble in playState.bubbles.members) {
				if (bubble != null && bubble.alive) {
					maxY = Math.max(maxY, bubble.y + bubble.height);
				}
			}
			if (maxY > playState.playerSprite.y - 3 * PlayState.bubbleHeight) {
				bubbleRate = 0;
			} else {
				bubbleRate = 4800;
			}
			if (text == null) {
				textBg = new FlxSprite(0, 0);
				playState.add(textBg);
				text = new FlxText(0, 0, FlxG.width);
				playState.add(text);
				textBg.makeGraphic(text.width, text.height, 0x44000000);
			}
			var average:Number = Math.round(600 * poppedBubbleCount / (elapsed - splitStartTime)) / 10;
			if (elapsed + FlxG.elapsed > levelDuration) {
				averages.push(average);
				// last frame
				var finalText:String = produceAverageText(averages);
				finalText += " (was " + BubbleColorUtils.roundTenths(PlayerSave.getBubblesPerMinute()) + ")";
				text.text = finalText;
				PlayerSave.setBubblesPerMinute(computeSmartAverage(averages));
			} else {
				text.text = permaText + String(average);
				if (Math.floor(elapsed / trialDuration) != Math.floor((elapsed + FlxG.elapsed) / trialDuration)) {
					permaText += String(average) + " ";
					averages.push(average);
				}
			}
			if (text.width > textBg.width || text.height > textBg.height) {
				textBg.makeGraphic(text.width, text.height, 0x44000000);
			}
		}
		
		/**
		 * drop the highest and the lowest; take the mean of the rest
		 */
		public static function computeSmartAverage(arrayOfNumbers:Array):Number {
			var min:Number = Number.MAX_VALUE;
			var max:Number = 0;
			for each (var num:Number in arrayOfNumbers) {
				min = Math.min(num, min);
				max = Math.max(num, max);
			}
			var mean:Number = 0;
			var trials:int = 0;
			for each (var num:Number in arrayOfNumbers) {
				if (num == min) {
					min = -1;
				} else if (num == max) {
					max = -1;
				} else {
					trials++;
					mean += num;
				}
			}
			return mean / trials;
		}
		
		public static function produceAverageText(arrayOfNumbers:Array):String {
			var finalText:String = "";
			var min:Number = Number.MAX_VALUE;
			var max:Number = 0;
			for each (var num:Number in arrayOfNumbers) {
				min = Math.min(num, min);
				max = Math.max(num, max);
			}
			var mean:Number = 0;
			var trials:int = 0;
			for each (var num:Number in arrayOfNumbers) {
				if (num == min) {
					finalText += "(" + BubbleColorUtils.roundTenths(num) + ") ";
					min = -1;
				} else if (num == max) {
					finalText += "(" + BubbleColorUtils.roundTenths(num) + ") ";
					max = -1;
				} else {
					finalText += BubbleColorUtils.roundTenths(num) + " ";
					trials++;
					mean += num;
				}
			}
			finalText += " = " + String(Math.round(10 * mean / trials) / 10);
			return finalText;
		}
	}
}