package  
{
	import org.flixel.*;

	public class Bubble extends FlxSprite
	{
		public static const STATE_NORMAL:int = 0;
		public static const STATE_GRABBING:int = 100;
		public static const STATE_THROWING:int = 200;
		public static const STATE_POPPING:int = 300;
		 
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
			this.state = STATE_NORMAL;
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
			changeState(STATE_GRABBING);
			this.playerPoint = playerPoint;
			updateOffsets();
		}
		
		public function wasThrown(playerPoint:PlayerSprite):void {
			changeState(STATE_THROWING);
			this.playerPoint = playerPoint;
			updateOffsets();
		}
		
		public function resetQuickApproach():void {
			this.quickApproachDistance = 0;
			this.quickApproachTime = 0;
			updateOffsets();
			updateConnectorOffsets();
		}
		
		public function quickApproach(distance:Number):void {
			this.quickApproachDistance = distance;
			this.quickApproachTime = 0;
			updateOffsets();
			updateConnectorOffsets();
		}
		
		/**
		 * @return True if the bubble should be displayed stationary, as held by the player
		 */
		public function isHeld():Boolean {
			return state == STATE_GRABBING && stateTime >= levelDetails.grabDuration;
		}
		
		private function updateOffsets():void {
			var statePct:Number;
			if (state == STATE_GRABBING) {
				// grabbing; apply grab offsets
				statePct = Math.min(1, Math.pow(stateTime / levelDetails.grabDuration, 2.5));
				offset.x = statePct * ((x + width / 2) - (playerPoint.getMidpoint().x));
				offset.y = statePct * ((y + height / 2) - (playerPoint.getMidpoint().y));
			} else if (state == STATE_THROWING) {
				// throwing; apply throw offsets
				statePct = Math.min(1, Math.pow(stateTime / levelDetails.throwDuration, 1.5));
				offset.x = (1 - statePct) * ((x + width / 2) - (playerPoint.getMidpoint().x));
				offset.y = (1 - statePct) * ((y + height / 2) - (playerPoint.getMidpoint().y));
			} else {
				// no offsets
				offset.x = 0;
				offset.y = 0;
			}
			statePct = Math.pow(1 - Math.min(1, quickApproachTime / levelDetails.grabDuration), 2.5);
			if (quickApproachDistance > 0) {
				offset.y += quickApproachDistance * statePct;
			}
		}
		
		override public function update():void {
			super.update();
			stateTime += FlxG.elapsed;
			updateOffsets();
			if (state == STATE_THROWING && stateTime >= levelDetails.throwDuration) {
				changeState(STATE_NORMAL);
			}
			if (quickApproachDistance > 0) {
				quickApproachTime += FlxG.elapsed;
				// apply 'quick approach' offsets
				updateConnectorOffsets();
			}
			updateAlpha();
		}
		
		public function justFinishedQuickApproach():Boolean {
			return quickApproachTime >= levelDetails.grabDuration;
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
			if (state == STATE_POPPING) {
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
			if (state == STATE_NORMAL) {
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