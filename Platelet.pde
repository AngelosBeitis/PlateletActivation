class Platelet extends BloodCont{
	
	boolean activated;
	
	Platelet(PVector l, float ms, float mf) {
		
		super(l,ms,mf,2.5);
		activated = false;
	}
	
	boolean scan(Damage d) {
		float distance = dist(position.x,position.y,d.position.x,d.position.y);
		boolean withinDist = distance < 40;
		float moveX = d.position.x;
		float moveY = d.position.y;
		if (distance < 40) {
			moveTo(random(d.left.x, d.right.x), random(d.top.y, d.bottom.y));
			if (distance < 10)
				activate();
		}
		return withinDist;
		
	}
	
	boolean scanForActivated(List<Platelet> platelets) {
		
		float distance;
		for (Platelet p : platelets) {
			distance = dist(position.x,position.y,p.position.x,p.position.y);
			if (p.activated == true && activated == false && distance < height / 1.5) {
				moveTo(p.position.x,p.position.y);
				if (distance < 2)
					activate();
				return true;
			}
		}
		
		return false;
		
	}
	
	void moveTo(float x,float y) {
		
		PVector target = new PVector(x,y);
		PVector desired = PVector.sub(target,position);
		float d = desired.mag();
		desired.normalize();
		
		if (d < 10) {
			float m = map(d,0,10,0,maxspeed);
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
		velocity = new PVector(0,0);
		acceleration = new PVector(0,0);
		
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