package org.slg.Utils
{
	
	/**
	 * ...
	 * @author ...
	 */
	public class MovieClipTools 
	{
		
		public function MovieClipTools() 
		{
			
		}
		private static function removeMc(mc:MovieClip):void
		{
			var n1:int = mc.numChildren;
			if (n1 >= 1)
			{
				for (var i1:int = n1 - 1; i1 >= 0; i1--) 
				{
					mc.removeChildAt(i1);
				}
			}
		}
		private static function removeMcAndEvent(mc:MovieClip):void
		{
			var n1:int = mc.numChildren;
			if (n1 >= 1)
			{
				for (var i1:int = n1 - 1; i1 >= 0; i1--) 
				{
					mc.removeChildAt(i1);
					mc.removeEventListener(MouseEvent.CLICK, onWalkRangeTileClickHandler);
					mc.removeEventListener(MouseEvent.ROLL_OVER, onMoveRangeRolloverHandler);
				}
			}
		}
	}
	
}