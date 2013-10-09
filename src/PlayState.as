package
{
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.FlxColor;
 
	public class PlayState extends FlxState
	{
		public var bubbleHeight:int = 17;
		public var columnWidth:int = 15;
		
		private var playerSprite:FlxSprite;
		private var bubbles:FlxGroup;
		private var connectors:FlxGroup;
		private var fallingBubbles:FlxGroup = new FlxGroup();
		private var heldBubbles:FlxGroup = new FlxGroup();
		private var popperEmitter:FlxEmitter = new FlxEmitter();
		private var bubbleRate:Number = 120; // bubbles per minute
		
		private var elapsed:Number = 0;
		private var rowScrollTimer:Number = 0;
		/**
		 * 100 == normal
		 * 110 == popping
		 * 120 == dropping
		 * 130 == scrolling paused
		 * 200 == game over
		 */
		private var gameState:int = 100;
		private var stateTime:Number = 0;
		private var stateDuration:Number = 0;
		
		private var suspendedBubbles:Array = new Array();
		private var thrownBubbles:Array = new Array();
		private var poppedBubbles:Array = new Array();
		
		private var newRowLocation:Number = -bubbleHeight;
		
		private var leftTimer:Number = 0;
		private var rightTimer:Number = 0;
		
		private const POP_DELAY:Number = 0.4;
		private const POP_PER_BUBBLE_DELAY:Number = 0.1;
		private const DROP_DELAY:Number = 0;
		private const DROP_PER_BUBBLE_DELAY:Number = 0.03;
		
		private var timerText:FlxText;
		
		override public function create():void
		{
			bubbles = new FlxGroup();
			add(bubbles);
			connectors = new FlxGroup();
			add(connectors);
			
			playerSprite = new FlxSprite(0, 224);
			playerSprite.makeGraphic(columnWidth, bubbleHeight, 0xffffffff);
			add(playerSprite);

			add(heldBubbles);
			add(fallingBubbles);
			
			timerText = new FlxText(290, 0, 100, "0.0");
			add(timerText);
		}
		
		override public function update():void
		{
			super.update();
			stateTime += FlxG.elapsed;
			timerText.text = String(Math.round(stateTime * 100) / 100);
			if (gameState < 200) {
				elapsed += FlxG.elapsed;
				bubbleRate += FlxG.elapsed * 3;
				// handle player input
				if (FlxG.keys.justPressed("LEFT")) {
					playerSprite.x = Math.max(playerSprite.x-columnWidth, 0);
				}
				if (FlxG.keys.justPressed("RIGHT")) {
					playerSprite.x = Math.min(playerSprite.x+columnWidth, columnWidth * 5);
				}
				if (FlxG.keys.justPressed("DOWN")) {
					playerSprite.x = columnWidth;
				}
				if (FlxG.keys.justPressed("UP")) {
					playerSprite.x = columnWidth*4;
				}
				if (FlxG.keys.pressed("LEFT")) {
					leftTimer += FlxG.elapsed;
					if (leftTimer > 0.175) {
						playerSprite.x = 0;
					}
				} else {
					leftTimer = 0;
				}
				if (FlxG.keys.pressed("RIGHT")) {
					rightTimer += FlxG.elapsed;
					if (rightTimer > 0.175) {
						playerSprite.x = columnWidth * 5;
					}
				} else {
					rightTimer = 0;
				}
				if (FlxG.keys.justPressed("Z")) {
					// find the next block above the player, and remove it
					grabBubbles();
				}
				if (FlxG.keys.justPressed("X")) {
					// find the next block above the player, and spit out our blocks below it
					for each (var heldBubble:Bubble in heldBubbles.members) {
						if (heldBubble != null && heldBubble.alive) {
							heldBubble.x = playerSprite.x;
							heldBubbles.remove(heldBubble);
							suspendedBubbles.push(heldBubble);
						}
					}
				}
				if (FlxG.keys.justPressed("C")) {
					var newPoppableBubbles:Array = new Array();
					for each (var bubble:Bubble in bubbles.members) {
						if (bubble != null && bubble.alive) {
							var wasAnchor:Boolean = bubble.isAnchor();
							bubble.y += bubbleHeight;
							bubble.updateAlpha();
							if (!bubble.isAnchor() && wasAnchor) {
								newPoppableBubbles.push(bubble);
							}							
						}
					}
					for each (var connector:Connector in connectors.members) {
						if (connector != null && connectors.alive) {
							connector.y += bubbleHeight;
						}
					}
					if (newPoppableBubbles.length > 0) {
						var positionMap:Object = newPositionMap();
						for each (var bubble:Bubble in newPoppableBubbles) {
							maybeAddConnector(bubble, positionMap[hashPosition(bubble.x, bubble.y + bubbleHeight)], Embed.Microbe0S);
							maybeAddConnector(bubble, positionMap[hashPosition(bubble.x - columnWidth, bubble.y + bubbleHeight / 2)], Embed.Microbe0Sw);
							maybeAddConnector(bubble, positionMap[hashPosition(bubble.x + columnWidth, bubble.y + bubbleHeight / 2)], Embed.Microbe0Se);
						}
					}					
					newRowLocation += bubbleHeight;
				}
			}
			// do we need to add new rows?
			if (gameState < 200 && newRowLocation > -bubbleHeight * 1.5) {
				// add new rows
				do {
					for each (var position:Array in [[0, newRowLocation], [columnWidth, newRowLocation-bubbleHeight*.5], [columnWidth*2, newRowLocation], [columnWidth*3, newRowLocation-bubbleHeight*.5], [columnWidth*4, newRowLocation], [columnWidth*5, newRowLocation-bubbleHeight*.5]]) {
						var mySprite:FlxSprite = new Bubble(position[0], position[1], randomColor());
						bubbles.add(mySprite);
					}
					newRowLocation -= bubbleHeight;
				} while (newRowLocation > -bubbleHeight * 1.5);
			}
			if (gameState == 100 || gameState == 130) {
				// did the player trigger a drop event?
				// if so, transition to state 120...
				if (FlxG.keys.justPressed("Z")) {
					checkForDetachedBubbles();
					if (gameState == 120) {
						return;
					}
				}

				if (suspendedBubbles.length > 0) {
					// handle suspended bubbles
					for each (var suspendedBubble:Bubble in suspendedBubbles) {
						var lowestBubble:Bubble = lowestBubble(suspendedBubble.x);
						suspendedBubble.y = lowestBubble.y + bubbleHeight;
						suspendedBubble.wasThrown(playerSprite);
						bubbles.add(suspendedBubble);
						thrownBubbles.push(suspendedBubble);
					}
					suspendedBubbles.length = 0;
				}
				// handle thrown bubbles
				var popCounter:PopCounter = new PopCounter(this);
				var thrownBubbleCount:int = 0;
				var positionMap:Object = newPositionMap();
				for (var i:int = 0; i < thrownBubbles.length; i++) {
					var thrownBubble:Bubble = thrownBubbles[i];

					if (thrownBubble != null && thrownBubble.alive) {
						if (thrownBubble.state == 200) {
							thrownBubbleCount++;
						} else {
							maybeAddConnector(thrownBubble, positionMap[hashPosition(thrownBubble.x - columnWidth, thrownBubble.y + bubbleHeight / 2)], Embed.Microbe0Sw); // SW
							maybeAddConnector(thrownBubble, positionMap[hashPosition(thrownBubble.x - columnWidth, thrownBubble.y - bubbleHeight / 2)], Embed.Microbe0Se); // NW
							maybeAddConnector(thrownBubble, positionMap[hashPosition(thrownBubble.x, thrownBubble.y - bubbleHeight)], Embed.Microbe0S); // N
							maybeAddConnector(thrownBubble, positionMap[hashPosition(thrownBubble.x + columnWidth, thrownBubble.y - bubbleHeight / 2)], Embed.Microbe0Sw); // NE
							maybeAddConnector(thrownBubble, positionMap[hashPosition(thrownBubble.x + columnWidth, thrownBubble.y + bubbleHeight / 2)], Embed.Microbe0Se); // SE
					
							thrownBubbles[i] = null;
							popCounter.popMatches(thrownBubble);
						}
					}
				}
				// did the player trigger a pop event?
				// if so, transition to state 110...
				if (popCounter.shouldPop()) {
					poppedBubbles = popCounter.getPoppedBubbles();
					poppedBubbles.sort(orderByPosition);
					changeState(110, POP_DELAY + POP_PER_BUBBLE_DELAY * poppedBubbles.length);
					return;
				}
				if (thrownBubbleCount == 0 && thrownBubbles.length > 0) {
					thrownBubbles.length = 0;
				}
				
				// is scrolling paused?
				if (gameState == 130) {
					// yes, scrolling is paused
					if (stateTime >= stateDuration) {
						changeState(100);
					}
				} else {
					// no, it's not paused
					rowScrollTimer += FlxG.elapsed * ((bubbleRate * bubbleHeight / 6) / 60);
					if (rowScrollTimer > 1) {
						// scroll all the bubbles down a little
						var newPoppableBubbles:Array = new Array();
						newRowLocation += Math.floor(rowScrollTimer);
						for each (var bubble:Bubble in bubbles.members) {
							if (bubble != null && bubble.alive) {
								var wasAnchor:Boolean = bubble.isAnchor();
								bubble.y += Math.floor(rowScrollTimer);
								bubble.updateAlpha();
								if (!bubble.isAnchor() && wasAnchor) {
									newPoppableBubbles.push(bubble);
								}
							}
						}
						for each (var connector:Connector in connectors.members) {
							if (connector != null && connector.alive) {
								connector.y += Math.floor(rowScrollTimer);
							}
						}
						if (newPoppableBubbles.length > 0) {
							var positionMap:Object = newPositionMap();
							for each (var bubble:Bubble in newPoppableBubbles) {
								maybeAddConnector(bubble, positionMap[hashPosition(bubble.x, bubble.y + bubbleHeight)], Embed.Microbe0S);
								maybeAddConnector(bubble, positionMap[hashPosition(bubble.x - columnWidth, bubble.y + bubbleHeight / 2)], Embed.Microbe0Sw);
								maybeAddConnector(bubble, positionMap[hashPosition(bubble.x + columnWidth, bubble.y + bubbleHeight / 2)], Embed.Microbe0Se);
							}
						}
						rowScrollTimer -= Math.floor(rowScrollTimer);
					}
				}
				
				// did the player lose?
				if (gameState == 100) {
					for each (var bubble:Bubble in bubbles.members) {
						if (bubble != null && bubble.alive && bubble.y > 232 && bubble.state == 0) {
							// yes, they lost. transition to state 200
							changeState(200);
							var text:FlxText = new FlxText(0, 0, FlxG.width, "You lasted " + Math.round(elapsed) + "." + (Math.round(elapsed * 10) % 10) + "s");
							text.alignment = "center";
							text.y = FlxG.height / 2 - text.height / 2;
							add(text);
							text = new FlxText(0, 0, FlxG.width, "Hit <Enter> to try again");
							text.alignment = "center";
							text.y = FlxG.height / 2 - text.height / 2 + text.height * 2;
							add(text);
							return;
						}
					}
				}
			}
			if (gameState == 110) {
				// change the bubble colors
				var popAnimState:int = (stateTime * 3) / POP_DELAY;
				if (popAnimState == 0 || popAnimState == 2) {
					for each (var bubble:Bubble in poppedBubbles) {
						bubble.loadPopGraphic();
					}
				} else {
					for each (var bubble:Bubble in poppedBubbles) {
						bubble.loadRegularGraphic();
					}
				}
				for (var i:int = 0; i < poppedBubbles.length; i++) {
					if ((i + 1) * POP_PER_BUBBLE_DELAY + POP_DELAY < stateTime) {
						var poppedBubble:Bubble = poppedBubbles[i];
						if (poppedBubble.visible) {
							poppedBubble.visible = false;
							poppedBubble.killConnectors();
							Embed.play(Embed.SfxBlip0);
						}
					}
				}
				// is the pop event over?
				if (stateTime >= stateDuration) {
					// if so, remove popped bubbles
					for each (var bubble:Bubble in poppedBubbles) {
						bubble.kill();
					}
					poppedBubbles.length = 0;
					// if the player triggered a drop event, transition to state 120...
					checkForDetachedBubbles();
					if (gameState == 110) {
						// otherwise transition to state 100
						changeState(100);
					}
				}
			} else if (gameState == 120) {
				// drop some bubbles
				for (var i:int = 0; i < poppedBubbles.length; i++) {
					if ((i + 1) * DROP_PER_BUBBLE_DELAY + DROP_DELAY < stateTime) {
						var bubble:Bubble = poppedBubbles[i];
						if (bubble.acceleration.y == 0) {
							Embed.play(Embed.SfxBlip0);
							bubbles.remove(bubble);
							bubble.killConnectors();
							fallingBubbles.add(bubble);
							bubble.flicker(1000);
							bubble.velocity.y = (bubbleRate * bubbleHeight / 6) / 60;
							bubble.velocity.x = bubble.velocity.y;
							bubble.acceleration.y = 600;
						}
					}
				}
				// is the drop event over?
				if (stateTime >= stateDuration) {
					// if so, transition to state 100
					poppedBubbles.length = 0;
					changeState(100);
				}
			} else if (gameState == 200) {
				// game over
				if (FlxG.keys.justPressed("ENTER")) {
					kill();
					FlxG.switchState(new PlayState());
					return;
				}
			}
		}
		
		private function changeState(newState:int, stateDuration:Number=0):void {
			gameState = newState;
			stateTime = 0;
			this.stateDuration = stateDuration;
		}
		
		public function maybeAddConnector(bubble:Bubble, bubbleS:Bubble, graphic:Class):void {
			if (bubbleS != null && bubbleS.bubbleColor == bubble.bubbleColor) {
				var connector:Connector = connectors.recycle(Connector) as Connector;
				connector.revive();
				connector.init(bubble, bubbleS, graphic);
				connectors.add(connector);
				bubble.connectors.push(connector);
				bubbleS.connectors.push(connector);
			}
		}
		
		private function checkForDetachedBubbles():void {
			var positionMap:Object = newPositionMap();
			var bubblesToCheck:Array = new Array();
			for each (var bubble:Bubble in bubbles.members) {
				if (bubble != null && bubble.alive && bubble.isAnchor()) {
					bubblesToCheck.push(bubble);
				}
			}

			var iBubblesToCheck:int = 0;
			for (var iBubblesToCheck:int = 0; iBubblesToCheck < bubblesToCheck.length;iBubblesToCheck++) {
				var bubbleToCheck:Bubble = bubblesToCheck[iBubblesToCheck];
				positionMap[hashPosition(bubbleToCheck.x, bubbleToCheck.y)] = null;
				var neighbors:Array = new Array();
				for each (var position:String in [
					hashPosition(bubbleToCheck.x, bubbleToCheck.y - bubbleHeight),
					hashPosition(bubbleToCheck.x + columnWidth, bubbleToCheck.y - bubbleHeight/2),
					hashPosition(bubbleToCheck.x + columnWidth, bubbleToCheck.y + bubbleHeight/2),
					hashPosition(bubbleToCheck.x, bubbleToCheck.y + bubbleHeight),
					hashPosition(bubbleToCheck.x - columnWidth, bubbleToCheck.y + bubbleHeight/2),
					hashPosition(bubbleToCheck.x - columnWidth, bubbleToCheck.y - bubbleHeight/2)
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
					poppedBubbles.push(positionMap[position]);
				}
			}
			if (poppedBubbles.length > 0) {
				poppedBubbles.sort(orderByPosition);
				changeState(120, DROP_DELAY + poppedBubbles.length * DROP_PER_BUBBLE_DELAY);
			}
		}
		
		private function isGrabbable(bubble:Bubble):Boolean {
			for each (var poppedBubble:Bubble in poppedBubbles) {
				if (poppedBubble == bubble) {
					return false;
				}
			}
			return true;
		}
		
		private function grabBubbles():void {
			var maxBubble:Bubble = lowestBubble();
			if (maxBubble == null || maxBubble.isAnchor()) {
				return;
			}
			var heldBubble:Bubble = heldBubbles.getFirstAlive() as Bubble;
			var positionMap:Object = newPositionMap();
			var y:Number = maxBubble.y;
			while(maxBubble != null) {
				if (heldBubble != null && maxBubble.bubbleColor != heldBubble.bubbleColor) {
					break;
				} else if (!isGrabbable(maxBubble)) {
					break;
				} else {
					heldBubble = maxBubble;
					heldBubbles.add(maxBubble);
					bubbles.remove(maxBubble);
					maxBubble.killConnectors();
					maxBubble.wasGrabbed(playerSprite);
					for (var i:int = 0; i < thrownBubbles.length; i++) {
						if (thrownBubbles[i] == maxBubble) {
							thrownBubbles[i] = null;
						}
					}
				}
				maxBubble = positionMap[hashPosition(maxBubble.x, maxBubble.y - bubbleHeight)];
			}
		}
		
		public function newPositionMap():Object {
			var positionMap:Object = new Object();
			for each (var bubble:Bubble in bubbles.members) {
				if (bubble != null && bubble.alive && !bubble.isAnchor()) {
					positionMap[hashPosition(bubble.x, bubble.y)] = bubble;
				}
			}
			return positionMap;
		}
		
		public function hashPosition(x:Number, y:Number):Object {
			return Math.round(x / columnWidth) + "," + Math.round((y - newRowLocation) * 2 / bubbleHeight);
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
				case 0: return 0xffff0000;
				case 1: return 0xffffff00;
				case 2: return 0xff00ff00;
				case 3: return 0xff0080ff;
				default: return 0xff8000ff;
			}
		}
		
		private function orderByPosition(a:Bubble, b:Bubble):Number {
			if (a.y != b.y) {
				return b.y - a.y;
			}
			return a.x - b.x;
		}
	}
}