class Protein extends BloodCont{
    
    Protein(PVector l, float ms, float mf) {
        super(l,ms,mf,2.5);
        
    }
    
    @Override
    void display() {
        float theta = velocity.heading2D() + radians(90);
        fill(0,255,0);
        stroke(0);
        ellipse(position.x,position.y,radius,radius);
    }
    
}