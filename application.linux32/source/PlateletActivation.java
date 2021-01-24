import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.List; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class PlateletActivation extends PApplet {



boolean debug = true;

// Flowfield object
FlowField flowfield;
// An ArrayList of vehicles
List<Rbc> rbcs;
List<Platelet> platelets;
Damage damage;
int flag = 0;
int currentTime = millis() / 1000;

public void setup() {
	frameRate(60);
	
	// Make a new flow field with "resolution" of 16
	flowfield = new FlowField(20);
	rbcs = new ArrayList<Rbc>();
	platelets = new ArrayList<Platelet>();
	damage = new Damage(350,15,50);
}

public void draw() {
	background(255,252,182);
	flowfield.update();
	
	// Display the flowfield in "debug" mode
	flowfield.display();
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
	// add red blood cells at a random height but at the right of the screen
	rbcs.add(new Rbc(new PVector(width, random(10,height - 20)), 2, 0.4f));
	
	// add platelets everey 5 seconds
	if ((millis() / 1000) - currentTime >= 5 && flag == 0) {
		platelets.add(new Platelet(new PVector(width, random(1,height / 2)), random(1.0f,2.0f), 0.4f));
		platelets.add(new Platelet(new PVector(width, random(height - 100,height)), 2, 0.4f));
		currentTime = millis() / 1000;
		flag = 1;
	}
	if ((millis() / 1000) - currentTime >= 5 && flag == 1) {
		platelets.add(new Platelet(new PVector(width, random(1,height / 2)), 2, 0.4f));
		platelets.add(new Platelet(new PVector(width, random(height - height / 2,height)), 2, 0.4f));
		currentTime = millis() / 1000;
		flag = 0;
	}
	fill(0);
	
}

public void heartBeat() {
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

public void mouseClicked() {
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
abstract class BloodCont{
	
	// The usual stuff
	PVector position;
	PVector velocity;
	PVector acceleration;
	float r;
	float maxforce;    // Maximum steering force
	float maxspeed;    // Maximum speed
	float radius;
	
	BloodCont(PVector l, float ms, float mf,float rad) {
		position = l.get();
		r = 3.0f;
		maxspeed = ms;
		radius = rad;
		maxforce = mf;
		acceleration = new PVector(0,0);
		velocity = new PVector(0,0);
	}
	
	// Implementing Reynolds' flow field following algorithm
	// http://www.red3d.com/cwr/steer/FlowFollow.html
	public void follow(FlowField flow) {
		// What is the vector at that spot in the flow field?
		PVector desired = flow.lookup(position);
		// Scale it up by maxspeed
		desired.mult(maxspeed);
		// Steering is desired minus velocity
		PVector steer = PVector.sub(desired, velocity);
		steer.limit(maxforce);  // Limit to maximum steering force
		applyForce(steer);
	}
	public void run() {
		update();
		display();
	}
	
	// Method to update position
	public void update() {
		// Update velocity
		velocity.add(acceleration);
		// Limit speed
		velocity.limit(maxspeed);
		position.add(velocity);
		// Reset accelertion to 0 each cycle
		acceleration.mult(0);
	}
	
	public void applyForce(PVector force) {
		// We could add mass here if we want A = F / M
		acceleration.add(force);
	}
	
	public abstract void display();
	
	public void checkBoundary() {
		
		if (position.y > height - radius - 15) {
			position.y = height - radius - 15;
		} else if (position.y < radius) {
			position.y = radius;
		}
	}
}
class Damage{
	
	PVector position;
	int size;
	int x;
	int y;
	PVector top;
	PVector bottom;
	PVector left;
	PVector right;
	Damage(float x1, float y1, int s) {
		size = s;
		position = new PVector(x1,y1);
		top = new PVector(x1,position.y - (size / 8));
		bottom = new PVector(x1,position.y + (size / 8));
		left = new PVector(position.x - size / 2 ,y1);
		right = new PVector(position.x + size / 2,y1);
	}
	
	public void display() {
		fill(73,70,70);
		ellipse(position.x,position.y,size,size / 4);
		
	}
	
	
	
}
class FlowField {
	
	// A flow field is a two dimensional array of PVectors
	PVector[][] field;
	int cols, rows; // Columns and Rows
	int resolution; // How large is each "cell" of the flow field
	
	float zoff = 0.0f; // 3rd dimension of noise
	
	FlowField(int r) {
		resolution = r;
		// Determine the number of columns and rows based on sketch's width and height
		cols = width / resolution;
		rows = height / resolution;
		field = new PVector[cols][rows];
		init();
	}
	
	public void init() {
		// Reseed noise so we get a new flow field every time
		noiseSeed((int)random(10000));
		float xoff = 0;
		float theta;
		for (int i = 0; i < cols; i++) {
			float yoff = 0;
			for (int j = 0; j < rows; j++) {
				theta = noise(xoff,yoff,zoff) + PI / 1.2f;
				//theta = PI/4;
				//Polar to cartesian coordinate transformation to get x and y components of the vector
				field[i][j] = new PVector(cos(theta),sin(theta));
				yoff += 0.1f;
			}
			xoff += 0.1f;
		}
	}
	public void update() {
		float xoff = 0;
		float theta;
		for (int i = 0; i < cols; i++) {
			float yoff = 0;
			for (int j = 0; j < rows; j++) {
				theta = map(noise(xoff,yoff,zoff),0,1,PI / 1.1f,PI * 1.1f);
				//Make a vector from an angle
				field[i][j] = PVector.fromAngle(theta);
				yoff += 0.1f;
			}
			xoff += 0.1f;
		}
		// Animate by changing 3rd dimension of noise every frame
		zoff += 0.01f;
	}
	
	// Draw every vector
	public void display() {
		// for (int i = 0; i < cols; i++) {
		// 	for (int j = 0; j < rows; j++) {
		// 		drawVector(field[i][j],i * resolution,j * resolution,resolution - 2);
		// 	}
		// }
		fill(213,110,110);
		ellipse(width / 2,height - 5,width,20);
		fill(213,110,110);
		ellipse(width / 2,5,width,20);
	}
	
	// Renders a vector object 'v' as an arrow and a position 'x,y'
	public void drawVector(PVector v, float x, float y, float scayl) {
		pushMatrix();
		float arrowsize = 1;
		// Translate to position to render vector
		translate(x,y);
		stroke(0,100);
		// Call vector heading function to get direction (note that pointing to the right is a heading of 0) and rotate
		rotate(v.heading2D());
		// Calculate length of vector & scale it to be bigger or smaller if necessary
		float len = v.mag() * scayl;
		// Draw three lines to make an arrow (draw pointing up since we've rotate to the proper direction)
		line(0,0,len,0);
		//line(len,0,len-arrowsize,+arrowsize/2);
		//line(len,0,len-arrowsize,-arrowsize/2);
		popMatrix();
	}
	
	public PVector lookup(PVector lookup) {
		int column = PApplet.parseInt(constrain(lookup.x / resolution,0,cols - 1));
		int row = PApplet.parseInt(constrain(lookup.y / resolution,0,rows - 1));
		return field[column][row].get();
	}
	
	
}
class Platelet extends BloodCont{
	
	boolean activated;
	
	Platelet(PVector l, float ms, float mf) {
		
		super(l,ms,mf,2.5f);
		activated = false;
	}
	
	public boolean scan(Damage d) {
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
	
	public boolean scanForActivated(List<Platelet> platelets) {
		
		float distance;
		for (Platelet p : platelets) {
			distance = dist(position.x,position.y,p.position.x,p.position.y);
			if (p.activated == true && activated == false && distance < height / 1.5f) {
				moveTo(p.position.x,p.position.y);
				if (distance < 5)
					activate();
				return true;
			}
		}
		
		return false;
		
	}
	
	public void moveTo(float x,float y) {
		
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
	
	public void activate() {
		activated = true;
		velocity = new PVector(0,0);
		acceleration = new PVector(0,0);
		
	}
	public @Override
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
class Rbc extends BloodCont{
	
	boolean stuck;
	
	Rbc(PVector l, float ms, float mf) {
		super(l,ms,mf,5);
		stuck = false;
	}
	public @Override
	void display() {
		float theta = velocity.heading2D() + radians(90);
		fill(255,0,0);
		stroke(0);
		ellipse(position.x,position.y,radius * 2,radius * 2);
	}
	
	public void stickTo(Platelet p) {
		
		if (p.activated == true && dist(position.x,position.y,p.position.x,p.position.y)<2) {
			velocity = new PVector(0,0);
			acceleration = new PVector(0,0);
			stuck = true;
		}
	}
	
	
	public void checkCollision(ArrayList<Rbc> others) {
		for (Rbc other : others) {
			
			// Get distances between the balls components
			PVector distanceVect = PVector.sub(other.position, position);
			
			float m = radius * .1f;
			
			// Calculate magnitude of the vector separating the balls
			float distanceVectMag = distanceVect.mag();
			
			// Minimum distance before they are touching
			float minDistance = radius + other.radius;
			
			if (distanceVectMag < minDistance) {
				float distanceCorrection = (minDistance - distanceVectMag) / 2.0f;
				PVector d = distanceVect.copy();
				PVector correctionVector = d.normalize().mult(distanceCorrection);
				other.position.add(correctionVector);
				position.sub(correctionVector);
				
			}
		}
	}
}
  public void settings() { 	size(640, 340); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "PlateletActivation" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
