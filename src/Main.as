package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import nape.callbacks.CbType;
	import nape.callbacks.InteractionCallback;
	import nape.callbacks.InteractionListener;
	import nape.constraint.PivotJoint;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.shape.Polygon;
	import nape.space.Space;
	import nape.util.ShapeDebug;
	import nape.phys.BodyType;
	import nape.callbacks.CbEvent;
	import nape.callbacks.InteractionType;
	
	/**
	 * ...
	 * @author SPGamesStudio
	 */
	
	 
	[SWF(width = "600", height = "600", backgroundColor = "#000000")]
	
	public class Main extends Sprite 
	{
		public var space:Space = new Space(new Vec2(0, 600));
		public var hand:PivotJoint = new PivotJoint(space.world, null, new Vec2(), new Vec2());	
		public var collision:CbType = new CbType();
		
		public function Main():void 
		{
			var debug:ShapeDebug = new ShapeDebug(600, 600, 0x000000);
			addChild(debug.display);
			debug.drawConstraints = true;
			debug.drawConstraintSprings = true;
			debug.drawCollisionArbiters = true;
			
			hand.stiff = false;
			hand.space = space;
			hand.active = false;
			
			var border:Body = new Body(BodyType.STATIC);
				border.shapes.add(new Polygon(Polygon.rect(0, 0, -40, 600)));
				border.shapes.add(new Polygon(Polygon.rect(600, 0, 40, 600)));
				border.shapes.add(new Polygon(Polygon.rect(0, 0, 600, -40)));
				border.shapes.add(new Polygon(Polygon.rect(0, 600, 600, 40)));
			border.space = space;
			
			addEventListener(Event.ENTER_FRAME, function(e:Event):void { 
				debug.clear();
				space.step(1 / stage.frameRate, 10, 10);
				debug.draw(space);
				debug.flush();
				hand.anchor1.setxy(mouseX, mouseY);					
			});
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void { 
				
				var mp:Vec2 = new Vec2(mouseX, mouseY);
				for (var i:int = 0; i < space.bodiesUnderPoint(mp).length; i++)
				{
					var b:Body = space.bodiesUnderPoint(mp).at(i);
					if (!b.isDynamic()) continue;						
						hand.body2 = b;
						hand.anchor2 = b.worldToLocal(mp);
						hand.active = true;
						break;				
				}
			} );
			
			stage.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent):void { 
				hand.active = false;
			} );
			
			drawBlocks(2);
			
			space.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, collision, collision, collisionBegun));
			space.listeners.add(new InteractionListener(CbEvent.ONGOING, InteractionType.COLLISION, collision, collision, collisionOngoing));
			space.listeners.add(new InteractionListener(CbEvent.END, InteractionType.COLLISION, collision, collision, collisionEnded));
			
		}	
		
		public function collisionBegun(cb:InteractionCallback):void {
			trace("Objects started bumping and grinding.");
		}
		public function collisionOngoing(cb:InteractionCallback):void {
			trace("Objects -still- bumping and grinding!");
		}
		public function collisionEnded(cb:InteractionCallback):void {
			trace("Objects finished bumping and grinding.");
		}
		
		private function drawBlocks(number:Number):void 
		{
			for (var i:int = 0; i < number; i++) {
				var block:Polygon = new Polygon(Polygon.box(50, 50));
				var body:Body = new Body(BodyType.DYNAMIC);
				
				body.shapes.add(block);
				
				body.position.setxy(stage.stageWidth / 2 + (i * 100), stage.stageHeight / 2);
				body.space = space;
				
				body.cbType = collision;
			}
		}
		
		
		
		
		
	}
	
}