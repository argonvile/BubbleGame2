package  
{
	import org.flixel.*;

	public class Bubble extends FlxSprite
	{
		/**
		 * state
		 * 0 = normal
		 * 100 = grabbing
		 * 200 = throwing
		 * 300 = popping
		 */
		public var state:int = 0;
		public var stateTime:Number = 0;
		protected var playerPoint:PlayerSprite;
		public var quickApproachTime:Number = 0;
		public var quickApproachDistance:Number;
		protected var levelDetails:LevelDetails;
		public var connectors:Array = new Array();
		public var countsTowardsQuota:Boolean = true;

		public function Bubble() 
		{
		}
		
		public function init(levelDetails:LevelDetails, x:Number, y:Number):void {
			this.levelDetails = levelDetails;
			this.x = x;
			this.y = y;
			this.state = 0;
			this.stateTime = 0;
			this.playerPoint = null;
			this.quickApproachTime = 0;
			this.quickApproachDistance = 0;
			this.connectors.length = 0;
			visible = true;
		}
		
		public function updateAlpha():void {
			if (isAnchor()) {
				alpha = 0.6;
			} else {
				alpha = 1.0;
			}		
		}
		
		public function isAnchor():Boolean {
			return y < 0;
		}
		
		public function wasGrabbed(playerPoint:PlayerSprite):void {
			changeState(100);
			this.playerPoint = playerPoint;
			offset.x = 0;
			offset.y = 0;
			addQuickApproachToOffset();
		}
		
		public function wasThrown(playerPoint:PlayerSprite):void {
			changeState(200);
			this.playerPoint = playerPoint;
			offset.x = (x + width / 2) - (playerPoint.getMidpoint().x);
			offset.y = (y + height / 2) - (playerPoint.getMidpoint().y);
			addQuickApproachToOffset();
		}
		
		public function resetQuickApproach():void {
			offset.y = 0;
			this.quickApproachDistance = 0;
			this.quickApproachTime = 0;
			updateConnectorOffsets();
		}
		
		public function quickApproach(distance:Number):void {
			this.quickApproachDistance = distance;
			this.quickApproachTime = 0;
			offset.y += distance;
			updateConnectorOffsets();
		}
		
		/**
		 * @return True if the bubble should be displayed stationary, as held by the player
		 */
		public function isHeld():Boolean {
			return state == 100 && stateTime >= levelDetails.grabDuration;
		}
		
		override public function update():void {
			super.update();
			stateTime += FlxG.elapsed;
			if (state == 100) {
				// grabbing; apply grab offsets
				var statePct:Number = Math.min(1, Math.pow(stateTime / levelDetails.grabDuration, 2.5));
				offset.x = statePct * ((x + width / 2) - (playerPoint.getMidpoint().x));
				offset.y = statePct * ((y + height / 2) - (playerPoint.getMidpoint().y));
			} else if (state == 200) {
				// throwing; apply throw offsets
				var statePct:Number = Math.min(1, Math.pow(stateTime / levelDetails.throwDuration, 1.5));
				offset.x = (1 - statePct) * ((x + width / 2) - (playerPoint.getMidpoint().x));
				offset.y = (1 - statePct) * ((y + height / 2) - (playerPoint.getMidpoint().y));
				if (statePct >= 1.0) {
					changeState(0);
				}
			} else {
				// no offsets
				offset.x = 0;
				offset.y = 0;
			}
			if (quickApproachDistance > 0) {
				quickApproachTime += FlxG.elapsed;
				// apply 'quick approach' offsets
				var statePct:Number = addQuickApproachToOffset();
				updateConnectorOffsets();
				if (statePct == 0) {
					quickApproachDistance = -1
				}
			} else if (quickApproachDistance == -1) {
				quickApproachDistance = 0;
			}
			updateAlpha();
		}
		
		private function addQuickApproachToOffset():Number {
			var statePct:Number = Math.pow(1 - Math.min(1, quickApproachTime / levelDetails.grabDuration), 2.5);
			offset.y += quickApproachDistance * statePct;
			return statePct;
		}
		
		public function justFinishedQuickApproach():Boolean {
			return quickApproachDistance == -1;
		}
		
		protected function updateConnectorOffsets():void {
			for each (var connector:Connector in connectors) {
				if (connector != null && connector.alive) {
					connector.offset.y = offset.y;
				}
			}
		}
		
		public function isGrabbable(heldBubbles:FlxGroup, firstGrab:Boolean):Boolean {
			if (isAnchor()) {
				return false;
			}
			if (state == 300) {
				return false;
			}
			return true;
		}
		
		override public function kill():void {
			super.kill();
			killConnectors();
		}
		
		public function killConnectors():void {
			for each (var connector:Connector in connectors) {
				if (connector != null && connector.alive) {
					connector.kill();
					if (connector.bubble0 != this) {
						connector.bubble0.removeConnector(connector);
					}
					if (connector.bubble1 != this) {
						connector.bubble1.removeConnector(connector);
					}
				}
			}
			connectors.length = 0;
		}
		
		public function removeConnector(connector:Connector):void {
			for (var i:int = 0; i < connectors.length; i++) {
				if (connectors[i] == connector) {
					connectors[i] = null;
				}
			}
		}
		
		public function isConnected(bubble:Bubble):Boolean {
			for each (var connector:Connector in connectors) {
				if (connector != null && connector.alive) {
					if (connector.bubble0 == bubble || connector.bubble1 == bubble) {
						return true;
					}
				}
			}
			return false;
		}
		
		public function changeState(state:int):void {
			if (state == 0) {
				offset.x = offset.y = 0;
			}
			this.state = state;
			this.stateTime = 0;
		}
		
		public function loadPopGraphic():void {
		}
		
		public function loadRegularGraphic():void {
		}
	}
}