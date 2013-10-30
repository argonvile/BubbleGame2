package  
{
	import flash.ui.Mouse;
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.FlxButtonPlus;

	public class KeyboardOptions extends FlxState
	{
		private var interactivePlayerSprite:PlayerSprite;
		private var interactivePlayerMover:PlayerMover;
		private var autoPlayerSprite:PlayerSprite;
		private var autoPlayerMover:PlayerMover;
		private var pressedRight:Boolean = false;
		private var pressedLeft:Boolean = false;
		private var autoPlayerWait:Number = 0;
		private var repeatDelayButtons:Array = new Array();
		private var repeatRateButtons:Array = new Array();
		public static const REPEAT_DELAYS:Array = [0.480, 0.343, 0.245, 0.175, 0.120];
		public static const REPEAT_RATES:Array = [0.18, 0.12, 0.08, 0.04, 0];
		
		override public function create():void {
			var button:FlxButtonPlus;
			var text:FlxText;

			var hRule:FlxSprite;
			hRule = new FlxSprite(5, 8);
			hRule.makeGraphic(310, 1);
			add(hRule);
			text = new FlxText(8, 8, 150, "Repeat Delay");
			add(text);
			text = new FlxText(8, 33, 150, "Long");
			add(text);
			text = new FlxText(152, 33, 160, "Short");
			text.alignment = "right";
			add(text);
			for (var i:int = 1; i <= 5;i++ ) {
				button = new FlxButtonPlus(48 * i, 30, setRepeatDelay, [REPEAT_DELAYS[i - 1]], String(i), 30, 20);
				add(button);
				repeatDelayButtons.push(button);
			}
			hRule = new FlxSprite(5, 58);
			hRule.makeGraphic(310, 1);
			add(hRule);
			text = new FlxText(8, 58, 150, "Repeat Rate");
			add(text);
			text = new FlxText(8, 83, 150, "Slow");
			add(text);
			text = new FlxText(152, 83, 160, "Fast");
			text.alignment = "right";
			add(text);
			for (var i:int = 1; i <= 5;i++ ) {
				button = new FlxButtonPlus(48 * i, 80, setRepeatRate, [REPEAT_RATES[i-1]], String(i), 30, 20);
				add(button);
				repeatRateButtons.push(button);
			}
			hRule = new FlxSprite(5, 108);
			hRule.makeGraphic(310, 1);
			add(hRule);
			text = new FlxText(8, 108, 150, "Test");
			add(text);
			
			autoPlayerSprite = new PlayerSprite(5, 133);
			add(autoPlayerSprite);
			autoPlayerMover = new PlayerMover(autoPlayerSprite, 5, 10);

			interactivePlayerSprite = new PlayerSprite(165, 133);
			add(interactivePlayerSprite);
			interactivePlayerMover = new PlayerMover(interactivePlayerSprite, 165, 10);
			
			button = new FlxButtonPlus(0, 215, exit, null, "Exit", 80, 20);
			button.screenCenter();
			add(button);
			
			updateButtons();
		}
		
		private function exit():void {
			kill();
			FlxG.switchState(new LevelSelect());
		}
		
		private function updateButtons():void {
			for (var i:int = 0; i < 5;i++) {
				var button:FlxButtonPlus = repeatDelayButtons[i];
				if (REPEAT_DELAYS[i] == PlayerSave.getRepeatDelay()) {
					button.updateActiveButtonColors([0xffa0a000, 0xffffff00]);
					button.updateInactiveButtonColors([0xffa0a000, 0xffffff00]);
				} else {
					button.updateActiveButtonColors([0xff800000, 0xffff0000]);
					button.updateInactiveButtonColors([0xff008000, 0xff00ff00]);
				}
			}
			for (var i:int = 0; i < 5;i++) {
				var button:FlxButtonPlus = repeatRateButtons[i];
				if (REPEAT_RATES[i] == PlayerSave.getRepeatRate()) {
					button.updateActiveButtonColors([0xffa0a000, 0xffffff00]);
					button.updateInactiveButtonColors([0xffa0a000, 0xffffff00]);
				} else {
					button.updateActiveButtonColors([0xff800000, 0xffff0000]);
					button.updateInactiveButtonColors([0xff008000, 0xff00ff00]);
				}
			}
		}
		
		private function setRepeatDelay(repeatDelay:Number):void {
			interactivePlayerMover.repeatDelay = repeatDelay;
			autoPlayerMover.repeatDelay = repeatDelay;
			PlayerSave.setRepeatDelay(repeatDelay);
			
			updateButtons();
		}

		private function setRepeatRate(repeatRate:Number):void {
			interactivePlayerMover.repeatRate = repeatRate;
			autoPlayerMover.repeatRate = repeatRate;
			PlayerSave.setRepeatRate(repeatRate);
			
			updateButtons();
		}

		override public function update():void {
			super.update();
			Mouse.show();
			interactivePlayerMover.movePlayerFromInput();
			
			if (autoPlayerWait > 0) {
				autoPlayerWait -= FlxG.elapsed
			} else {
				var justPressedLeft:Boolean = false;
				var justPressedRight:Boolean = false;
				if (autoPlayerSprite.x == autoPlayerMover.minX) {
					justPressedRight = true;
					pressedRight = true;
					pressedLeft = false;
				} else if (autoPlayerSprite.x == autoPlayerMover.maxX) {
					justPressedLeft = true;
					pressedRight = false;
					pressedLeft = true;
				}
				autoPlayerMover.movePlayer(justPressedLeft, justPressedRight, false, false, pressedLeft, pressedRight);
				if (autoPlayerSprite.x == autoPlayerMover.minX || autoPlayerSprite.x == autoPlayerMover.maxX) {
					autoPlayerWait = 1.0;
				}
			}
		}
	}

}