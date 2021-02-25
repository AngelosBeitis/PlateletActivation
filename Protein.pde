class Protein extends BloodCont{
    
    Protein(PVector l) {
        
        super(l,1);   
        ax = 0;
        ay = 0;   
        // will make them stay close to the damaged area
        //mass = 0.01;
        createShapes();
    }
    
    public void createShapes() {
        
        //float theta = velocity.heading2D() + radians(90);
        pushMatrix();
        fill(255,0,0);
        
        PShape protein = createShape(GROUP);
        fill(0,255,0);
        stroke(0);
        protein.addChild(createShape(ELLIPSE,0,0,rad * 2,rad * 2));
        setShape(protein);
        popMatrix();
    }
    
}