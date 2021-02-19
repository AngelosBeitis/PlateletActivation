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
        
        // add force: Fluid Velocity
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
        
        
        this.addForce(fluid_vxy);
        updateShapePosition();
        updatePosition(0.5);
        
    }
    
    public void applyForce(PVector force) {
        // We could add mass here if we want A = F / M
        acceleration.add(force);
    }
    
    public void display(PGraphics pg) {
        pg.shape(this.getShape());
        
    }    
    public void checkBoundary() {
        //bottom boundary
        if (cy > height - this.rad - 30) {
            cy = height - this.rad - 30;
            
        }
        //top boundary
        if (cy < 30 + this.rad && (cx < damage.left.x - this.rad || cx > damage.right.x + this.rad)) {
            cy = 30 + radius;
        }
        // within damaged cell
        if (cx > damage.left.x + this.rad && cx < damage.right.x + this.rad) {
            //ifdamage is on top
            if (cy < 15 + this.rad)
                cy = 15 + this.rad;
            // if damage is on the bottom
            if (cy > height - 15 + this.rad)
                cy = height - 15 + this.rad;
        }
        if (cx < damage.left.x + this.rad && cy > height - this.rad - 15) {
            cx = damage.left.x + this.rad;
        }
        if (cx > damage.right.x + this.rad && cy > height - this.rad - 15) {
            cx = damage.right.x + this.rad;
        }
        if (cx < damage.left.x + this.rad && cy < 15 + this.rad) {
            cx = damage.left.x + this.rad;
        }
        if (cx > damage.right.x + this.rad && cy < 15 + this.rad) {
            cx = damage.right.x + this.rad;
        }
        
    }
    
    // public void moveTo(float x,float y,boolean flag) {
    
    //     PVector target = new PVector(x,y);
    //     float distance = dist(cx,cy,x,y);
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
