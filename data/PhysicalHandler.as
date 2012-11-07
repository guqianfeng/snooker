package data 
{
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.*;
	import Box2D.Common.Math.*;
	import flash.events.EventDispatcher;
	import flash.utils.getDefinitionByName;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.Shapes.b2CircleShape;
	import flash.geom.Point;
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import com.hexagonstar.util.debug.Debug;
	/**
	 * ...
	 * @author JackyGu
	 * 用于处理box2d
	 */
	public class PhysicalHandler extends EventDispatcher{
		private var world:b2World;
		private var scale:int = 30;
		private var laobanBall:b2Body;
		private var container:Sprite;
		
		public function PhysicalHandler(_world:b2World, _container:Sprite, _scale:int = 30):void{
			world = _world;
			scale = _scale;
			container = _container;
		}
		public function initWall():void {
			//初始化墙体
			var boardClass:Class = getDefinitionByName("BoardLine") as Class;
			//墙体的id为-1
			addBox(Config.wallName, -1, boardClass, Config.tableWidth, Config.tableFrameWidth, Config.tableX + Config.tableWidth / 2, Config.tableY + Config.tableFrameWidth / 2, false, Config.wallDensity, Config.wallFriction, Config.worldRestitution);//上
			addBox(Config.wallName, -1, boardClass, Config.tableWidth, Config.tableFrameWidth, Config.tableX + Config.tableWidth / 2, Config.tableY + Config.tableFrameWidth / 2, false, Config.wallDensity, Config.wallFriction, Config.worldRestitution);//上
			addBox(Config.wallName, -1, boardClass, Config.tableWidth, Config.tableFrameWidth, Config.tableX + Config.tableWidth / 2, Config.tableY + Config.tableWidth - Config.tableFrameWidth / 2, false, Config.wallDensity, Config.wallFriction, Config.worldRestitution);//下
			addBox(Config.wallName, -1, boardClass, Config.tableFrameWidth, Config.tableWidth, Config.tableX + Config.tableFrameWidth / 2, Config.tableY + Config.tableWidth / 2, false, Config.wallDensity, Config.wallFriction, Config.worldRestitution);//左
			addBox(Config.wallName, -1, boardClass, Config.tableFrameWidth, Config.tableWidth, Config.tableX + Config.tableWidth - Config.tableFrameWidth / 2, Config.tableY + Config.tableWidth / 2, false, Config.wallDensity, Config.wallFriction, Config.worldRestitution);//右
		}
		public function initBalls():void {
			//初始化球体
			for (var i:int = 0; i < Config.qiziArray.length; i++ ) initQiziBalls(i + 1);
			initLaobanBall(1);//初始化时side=1
			laobanBall = getBodyById(0);
		}
		public function initQiziBalls(id:int):void {
			//初始化棋子，棋子id从1开始，这个非常重要
			var position:Point = Config.qiziPosition[id - 1];
			var tablePos:Point = new Point(position.x + Config.tableX, position.y + Config.tableY);
			addQiziBallById(id, tablePos);
		}
		public function addQiziBallById(id:int, position:Point):b2Body {
			//添加棋子
			var name:String = Config.qiziArray[id - 1];//棋子的名字，可以重复，如红色的马就有两个
			//doubleTrace("id: " + id + " -> " + name);
			if (name) return addQiziBallByName(name, id, position);
			else return null;
		}
		public function addQiziBallByName(name:String, id:int, position:Point):b2Body {
			return addCircle(name, id, Config.SmallBallRadius, position.x, position.y, true, true, Config.qiziDensity, Config.worldFriction, Config.worldRestitution);						
		}
		public function initLaobanBall(side:int):void {
			//初始化老板球
			var laobaoInitPosition:Point = getLaobanPosition(side);//老板球初始位置
			addCircle(Config.laobanBallClassname, 0, Config.LaobanBallRadius, laobaoInitPosition.x, laobaoInitPosition.y, true, true, Config.qiziDensity, Config.worldFriction, Config.worldRestitution);
		}
		public function resetLaobanBall(side:int):void {
			var laobanPosition:Point = getLaobanPosition(side);
			laobanBall.SetPosition(MyMath.Point2Vect2(laobanPosition));
		}
		//添加物体 注意box2d里面1米=30像素  addBox参数单位都为像素
		private function addBox(_name:String, _id:int, className:Class, width:int = 30, height:int = 30, xx:int = 0, yy:int = 0, _dynamic:Boolean = true, density:Number = 1000.0, friction:Number = 0.8, restitution:Number = 0.6):void {
			//trace("width = " + width + ", height = " + height + ", x = " + xx + ", y = " + yy);
			var boxShape:b2PolygonShape = new b2PolygonShape();
			var fixtureDef:b2FixtureDef = new b2FixtureDef();
			var bodyDef:b2BodyDef = new b2BodyDef();
			var body:b2Body;//要搞清楚以上4个东西的关系
			
			bodyDef.type = _dynamic ? b2Body.b2_dynamicBody : b2Body.b2_staticBody; //动态or静态物体，不设置默认为静态
			bodyDef.position.Set(xx / scale, yy / scale); //这里用米作单位
			bodyDef.userData = new className();
			bodyDef.userData.width = width; //比例要和boxShape.SetAsBox比例一样
			bodyDef.userData.height = height;
			
			boxShape.SetAsBox(width / scale / 2, height / scale / 2); //这里用米作单位并且高宽为实际的一半
			fixtureDef.shape = boxShape; //外表
			fixtureDef.density = 0; //密度
			fixtureDef.friction = friction; //摩擦力0-1
			fixtureDef.restitution = restitution; //弹力0-1
			
			body = world.CreateBody(bodyDef);
			body.name = _name;
			body.id = _id;
			body.CreateFixture(fixtureDef);
			container.addChild(bodyDef.userData);
		}

		private function addCircle(_name:String, _id:int, radius:int = 30, x:int = 0, y:int = 0, _dynamic:Boolean = true, isBullet:Boolean = false, density:int = 100, friction:Number = 0.8, restitution:Number = 0.6):b2Body {
			var boxShape:b2CircleShape = new b2CircleShape();
			var fixtureDef:b2FixtureDef = new b2FixtureDef();
			var bodyDef:b2BodyDef = new b2BodyDef();
			var body:b2Body;
			bodyDef.type = _dynamic ? b2Body.b2_dynamicBody : b2Body.b2_staticBody; //动态or静态物体，不设置默认为静态
			bodyDef.position.Set(x / scale, y / scale); //这里用米作单位
			var aClass:Class = getDefinitionByName(_name) as Class;
			var sprite:Sprite = new aClass() as Sprite;
			//sprite.filters = new Array(new DropShadowFilter(1, 45, 0, 1, 1, 1, 1, 3));
			sprite.cacheAsBitmap = false;
			sprite.name = String(_id);//body的sprite
			//sprite.alpha = 0;
			//TweenLite.to(ball.sprite, 0.5, { alpha:1 } );
			bodyDef.userData = sprite;
			
			bodyDef.userData.width = radius * 2; //比例要和boxShape.SetAsBox比例一样
			bodyDef.userData.height = radius * 2;
			bodyDef.bullet = isBullet;
			
			boxShape.SetRadius((radius) / scale); //这里用米作单位并且高宽为实际的一半
			fixtureDef.shape = boxShape; //外表
			fixtureDef.density = density;// * Math.random(); //密度
			fixtureDef.friction = friction; //摩擦力0-1
			fixtureDef.restitution = restitution; //弹力0-1
			
			body = world.CreateBody(bodyDef);
			body.name = _name;//name和id两个属性是古千峰加到b2Body类中的
			body.id = _id;
			body.SetLinearDamping(Config.linearDamping);//设置阻尼
			body.SetAngularDamping(Config.angularDamping);
			
			body.CreateFixture(fixtureDef);
			container.addChild(bodyDef.userData);
			
			return body;
		}
		private function getLaobanPosition(side:int = 1):Point {
			//重置老板球位置，side=0西方，1-南方，2-北方，3-东方
			//var redballStart:Point = new Point(redBall.px, redBall.py);
			var xx:Number = Config.laobanBollInitPosition[side].x + Config.tableX;
			var yy:Number = Config.laobanBollInitPosition[side].y + Config.tableY;
			while (ifCollide(new Point(xx, yy), Config.LaobanBallRadius, Config.SmallBallRadius)) {
				//老板球的初始位置和子球位置冲突
				if (xx > Config.tableX + Config.tableWidth / 2) {
					//如果位置位于棋盘右半边
					xx = xx + Config.SmallBallRadius;//往右移5
				}else {
					xx = xx - Config.SmallBallRadius;//往左移5
				}
			}
			return new Point(xx, yy);
		}
		public function ifCollide(checkPoint:Point, particle1Radius:Number, particle2Radius:Number):Boolean {
			//根据checkPoint寻找附近空位子，以免与现有的子发生碰撞
			//如果碰撞，不能放下，则返回true
			//particleRadius是即将放入粒子的半径
			var ifCollide:Boolean = false;
			for (var bb:b2Body = world.GetBodyList(); bb; bb = bb.GetNext()) {
				if (bb && bb.name && bb.id > 0) {
					//如果不是老板球
					var distance:Number = MyMath.distance(checkPoint, MyMath.b2Vect2Point(bb.GetPosition()));
					if (distance <= particle1Radius + particle2Radius) {
						//不能放置新的球，需要重新定位
						ifCollide = true;
						break;
					}
				}
				
			}
			return ifCollide;
		}
		public function getBodyByName(name:String):b2Body {
			//根据body名称获得body对象
			var sprite:Sprite;
			for (var bb:b2Body = world.GetBodyList(); bb; bb = bb.GetNext()) {
				//sprite = bb.GetUserData() as Sprite;
				if (bb.name == name) {
					break;
				}
			}
			return bb;
		}
		public function getBodyById(id:int):b2Body {
			//根据body名称获得body对象
			//老板球的id=0
			//其他子球的id从1开始
			var sprite:Sprite;
			for (var bb:b2Body = world.GetBodyList(); bb; bb = bb.GetNext()) {
				//sprite = bb.GetUserData() as Sprite;
				if (bb.id == id) {
					break;
				}
			}
			return bb;
		}
		public function removeBall(ball:b2Body):void {
			//从棋盘中清除子球
			world.DestroyBody(ball);
			var sprite:Sprite = ball.GetUserData() as Sprite;
			if (sprite) container.removeChild(sprite);
			sprite = null;
			ball = null;
		}
		public function destroy():void {
			//清除
			for (var ball:b2Body = world.GetBodyList(); ball; ball = ball.GetNext()) {
				if(ball) removeBall(ball);
			}
			
		}
		//=====================计算罚球位置=============================
		public function getAddedBallPositions(maxDistance:Number, step:Number):Array {
			//根据两球之间的中位线寻找可以放置的位置
			//maxDistance是两球之间的最大距离，step是步长
			var center:Point = new Point(350, 270);//中心点
			var ballArray:Array = new Array();
			var radius:Number;//球的半径
			var _distance:Number;
			var i:uint;
			var j:uint;
			for (var bb:b2Body = world.GetBodyList(); bb; bb = bb.GetNext()) {
				if (bb && bb.name && bb.id > 0) {
					var position:Point = MyMath.b2Vect2Point(bb.GetPosition());
					_distance = MyMath.distance(center, position);
					ballArray.push( { id:bb.id, distance:_distance, pos: position } );
				}
			}
			//排序ballArray
			ballArray.sort(sortOnDistance);
			//输出排序后的数组
			/*
			for (i = 0; i < ballArray.length; i++) {
				var obj:Object = ballArray[i] as Object;
				trace("#" + i + ": id = " + obj.id + ", " + obj.pos + ", " + obj.distance);
			}
			*/
			//从最近的球开始，两两比较，找出与两个球相切的两个位置
			var potentialPointArray:Array = new Array();
			for (var delta:int = 0; delta < maxDistance; delta = delta + step) {
				radius = Config.SmallBallRadius + delta;
				for (i = 0; i < ballArray.length - 1; i++) {
					for (j = i + 1; j < ballArray.length; j++) {
						var A:Point = ballArray[i].pos;
						var B:Point = ballArray[j].pos;
						_distance = MyMath.distance(A, B);
						if (_distance >= 4 * radius) {
							//两球距离之间可以放置一个小球
							//????????????????????????????????
						}else if (_distance < 4 * radius) {
							//两球距离不够放一个小球，只能相切放置
							var centerArray:Array = getCircleCenterPoint(A, B, radius);
							for (var k:uint = 0; k < centerArray.length; k++) {
								var p:Point = centerArray[k] as Point;//获得与当前两个小球相切的球的中点位置
								//遍历所有小球，判断是否p这个点与其他小球相交，如果没有则选此位置
								if (!ifCollide(p, Config.SmallBallRadius, radius)) 
									potentialPointArray.push(p);//如果没有碰撞，则把这个位置压入潜在合格位置
							}
						}
					}
				}
			}
			return potentialPointArray;
		}
		private function sortOnDistance(a:Object, b:Object):int {
			var re:int;
			if (a.distance > b.distance) re = 1;
			else if (a.distance < b.distance) re = -1;
			else re = 0;
			return re;
		}
		public function getCircleCenterPoint(A:Point, B:Point, R:Number):Array {
			//求与两球相切的圆的中心点方程
			var result:Array = new Array();//结果的数组
			var zcx:Object = zhongchuixian(A, B);//求A,B两点的中垂线直线方程
			var k:Number = zcx.k;
			var a:Number = zcx.a;
			var aa:Number = 1 + k * k;//把中垂线的K和A带入圆的方程后，得到一元二次方程的A
			var bb:Number = -2 * A.x + 2 * a * k - 2 * A.y * k;//一元二次方程的B
			var cc:Number = A.x * A.x + a * a - 2 * A.y * a + A.y * A.y - 4 * R * R;//一元二次方程中的C
			var xArray:Array = MyMath.QuadraticEquation(aa, bb, cc);
			for (var i:int = 0; i < xArray.length; i++) {
				var y:Number = xArray[i] * k + a;
				result.push(new Point(xArray[i], y));
			}
			return result;
		}
		public function zhongchuixian(a:Point, b:Point):Object {
			//求两点中垂线方程
			var _k:Number = (a.x - b.x) / (b.y - a.y);//中垂线的斜率
			var _a:Number = (a.y + b.y) / 2 - _k * (a.x + b.x) / 2;//中垂线的
			return { k:_k, a:_a };
		}
		private function doubleTrace(msg:String):void {
			Debug.trace(msg);
			trace(msg);
		}
	}

}