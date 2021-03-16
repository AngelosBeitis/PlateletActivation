class Protein extends BloodCont{
    
    Protein(PVector l) {
        
        super(l,1);   
        ax = random( - 1,1);
        ay = random(0,1);   
        // will make them stay close to the damaged area
        //mass = 2;
        enableCollisions(false);        
        createShapes();
    }
    
    public void createShapes() {
        
        //float theta = velocity.heading2D() + radians(90);
        pushMatrix();
        fill(0,255,0);
        
        PShape protein = createShape(GROUP);
        stroke(0);
        protein.addChild(createShape(ELLIPSE,0,0,rad * 2,rad * 2));
        setShape(protein);
        popMatrix();
    }
    
}