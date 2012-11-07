package {
	import Box2D.Collision.Shapes.*;
	import Box2D.Collision.*;
	import Box2D.Common.Math.*;
	import Box2D.Common.*;
	import Box2D.Dynamics.Contacts.b2PolygonContact;
	import Box2D.Dynamics.*;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.getDefinitionByName;

	/**
	 *box2.1 alpha版的，注意网上一般都程都为2.0版的，可到http://box2dflash.boristhebrave.com下载
	 */
	[SWF(width="600", height="450")]
	public class TestBox2D extends Sprite {
		private var world:b2World=new b2World(new b2Vec2(0, 0), true); //创建一个世界 
		private var PhysBox:Class;// = new PhysBox();
		private var PhysCircle:Class;// = new PhysCircle();
		private var PhysGround:Class;// = new PhysGround();
		private var BG:Class;// = new BG();
		private var restitution:Number = 0.6;
		private var friction:Number = 0.5;

		public function TestBox2D() {
			defineClass();
			stage.scaleMode = StageScaleMode.NO_SCALE;
			var sw:int = 600; //stage.stageWidth 这里stageWidth，stageHeight都为0，就算我加在Event.ADDED_TO_STAGE里面处理还是0，知道的朋友告诉声
			var sh:int = 450; //stage.stageHeight
			var b:Sprite = new BG as Sprite;
			//平铺背景参考层
			addBG(sw, sh, b.width, b.height);
			//添加上下左右4边
			addBox(PhysGround, sw, sw / 10, sw / 2, 0, false);
			addBox(PhysGround, sw, sw / 10, sw / 2, sh, false);
			addBox(PhysGround, sw / 10, sw, 0, sh / 2, false);
			addBox(PhysGround, sw / 10, sw, sw, sh / 2, false);
			//添加物体
			for (var i:int=0; i < 10; i++) {
				//addBox(PhysBox, 30 * Math.random() * 2 + 30, 30 * Math.random() * 2 + 30, 30 * Math.random() * 20, 30 * Math.random() * 10);
				//addCircle("ball_" + i, 30 * Math.random() * 2 + 30, 30 * Math.random() * 20, 30 * Math.random() * 10);
				addCircle("ball_" + i, 3 * 2 + 30, 30 * Math.random() * 20, 30 * Math.random() * 10);
			}
			//addBox(PhysCircle, 90, 75, 220, 100, true)
			addEventListener(Event.ENTER_FRAME, Update); //添加刷新
		}
		private function defineClass():void {
			PhysBox = getDefinitionByName("PhysBox") as Class;
			PhysCircle = getDefinitionByName("PhysCircle") as Class;
			PhysGround = getDefinitionByName("PhysGround") as Class;
			BG = getDefinitionByName("BG") as Class;
		}
		//添加物体 注意box2d里面1米=30像素  addBox参数单位都为像素
		private function addBox(className:Class, width:int=30, height:int=30, x:int=0, y:int=0, dynamic:Boolean=true):void {
			var scale:int = 30;
			var boxShape:b2PolygonShape = new b2PolygonShape();
			var fixtureDef:b2FixtureDef = new b2FixtureDef();
			var bodyDef:b2BodyDef = new b2BodyDef();
			var body:b2Body;//要搞清楚以上4个东西的关系
			bodyDef.type=dynamic ? b2Body.b2_dynamicBody : b2Body.b2_staticBody; //动态or静态物体，不设置默认为静态
			bodyDef.position.Set(x / scale, y / scale) //这里用米作单位
			bodyDef.userData = new className();
			bodyDef.userData.width=width; //比例要和boxShape.SetAsBox比例一样
			bodyDef.userData.height = height;
			
			boxShape.SetAsBox(width / scale / 2, height / scale / 2); //这里用米作单位并且高宽为实际的一半
			fixtureDef.shape=boxShape; //外表
			fixtureDef.density=1000 * Math.random(); //密度
			fixtureDef.friction=friction; //摩擦力0-1
			fixtureDef.restitution = restitution; //弹力0-1
			//
			body=world.CreateBody(bodyDef);
			body.CreateFixture(fixtureDef);
			addChild(bodyDef.userData);
		}

		private function addCircle(name:String, radius:int=30, x:int=0, y:int=0, dynamic:Boolean=true):void {
			var scale:int=30
			var boxShape:b2CircleShape=new b2CircleShape();
			var fixtureDef:b2FixtureDef=new b2FixtureDef();
			var bodyDef:b2BodyDef=new b2BodyDef();
			var body:b2Body
			bodyDef.type=dynamic ? b2Body.b2_dynamicBody : b2Body.b2_staticBody; //动态or静态物体，不设置默认为静态
			bodyDef.position.Set(x / scale, y / scale) //这里用米作单位
			var sprite:Sprite = new PhysCircle();
			sprite.addEventListener(MouseEvent.MOUSE_DOWN, onBallMouseDownHandler);
			sprite.name = name;
			bodyDef.userData = sprite;
			
			bodyDef.userData.width=radius; //比例要和boxShape.SetAsBox比例一样
			bodyDef.userData.height = radius;
			bodyDef.bullet = true;
			
			boxShape.SetRadius(radius / scale / 2); //这里用米作单位并且高宽为实际的一半
			fixtureDef.shape = boxShape; //外表
			fixtureDef.density = 50;// * Math.random(); //密度
			fixtureDef.friction=friction; //摩擦力0-1
			fixtureDef.restitution=restitution; //弹力0-1
			//
			body=world.CreateBody(bodyDef);
			body.CreateFixture(fixtureDef);
			addChild(bodyDef.userData);
		}

		//背景平铺
		private function addBG(bgWidth:int, bgHeight:int, imgWidth:int, imgHeight:int):void {
			var r:Sprite
			for (var i:int=0; i < bgWidth / imgWidth; i++) {
				for (var j:int=0; j < bgHeight / imgHeight; j++) {
					r=new BG as Sprite //BG为中心对齐的
					r.x=i * imgWidth + imgWidth / 2
					r.y=j * imgHeight + imgHeight / 2
					addChild(r)
				}
			}
		}

		//这个为刷新的，一般不需要改
		private function Update(e:Event):void {
			world.Step(1 / 30, 10, 10);
			for (var bb:b2Body=world.GetBodyList(); bb; bb=bb.GetNext()) {
				if (bb.GetUserData() is Sprite) {
					var sprite:Sprite = bb.GetUserData() as Sprite;
					sprite.x=bb.GetPosition().x * 30;
					sprite.y=bb.GetPosition().y * 30;
					sprite.rotation=bb.GetAngle() * (180 / Math.PI);
				}
			}
		}
		private function onBallMouseDownHandler(e:MouseEvent):void {
			var body:b2Body = getBodyByUserDataName(e.currentTarget.name);
			trace(e.currentTarget.name + ": " + body.GetPosition());
			//body.ApplyImpulse(new b2Vec2(0, -20000), body.GetWorldCenter());
		}
		private function getBodyByUserDataName(name:String):b2Body {
			var sprite:Sprite;
			for (var bb:b2Body = world.GetBodyList(); bb; bb = bb.GetNext()) {
				sprite = bb.GetUserData() as Sprite;
				if (sprite.name == name) {
					break;
				}
			}
			return bb;
		}
	}
}