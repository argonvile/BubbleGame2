package
{
	import flash.utils.getTimer;
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.FlxColor;
	import levels.*;
	import levels.boring.*;
	import levels.cosmetic.*;
	import levels.mean.*;
	import levels.nice.*;
 
	public class PlayState extends FlxState
	{
		public static const bubbleHeight:int = 17;
		public static const columnWidth:int = 15;
		
		public var leftEdge:int = 8;
		public var playerSprite:PlayerSprite;
		public var bubbles:FlxGroup;
		public var connectors:FlxGroup;
		public var fallingBubbles:FlxGroup = new FlxGroup();
		private var popperEmitter:FlxEmitter = new FlxEmitter();
		
		public var elapsed:Number = 0;
		public var rowScrollTimer:Number = 0;
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
		public var poppedBubbles:Array = new Array();
		
		public var newRowLocation:Number;
		
		public var levelDetails:LevelDetails;
		
		private var bgSprite:FlxSprite;
		private var fgSprite:FlxSprite;
		private var playerMover:PlayerMover;
		public var scrollBubblesFunction:Function = scrollBubbles;
		
		private var playerLine:PlayerLine;
		public var comboSfxCount:Number = 0;
		public var comboLevel:int = 0;
		public var comboLevelBubbleCount:int = 0;
		public var speedupFactor:Number = 1.0;
		
		public var variableDifficultyMode:Boolean = false;
		private var nextDifficultyIncrementTime:int;
		private var difficultyIncrementFrequency:int = 3000;
		private var variableDifficultyDeaths:Array = new Array();
		private var returnClass:Class;
		private var thermometerGraphic:ThermometerGraphic;
		private var ekgGraphic:EkgGraphic;
		public var eliminatedBubbleCount:int = 0;
		
		public function PlayState(returnClass:Class=null, levelDetails:LevelDetails = null) {
			this.returnClass = returnClass;
			this.levelDetails = levelDetails;
		}
		
		override public function create():void
		{
			if (returnClass == null) {
				returnClass = AllLevelSelect;
			}
			if (levelDetails == null) {
				levelDetails = new Moustache(3);
			}
			
			if (variableDifficultyMode) {
				FlxG.timeScale = 6/7;
				levelDetails.levelDuration = 10;
				nextDifficultyIncrementTime = getTimer() + 10000 + difficultyIncrementFrequency;
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
			
			playerSprite = new PlayerSprite(leftEdge, 215);
			add(playerSprite);
			
			bubbles = new FlxGroup();
			add(bubbles);
			connectors = new FlxGroup();
			add(connectors);
			
			playerMover = new PlayerMover(playerSprite, leftEdge, levelDetails.columnCount);
			
			add(fallingBubbles);
			
			playerLine = new PlayerLine(this);
			add(playerLine);

			levelDetails.prepareLevel();
			for each (var bubble:Bubble in bubbles.members) {
				if (bubble != null && bubble.alive && bubble.y < newRowLocation) {
					newRowLocation = bubble.y;
				}
			}

			add(fgSprite);
			
			var thermometerPoint:FlxPoint;
			var ekgPoint:FlxPoint;
			if (levelDetails.columnCount <= 8) {
				thermometerPoint = new FlxPoint(178, 40);
				ekgPoint = new FlxPoint(233, 80);
			} else if (levelDetails.columnCount <= 11) {
				thermometerPoint = new FlxPoint(218, 40);
				ekgPoint = new FlxPoint(248, 100);
			} else {
				thermometerPoint = new FlxPoint(258, 40);
				ekgPoint = new FlxPoint(263, 120);
			}
			
			thermometerGraphic = new ThermometerGraphic(thermometerPoint.x, thermometerPoint.y, this);
			add(thermometerGraphic);
			
			ekgGraphic = new EkgGraphic(ekgPoint.x, ekgPoint.y);
			add(ekgGraphic);
		}
		
		public function scrollBg(howMany:int = 1):void {
			var remainingTime:Number = Math.max(10, levelDetails.levelDuration - elapsed);
			var spriteVelocity:Number = -bgSprite.y / remainingTime;
			bgSprite.y = Math.min(0, bgSprite.y + spriteVelocity * howMany * FlxG.elapsed);
			fgSprite.y = Math.min(0, fgSprite.y + spriteVelocity * howMany * FlxG.elapsed);
		}
		
		public function get heldBubbles():FlxGroup {
			return playerSprite.heldBubbles;
		}
		
		override public function update():void
		{
			stateTime += FlxG.elapsed;
			if (variableDifficultyMode) {
				ekgGraphic.setSeconds(elapsed);
			} else {
				ekgGraphic.setSeconds(Math.max(0, levelDetails.levelDuration - elapsed));
			}
			if (gameState < 200) {
				if (variableDifficultyMode && getTimer() >= nextDifficultyIncrementTime) {
					FlxG.timeScale = Math.min(50.0, FlxG.timeScale * Math.sqrt(7 / 6));
					nextDifficultyIncrementTime += difficultyIncrementFrequency;
				}
				// still alive...
				elapsed += FlxG.elapsed;
				levelDetails.update(elapsed);
				playerMover.movePlayerFromInput();
			}
			/**
			 * Update after moving the player -- to ensure stuff like bubbles track with the player correctly
			 */
			super.update();
			if (gameState < 200) {
				if (FlxG.keys.justPressed("ESCAPE")) {
					kill();
					FlxG.switchState(new returnClass());
					return;					
				}
				if (FlxG.keys.justPressed("Z")) {
					// find the next block above the player, and remove it
					grabBubbles();
				}
				if (FlxG.keys.justPressed("X")) {
					// find the next block above the player, and spit out our blocks below it
					for each (var heldBubble:Bubble in playerSprite.heldBubbles.members) {
						if (heldBubble != null && heldBubble.alive) {
							heldBubble.x = playerSprite.x;
							playerSprite.heldBubbles.remove(heldBubble);
							suspendedBubbles.push(heldBubble);
						}
					}
				}
				if (FlxG.keys.justPressed("C")) {
					scrollBubblesFunction.call(this, levelDetails.quickScrollPixels);
					levelDetails.bubblesScrolled();
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
			if (gameState < 300 && newRowLocation > levelDetails.minNewRowLocation) {
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
				var popCounter:PopCounter = levelDetails.newPopCounter(this);
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
					for (var i:int = 0; i < thrownBubbles.length; i++) {
						var thrownBubble:Bubble = thrownBubbles[i];
						if (thrownBubble != null && thrownBubble.alive) {
							popCounter.popMatches(thrownBubble);
							if (popCounter.shouldPopBubble(thrownBubble)) {
								thrownBubble.changeState(0);
								thrownBubbles[i] = null;
								maybeAddConnectorSingle(positionMap, thrownBubble)
							}
						}
					}
					
					poppedBubbles = popCounter.getPoppedBubbles();
					poppedBubbles.sort(orderByPosition);
					for each (var bubble:Bubble in poppedBubbles) {
						bubble.changeState(300);
					}
					comboLevelBubbleCount = 0;
					comboLevel++;
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
					rowScrollTimer += levelDetails.rowScrollPixels() * speedupFactor;
					scrollBg();
					if (rowScrollTimer > levelDetails.minScrollPixels) {
						var scrollAmount:Number = Math.floor(rowScrollTimer / levelDetails.minScrollPixels) * levelDetails.minScrollPixels;
						// scroll all the bubbles down a little
						scrollBubblesFunction.call(this, scrollAmount);
						levelDetails.bubblesScrolled();
						rowScrollTimer -= scrollAmount;
					}
					if (gameState == 100) {
						// kill the combo
						comboSfxCount = 0;
						comboLevel = 0;
						
						var badBubbleCount:int = countBadBubbles();
						if (badBubbleCount > 1000) {
							if (variableDifficultyMode) {
								// player would have lost; eliminate some bubbles and reset them
								changeState(130, 1.0 * FlxG.timeScale);
								variableDifficultyDeaths.push(FlxG.timeScale);
								if (variableDifficultyDeaths.length >= 9) {
									FlxG.timeScale = 1.0;
									changeState(200);
									var text:FlxText = new FlxText(0, 0, FlxG.width);
									text.text = BpmLevel.produceAverageText(variableDifficultyDeaths.slice(2));
									text.alignment = "center";
									text.y = FlxG.height / 2 - text.height / 2;
									add(text);
									
									text = new FlxText(0, text.y + text.height, FlxG.width);
									var smartAverage:Number = BpmLevel.computeSmartAverage(variableDifficultyDeaths.slice(3));
									var adjustedBpm:Number = PlayerSave.getBubblesPerMinute()/smartAverage;
									text.text = String(BpmLevel.roundTenths(PlayerSave.getBubblesPerMinute()));
									text.text += " / " + BpmLevel.roundTenths(smartAverage);
									text.text += " = " + BpmLevel.roundTenths(adjustedBpm) + " rating. difficulty ";
									text.text += PlayerData.getDifficultyIndex(adjustedBpm) + ", " + PlayerData.getDifficultyString(adjustedBpm);
									
									text.alignment = "center";
									add(text);
									
									text = new FlxText(0, text.y + text.height, FlxG.width, "Hit <Enter>");
									text.alignment = "center";
									add(text);
									return;
								}
								FlxG.timeScale = Math.max(0.02, FlxG.timeScale * 0.6);
								nextDifficultyIncrementTime = getTimer() + difficultyIncrementFrequency * 2;
								for each (var bubble:Bubble in bubbles.members) {
									if (bubble != null && bubble.alive) {
										bubble.kill();
									}
								}
								levelDetails.prepareLevel();
								for each (var bubble:Bubble in bubbles.members) {
									if (bubble != null && bubble.alive && bubble.y < newRowLocation) {
										newRowLocation = bubble.y;
									}
								}
								return;
							}
							
							// player loses. transition to state 200
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
						} else if (badBubbleCount > 0) {
							// player is in trouble
							speedupFactor += FlxG.elapsed * 5;
						} else {
							// player is safe
							speedupFactor = 1.0;
						}
					}
				}

				// did the player win?
				if (!variableDifficultyMode && (elapsed > levelDetails.levelDuration || eliminatedBubbleCount >= levelDetails.levelQuota)) {
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
					for each (var bubble:Bubble in poppedBubbles) {
						bubble.loadPopGraphic();
					}
				} else {
					for each (var bubble:Bubble in poppedBubbles) {
						if (bubble != null) {
							bubble.loadRegularGraphic();
						}
					}
				}
				for (var i:int = 0; i < poppedBubbles.length; i++) {
					if ((i + 1) * levelDetails.popPerBubbleDelay + levelDetails.popDelay < stateTime) {
						var poppedBubble:Bubble = poppedBubbles[i];
						if (poppedBubble != null && poppedBubble.alive) {
							poppedBubble.killConnectors();
							poppedBubble.kill();
							// after we kill it, it can be revived/reused for adding new bubbles.
							// so, let's make sure we don't reuse it by mistake
							poppedBubbles[i] = null;
							levelDetails.bubbleVanished(poppedBubble);
							if (poppedBubble.countsTowardsQuota) {
								eliminatedBubbleCount++;
							}
							levelDetails.playPopSound(comboSfxCount, comboLevel, comboLevelBubbleCount);
							comboLevelBubbleCount++;
							comboSfxCount += 1;
						}
					}
				}
				// is the pop event over?
				if (stateTime >= stateDuration) {
					levelDetails.bubblesFinishedPopping();
					// if so, remove popped bubbles
					poppedBubbles.length = 0;
					if (gameState == 110) {
						// if the player triggered a drop event, transition to state 120...
						checkForDetachedBubbles();
					}
					if (gameState == 110) {
						if (suspendedBubbles.length > 0) {
							// if the player has suspended bubbles, transition to the "paused state" until they're thrown
							changeState(130, levelDetails.throwDuration);
						} else {
							// otherwise, transition to the "paused state" for just 1 frame
							changeState(130, 0);
						}
					}
					for each (var fallingBubble:Bubble in fallingBubbles.members) {
						if (fallingBubble != null && fallingBubble.y > FlxG.height) {
							fallingBubble.kill();
							fallingBubbles.remove(fallingBubble);
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
							dropBubble(bubble);
						}
					}
				}
				// is the drop event over?
				if (stateTime >= stateDuration) {
					levelDetails.bubblesFinishedDropping(poppedBubbles);
					poppedBubbles.length = 0;
					if (suspendedBubbles.length > 0) {
						// if the player has suspended bubbles, transition to the "paused state" until they're thrown
						changeState(130, levelDetails.throwDuration);
					} else {
						// otherwise, transition to the "paused state" for just 1 frame
						changeState(130, 0);
					}
					// check if the user triggered another drop while we were dropping...
					checkForDetachedBubbles();
				}
			} else if (gameState == 200 || gameState == 300) {
				// game over
				if (gameState == 200) {
					rowScrollTimer += levelDetails.rowScrollPixels() * speedupFactor;
					if (rowScrollTimer > levelDetails.minScrollPixels) {
						var scrollAmount:Number = Math.floor(rowScrollTimer / levelDetails.minScrollPixels) * levelDetails.minScrollPixels;
						// scroll all the bubbles down a little
						scrollBubblesFunction.call(this, scrollAmount);
						levelDetails.bubblesScrolled();
						rowScrollTimer -= scrollAmount;
					}
					// removes bubbles off bottom of screen
					countBadBubbles();
				}
				if (FlxG.keys.justPressed("ENTER")) {
					kill();
					FlxG.switchState(new returnClass());
					return;
				}
			}
		}
		
		public function dropBubble(bubble:Bubble):void {
			eliminatedBubbleCount++;
			comboSfxCount += 0.3;
			bubbles.remove(bubble);
			bubble.killConnectors();
			fallingBubbles.add(bubble);
			bubble.flicker(1000);
			bubble.velocity.y = 20;
			bubble.velocity.x = bubble.velocity.y;
			bubble.acceleration.y = 600;
		}

		/**
		 * Counts the number of bubbles off the bottom of the screen. If any bubbles are WAY off the screen, this function kills those bubbles
		 * and returns a number greater than 9999.
		 */
		private function countBadBubbles():int {
			var badBubbleCount:int = 0;
			for each (var bubble:Bubble in bubbles.members) {
				if (bubble != null && bubble.alive && (bubble.y + bubble.height >= playerSprite.y) && bubble.state != 200) {
					badBubbleCount++;
					if (bubble.y > FlxG.height * 1.5) {
						bubble.kill();
						badBubbleCount = 9999;
					}
				}
			}
			return badBubbleCount;
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
			levelDetails.maybeAddConnector(bubble, positionMap[hashPosition(bubble.x, bubble.y - bubbleHeight)], Embed.Microbe0S); // N
			levelDetails.maybeAddConnector(bubble, positionMap[hashPosition(bubble.x + columnWidth, bubble.y - bubbleHeight / 2)], Embed.Microbe0Sw); // NE
			levelDetails.maybeAddConnector(bubble, positionMap[hashPosition(bubble.x + columnWidth, bubble.y + bubbleHeight / 2)], Embed.Microbe0Se); // SE
			levelDetails.maybeAddConnector(bubble, positionMap[hashPosition(bubble.x, bubble.y + bubbleHeight)], Embed.Microbe0S); // S
			levelDetails.maybeAddConnector(bubble, positionMap[hashPosition(bubble.x - columnWidth, bubble.y + bubbleHeight / 2)], Embed.Microbe0Sw); // SW
			levelDetails.maybeAddConnector(bubble, positionMap[hashPosition(bubble.x - columnWidth, bubble.y - bubbleHeight / 2)], Embed.Microbe0Se); // NW
		}
		
		public function addBubble(bubbleClass:Class):Bubble {
			var bubble:Bubble = bubbles.recycle(bubbleClass) as Bubble;
			bubble.revive();
			return bubble;
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
				if (maxBubble.y >= FlxG.height + bubbleHeight) {
					// we don't let people grab bubbles which are below the bottom of the screen -- this prevents
					// players from fudging their way through certain 2-3 color levels, where they could otherwise
					// play the level blind with some success
					if (firstGrab) {
						Embed.play(Embed.SfxBuzz, 0.5);
					}
					break;
				}
				if (!maxBubble.isGrabbable(playerSprite.heldBubbles, firstGrab)) {
					if (firstGrab) {
						Embed.play(Embed.SfxBuzz, 0.5);
					}
					break;
				}
				playerSprite.heldBubbles.add(maxBubble);
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