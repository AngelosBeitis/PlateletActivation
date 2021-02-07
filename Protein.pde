class Protein extends BloodCont{
    
    Protein(PVector l, float ms, float mf) {
        
        super(l,ms,mf,2.5);      
        acceleration.add(random(- 50,100),random(0,100));
    }
    
    @Override
    public void display() {
        
        float theta = velocity.heading2D() + radians(90);
        fill(0,255,0);
        stroke(0);
        ellipse(position.x,position.y,radius,radius);
    }
    @Override
    public void follow(FlowField flow) {
        // What is the vector at that spot in the flow field?
        PVector desired = flow.lookup(position);
        // Scale it up by maxspeed
        desired.mult(positionSpeed());
        // Steering is desired minus velocity
        PVector steer = PVector.sub(desired, velocity);
        //steer.limit(currentSpeed);  // Limit to maximum steering force
        applyForce(steer);
        
    }
}