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
        r = 3.0;
        maxspeed = ms;
        radius = rad;
        maxforce = mf;
        acceleration = new PVector(0,0);
        velocity = new PVector(0,0);
    }
    
    // Implementing Reynolds' flow field following algorithm
    // http://www.red3d.com/cwr/steer/FlowFollow.html
    void follow(FlowField flow) {
        // What is the vector at that spot in the flow field?
        PVector desired = flow.lookup(position);
        // Scale it up by maxspeed
        desired.mult(positionSpeed());
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
    void update() {
        // Update velocity
        velocity.add(acceleration);
        // Limit speed
        velocity.limit(maxspeed);
        position.add(velocity);
        // Reset accelertion to 0 each cycle
        acceleration.mult(0);
    }
    
    void applyForce(PVector force) {
        // We could add mass here if we want A = F / M
        acceleration.add(force);
    }
    
    abstract void display();
    
    void checkBoundary() {
        
        if (position.y > height - radius - 15) {
            position.y = height - radius - 15;
        } else if (position.y < 15 + radius && (position.x < damage.left.x || position.x > damage.right.x)) {
            position.y = 15 + radius;
        }
    }
    PVector flowVelocity(FlowField flow) {
        PVector flowVelocity = flow.lookup(position);
        if (position.y >= height / 2)
            flowVelocity.mult(positionSpeed());
        else
            flowVelocity.mult(positionSpeed());
        
        return flowVelocity;     
    }
    
    float positionSpeed() {
        if (position.y >= height / 2)
            return map(position.y,height / 2,height - 15 - radius ,maxspeed,0);
        else
            return map(position.y,15 + radius,height / 2,0,maxspeed);
        
    }
}