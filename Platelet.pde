class Platelet extends BloodCont{
	
	Platelet(PVector l, float ms, float mf) {
		super(l,ms,mf,2.5);
	}
	
	boolean scan(Damage d) {
		float distance = dist(position.x,position.y,d.position.x,d.position.y);
		boolean withinDist = distance < 30;
		
		if (distance < 30) {
			moveTo(d.position.x,d.position.y);
			if (distance < 2)
				activate();
		}
		return withinDist;
		
	}
	
	void moveTo(float x,float y) {
		
		PVector target = new PVector(x,y);
		PVector desired = PVector.sub(target,position);
		float d = desired.mag();
		desired.normalize();
		
		if (d < 1) {
			float m = map(d,0,1,0,maxspeed);
			desired.mult(m);
			
		} else {
			desired.mult(maxspeed);
		}
		PVector steer = PVector.sub(desired,velocity);
		steer.limit(maxforce);
		applyForce(steer);
		
	}
	
	void activate() {
		activated = true;
		
	}
	@Override
	void display() {
		// Draw a triangle rotated in the direction of velocity
		if (activated == false) {
			fill(255);
			stroke(0);
			ellipse(position.x,position.y,radius * 2,radius * 2);
		}
		else{
			float theta = velocity.heading2D() + radians(90);
			fill(255);
			stroke(0);
			pushMatrix();
			translate(position.x,position.y);
			rotate(theta);
			PShape platelet = createShape(GROUP);
			
			// Make 4 shapes
			PShape body = createShape(ELLIPSE, 0, 0, radius * 3, radius * 3);
			PShape leg1 = createShape(LINE, 0, - 4 * radius, radius / 8, radius * 4);
			PShape leg2 = createShape(LINE, 0, - 4 * radius , radius / 8,radius * 4);
			PShape leg3 = createShape(LINE, 0, - 4 * radius , radius / 8,radius * 4);
			body.fill(255);
			leg2.rotate(1);
			leg3.rotate(2);
			// Add the 4 "child" shapes to the parent group
			
			platelet.addChild(leg1);
			platelet.addChild(leg2);
			platelet.addChild(leg3);
			platelet.addChild(body);
			
			
			// Draw the group
			
			shape(platelet);
			popMatrix();
		}
	}
	
	
}