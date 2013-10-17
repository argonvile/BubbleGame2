package
{
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.FlxColor;
	import levels.*;
 
	public class PlayState extends FlxState
	{
		public static const bubbleHeight:int = 17;
		public static const columnWidth:int = 15;
		
		public var leftEdge:int = 8;
		public var playerSprite:FlxSprite;
		public var bubbles:FlxGroup;
		private var connectors:FlxGroup;
		private var fallingBubbles:FlxGroup = new FlxGroup();
		public var heldBubbles:FlxGroup = new FlxGroup();
		private var popperEmitter:FlxEmitter = new FlxEmitter();
		
		private var elapsed:Number = 0;
		private var rowScrollTimer:Number = 0;
		/**
		 * 100 == normal
		 * 110 == popping
		 * 120 == dropping
		 * 130 == scrolling paused
		 * 140-149 == custom (paused, non-interactive)
		 * 200 == game over (lose)
		 * 300 == game over (win)
		 */
		public var gameState:int = 100;
		public var stateTime:Number = 0;
		public var stateDuration:Number = 0;
		
		public var suspendedBubbles:Array = new Array();
		private var thrownBubbles:Array = new Array();
		private var poppedBubbles:Array = new Array();
		
		public var newRowLocation:Number;
		
		private var timerText:FlxText;
		
		private var levelDetails:LevelDetails;
		
		private var bgSprite:FlxSprite;
		private var fgSprite:FlxSprite;
		private var playerMover:PlayerMover;
		public var scrollBubblesFunction:Function = scrollBubbles;
		
		private var playerLine:PlayerLine;
		public var comboSfxCount:Number = 0;
		
		public function PlayState(levelDetails:LevelDetails=null) {
			this.levelDetails = levelDetails;
		}
		
		override public function create():void
		{
			if (levelDetails == null) {
				levelDetails = new LuckySeven(4);
			}
			levelDetails.init(this);
			
			var tempSprite:FlxSprite;
			tempSprite = new FlxSprite(0, 0, Embed.GutsBg);
			tempSprite.alpha = 0.6;
			tempSprite.scale.x = 480 / tempSprite.width;
			tempSprite.scale.y = 480 / tempSprite.height;
			tempSprite.width = 480;
			tempSprite.height = 480;
			tempSprite.setOriginToCorner();
			
			bgSprite = new FlxSprite(0, -240);
			bgSprite.makeGraphic(480, 480, 0xff000000);
			bgSprite.stamp(tempSprite, 0, 0);
			
			tempSprite.loadGraphic(Embed.GutsFg);
			tempSprite.alpha = 1.0;
			tempSprite.setOriginToCorner();
			
			fgSprite = new FlxSprite(0, -240);
			fgSprite.makeGraphic(480, 480, 0x00000000);
			fgSprite.stamp(tempSprite, leftEdge - 480, 0);
			fgSprite.stamp(tempSprite, leftEdge + levelDetails.columnCount * columnWidth + 2, 0);
			
			tempSprite.loadGraphic(Embed.GutsEdge);
			tempSprite.setOriginToCorner();
			fgSprite.stamp(tempSprite, leftEdge - 5, 0);
			fgSprite.stamp(tempSprite, leftEdge + levelDetails.columnCount * columnWidth + 2 - 5, 0);
			
			add(bgSprite);
			
			bubbles = new FlxGroup();
			add(bubbles);
			connectors = new FlxGroup();
			add(connectors);
			
			playerSprite = new FlxSprite(leftEdge, 224);
			playerSprite.makeGraphic(columnWidth, bubbleHeight, 0xffcccccc);
			playerSprite.offset.x = -1;
			add(playerSprite);
			
			playerMover = new PlayerMover(playerSprite, leftEdge, levelDetails.columnCount);
			
			add(heldBubbles);
			add(fallingBubbles);
			
			timerText = new FlxText(290, 0, 100, "0.0");
			add(timerText);
			
			add(fgSprite);
			
			levelDetails.prepareLevel();
			for each (var bubble:Bubble in bubbles.members) {
				if (bubble != null && bubble.alive && bubble.y < newRowLocation) {
					newRowLocation = bubble.y;
				}
			}
			
			playerLine = new PlayerLine(this);
			add(playerLine);
		}
		
		private function scrollBg(howMany:int=1):void {
			var remainingTime:Number = Math.max(10, levelDetails.levelDuration - elapsed);
			var spriteVelocity:Number = -bgSprite.y / remainingTime;
			bgSprite.y = Math.min(0, bgSprite.y + spriteVelocity * howMany * FlxG.elapsed);
			fgSprite.y = Math.min(0, fgSprite.y + spriteVelocity * howMany * FlxG.elapsed);
		}
		
		override public function update():void
		{
			super.update();
			stateTime += FlxG.elapsed;
			timerText.text = String(Math.round(stateTime * 100) / 100);
			if (gameState < 200) {
				// still alive...
				elapsed += FlxG.elapsed;
				levelDetails.update(elapsed);
				playerMover.movePlayerFromInput();
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
					scrollBubblesFunction.call(this, levelDetails.quickScrollPixels);
					scrollBg(bubbleHeight);
				}
				var justScrolledBubbles:Array = new Array();
				for each (var bubble:Bubble in bubbles.members) {
					if (bubble != null && bubble.alive) {
						if (bubble.justFinishedQuickApproach()) {
							justScrolledBubbles.push(bubble);
						}
					}
				}
				maybeAddConnectors(justScrolledBubbles);				
			}
			playerLine.finalUpdate();
			if (gameState < 200 && newRowLocation > levelDetails.minNewRowLocation) {
				// need to add new rows
				var removedNullBubbles:Boolean = false;
				var newPoppableBubbles:Array = new Array();
				do {
					for (var i:int = 0; i < levelDetails.columnCount; i++) {
						var x:Number = leftEdge + i * columnWidth;
						var y:Number = (i % 2 == 0)?newRowLocation:newRowLocation - bubbleHeight * .5;
						var nextBubble:Bubble = levelDetails.nextBubble(x, y);
						if (nextBubble is NullBubble) {
							if (nextBubble.isAnchor()) {
								bubbles.add(nextBubble);
							} else {
								removedNullBubbles = true;
							}
						} else {
							bubbles.add(nextBubble);
							if (!nextBubble.isAnchor()) {
								newPoppableBubbles.push(nextBubble);
							}
						}
					}
					newRowLocation -= bubbleHeight;
				} while (newRowLocation > levelDetails.minNewRowLocation);
				if (removedNullBubbles && (gameState == 100 || gameState == 130)) {
					checkForDetachedBubbles();
				}
				maybeAddConnectors(newPoppableBubbles);
			}
			if (gameState == 100 || gameState == 130) {
				// playfield is currently interactive...
				
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
							thrownBubbles[i] = null;
							maybeAddConnectorSingle(positionMap, thrownBubble)
							popCounter.popMatches(thrownBubble);
						}
					}
				}
				// did the player trigger a pop event?
				// if so, transition to state 110...
				if (popCounter.shouldPop()) {
					poppedBubbles = popCounter.getPoppedBubbles();
					poppedBubbles.sort(orderByPosition);
					for each (var bubble:Bubble in poppedBubbles) {
						bubble.changeState(300);
					}
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
					scrollBg();
					if (rowScrollTimer > levelDetails.minScrollPixels) {
						var scrollAmount:Number = Math.floor(rowScrollTimer / levelDetails.minScrollPixels) * levelDetails.minScrollPixels;
						// scroll all the bubbles down a little
						scrollBubblesFunction.call(this, scrollAmount);
						rowScrollTimer -= scrollAmount;
					}
					if (gameState == 100) {
						// kill the combo
						comboSfxCount = 0;
						
						// did the player lose?
						for each (var bubble:Bubble in bubbles.members) {
							if (bubble != null && bubble.alive && bubble.y > 232 && bubble.state != 200) {
								// yes, they lost. transition to state 200
								changeState(200);
								var text:FlxText = new FlxText(0, 0, FlxG.width, "You lasted " + Math.round(elapsed) + "." + (Math.round(elapsed * 10) % 10) + "s");
								text.alignment = "center";
								text.y = FlxG.height / 2 - text.height / 2;
								add(text);
								text = new FlxText(0, 0, FlxG.width, "Hit <Enter>");
								text.alignment = "center";
								text.y = FlxG.height / 2 - text.height / 2 + text.height * 2;
								add(text);
								return;
							}
						}
					}
				}

				// did the player win?
				if (elapsed > levelDetails.levelDuration) {
					var text:FlxText = new FlxText(0, 0, FlxG.width, "You win!");
					text.alignment = "center";
					text.y = FlxG.height / 2 - text.height / 2;
					add(text);
					text = new FlxText(0, 0, FlxG.width, "Hit <Enter>");
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
					for each (var defaultBubble:DefaultBubble in poppedBubbles) {
						if (defaultBubble != null) {
							defaultBubble.loadPopGraphic();
						}
					}
				} else {
					for each (var defaultBubble:DefaultBubble in poppedBubbles) {
						if (defaultBubble != null) {
							defaultBubble.loadRegularGraphic();	
						}
					}
				}
				for (var i:int = 0; i < poppedBubbles.length; i++) {
					if ((i + 1) * levelDetails.popPerBubbleDelay + levelDetails.popDelay < stateTime) {
						var poppedBubble:DefaultBubble = poppedBubbles[i];
						if (poppedBubble.visible) {
							poppedBubble.visible = false;
							poppedBubble.killConnectors();
							levelDetails.bubbleVanished(poppedBubble);
							Embed.playPopSound(comboSfxCount);
							comboSfxCount += 1;
						}
					}
				}
				// is the pop event over?
				if (stateTime >= stateDuration) {
					levelDetails.bubblesFinishedPopping(poppedBubbles);
					// if so, remove popped bubbles
					for each (var bubble:Bubble in poppedBubbles) {
						bubble.kill();
					}
					poppedBubbles.length = 0;
					if (gameState == 110) {
						// if the player triggered a drop event, transition to state 120...
						checkForDetachedBubbles();
					}
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
							Embed.playPopSound(comboSfxCount);
							comboSfxCount += 0.3;
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
					changeState(100);
					// check if the user triggered another drop while we were dropping...
					checkForDetachedBubbles();
					if (gameState == 100) {
						if (suspendedBubbles.length > 0) {
							// if the player has suspended bubbles, transition to the "paused state"
							changeState(130, levelDetails.throwDuration);
						}
					}
				}
			} else if (gameState == 200 || gameState == 300) {
				// game over
				if (FlxG.keys.justPressed("ENTER")) {
					kill();
					FlxG.switchState(new LevelSelect());
					return;
				}
			}
		}
		
		public function scrollBubbles(scrollAmount:Number):void {
			newRowLocation += scrollAmount;
			var newPoppableBubbles:Array = new Array();
			var removedNullBubbles:Boolean = false;
			for each (var bubble:Bubble in bubbles.members) {
				if (bubble != null && bubble.alive) {
					var wasAnchor:Boolean = bubble.isAnchor();
					bubble.y += scrollAmount;
					if (scrollAmount >= bubbleHeight) {
						bubble.quickApproach(scrollAmount);
					}
					bubble.updateAlpha();
					if (!bubble.isAnchor() && wasAnchor) {
						if (bubble is NullBubble) {
							bubbles.remove(bubble);
							removedNullBubbles = true;
						} else {
							newPoppableBubbles.push(bubble);
						}
					}
				}
			}
			if (removedNullBubbles && (gameState == 100 || gameState == 130)) {
				checkForDetachedBubbles();
			}
			for each (var connector:Connector in connectors.members) {
				if (connector != null && connector.alive) {
					connector.y += scrollAmount;
				}
			}
			maybeAddConnectors(newPoppableBubbles);			
		}
		
		public function changeState(newState:int, stateDuration:Number=0):void {
			gameState = newState;
			stateTime = 0;
			this.stateDuration = stateDuration;
		}
		
		public function maybeAddConnectors(newPoppableBubbles:Array):void {
			if (newPoppableBubbles.length > 0) {
				var positionMap:Object = newPositionMap();
				for each (var bubble:Bubble in newPoppableBubbles) {
					maybeAddConnectorSingle(positionMap, bubble);
				}
			}
		}
		
		public function maybeAddConnectorSingle(positionMap:Object, bubble:Bubble):void {
			maybeAddConnector(bubble, positionMap[hashPosition(bubble.x, bubble.y - bubbleHeight)], Embed.Microbe0S); // N
			maybeAddConnector(bubble, positionMap[hashPosition(bubble.x + columnWidth, bubble.y - bubbleHeight / 2)], Embed.Microbe0Sw); // NE
			maybeAddConnector(bubble, positionMap[hashPosition(bubble.x + columnWidth, bubble.y + bubbleHeight / 2)], Embed.Microbe0Se); // SE
			maybeAddConnector(bubble, positionMap[hashPosition(bubble.x, bubble.y + bubbleHeight)], Embed.Microbe0S); // S
			maybeAddConnector(bubble, positionMap[hashPosition(bubble.x - columnWidth, bubble.y + bubbleHeight / 2)], Embed.Microbe0Sw); // SW
			maybeAddConnector(bubble, positionMap[hashPosition(bubble.x - columnWidth, bubble.y - bubbleHeight / 2)], Embed.Microbe0Se); // NW
		}
		
		public function maybeAddConnector(bubble:Bubble, bubbleS:Bubble, graphic:Class):void {
			if (bubble is DefaultBubble && bubbleS is DefaultBubble) {
				if (bubble.offset.y != bubbleS.offset.y) {
					return;
				}
				if (bubble.offset.x != bubbleS.offset.x) {
					return;
				}
				if (bubble.isAnchor() || bubbleS.isAnchor()) {
					return;
				}
				if (!bubble.visible || !bubbleS.visible) {
					return;
				}
				if (bubble.isConnected(bubbleS)) {
					return;
				}
				var defaultBubble:DefaultBubble = bubble as DefaultBubble;
				var defaultBubbleS:DefaultBubble = bubbleS as DefaultBubble;
				if (defaultBubbleS.bubbleColor == defaultBubble.bubbleColor) {
					var connector:DefaultConnector = connectors.recycle(DefaultConnector) as DefaultConnector;
					connector.revive();
					connector.init(defaultBubble, defaultBubbleS, graphic);
					connector.offset.y = defaultBubble.offset.y;
					connectors.add(connector);
					defaultBubble.connectors.push(connector);
					defaultBubbleS.connectors.push(connector);
				}
			}
		}
		
		public function checkForDetachedBubbles():void {
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
					positionMap[position].changeState(300);
				}
			}
			if (poppedBubbles.length > 0) {
				poppedBubbles.sort(orderByPosition);
				changeState(120, levelDetails.dropDelay + poppedBubbles.length * levelDetails.dropPerBubbleDelay);
			}
		}
		
		private function grabBubbles():void {
			var maxBubble:Bubble = lowestBubble() as Bubble;
			var positionMap:Object = newPositionMap();
			var y:Number = maxBubble.y;
			var firstGrab:Boolean = true;
			while (maxBubble != null) {
				if (!maxBubble.isGrabbable(heldBubbles, firstGrab)) {
					break;
				}
				heldBubbles.add(maxBubble);
				bubbles.remove(maxBubble);
				maxBubble.killConnectors();
				maxBubble.wasGrabbed(playerSprite);
				for (var i:int = 0; i < thrownBubbles.length; i++) {
					if (thrownBubbles[i] == maxBubble) {
						thrownBubbles[i] = null;
					}
				}
				maxBubble = positionMap[hashPosition(maxBubble.x, maxBubble.y - bubbleHeight)];
				firstGrab = false;
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
		
		public function lowestBubble(x:Number = -9999):Bubble {
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
		
		public function orderByPosition(a:Bubble, b:Bubble):Number {
			if (a.y != b.y) {
				return b.y - a.y;
			}
			return a.x - b.x;
		}
	}
}