package  
{
	import org.flixel.*;
	
	public class RankChangeDialog extends FlxGroup
	{
		private var rankGraphic:RankGraphic;
		private var toRank:int;
		private var x:Number = FlxG.width / 2 - 50;
		private var y:Number = FlxG.height / 2 - 34;
		private var width:Number = 100;
		private var height:Number = 68;
		
		public function RankChangeDialog(fromPct:Number = 0.1, toPct:Number = 0.9, fromRank:int = 0,toRank:int=0,message:String="") 
		{
			super();
			this.toRank = toRank;
			
			var dialog:MiscDialog = new MiscDialog(x, y, width, height);
			add(dialog);
			var newText:FlxText;
			newText = new FlxText(FlxG.width / 2 - 50, FlxG.height / 2 - 34 + 8, 100, message);
			newText.setFormat("pixel", 8, 0xffffffff, "center");
			add(newText);
			rankGraphic = new RankGraphic(fromRank);
			rankGraphic.x = FlxG.width / 2 - rankGraphic.width/2;
			rankGraphic.y = FlxG.height / 2 - 34 + 16;
			add(rankGraphic);
			newText = new FlxText(FlxG.width / 2 - 50, FlxG.height / 2 - 34 + 14 + rankGraphic.height, 100, "To next rank:");
			newText.setFormat("pixel", 8, 0xffffffff, "center");
			add(newText);
			var experienceBar:ExperienceBar = new ExperienceBar(FlxG.width / 2 - 40, FlxG.height / 2 - 34 + 26 + rankGraphic.height, 80, 8);
			experienceBar.fromPct = fromPct;
			experienceBar.toPct = toPct;
			experienceBar.onRankUp = rankUp;
			add(experienceBar);
		}
		
		public function rankUp():void {
			remove(rankGraphic);
			rankGraphic = new RankGraphic(toRank);
			rankGraphic.x = FlxG.width / 2 - rankGraphic.width/2;
			rankGraphic.y = FlxG.height / 2 - 34 + 16;
			add(rankGraphic);
			for (var i:int = 0; i < 80; i++) {
				var particle:FadeParticle = new FadeParticle();
				particle.makeGraphic(i % 3 + 4, i % 3 + 4, 0xffffffff);
				particle.x = rankGraphic.x + rankGraphic.width * Math.random();
				particle.y = rankGraphic.y + rankGraphic.height * Math.random();
				particle.velocity.x = Math.random() * 200 + 200;
				particle.velocity.x *= (Math.random() > 0.5) ? 1 : -1;
				particle.velocity.y = Math.random() * 200 + 200;
				particle.velocity.y *= (Math.random() > 0.5) ? 1 : -1;
				particle.drag.x = 600;
				particle.drag.y = 600;
				particle.setLifespan(Math.random() * 0.25 + 0.15);
				add(particle);
			}
			var bigParticle:FadeParticle = new FadeParticle();
			bigParticle.makeGraphic(width, height);
			bigParticle.x = x;
			bigParticle.y = y;
			bigParticle.setLifespan(0.25 + 0.15);
			add(bigParticle);
		}
	}
}