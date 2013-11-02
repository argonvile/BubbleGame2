package levels 
{
	import flash.utils.getTimer;
	import org.flixel.*;

	public class Kerosene extends LevelDetails
	{
		public static const name:String = "Kerosene";
		public static const scenarioBpms:Array = [47.1, 68.4, 114.3, 174.6, 273.0];
		private var scrollAmounts:ShuffledArray = new ShuffledArray();
		private var keroseneChance:ShuffledArray = new ShuffledArray();
		private var explosionLayer:FlxGroup;
		private var bigShake:Boolean = false;
		
		public function Kerosene(scenario:int) 
		{
			super(scenario);
			minNewRowLocation = -PlayState.bubbleHeight * 8.5;
			avgChainLength = 11;
			popPerBubbleDelay = 1 / 90;
			for (var i:int = 0; i < 50; i++) {
				keroseneChance.push(0);
			}
			if (scenario == 0) {
				maxBubbleRate = 363;
				scrollAmounts.push(1, 2);
				keroseneChance.push(1, 1, 1);
				columnCount = 13;
			} else if (scenario == 1) {
				maxBubbleRate = 544;
				columnCount = 15;
				scrollAmounts.push(1, 1, 2, 3);
				keroseneChance.push(1, 1, 1, 1, 1);
			} else if (scenario == 2) {
				maxBubbleRate = 817;
				columnCount = 15;
				scrollAmounts.push(1, 1, 1, 2, 3, 3);
				keroseneChance.push(1, 1, 1);
			} else if (scenario == 3) {
				maxBubbleRate = 1226;
				columnCount = 13;
				scrollAmounts.push(1, 1, 1, 2, 3, 3, 5);
				keroseneChance.push(1, 1, 1, 1, 1);
			} else if (scenario == 4) {
				maxBubbleRate = 1839;
				columnCount = 11;
				scrollAmounts.push(1, 1, 1, 2, 3, 3, 5, 5);
				keroseneChance.push(1, 1);
			}
			scrollAmounts.reset();
			keroseneChance.reset();
			minScrollPixels = PlayState.bubbleHeight * 3;
		}
		
		override public function nextBubble(x:Number, y:Number):Bubble {
			if (keroseneChance.next() == 1) {
				var nextDefaultBubble:BombBubble = playState.addBubble(BombBubble) as BombBubble;
				nextDefaultBubble.init(this, x, y);
				return nextDefaultBubble;
			} else {
				return super.nextBubble(x, y);
			}
		}
		
		override public function bubblesScrolled():void {
			minScrollPixels = PlayState.bubbleHeight * int(scrollAmounts.next());
		}
		
		override public function bubbleVanished(bubble:Bubble):void {
			var flxParticle:FlxParticle = explosionLayer.recycle(FlxParticle) as FlxParticle;
			flxParticle.revive();
			if (flxParticle.width == 16) {
				// just loaded
				flxParticle.loadGraphic(Embed.Explosion, true, false, 50, 50);
				flxParticle.addAnimation("play0", [0,1,2], 20);
				flxParticle.addAnimation("play1", [3,4,5], 20);
				flxParticle.addAnimation("play2", [6,7,8], 20);
				flxParticle.origin.x = 25;
				flxParticle.origin.y = 25;
			}
			flxParticle.lifespan = 3/20;
			flxParticle.x = bubble.x + bubble.width / 2 - flxParticle.width / 2;
			flxParticle.y = bubble.y + bubble.height / 2 - flxParticle.height / 2;
			flxParticle.play("play" + int(Math.random()*3), true);
			flxParticle.angle = 360 * Math.random();
			
			if (bubble is BombBubble) {
				bigShake = true;
				FlxG.shake(0.006, 0.2, bigShakeDone, true);
				Embed.playAny([Embed.SfxBigBoulder0, Embed.SfxBigBoulder1, Embed.SfxBigBoulder2]);
				for each (var neighbor:Bubble in playState.bubbles.members) {
					if (neighbor != null && Math.sqrt((neighbor.x - bubble.x) * (neighbor.x - bubble.x) + (neighbor.y - bubble.y) * (neighbor.y - bubble.y)) <= PlayState.bubbleHeight * 2.5) {
						if (neighbor is DefaultBubble && !neighbor.isAnchor() && neighbor.state == 0) {
							var neighborDefaultBubble:DefaultBubble = neighbor as DefaultBubble;
							playState.dropBubble(neighbor);
							neighbor.velocity.x = Math.random() * 50 - 25 + 15 * (neighbor.x - bubble.x);
							neighbor.velocity.y = Math.random() * 50 - 25 + 15 * (neighbor.y - bubble.y);
							neighborDefaultBubble.setBubbleColor(0xff000000);
						} else if (neighbor is BombBubble && !neighbor.isAnchor() && neighbor.state == 0) {
							var neighborBomb:BombBubble = neighbor as BombBubble;
							neighborBomb.state = 300;
							playState.poppedBubbles.push(neighborBomb);
							playState.stateDuration += popPerBubbleDelay;
						}
					}
				}
			} else {
				var positionMap:Object = playState.newPositionMap();
				for each (var position:String in [
					playState.hashPosition(bubble.x, bubble.y - PlayState.bubbleHeight),
					playState.hashPosition(bubble.x + PlayState.columnWidth, bubble.y - PlayState.bubbleHeight/2),
					playState.hashPosition(bubble.x + PlayState.columnWidth, bubble.y + PlayState.bubbleHeight/2),
					playState.hashPosition(bubble.x, bubble.y + PlayState.bubbleHeight),
					playState.hashPosition(bubble.x - PlayState.columnWidth, bubble.y + PlayState.bubbleHeight/2),
					playState.hashPosition(bubble.x - PlayState.columnWidth, bubble.y - PlayState.bubbleHeight/2)
				]) {
					var neighbor:Bubble = positionMap[position] as Bubble;
					if (neighbor is DefaultBubble && !neighbor.isAnchor() && neighbor.state == 0) {
						var neighborDefaultBubble:DefaultBubble = neighbor as DefaultBubble;
						playState.dropBubble(neighbor);
						neighbor.velocity.x = Math.random() * 50 - 25 + 15 * (neighbor.x - bubble.x);
						neighbor.velocity.y = Math.random() * 50 - 25 + 15 * (neighbor.y - bubble.y);
						neighborDefaultBubble.setBubbleColor(0xff000000);
					} else if (neighbor is BombBubble && !neighbor.isAnchor() && neighbor.state == 0) {
						var neighborBomb:BombBubble = neighbor as BombBubble;
						neighborBomb.state = 300;
						playState.poppedBubbles.push(neighborBomb);
						playState.stateDuration += popPerBubbleDelay;
					}
				}
			}
		}
		
		private function bigShakeDone() {
			bigShake = false;
		}
		
		override public function playPopSound(comboSfxCount:Number, comboLevel:int, comboLevelBubbleCount:int):void {
			if (!bigShake) {
				FlxG.shake(0.002, 0.05, null, false);
			}
			if (comboLevelBubbleCount == 0) {
				Embed.playAny([Embed.SfxBigBoulder0, Embed.SfxBigBoulder1, Embed.SfxBigBoulder2]);
			}
		}
		
		override public function prepareLevel():void {
			super.prepareLevel();
			if (explosionLayer == null) {
				explosionLayer = new FlxGroup();
				playState.add(explosionLayer);
			}
		}
	}
}