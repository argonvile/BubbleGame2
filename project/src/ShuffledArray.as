package  
{
	public dynamic class ShuffledArray extends Array
	{
		private var nextIndex:int;
		
		public function ShuffledArray(...args) 
		{
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
			nextIndex = length - 1;
		}
		
		public function reset():void {
			nextIndex = length - 1;
		}
		
		public function next():Object {
			if (nextIndex == 0) {
				nextIndex = length - 1;
				return this[0];
			}
			var randomPos:int = Math.floor(Math.random() * (nextIndex + 1));
			var tmp:* = this[randomPos];
			this[randomPos] = this[nextIndex];
			this[nextIndex] = tmp;
			nextIndex--;
			return tmp;
		}
	}
}