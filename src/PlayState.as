package
{
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.FlxColor;
 
	public class PlayState extends FlxState
	{
		private var bubbleHeight:int = 17;
		private var bubbleWidth:int = 17;
		private var columnWidth:int = 15;
		
		private var playerSprite:FlxSprite;
		private var bubbles:FlxGroup;
		private var connectors:FlxGroup;
		private var droppedBubbles:FlxGroup = new FlxGroup();
		private var heldBubbles:FlxGroup = new FlxGroup();
		private var popperEmitter:FlxEmitter = new FlxEmitter();
		private var bubbleRate:Number = 120; // bubbles per minute
		private var bubbleLifespan:Number = 0; // if bubbles are popping
		
		private var elapsed:Number = 0;
		private var rowScrollTimer:Number = 0;
		private var gameState:int = 100;
		private var suspendedBubbles:Array = new Array();
		private var thrownBubbles:Array = new Array();
		private var newRowLocation:Number = -bubbleHeight;
		private var scrollPause:Number = 0;
		
		private var leftTimer:Number = 0;
		private var rightTimer:Number = 0;
		
		private const POP_DURATION:Number = 0.8;
		
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
			add(droppedBubbles);
		}
		
		override public function update():void
		{
			super.update();
			if(bubbleLifespan > 0) {
				bubbleLifespan -= FlxG.elapsed;
				if(bubbleLifespan <= 0) {
					dropDetachedBubbles();
					if (suspendedBubbles.length > 0) {
						scrollPause = Bubble.THROW_DURATION;
					}
				}
			}
			// handle dropped bubbles
			for each (var droppedBubble:Bubble in droppedBubbles.members) {
				if (droppedBubble != null && droppedBubble.alive) {
					if (droppedBubble.y > FlxG.height) {
						droppedBubble.kill();
					}
				}
			}
			if (gameState == 100) {
				elapsed += FlxG.elapsed;
				bubbleRate += FlxG.elapsed * 3;
				if (bubbleLifespan <= 0) {
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
					var thrownBubbleCount:int = 0;
					for (var i:int = 0; i < thrownBubbles.length; i++) {
						var thrownBubble:Bubble = thrownBubbles[i];
						if (thrownBubble != null && thrownBubble.alive) {
							if (thrownBubble.state == 200) {
								thrownBubbleCount++;
							} else {
								thrownBubbles[i] = null;
								popMatches(thrownBubble);
							}
						}
					}
					if (thrownBubbleCount == 0 && thrownBubbles.length > 0) {
						thrownBubbles.length = 0;
					}
				}
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
					dropDetachedBubbles();
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
				if (bubbleLifespan <= 0) {
					if (scrollPause > 0) {
						scrollPause -= FlxG.elapsed;
					} else {
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
				}
				if (newRowLocation > -bubbleHeight*1.5) {
					// add a new row
					do {
						for each (var position:Array in [[0, newRowLocation], [columnWidth, newRowLocation-bubbleHeight*.5], [columnWidth*2, newRowLocation], [columnWidth*3, newRowLocation-bubbleHeight*.5], [columnWidth*4, newRowLocation], [columnWidth*5, newRowLocation-bubbleHeight*.5]]) {
							var mySprite:FlxSprite = new Bubble(position[0], position[1], randomColor());
							bubbles.add(mySprite);
						}
						newRowLocation -= bubbleHeight;
					} while (newRowLocation > -bubbleHeight*1.5);
					// check if they lose
					if (bubbleLifespan <= 0 && scrollPause <= 0) {
						for each (var bubble:Bubble in bubbles.members) {
							if (bubble != null && bubble.alive && bubble.y > 232 && bubble.state == 0) {
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
				}
			} else if (gameState == 200) {
				if (FlxG.keys.justPressed("ENTER")) {
					kill();
					FlxG.switchState(new PlayState());
					return;
				}
			}
		}
		
		private function maybeAddConnector(bubble:Bubble, bubbleS:Bubble, graphic:Class):void {
			if (bubbleS != null && bubbleS.bubbleColor == bubble.bubbleColor) {
				var connector:Connector = connectors.recycle(Connector) as Connector;
				connector.revive();
				connector.init(bubble, bubbleS, graphic);
				connectors.add(connector);
				bubble.connectors.push(connector);
				bubbleS.connectors.push(connector);
			}
		}
		
		private function dropDetachedBubbles():void {
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
					var bubble:Bubble = positionMap[position];
					if (bubble.alive) {
						bubbles.remove(bubble);
						bubble.killConnectors();
						droppedBubbles.add(bubble);
						bubble.flicker(1000);
						bubble.velocity.y = (bubbleRate * bubbleHeight / 6) / 60;
						bubble.velocity.x = bubble.velocity.y;
						bubble.acceleration.y = 600;
					}
				}
			}
		}
		
		private function popMatches(maxBubble:Bubble):void {
			// create map
			var positionMap:Object = newPositionMap();
			var bubblesToCheck:Array = new Array(maxBubble);
			var iBubblesToCheck:int = 0;
			
			maybeAddConnector(maxBubble, positionMap[hashPosition(maxBubble.x - columnWidth, maxBubble.y + bubbleHeight / 2)], Embed.Microbe0Sw); // SW
			maybeAddConnector(maxBubble, positionMap[hashPosition(maxBubble.x - columnWidth, maxBubble.y - bubbleHeight / 2)], Embed.Microbe0Se); // NW
			maybeAddConnector(maxBubble, positionMap[hashPosition(maxBubble.x, maxBubble.y - bubbleHeight)], Embed.Microbe0S); // N
			maybeAddConnector(maxBubble, positionMap[hashPosition(maxBubble.x + columnWidth, maxBubble.y - bubbleHeight / 2)], Embed.Microbe0Sw); // NE
			maybeAddConnector(maxBubble, positionMap[hashPosition(maxBubble.x + columnWidth, maxBubble.y + bubbleHeight / 2)], Embed.Microbe0Se); // SE
			
			do {
				var bubbleToCheck:Bubble = bubblesToCheck[iBubblesToCheck];
				positionMap[hashPosition(bubbleToCheck.x, bubbleToCheck.y)] = null;
				for each (var position:String in [
					hashPosition(bubbleToCheck.x, bubbleToCheck.y - bubbleHeight),
					hashPosition(bubbleToCheck.x + columnWidth, bubbleToCheck.y - bubbleHeight/2),
					hashPosition(bubbleToCheck.x + columnWidth, bubbleToCheck.y + bubbleHeight/2),
					hashPosition(bubbleToCheck.x, bubbleToCheck.y + bubbleHeight),
					hashPosition(bubbleToCheck.x - columnWidth, bubbleToCheck.y + bubbleHeight/2),
					hashPosition(bubbleToCheck.x - columnWidth, bubbleToCheck.y - bubbleHeight/2)
				]) {
					var neighbor:Bubble = positionMap[position];
					if (neighbor != null && neighbor.bubbleColor == bubbleToCheck.bubbleColor) {
						positionMap[position] = null;
						bubblesToCheck.push(neighbor);
					}
				}
			} while (++iBubblesToCheck < bubblesToCheck.length);
			
			if (iBubblesToCheck >= 4) {
				bubbleLifespan = POP_DURATION;
				for each(var bubble:Bubble in bubblesToCheck) {
					bubble.wasPopped(bubbleLifespan);
				}
			}
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
				} else if (maxBubble.lifespan > 0) {
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
		
		private function newPositionMap():Object {
			var positionMap:Object = new Object();
			for each (var bubble:Bubble in bubbles.members) {
				if (bubble != null && bubble.alive && !bubble.isAnchor()) {
					positionMap[hashPosition(bubble.x, bubble.y)] = bubble;
				}
			}
			return positionMap;
		}
		
		private function hashPosition(x:Number, y:Number):Object {
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
	}
}