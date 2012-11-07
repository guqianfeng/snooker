package data 
{
	import Box2D.Common.Math.b2Vec2;
	import flash.geom.Point;
	/**
	 * ...
	 * @author JackyGu
	 */
	public class MyMath {
		private static var scale = 30;//用于Box2d的单位
		public static function QuadraticEquation(a:Number, b:Number, c:Number):Array {
			//求一元二次方程函数
			//返回值：无解为空，有一个解时数组长度为1，有两个解时数组长度为2
			var re:Array = new Array();
			var delta:Number = b * b -4 * a * c;
			var d:Number;
			if (delta < 0) {
				re = null;
			}else if (delta == 0) {
				d = -b / (2 * a);
				re.push(d);
			}else if (delta > 0) {
				d = ( -b + Math.sqrt(delta)) / (2 * a);
				re.push(d);
				d = ( -b - Math.sqrt(delta)) / (2 * a);
				re.push(d);
			}
			return re;
		}
		
		public static function findPoint(bigBallRadius:Number, smallBallRadius:Number, smallBallCenter:Point, line_K:Number, Line_A:Number):Array {
			//用于计算两个球相切时，母球的中心点，其中母球中心点位于y = line_K * x + line_A线上
			//返回数组，如果数组为空，则不相交
			//如果数组长度为1，则只有一个点相交，即垂直
			//如果数组长度为2，则有两个相交点，需要另外判断哪个相交点有效
			var array:Array = new Array();
			var p:Point = new Point();
			var x_b:Number = smallBallCenter.x;
			var y_b:Number = smallBallCenter.y;
			var a:Number = 1 + line_K * line_K;
			var b:Number = 2 * Line_A * line_K - 2 * x_b - 2 * line_K * y_b;
			var c:Number = x_b * x_b + Line_A * Line_A - 2 * Line_A * y_b + y_b * y_b - (bigBallRadius + smallBallRadius) * (bigBallRadius + smallBallRadius);
			var re:Array = QuadraticEquation(a, b, c);
			if (re) {
				for (var i:int = 0; i < re.length;i++)
					array.push(new Point(re[i], line_K * re[i] + Line_A));					
			}
			return array;
		}
		
		public static function findDirectionLine(bigBallCenter:Point, smallBallCenter:Point, lineLength:Number):Object {
			//求大球和小球相撞后，小球改变方向的直线函数
			//相撞时打球的中心点为bigBallCenter，小球的中心店为smallBallCenter
			//lineLength为小球方向示意线的长度
			//返回一个对象，该对象结构{k:直线函数k值, a:直线函数a值}
			var obj:Object = new Object;
			
			return obj;
		}
		public static function point2lineDistance(point:Point, k:Number, a:Number):Number {
			//计算点到直线的垂直距离
			return (k * point.x - point.y + a) / Math.sqrt(k * k + 1);
		}
		public static function Quadrant(center:Point, pos:Point):uint {
			//返回位置pos位于center的相对位置，1-第一象限，2-第二象限，3-第三象限，4-第四象限
			var re:uint;
			if (pos.x > center.x && pos.y <= center.y) re = 1;
			if (pos.x <= center.x && pos.y < center.y) re = 2;
			if (pos.x < center.x && pos.y >= center.y) re = 3;
			if (pos.x >= center.x && pos.y > center.y) re = 4;
			return re;
		}
		/*
		public static function mouseAndBallCenterAnger(bigBallCenter:Point, smallBallCenter:Point, mousePosition:Point):Number {
			//计算以bigBallCenter为原点，mousePosition与smallBallCenter的夹角
			var smallBallAnger:Number = radianToAngle(Math.atan2((bigBallCenter.y - smallBallCenter.y) / (smallBallCenter.x - bigBallCenter.x)));
			var mouseAnger:Number = radianToAngle(Math.atan2((bigBallCenter.y - mousePosition.y) / (mousePosition.x - bigBallCenter.x)));
			var anger:Number = Math.abs(smallBallAnger - mouseAnger);
			return anger;
		}
		*/
		public static function anger2(bigBallRadius:Number, smallBallRadius:Number, bigBallCenter:Point, smallBallCenter:Point):Number {
			//计算以bigBallCenter为原点，虚拟一个老板球和目标球相切，求这个相切的老板球的中心与目标球的夹角
			var distanceOfSmallBallAndBigBall:Number = distance(bigBallCenter, smallBallCenter);
			var anger:Number = Math.asin((bigBallRadius + smallBallRadius) / distanceOfSmallBallAndBigBall);
			return radianToAngle(anger);
		}
		public static function getAngle(from:Point, to:Point):Number {
			var tmpx:Number = to.x - from.x;  
			var tmpy:Number = from.y - to.y;
			var angle:Number = radianToAngle(Math.atan2(tmpy, tmpx));
			return angle;  
		}  
     
		public static function angleToRadian(angle:Number):Number { 
			return angle * (Math.PI / 180);
		} 
		public static function radianToAngle(radian:Number):Number { 
			return radian * (180 / Math.PI); 
		} 
		public static function distance(point1:Point, point2:Point):Number {
			return Math.sqrt((point1.x - point2.x) * (point1.x - point2.x) + (point1.y - point2.y) * (point1.y - point2.y));
		}
		public static function lineCrossingPoint(k1:Number, a1:Number, k2:Number, a2:Number):Point {
			//求两条线的焦点
			var x:Number = (a2 - a1) / (k1 - k2);
			var y:Number = k1 * x + a1;
			return new Point(x, y);
		}
		public static function isInsideTriangle(A:Point, B:Point, C:Point, P:Point):Boolean {
			//判断点P是否在A,B,C三点构成的三角形内部
			var planeAB:Number = (A.x-P.x)*(B.y-P.y)-(B.x-P.x)*(A.y-P.y);
			var planeBC:Number = (B.x-P.x)*(C.y-P.y)-(C.x - P.x)*(B.y-P.y);
			var planeCA:Number = (C.x-P.x)*(A.y-P.y)-(A.x - P.x)*(C.y-P.y);
			return sign(planeAB)==sign(planeBC) && sign(planeBC)==sign(planeCA);
		}
		private static function sign(n:Number):int {
			return Math.abs(n)/n;
		}
		public static function b2Vect2Point(pos:b2Vec2):Point {
			return new Point(pos.x * scale, pos.y * scale);
		}
		public static function Point2Vect2(pos:Point):b2Vec2 {
			return new b2Vec2(pos.x / scale, pos.y / scale);
		}
		public static function randArray(_arr:Array):Array{
			var rand:Function = function(){
				var i:Number = Math.random() - 0.5;
				if (i < 0) return -1;
				else return 1;
			}
			var _ar:Array = _arr.slice();
			_ar.sort(rand);
			return _ar;
		}
	}
}