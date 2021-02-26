class Platelet extends BloodCont{
    
    public boolean activated;
    public PVector positionInDamage;    
    
    
    Platelet(PVector l) {
        
        super(l,1.5);
        activated = false;
        enableCollisions(true);
        createShapes();
        
    }
    
    
    public boolean scan(Damage d) {
        if (positionInDamage == null) {
            float newX = random(d.left.x + 7, d.right.x - 7);
            float newY = d.top.y + 2.5;
            positionInDamage = new PVector(newX,newY);
        }
        float distance = dist(cx,cy,positionInDamage.x,positionInDamage.y);
        distance = distance - this.rad;
        boolean withinDist = distance < 60;
        float moveX = d.position.x;
        float moveY = d.position.y;
        if (withinDist) {
            float[] cnew = new float[2];
            cnew[0] = positionInDamage.x;
            cnew[1] = positionInDamage.y;
            moveTo(cnew,0.01);
            //moveTo(positionInDamage.x,positionInDamage.y);
            //activate at the damaged area
            if (distance < 0.2 && activated == false)
                activate();
        }
        return withinDist;
        
    }
    
    public boolean scanForProteins() {
        float distance;
        for (Protein p : proteins) {
            float[] cnew = new float[2];
            cnew[0] = p.cx;
            cnew[1] = p.cy;
            
            distance = dist(cx,cy,p.cx,p.cy);
            if (!activated && distance < 20) {
                moveTo(cnew,0.01);
                //moveTo(p.cx,p.cy);
                if (distance < 2) {
                    proteins.remove(p);
                    scanForProteins();
                }
            }
            return true;
            
        }
        
        return false;
        
    }
    
    
    public void activate() {
        activated = true;
        this.rad = 2;
        //create the new shape
        //createShapes();     
    }
    
    private void createShapes() {
        if (!activated) {
            stroke(0);
            pushMatrix();
            fill(255);
            PShape platelet = createShape(GROUP);
            
            PShape body = createShape(ELLIPSE,0,0, this.rad * 2, this.rad * 2);
            fill(255);
            platelet.addChild(body);
            setShape(platelet);     
            popMatrix();
        }
        else{
            fill(255);
            stroke(0);
            pushMatrix();
            //translate(cx,cy);
            PShape platelet = createShape(GROUP);
            
            // Make 4shapes
            PShape body = createShape(ELLIPSE, 0, 0,this.rad * 2,this.rad * 2);
            PShape leg1 = createShape(LINE, 0, - this.rad * 2,this.rad / 8,this.rad * 2);
            PShape leg2 = createShape(LINE, 0, - this.rad * 2 ,this.rad / 8,this.rad * 2);
            PShape leg3 = createShape(LINE, 0, - this.rad * 2 ,this.rad / 8,this.rad * 2);
            body.fill(255);
            leg2.rotate(1);
            leg3.rotate(2);
            // Add the 4 "child" shapes to the parent group
            
            platelet.addChild(leg1);
            platelet.addChild(leg2);
            platelet.addChild(leg3);
            platelet.addChild(body);
            
            
            // Draw the group
            setShape(platelet);
            popMatrix();
        }
        
    }
    
    public boolean withinDamage() {
        if (cy < damage.bottom.y && cx > damage.left.x && cx < damage.right.x)
            return true;
        return false;
    }
    
    public void collision(List<Platelet> platelets) {
        for (Platelet p : platelets) {
            this.updateCollision(p);
            afterCollision();
        }
        
        
    }
    // public void checkCollision() {
    //     for (Platelet o : platelets) {
    //         // Get distances between the balls components
    //         PVector otherPosition = new PVector(o.cx,o.cy);
    //         PVector position = new PVector(cx,cy);
    //         PVector distanceVect = PVector.sub(otherPosition, position);
    
    
    
    //         // Calculate magnitude of the vector separating the balls
    //         float distanceVectMag = distanceVect.mag();
    
    //         // Minimum distance before they are touching
    
    //         float minDistance = this.rad + o.rad;
    
    //         if (distanceVectMag < minDistance) {
    //             float distanceCorrection = (minDistance - distanceVectMag) / 2.0;
    //             PVector d = distanceVect.copy();
    //             PVector correctionVector = d.normalize().mult(distanceCorrection);
      
    //             //otherPosition.add(correctionVector);
    //             o.cx += correctionVector.x;
    //             o.cy += correctionVector.y;
    //             // if (this.activated)
    //             //     o.activate();
    //             //position.sub(correctionVector);
    //             cx += correctionVector.x;
    //             cy += correctionVector.y;
    //             // if (o.activated) 
    //             //     this.activate();
    //         }
    //     }
// }
    
}