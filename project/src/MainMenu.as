package  
{
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.*;
	import flash.ui.Mouse;
	import levels.boring.*;
	
	public class MainMenu extends FlxState
	{
		private var tree:Array = new Array("");
		private static var treeLevel:Array = new Array();
		private var scrollY:Number = 0;
		
		public function MainMenu() 
		{
			Worlds.init();
			tree.push(["Normal"]);
			for (var i:int = 0; i < Worlds.allWorlds.length; i++) {
				var node:Array = getNode(["Normal"]);
				node.push(["World " + (i + 1)]);
				var uncleared:int = 0;
				for (var j:int = 0; j < Worlds.allWorlds[i].length; j++) {
					var level:LevelSummary = Worlds.allWorlds[i][j];
					var scenarioName:String = LevelButton.scenarioName(level.levelClass, level.scenario);
					if (uncleared >= 3) {
						scenarioName = "?????";
					} else if (PlayerSave.isClearedNormalLevel(level.levelClass, level.scenario)) {
						scenarioName = "(" + scenarioName.toLowerCase() + ")";
					} else {
						uncleared++;
					}
					var newArray:Array = [scenarioName, level.levelClass, level.scenario, level.duration];
					getNode(["Normal","World " + (i+1)]).push(newArray);
				}
			}
			tree.push(["Ranked"]);
			tree.push(["All Levels"]);
			tree.push(["Keyboard Settings"]);
			
			expand(treeLevel)
		}
		
		private function scrollEm(scrollAmount:Number):void {
			var bottom:Number = 0;
			for each (var basic:FlxBasic in members) {
				if (basic is FlxButtonPlus) {
					var flxButtonPlus:FlxButtonPlus = basic as FlxButtonPlus;
					if (flxButtonPlus.width > 50) {
						bottom = Math.max(bottom, flxButtonPlus.y + flxButtonPlus.height);
					}
				}
			}
			
			var newScrollY:Number = scrollY + scrollAmount;
			newScrollY = Math.max(0, newScrollY);
			newScrollY = Math.min(bottom + scrollY + 5 - FlxG.height, newScrollY);
			for each (var basic:FlxBasic in members) {
				if (basic is FlxButtonPlus) {
					var flxButtonPlus:FlxButtonPlus = basic as FlxButtonPlus;
					if (flxButtonPlus.width > 50) {
						flxButtonPlus.y -= (newScrollY - scrollY);
					}
				}
			}
			scrollY = newScrollY;
		}
		
		private function getNode(strings:Array):Array {
			var node:Array = tree;
			for (var i:int = 0; i < strings.length; i++) {
				var j:int;
				for (j = 1; j < node.length; j++) {
					if (node[j][0] == strings[i]) {
						break;
					}
				}
				node = node[j];
			}
			return node;
		}
		
		private function expand(newTreeLevel:Array):void {
			scrollY = 0;
			kill();
			var node:Array = getNode(newTreeLevel);
			if (node[1] is Class) {
				startGame(node[1], node[2], node[3]);
				return;
			}
			if (node.length == 1) {
				if (node[0] == "Ranked") {
					kill();
					FlxG.switchState(new RankedLevelSelect());
					return;
				}
				if (node[0] == "All Levels") {
					kill();
					FlxG.switchState(new AllLevelSelect());
					return;
				}
				if (node[0] == "Keyboard Settings") {
					kill();
					FlxG.switchState(new KeyboardOptions(MainMenu));
					return;
				}
			}
			treeLevel = newTreeLevel;
			var y:int = 5;
			for (var i:int = 1; i < node.length;i++) {
				var newStrings:Array = treeLevel.slice();
				newStrings.push(node[i][0]);
				var button:FlxButtonPlus = new FlxButtonPlus(5, y, expand, [newStrings], node[i][0], 150, 20);
				if (node[i][1] is Class) {
					var buttonText:String = node[i][0];
					if (buttonText.substring(0, 1) == "(") {
						button.updateActiveButtonColors([0x80800000, 0x80ff0000]);
						button.updateInactiveButtonColors([0x80008000, 0x8000ff00]);
					} else if (buttonText.substring(0, 1) == "?") {
						button.updateActiveButtonColors([0xff404040, 0xff808080]);
						button.updateInactiveButtonColors([0xff404040, 0xff808080]);
						button.active = false;
					} else {
						button.updateActiveButtonColors([0xff800000, 0xffff0000]);
						button.updateInactiveButtonColors([0xff008000, 0xff00ff00]);
					}
				}
				add(button);
				y += 25;
			}
			if (node.length >= 10) {
				var upButton:FlxButtonPlus = new FlxButtonPlus(300, 5, scrollEm, [-(FlxG.height - 25)], "-", 15, 20);
				add(upButton);
				var downButton:FlxButtonPlus = new FlxButtonPlus(300, FlxG.height - 25, scrollEm, [(FlxG.height + 25)], "+", 15, 20);
				add(downButton);				
			}
		}
		
		private function startGame(clazz:Class, scenario:int, duration:int):void {
			Mouse.hide();
			kill();
			var levelDetails:LevelDetails = new clazz(scenario);
			levelDetails.levelDuration = duration;
			var playState:PlayState = new PlayState(MainMenu, levelDetails);
			playState.setWinCallback(normalWin, [playState, clazz, scenario]);
			FlxG.switchState(playState);
		}
		
		public static function normalWin(playState:PlayState,clazz:Class, scenario:int):void {
			PlayerSave.setClearedNormalLevel(clazz, scenario);
			var text:FlxText = new FlxText(0, 0, FlxG.width, "You win!");
			text.alignment = "center";
			text.y = FlxG.height / 2 - text.height / 2;
			playState.add(text);
			text = new FlxText(0, 0, FlxG.width, "Hit <Enter>");
			text.alignment = "center";
			text.y = FlxG.height / 2 - text.height / 2 + text.height * 2;
			playState.add(text);
		}
		
		override public function update():void {
			super.update();
			Mouse.show();
			if (FlxG.keys.justPressed("ESCAPE")) {
				expand(treeLevel.slice(0, treeLevel.length - 1));
			}
		}		
	}
}