abstract class BloodCont extends DwParticle2D{
    
    // The usual stuff
    public DwParticle2D.Param param = new DwParticle2D.Param();
    
    BloodCont(PVector l,float rad) {
        super(1,l.x,l.y,rad);
        param.DAMP_COLLISION = 0.2f;
        param.DAMP_VELOCITY  = 0.2f;
        this.setPosition(l.x,l.y);
        
    }
    
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
        fluid_vxy[0] = + fluid_velocity[PIDX * 2] * 0.05f * 1f;
        fluid_vxy[1] = - fluid_velocity[PIDX * 2 + 1] * 0.05f * 1f; // invert y
        
        
        this.addForce(fluid_vxy);
        // updateShapePosition();
        // updatePosition(1);
        
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
            cy = 30 + this.rad;
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
    
    // public void moveTo(float x,float y) {
    //     PVector position = new PVector(cx,cy);
    //     PVector target = new PVector(x,y);
    //     float distance = dist(cx,cy,x,y);
    //     PVector desired = PVector.sub(target,position);
    //     float d = desired.mag();
    //     desired.normalize();
    //     float m = ax;
    //     desired.mult(m);
    //     //PVector steer = PVector.sub(desired,velocity);
    //     float[] o = new float[2];
    //     o[0] = desired.x;
    //     o[1] = desired.y;
    //     this.addForce(o);
    
// }
    
    
}
