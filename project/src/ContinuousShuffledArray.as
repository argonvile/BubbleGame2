package  
{
	public dynamic class ContinuousShuffledArray extends Array
	{
		private var shuffledIndexCount:int;
		
		public function ContinuousShuffledArray(shuffledIndexCount:int, ...args) {
			this.shuffledIndexCount = shuffledIndexCount;
			var n:uint = args.length 
			if (n == 1 && (args[0] is Number)) 
			{ 
				var dlen:Number = args[0]; 
				var ulen:uint = dlen; 
				if (ulen != dlen) 
				{ 
					throw new RangeError("Array index is not a 32-bit unsigned integer ("+dlen+")"); 
				} 
				length = ulen; 
			} 
			else 
			{ 
				length = n; 
				for (var i:int=0; i < n; i++) 
				{ 
					this[i] = args[i]  
				} 
			}
			reset();
		}
		
		public function reset():void {
			for (var nextIndex:int = length - 1; nextIndex > 0; nextIndex--) {
				var randomPos:int = Math.floor(Math.random() * (nextIndex + 1));
				var tmp:* = this[randomPos];
				this[randomPos] = this[nextIndex];
				this[nextIndex] = tmp;
			}
		}
		
		public function next():Object {
			var returnValue:Object = pop();
			this.splice(Math.random() * shuffledIndexCount, 0, returnValue);
			return returnValue;
		}
	}
}