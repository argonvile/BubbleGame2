package  
{
	public class LevelSummary 
	{
		public var levelClass:Class;
		public var scenario:int;
		public var duration:Number = 90;
		
		public function getScenarioBpm():Number {
			return levelClass["scenarioBpms"][scenario];
		}
	}
}