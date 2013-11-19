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
				for (var j:int = 0; j < Worlds.allWorlds[i].length; j++) {
					var level:Object = Worlds.allWorlds[i][j];
					var newArray:Array = [LevelButton.scenarioName(level.levelClass, level.scenario), level.levelClass, level.scenario];
					getNode(["Normal","World " + (i+1)]).push(newArray);
				}
			}
			tree.push(["All Levels"]);
			tree.push(["Six Levels"]);
			tree.push(["Keyboard Settings"]);
			
			expand(treeLevel)
			
			/*var y:int = 5;
			for (var i:int = 1; i < tree.length;i++) {
				add(new FlxButtonPlus(5, y, expand, [[tree[i][0]]], tree[i][0], 150, 20));
				y += 25;
			}*/
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
				startGame(node[1], node[2]);
				return;
			}
			if (node.length == 1) {
				if (node[0] == "All Levels") {
					kill();
					FlxG.switchState(new AllLevelSelect());
					return;
				}
				if (node[0] == "Six Levels") {
					kill();
					FlxG.switchState(new LevelSelect());
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
				add(new FlxButtonPlus(5, y, expand, [newStrings], node[i][0], 150, 20));
				y += 25;
			}
			if (node.length >= 10) {
				var upButton:FlxButtonPlus = new FlxButtonPlus(300, 5, scrollEm, [-(FlxG.height - 25)], "-", 15, 20);
				add(upButton);
				var downButton:FlxButtonPlus = new FlxButtonPlus(300, FlxG.height - 25, scrollEm, [(FlxG.height + 25)], "+", 15, 20);
				add(downButton);				
			}
		}
		
		private function startGame(clazz:Class, scenario:int):void {
			Mouse.hide();
			kill();
			var playState:PlayState = new PlayState(MainMenu, new clazz(scenario));
			FlxG.switchState(playState);
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