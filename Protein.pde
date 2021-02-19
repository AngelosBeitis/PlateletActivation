class Protein extends BloodCont{
    
    Protein(PVector l, float ms, float mf) {
        
        super(l,ms,mf,1);      
        velocity.add(random(- 50,100),random(0,100));
        createShapes();
    }
    
    public void createShapes() {
        
        //float theta = velocity.heading2D() + radians(90);
        fill(0,255,0);
        stroke(0);
        setShape(createShape(ELLIPSE,cx,cy,rad,rad));
    }
    // @Override
    // public void follow(FlowField flow) {
    //     // What is the vector at that spot in the flow field?
    //     PVector desired = flow.lookup(position);
    //     // Scale it up by maxspeed
    //     desired.mult(positionSpeed());
    //     // Steering is desired minus velocity
    //     PVector steer = PVector.sub(desired, velocity);
    //     steer.limit(maxForce);  // Limit to maximum steering force
    //     applyForce(steer);
    
// }
    
}