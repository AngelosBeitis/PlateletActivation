class Rbc extends BloodCont{
    
    public boolean stuck;
    
    Rbc(PVector l) {
        super(l,2);
        stuck = false;
        createShapes();
        enableCollisions(true);
        
    }
    
    private void createShapes() {
        
        stroke(0);
        pushMatrix();
        fill(255,0,0);
        
        PShape rbc = createShape(GROUP);
        
        PShape body = createShape(ELLIPSE,0,0, this.rad * 2, this.rad * 2);        
        PShape inner = createShape(ELLIPSE,0,0, this.rad / 2, this.rad / 2);
        
        rbc.addChild(body);
        rbc.addChild(inner);
        this.setShape(rbc);
        //this.setColor(color(255,0,0));
        
        popMatrix();
        
    }
    
    public void checkStuck() {
        for (Platelet o : platelets) {
            // Get distances between the balls components
            PVector otherPosition = new PVector(o.cx,o.cy);
            PVector position = new PVector(cx,cy);
            PVector distanceVect = PVector.sub(otherPosition, position);
            
            // Calculate magnitude of the vector separating the balls
            float distanceVectMag = distanceVect.mag();
            
            // Minimum distance before they are touching
            
            float minDistance = this.rad  + o.rad;
            if (distanceVectMag < minDistance) {
                if (o.activated) {
                    
                    this.stuck = true;
                    return;
                }
            }
            else{
                this.stuck = false;
            }
            
        }
    }
}