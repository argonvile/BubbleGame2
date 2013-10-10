package
{
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.FlxColor;
 
	public class PlayState extends FlxState
	{
		public static const bubbleHeight:int = 17;
		public static const columnWidth:int = 15;
		
		private var playerSprite:FlxSprite;
		private var bubbles:FlxGroup;
		private var connectors:FlxGroup;
		private var fallingBubbles:FlxGroup = new FlxGroup();
		private var heldBubbles:FlxGroup = new FlxGroup();
		private var popperEmitter:FlxEmitter = new FlxEmitter();
		
		private var elapsed:Number = 0;
		private var rowScrollTimer:Number = 0;
		/**
		 * 100 == normal
		 * 110 == popping
		 * 120 == dropping
		 * 130 == scrolling paused
		 * 200 == game over (lose)
		 * 300 == game over (win)
		 */
		private var gameState:int = 100;
		private var stateTime:Number = 0;
		private var stateDuration:Number = 0;
		
		private var suspendedBubbles:Array = new Array();
		private var thrownBubbles:Array = new Array();
		private var poppedBubbles:Array = new Array();
		
		private var newRowLocation:Number = 6*bubbleHeight;
		
		private var leftTimer:Number = 0;
		private var rightTimer:Number = 0;
		
		private var timerText:FlxText;
		
		private var levelDetails:LevelDetails;
		
		override public function create():void
		{
			levelDetails = new ThreeColorBlitz();
			
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
				levelDetails.update(elapsed);
				// handle player input
				if (FlxG.keys.justPressed("LEFT")) {
					playerSprite.x = Math.max(playerSprite.x-columnWidth, 0);
				}
				if (FlxG.keys.justPressed("RIGHT")) {
					playerSprite.x = Math.min(playerSprite.x+columnWidth, columnWidth * (levelDetails.columnCount - 1));
				}
				if (FlxG.keys.justPressed("DOWN")) {
					playerSprite.x = columnWidth*(Math.floor(0.33333333 * (levelDetails.columnCount - 1)));
				}
				if (FlxG.keys.justPressed("UP")) {
					playerSprite.x = columnWidth*(Math.ceil(0.66666667 * (levelDetails.columnCount - 1)));
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
						playerSprite.x = columnWidth * (levelDetails.columnCount - 1);
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
					maybeAddConnectors(newPoppableBubbles);
					newRowLocation += bubbleHeight;
				}
			}
			// do we need to add new rows?
			if (gameState < 200 && newRowLocation > -bubbleHeight * 1.5) {
				// add new rows
				var newPoppableBubbles:Array = new Array();
				do {
					for (var i:int = 0; i < levelDetails.columnCount; i++) {
						var x:int = i * columnWidth;
						var y = (i % 2 == 0)?newRowLocation:newRowLocation - bubbleHeight * .5;
						var bubble:Bubble = new Bubble(levelDetails, x, y, levelDetails.nextBubbleColor());
						bubbles.add(bubble);
						if (!bubble.isAnchor()) {
							newPoppableBubbles.push(bubble);
						}
					}
					newRowLocation -= bubbleHeight;
				} while (newRowLocation > -bubbleHeight * 1.5);
				maybeAddConnectors(newPoppableBubbles);
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
					changeState(110, levelDetails.popDelay + levelDetails.popPerBubbleDelay * poppedBubbles.length);
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
					rowScrollTimer += levelDetails.rowScrollPixels();
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
				// did the player win?
				if (elapsed > levelDetails.levelDuration) {
					var text:FlxText = new FlxText(0, 0, FlxG.width, "You win!");
					text.alignment = "center";
					text.y = FlxG.height / 2 - text.height / 2;
					add(text);
					text = new FlxText(0, 0, FlxG.width, "Hit <Enter> to try again");
					text.alignment = "center";
					text.y = FlxG.height / 2 - text.height / 2 + text.height * 2;
					add(text);
					changeState(300);
					return;
				}
			}
			if (gameState == 110) {
				// change the bubble colors
				var popAnimState:int = (stateTime * 3) / levelDetails.popDelay;
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
					if ((i + 1) * levelDetails.popPerBubbleDelay + levelDetails.popDelay < stateTime) {
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
						if (suspendedBubbles.length > 0) {
							// if the player has suspended bubbles, transition to the "paused state"
							changeState(130, levelDetails.throwDuration);
						} else {
							// otherwise, transition to state 100
							changeState(100);
						}
					}
				}
			} else if (gameState == 120) {
				// drop some bubbles
				for (var i:int = 0; i < poppedBubbles.length; i++) {
					if ((i + 1) * levelDetails.dropPerBubbleDelay + levelDetails.dropDelay < stateTime) {
						var bubble:Bubble = poppedBubbles[i];
						if (bubble.acceleration.y == 0) {
							Embed.play(Embed.SfxBlip0);
							bubbles.remove(bubble);
							bubble.killConnectors();
							fallingBubbles.add(bubble);
							bubble.flicker(1000);
							bubble.velocity.y = 20;
							bubble.velocity.x = bubble.velocity.y;
							bubble.acceleration.y = 600;
						}
					}
				}
				// is the drop event over?
				if (stateTime >= stateDuration) {
					poppedBubbles.length = 0;
					if (suspendedBubbles.length > 0) {
						// if the player has suspended bubbles, transition to the "paused state"
						changeState(130, levelDetails.throwDuration);
					} else {
						// otherwise, transition to state 100
						changeState(100);
					}
				}
			} else if (gameState == 200 || gameState == 300) {
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
		
		private function maybeAddConnectors(newPoppableBubbles:Array):void {
			if (newPoppableBubbles.length > 0) {
				var positionMap:Object = newPositionMap();
				for each (var bubble:Bubble in newPoppableBubbles) {
					maybeAddConnector(bubble, positionMap[hashPosition(bubble.x, bubble.y + bubbleHeight)], Embed.Microbe0S);
					maybeAddConnector(bubble, positionMap[hashPosition(bubble.x - columnWidth, bubble.y + bubbleHeight / 2)], Embed.Microbe0Sw);
					maybeAddConnector(bubble, positionMap[hashPosition(bubble.x + columnWidth, bubble.y + bubbleHeight / 2)], Embed.Microbe0Se);
				}
			}
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
				changeState(120, levelDetails.dropDelay + poppedBubbles.length * levelDetails.dropPerBubbleDelay);
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
		
		private function orderByPosition(a:Bubble, b:Bubble):Number {
			if (a.y != b.y) {
				return b.y - a.y;
			}
			return a.x - b.x;
		}
	}
}