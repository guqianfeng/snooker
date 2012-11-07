package data 
{
	import Box2D.Collision.b2Bound;
	import Box2D.Dynamics.b2ContactListener;
	import Box2D.Collision.b2ContactPoint;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Collision.b2WorldManifold;
	import Box2D.Dynamics.b2World;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Dynamics.b2Body;
	import flash.events.IEventDispatcher;
	
	/**
	 * ...
	 * @author JackyGu
	 */
	public class MyContactListener extends b2ContactListener{
		private var _body1:b2Body;
		private var _body2:b2Body;
		public function MyContactListener(_world:b2World) {
			//super(world);
		}
		override public function EndContact(contact:b2Contact):void {
			super.EndContact(contact);
			
			//var mw:b2WorldManifold = contact.GetWorldManifold(mw);
			//var firstPoint:b2Vec2 = mw.m_points[0];
			//var normal:b2Vec2 = mw.m_normal;
			 
			var fixture1:b2Fixture = contact.GetFixtureA();
			var shape1:b2Shape = fixture1.GetShape();
			_body1 = fixture1.GetBody();
			
			var fixture2:b2Fixture = contact.GetFixtureB();
			var shape2:b2Shape = fixture2.GetShape();
			_body2 = fixture2.GetBody();
			
			//trace("碰撞: " + body1.name + " 与 " + body2.name);
		}
		public function get body1():b2Body {
			return _body1;
		}
		public function get body2():b2Body {
			return _body2;
		}
	}

}