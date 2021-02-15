abstract class BloodCont{
    
    // The usual stuff
    PVector position;
    PVector velocity;
    PVector acceleration;
    float maxforce;    // Maximum steering force
    float speed;    // Maximum speed
    float radius;
    float currentSpeed;
    boolean activated;
    
    BloodCont(PVector l, float s, float mf,float rad) {
        position = l.get();
        speed = s;
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
        desired.mult(positionSpeed());
        // Steering is desired minus velocity
        PVector steer = PVector.sub(desired, velocity);
        steer.limit(maxForce);  // Limit to maximum steering force
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
        if(positionSpeed()==0)
            velocity.limit(speed);
        else
            velocity.limit(maxSpeed);
        position.add(velocity);
        // Reset accelertion to 0 each cycle
        acceleration.mult(0);
    }
    
    public void applyForce(PVector force) {
        // We could add mass here if we want A = F / M
        acceleration.add(force);
    }
    
    abstract void display();
    
    public void checkBoundary() {
        //bottom boundary
        if (position.y > height - this.radius - 30) {
            position.y = height - this.radius - 30;
            
        }
        //top boundary
        if (position.y < 30 + this.radius && (position.x < damage.left.x - this.radius || position.x > damage.right.x + this.radius)) {
            position.y = 30 + radius;
        }
        // within damaged cell
        if (position.x > damage.left.x + this.radius && position.x < damage.right.x + this.radius) {
            //if damage is on top
            if (position.y < 15 + this.radius)
                position.y = 15 + this.radius;
            // if damage is on the bottom
            if (position.y > height - 15 + this.radius)
                position.y = height - 15 + this.radius;
        }
        if (position.x < damage.left.x + this.radius && position.y > height - this.radius - 15) {
            position.x = damage.left.x + this.radius;
        }
        if (position.x > damage.right.x + this.radius && position.y > height - this.radius - 15) {
            position.x = damage.right.x + this.radius;
        }
        if (position.x < damage.left.x + this.radius && position.y < 15 + this.radius) {
            position.x = damage.left.x + this.radius;
        }
        if (position.x > damage.right.x + this.radius && position.y < 15 + this.radius) {
            position.x = damage.right.x + this.radius;
        }
        
    }
    public PVector flowVelocity() {
        PVector flowVelocity = flowfield.lookup(position);
        if (position.y >= height / 2)
            flowVelocity.mult(positionSpeed());
        else
            flowVelocity.mult(positionSpeed());
        
        return flowVelocity;     
    }
    
    public float positionSpeed() {
        
        if (position.y >= height / 2)
            currentSpeed = map(position.y,height / 2,height - 30 - this.radius ,flowfield.maxSpeed,0);
        else
            currentSpeed = map(position.y,30 + this.radius,height / 2,0,flowfield.maxSpeed);
        
        if (position.y <= 30 || position.y >= height - 30) {
            currentSpeed = 0;
        }
        return currentSpeed;
    }
    
    public void moveTo(float x,float y,boolean flag) {
        
        PVector target = new PVector(x,y);
        float distance = dist(position.x,position.y,x,y);
        PVector desired = PVector.sub(target,position);
        float d = desired.mag();
        desired.normalize();
        float speed = positionSpeed();
        float m;
        if (flag)
            m = map(d,1,distance,0,0.2);
        //m = 2;
        else
            m = map(d,0,100,flowfield.maxSpeed,currentSpeed);
        //float m = 1;
        desired.mult(m);
        PVector flowVelocity = flowVelocity();
        PVector steer = PVector.sub(desired,velocity);
        steer.add(flowVelocity);
        steer.limit(maxforce);
        applyForce(steer);
        
    }
    
    
}
