class Rbc extends BloodCont{
    
    boolean stuck;
    
    Rbc(PVector l) {
        super(l,2);
        stuck = false;
        createShapes();
        enableCollisions(false);
        
    }
    
    private void createShapes() {
        stroke(0);
        pushMatrix();
        fill(color(255,0,0));
        
        PShape rbc = createShape(GROUP);
        
        PShape body = createShape(ELLIPSE,0,0, this.rad * 2, this.rad * 2);
        //PShape inner = createShape(ELLIPSE,0,0, this.radius, this.radius);
        rbc.addChild(body);
        rbc.setStroke(color(255,0,0));
        rbc.setFill(color(255,0,0));
        //rbc.addChild(inner);
        setShape(rbc);  
        //this.setColor(120);   
        popMatrix();
    }
    
    public void stickTo(Platelet p) {
        
        if (p.activated == true && dist(cx,cy,p.cx,p.cy) < 2) {
            
            stuck = true;
        }
    }
    
}