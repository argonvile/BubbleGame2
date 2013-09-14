package
{
	import org.flixel.*;
 
	public class PlayState extends FlxState
	{
		private var playerSprite:FlxSprite;
		private var bubbles:FlxGroup;
		private var heldBubbles:FlxGroup = new FlxGroup();
		private var popperEmitter:FlxEmitter = new FlxEmitter();
		private var bubbleRate:Number = 120; // bubbles per minute
		private var bubbleLifespan:Number = 0; // if bubbles are popping
		
		private var elapsed:Number = 0;
		private var newBubbleTimer:Number = 0;
		private var gameState:int = 100;
		private var thrownBubbles:Array = new Array();
		
		override public function create():void
		{
			// bumps
			{
				var bump:FlxSprite;
				bump = new FlxSprite(16, 0);
				bump.makeGraphic(16, 8, 0xff888888);
				add(bump);
				bump = new FlxSprite(48, 0);
				bump.makeGraphic(16, 8, 0xff888888);
				add(bump);
				bump = new FlxSprite(80, 0);
				bump.makeGraphic(16, 8, 0xff888888);
				add(bump);
			}
			bubbles = new FlxGroup();
			for (var y:int = 0; y < 160; y += 16) {
				var x:int;
				for (x = 0; x < 96; x += 32) {
					var mySprite:FlxSprite = new Bubble(x, y, randomColor());
					bubbles.add(mySprite);
				}
				for (x = 16; x < 96; x+=32) {
					var mySprite:FlxSprite = new Bubble(x, y + 8, randomColor());
					bubbles.add(mySprite);
				}
			}
			add(bubbles);
			playerSprite = new FlxSprite(0, 224);
			playerSprite.makeGraphic(16, 16, 0xffffffff);
			add(playerSprite);
		}
		
		override public function update():void
		{
			super.update();
			if(bubbleLifespan > 0) {
				bubbleLifespan -= FlxG.elapsed;
				if(bubbleLifespan <= 0) {
					dropDetachedBubbles();
				}
			}
			if (gameState == 100) {
				elapsed += FlxG.elapsed;
				bubbleRate += FlxG.elapsed * 3;
				if (bubbleLifespan <= 0) {
					newBubbleTimer += FlxG.elapsed * (bubbleRate / 60);
					if (thrownBubbles.length > 0) {
						// handle thrown bubbles
						for each (var thrownBubble:Bubble in thrownBubbles) {
							var lowestBubble:Bubble = lowestBubble(thrownBubble.x);
							if (lowestBubble == null) {
								lowestBubble = new Bubble(thrownBubble.x, thrownBubble.x%32 == 0 ? -16 : -8, 0xffff0000);
							}
							thrownBubble.y = lowestBubble.y + 16;
							bubbles.add(thrownBubble);
							popMatches(thrownBubble);
						}
						thrownBubbles.length = 0;
					}
				}
				if (FlxG.keys.justPressed("LEFT")) {
					playerSprite.x = Math.max(playerSprite.x-16, 0);
				} else if (FlxG.keys.justPressed("RIGHT")) {
					playerSprite.x = Math.min(playerSprite.x+16, 80);
				}
				if (FlxG.keys.justPressed("Z")) {
					// find the next block above the player, and remove it
					grabBubbles();
					dropDetachedBubbles();
				}
				if (FlxG.keys.justPressed("X")) {
					// find the next block above the player, and spit out our blocks below it
					for each (var heldBubble:Bubble in heldBubbles.members) {
						if (heldBubble != null && heldBubble.alive) {
							heldBubble.x = playerSprite.x;
							heldBubbles.remove(heldBubble);
							thrownBubbles.push(heldBubble);
						}
					}
				}
				if (FlxG.keys.justPressed("C") || newBubbleTimer > 6) {
					newBubbleTimer = 0;
					// add another row of bubbles
					for each (var bubble:Bubble in bubbles.members) {
						if (bubble != null && bubble.alive) {
							bubble.y += 16;
						}
					}
					for each (var position:Array in [[0, 0], [16, 8], [32, 0], [48, 8], [64, 0], [80, 8]]) {
						var mySprite:FlxSprite = new Bubble(position[0], position[1], randomColor());
						bubbles.add(mySprite);
					}
					// check if they lose
					for each (var bubble:Bubble in bubbles.members) {
						if (bubble != null && bubble.alive && bubble.y > 232) {
							gameState = 200;
							var text:FlxText = new FlxText(0, 0, FlxG.width, "You lasted " + Math.round(elapsed) + "." + (Math.round(elapsed * 10) % 10) + "s");
							text.alignment = "center";
							text.y = FlxG.height / 2 - text.height / 2;
							add(text);
							text = new FlxText(0, 0, FlxG.width, "Hit <Enter> to try again");
							text.alignment = "center";
							text.y = FlxG.height / 2 - text.height / 2 + text.height * 2;
							add(text);
						}
					}
				}
			} else if (gameState == 200) {
				if (FlxG.keys.justPressed("ENTER")) {
					kill();
					FlxG.switchState(new PlayState());
					return;
				}
			}
		}
		
		private function dropDetachedBubbles():void {
			var positionMap:Object = newPositionMap();
			var bubblesToCheck:Array = new Array();
			for each (var position:String in [
				hashPosition(0, 0),
				hashPosition(16, 8),
				hashPosition(32, 0),
				hashPosition(48, 8),
				hashPosition(64, 0),
				hashPosition(80, 8)
			]) {
				if (positionMap[position] != null) {
					bubblesToCheck.push(positionMap[position]);
					positionMap[position] = null;
				}
			}
			var iBubblesToCheck:int = 0;
			for (var iBubblesToCheck:int = 0; iBubblesToCheck < bubblesToCheck.length;iBubblesToCheck++) {
				var bubbleToCheck:Bubble = bubblesToCheck[iBubblesToCheck];
				positionMap[hashPosition(bubbleToCheck.x, bubbleToCheck.y)] = null;
				var neighbors:Array = new Array();
				for each (var position:String in [
					hashPosition(bubbleToCheck.x, bubbleToCheck.y - 16),
					hashPosition(bubbleToCheck.x + 16, bubbleToCheck.y - 8),
					hashPosition(bubbleToCheck.x + 16, bubbleToCheck.y + 8),
					hashPosition(bubbleToCheck.x, bubbleToCheck.y + 16),
					hashPosition(bubbleToCheck.x - 16, bubbleToCheck.y + 8),
					hashPosition(bubbleToCheck.x - 16, bubbleToCheck.y - 8)
				]) {
					var neighbor:Bubble = positionMap[position];
					if (neighbor != null) {
						positionMap[position] = null;
						bubblesToCheck.push(neighbor);
					}
				}
			}
			for (var position:String in positionMap) {
				if (positionMap[position] != null) {
					var bubble:Bubble = positionMap[position];
					if (bubble.alive) {
						bubble.kill();
					}
				}
			}
		}
		
		private function throwBubbles():Bubble {
			var maxBubble:Bubble = lowestBubble();
			if (maxBubble == null) {
				maxBubble = new Bubble(playerSprite.x, playerSprite.x%32 == 0 ? -16 : -8, 0xffff0000);
			}
			var heldBubble:Bubble = heldBubbles.getFirstAlive() as Bubble;
			while(heldBubble != null) {
				heldBubbles.remove(heldBubble);
				heldBubble.x = maxBubble.x;
				heldBubble.y = maxBubble.y + 16;
				maxBubble = heldBubble;
				bubbles.add(heldBubble);
				heldBubble = heldBubbles.getFirstAlive() as Bubble;
			}
			return maxBubble;
		}
		
		private function popMatches(maxBubble:Bubble):void {
			// create map
			var positionMap:Object = newPositionMap();
			var bubblesToCheck:Array = new Array(maxBubble);
			var iBubblesToCheck:int = 0;
			
			do {
				var bubbleToCheck:Bubble = bubblesToCheck[iBubblesToCheck];
				positionMap[hashPosition(bubbleToCheck.x, bubbleToCheck.y)] = null;
				for each (var position:String in [
					hashPosition(bubbleToCheck.x, bubbleToCheck.y - 16),
					hashPosition(bubbleToCheck.x + 16, bubbleToCheck.y - 8),
					hashPosition(bubbleToCheck.x + 16, bubbleToCheck.y + 8),
					hashPosition(bubbleToCheck.x, bubbleToCheck.y + 16),
					hashPosition(bubbleToCheck.x - 16, bubbleToCheck.y + 8),
					hashPosition(bubbleToCheck.x - 16, bubbleToCheck.y - 8)
				]) {
					var neighbor:Bubble = positionMap[position];
					if (neighbor != null && neighbor.bubbleColor == bubbleToCheck.bubbleColor) {
						positionMap[position] = null;
						bubblesToCheck.push(neighbor);
					}
				}
			} while (++iBubblesToCheck < bubblesToCheck.length);
			
			if (iBubblesToCheck >= 4) {
				bubbleLifespan = 1.2;
				for each(var bubble:Bubble in bubblesToCheck) {
					bubble.lifespan = bubbleLifespan;
					bubble.makeGraphic(bubble.width, bubble.height, 0xffffffff);
				}
			}
		}
		
		private function grabBubbles():void {
			var maxBubble:Bubble = lowestBubble();
			var heldBubble:Bubble = heldBubbles.getFirstAlive() as Bubble;
			var positionMap:Object = newPositionMap();
			var y:Number = maxBubble.y;
			while(maxBubble != null) {
				if (heldBubble != null && maxBubble.bubbleColor != heldBubble.bubbleColor) {
					break;
				} else if (maxBubble.lifespan > 0) {
					break;
				} else {
					heldBubble = maxBubble;
					heldBubbles.add(maxBubble);
					bubbles.remove(maxBubble);
				}
				maxBubble = positionMap[hashPosition(maxBubble.x, maxBubble.y - 16)];
			}
		}
		
		private function newPositionMap():Object {
			var positionMap:Object = new Object();
			for each (var bubble:Bubble in bubbles.members) {
				if (bubble != null && bubble.alive) {
					positionMap[hashPosition(bubble.x, bubble.y)] = bubble;
				}
			}
			return positionMap;
		}
		
		private function hashPosition(x:Number, y:Number):Object {
			return Math.round(x) + "," + Math.round(y);
		}
		
		private function lowestBubble(x:Number = -9999):Bubble {
			if (x == -9999) {
				x = playerSprite.x;
			}
			var maxBubble:Bubble;
			for each (var bubble:Bubble in bubbles.members) {
				if (bubble != null && bubble.alive && bubble.x == x) {
					if (maxBubble == null || bubble.y > maxBubble.y) {
						maxBubble = bubble;
					}
				}
			}
			return maxBubble;
		}
		
		private function randomColor():int {
			var randomInt:int = Math.random() * 5;
			switch(randomInt) {
				case 0: return 0xffcc3333;
				case 1: return 0xffcccc33;
				case 2: return 0xff33cc33;
				case 3: return 0xff3380cc;
				default: return 0xff8033cc;
			}
		}
	}
}