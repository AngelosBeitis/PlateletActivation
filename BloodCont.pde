abstract class BloodCont extends DwParticle2D{
    
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
        super(1,l.x,l.y,rad);
        this.setPosition(l.x,l.y);
        position = l.get();
        speed = s;
        radius = rad;
        maxforce = mf;
        acceleration = new PVector(0,0);
        velocity = new PVector(0,0);
    }
    
    // Implementing Reynolds' flow field following algorithm
    // http://www.red3d.com/cwr/steer/FlowFollow.html
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
    
    
    // Method to update position
    public void update(float[] fluid_velocity) {
        
        // add force: FLuid Velocity
        float[] fluid_vxy = new float[2];
        
        int px_view = Math.round(this.cx);
        int py_view = Math.round(height - 1 - this.cy); // invert y
        
        int px_grid = px_view / fluid.grid_scale;
        int py_grid = py_view / fluid.grid_scale;
        
        int w_grid  = fluid.tex_velocity.src.w;
        int h_grid  = fluid.tex_velocity.src.h;
        
        // clamp coordinates, just in case
        if (px_grid < 0) px_grid = 0; else if (px_grid >= w_grid) px_grid = w_grid;
        if (py_grid < 0) py_grid = 0; else if (py_grid >= h_grid) py_grid = h_grid;
        
        int PIDX = py_grid * w_grid + px_grid;
        
        fluid_vxy[0] = + fluid_velocity[PIDX * 2 + 0] * 0.05f * 0.50f;
        fluid_vxy[1] = - fluid_velocity[PIDX * 2 + 1] * 0.05f * 0.50f; // invert y
        
        // PVector force = new PVector(fluid_vxy[0],fluid_vxy[1]);
        // this.applyForce(force);
        this.addForce(fluid_vxy);
        //this.moveTo(fluid_vxy,0.1);
        
    }
    
    public void applyForce(PVector force) {
        // We could add mass here if we want A = F / M
        acceleration.add(force);
    }
    
    abstract void display(PGraphics pg);
    
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
            //ifdamage is on top
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
    
    // public void moveTo(float x,float y,boolean flag) {
    
    //     PVector target = new PVector(x,y);
    //     float distance = dist(position.x,position.y,x,y);
    //     PVector desired = PVector.sub(target,position);
    //     float d = desired.mag();
    //     desired.normalize();
    //     float speed = positionSpeed();
    //     float m;
    //     if (flag)
    //         m = map(d,1,distance,0,0.2);
    //     //m = 2;
    //     else
    //         m = map(d,0,100,flowfield.maxSpeed,currentSpeed);
    //     //float m = 1;
    //     desired.mult(m);
    //     PVector flowVelocity = flowVelocity();
    //     PVector steer = PVector.sub(desired,velocity);
    //     steer.add(flowVelocity);
    //     steer.limit(maxforce);
    //     applyForce(steer);
    
// }
    
    
}
