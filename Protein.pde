class Protein extends BloodCont{
    
    Protein(PVector l) {
        
        super(l,1);   
        ax = 0;
        ay = 0.05;   
        // will make them stay close to the damaged area
        //mass = 2;
        enableCollisions(false);        
        createShapes();
    }
    
    public void createShapes() {
        
        pushMatrix();
        fill(0,255,0);
        PShape protein = createShape(GROUP);
        stroke(0);
        protein.addChild(createShape(ELLIPSE,0,0,rad * 2,rad * 2));
        setShape(protein);
        popMatrix();
    }
    
}
