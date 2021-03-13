abstract class BloodCont extends DwParticle2D{
    
    // fluid velocity
    public float[] fv;
    
    BloodCont(PVector l,float rad) {
        super(1,l.x,l.y,rad);
        //fv = new float[2];
        this.setPosition(l.x,l.y);
        
    }
    
    public float[] fluidVelocity(float[] fluid_velocity) {
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
        fluid_vxy[0] = + fluid_velocity[PIDX * 2] * 0.05f * 1f;
        fluid_vxy[1] = - fluid_velocity[PIDX * 2 + 1] * 0.05f * 1f; // invert y
        
        return fluid_vxy;
    }
    // Method to update position
    public void update(float[] fluid_velocity) {
        
        
        this.fv = fluid_velocity;
        this.addForce(fluidVelocity(fv));
        updateShapePosition();
        updatePosition(1);
        
    }
    //abstract void createShapes();
    
    public void checkBoundary() {
        //bottom boundary
        if (cy > height - this.rad - 30) {
            cy = height - this.rad - 30;
            
        }
        //top boundary
        if (cy < 30 + this.rad && (cx < damage.left.x - this.rad || cx > damage.right.x + this.rad)) {
            cy = 30 + this.rad;
        }
        // within damaged cell
        if (cx > damage.left.x - this.rad && cx < damage.right.x + this.rad) {
            //ifdamage is on top
            if (cy < 15 + this.rad)
                cy = 15 + this.rad;
            // if damage is on the bottom
            if (cy > height - 15 + this.rad)
                cy = height - 15 + this.rad;
        }
        if (cx < damage.left.x + this.rad && cy > height - this.rad - 30) {
            cx = damage.left.x + this.rad;
            
        }
        if (cx > damage.right.x - this.rad && cy > height - this.rad - 30) {
            cx = damage.right.x - this.rad;
            
        }
        if (cx < damage.left.x + this.rad && cy < 30 + this.rad) {
            cx = damage.left.x + this.rad;            
        }
        if (cx > damage.right.x - this.rad && cy < 30 + this.rad) {
            cx = damage.right.x - this.rad;
            
        }
        
    }
    public void moveTo(float[] cnew) {
        PVector position = new PVector(cx,cy);
        PVector target = new PVector(cnew[0],cnew[1]);
        //float distance = dist(this.cx,this.cy,cnew[0],cnew[1]);
        PVector desired = PVector.sub(target,position);
        float d = desired.mag();
        desired.normalize();
        float m = 0.05;
        desired.mult(m);
        float vx = (cx - px) * ax;
        float vy = (cy - py) * ay;
        PVector velocity = new PVector(vx ,vy);
        //velocity.normalize();
        PVector steer = PVector.sub(desired,velocity);
        
        float[] steerNew = new float[2];
        steerNew[0] = steer.x;
        steerNew[1] = steer.y;
        addForce(steerNew);
        
    }
    
}
