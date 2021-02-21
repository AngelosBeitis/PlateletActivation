class Protein extends BloodCont{
    
    Protein(PVector l) {
        
        super(l,1);      
        createShapes();
    }
    
    public void createShapes() {
        
        //float theta = velocity.heading2D() + radians(90);
        fill(0,255,0);
        stroke(0);
        setShape(createShape(ELLIPSE,cx,cy,rad,rad));
    }
    
}