class Rbc extends BloodCont{
    
    boolean stuck;
    
    Rbc(PVector l, float ms, float mf) {
        super(l,ms,mf,5);
        stuck = false;
    }
    @Override
    public void display() {
        float theta = velocity.heading2D() + radians(90);
        stroke(0);
        pushMatrix();
        PShape rbc = createShape(GROUP);
        
        PShape body = createShape(ELLIPSE,position.x,position.y, this.radius * 2, this.radius * 2);
        PShape inner = createShape(ELLIPSE,position.x,position.y, this.radius, this.radius);
        fill(255,0,0);
        rbc.addChild(body);
        rbc.addChild(inner);
        setShape(rbc);
        popMatrix();
    }
    public void stickTo(Platelet p) {
        
        if (p.activated == true && dist(position.x,position.y,p.position.x,p.position.y) < 2) {
            velocity = new PVector(0,0);
            acceleration = new PVector(0,0);
            stuck = true;
        }
    }
    
    // public void checkCollision(ArrayList<Rbc> others) {
    //     for (Rbc other : others) {
    
    //         // Get distances between the balls components
    //         PVector distanceVect = PVector.sub(other.position, position);
    
    //         float m =this.radius * .1;
    
    //         // Calculate magnitude of the vector separating the balls
    //         float distanceVectMag = distanceVect.mag();
    
    //         // Minimum distance before they are touching
    //         float minDistance =this.radius + other.radius;
    
    //         if (distanceVectMag < minDistance) {
    //             float distanceCorrection = (minDistance - distanceVectMag) / 2.0;
    //             PVector d = distanceVect.copy();
    //             PVector correctionVector = d.normalize().mult(distanceCorrection);
    //             other.position.add(correctionVector);
    //             position.sub(correctionVector);
     
    //         }
    //     }
//}
}