import java.util.List;

boolean debug = true;

// Flowfield object
FlowField flowfield;
// An ArrayList of vehicles
List<Rbc> rbcs;
List<Platelet> platelets;
Damage damage;
int flag = 0;
int currentTime = millis() / 1000;

void setup() {
	frameRate(60);
	size(640, 340);
	// Make a new flow field with "resolution" of 16
	flowfield = new FlowField(20);
	rbcs = new ArrayList<Rbc>();
	platelets = new ArrayList<Platelet>();
	damage = new Damage(350,15,50);
}

void draw() {
	background(0);
	flowfield.update();
	
	// Display the flowfield in "debug" mode
	if (debug) {
		background(255);
		flowfield.display();
	}
	damage.display(); 
	// Tell all the vehicles to follow the flow field
	for (Rbc r : rbcs) {
		r.follow(flowfield);
		r.checkBoundary();
		for (Platelet p : platelets) {
			r.stickTo(p);
		}
		r.run();
	}
	for (int i = rbcs.size() - 1; i>= 0;i--) {
		BloodCont r = rbcs.get(i);
		if (r.position.x < 0 - r.radius) {
			rbcs.remove(i);
		}
	}
	
	for (Platelet p : platelets) {
		
		if (p.scan(damage) == true) {
			
		} else if (p.scanForActivated(platelets) == true) {
			p.scan(damage);
		}
		else{
			if (p.activated == false)
				p.follow(flowfield);
		}
		p.checkBoundary();
		p.run();
		
	}
	for (int i = platelets.size() - 1; i>= 0;i--) {
		BloodCont p = platelets.get(i);
		if (p.position.x < 0 - p.radius) {
			platelets.remove(i);
		}
		
	}
	
	rbcs.add(new Rbc(new PVector(width, random(10,height - 20)), 2, 0.4));
	
	if ((millis() / 1000) - currentTime >= 5 && flag == 0) {
		platelets.add(new Platelet(new PVector(width, random(1,height / 2)), random(1.0,2.0), 0.4));
		platelets.add(new Platelet(new PVector(width, random(height - 100,height)), 2, 0.4));
		currentTime = millis() / 1000;
		flag = 1;
	}
	if ((millis() / 1000) - currentTime >= 5 && flag == 1) {
		platelets.add(new Platelet(new PVector(width, random(1,height / 2)), 2, 0.4));
		platelets.add(new Platelet(new PVector(width, random(height - height / 2,height)), 2, 0.4));
		currentTime = millis() / 1000;
		flag = 0;
	}
	fill(0);
	
}

void heartBeat() {
	// simulate heart beat, making all the elements go faster
	currentTime = millis() / 1000;
	if ((millis() / 1000) - currentTime >= 1 && flag == 0) {
		for (Rbc r : rbcs) {
			r.maxspeed = 10;
		}
		currentTime = millis() / 1000;
		flag = 1;
	}
	if ((millis() / 1000) - currentTime >= 1 && flag == 1) {
		for (Rbc r : rbcs) {
			r.maxspeed = 1;
		}
		currentTime = millis() / 1000;
		flag = 0;
	}
	
}

void mouseClicked() {
	int stuck = 0;
	int activated = 0;
	for (Platelet p : platelets) {
		if (p.activated) 
			activated++;
	}
	for (Rbc r : rbcs) {
		if (r.stuck)
			stuck++;
	}
	print("Stuck: " + stuck + "\n");
	print("Activated: " + activated + "\n");
}


