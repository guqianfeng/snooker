package org.slg.Utils {
	import flash.events.EventDispatcher;
    import flash.geom.*;
    import flash.display.*;
    import flash.errors.*;
	import org.slg.Events.PathFindEvent;

    public class FindPath extends EventDispatcher {

        public var startPoint:Point;
        public var endPoint:Point;
        private var endPosition:uint;
        private var FinalList:Array;
        private var PointList:Array;
        private var tempPosition:uint;
        private var mapArray:Array;
        private var CloseList8:Array;
        private var disArray:Array;
        private var w:uint;
        private var OpenList:Array;
        private var h:uint;
        private var CloseList:Array;
        private var startPosition:uint;
        private var PointList8:Array;
		public var result:Array;

        public function FindPath(_arg1:Array=null):void{
            var mapA = _arg1;
            super();
            if (!mapA){
                return;
            };
            try {
                mapArray = mapA;
                w = mapArray[0].length;
                h = mapArray.length;
            } catch(e:Error) {
                throw (new IOError("请输入正确格式的数组,类似:[[1,0,0,0,1,0],[1,0,0,0,1,0]]"));
            };
        }
        private function xTest(_arg1:uint, _arg2:uint, _arg3:uint):Boolean{
            var _local4:uint;
            if ((((_arg2 < w)) && ((_arg3 < h)))){
                if (!mapArray[_arg3][_arg2]){
                    if (_arg1 == endPosition){
                        PointList[_arg1] = tempPosition;
                        _local4 = endPosition;
                        FinalList.push(new Point((_local4 % w), ((_local4 / w) ^ 0)));
                        while (_local4 != startPosition) {
                            _local4 = PointList[_local4];
                            FinalList.push(new Point((_local4 % w), ((_local4 / w) ^ 0)));
                        };
                        FinalList.reverse();
                        return (false);
                    };
                    if (!CloseList[_arg1]){
                        OpenList.push(_arg1);
                        PointList[_arg1] = tempPosition;
                        CloseList[_arg1] = true;
                    };
                    return (true);
                } else {
                    CloseList[_arg1] = true;
                };
            };
            return (false);
        }
        override public function toString():String{
            return ("[Object org.slg.Utils::FindPath]");
        }
        private function runWhile(_arg1:Boolean=false):void{
            var _local2:uint;
            var _local3:uint;
            var _local4:Boolean;
            var _local5:Boolean;
            var _local6:Boolean;
            var _local7:Boolean;
            tempPosition = OpenList.shift();
            _local2 = (tempPosition % w);
            _local3 = ((tempPosition / w) << 0);
            CloseList[tempPosition] = true;
            _local4 = xTest((tempPosition + 1), (_local2 + 1), _local3);
            _local5 = xTest((tempPosition + w), _local2, (_local3 + 1));
            _local6 = xTest((tempPosition - w), _local2, (_local3 - 1));
            _local7 = xTest((tempPosition - 1), (_local2 - 1), _local3);
            if (_arg1){
                if (((_local4) && (_local5))){
                    xTest(((tempPosition + w) + 1), (_local2 + 1), (_local3 + 1));
                };
                if (((_local6) && (_local4))){
                    xTest(((tempPosition - w) + 1), (_local2 + 1), (_local3 - 1));
                };
                if (((_local5) && (_local7))){
                    xTest(((tempPosition + w) - 1), (_local2 - 1), (_local3 + 1));
                };
                if (((_local7) && (_local6))){
                    xTest(((tempPosition - w) - 1), (_local2 - 1), (_local3 - 1));
                };
            };
        }
        public function getPath4(_arg1:Point, _arg2:Point):Array
		{
            var _local3:uint;
            var _local4:uint;
            if ((((((((_arg1.x < 0)) || ((_arg1.y < 0)))) || ((_arg1.x >= w)))) || ((_arg1.y >= h)))){
                throw (new IOError("起点位置错误,请重新输"));
            };
            if ((((((((_arg2.x < 0)) || ((_arg2.y < 0)))) || ((_arg2.x >= w)))) || ((_arg2.y >= h)))){
                throw (new IOError("终点位置错误,请重新输"));
            };
            startPoint = _arg1;
            endPoint = _arg2;
            if (startPoint.equals(endPoint)){
                return (undefined);
            };
            OpenList = [];
            CloseList = [];
            PointList = [];
            FinalList = [];
            startPosition = ((startPoint.y * w) + startPoint.x);
            endPosition = ((endPoint.y * w) + endPoint.x);
            OpenList.push(startPosition);
            while (OpenList.length > 0) {
                runWhile();
                if (FinalList.length) {
					var params:Object = FinalList;
					dispatchEvent(new PathFindEvent(PathFindEvent.PATH_FIND_FINISHED, params));
                    return (FinalList);
                };
            };
			dispatchEvent(new PathFindEvent(PathFindEvent.PATH_FIND_FAIL));
            return (undefined);
        }
		
        public function getPath8(_arg1:Point, _arg2:Point):Array{
            if ((((((((_arg1.x < 0)) || ((_arg1.y < 0)))) || ((_arg1.x >= w)))) || ((_arg1.y >= h)))){
                throw (new IOError("起点位置错误,请重新输"));
            };
            if ((((((((_arg2.x < 0)) || ((_arg2.y < 0)))) || ((_arg2.x >= w)))) || ((_arg2.y >= h)))){
                throw (new IOError("终点位置错误,请重新输"));
            };
            startPoint = _arg1;
            endPoint = _arg2;
            if (startPoint.equals(endPoint)){
                return (undefined);
            };
            OpenList = [];
            CloseList = [];
            PointList = [];
            FinalList = [];
            startPosition = ((startPoint.y * w) + startPoint.x);
            endPosition = ((endPoint.y * w) + endPoint.x);
            OpenList.push(startPosition);
            while (OpenList.length) {
                runWhile(true);
                if (FinalList.length){
					var params:Object = FinalList;
					dispatchEvent(new PathFindEvent(PathFindEvent.PATH_FIND_FINISHED, params));
                    return (FinalList);
                };
            };
			dispatchEvent(new PathFindEvent(PathFindEvent.PATH_FIND_FAIL));
            return (undefined);
        }
    }
}
