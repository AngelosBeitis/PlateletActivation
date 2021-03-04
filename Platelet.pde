class Platelet extends BloodCont{
    
    public boolean activated;
    public PVector positionInDamage;    
    
    
    Platelet(PVector l) {
        
        super(l,2);
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
        this.setRadius(2);
        //create the new shape
        createShapes();     
    }
    
    private void createShapes() {
        if (!activated) {
            stroke(0);
            pushMatrix();
            fill(255);
            PShape platelet = createShape(GROUP);
            
            PShape body = createShape(ELLIPSE,0,0, this.rad * 2, this.rad * 2);
            platelet.addChild(body);
            setShape(platelet);
            popMatrix();
        }
        else{
            stroke(0);
            
            pushMatrix();
            fill(255);
            //translate(cx,cy);
            PShape platelet = createShape(GROUP);
            
            // Make 4shapes
            PShape body = createShape(ELLIPSE, 0, 0,this.rad * 2,this.rad * 2);
            PShape leg1 = createShape(LINE, 0, - this.rad * 2,this.rad / 8,this.rad * 2);
            PShape leg2 = createShape(LINE, 0, - this.rad * 2 ,this.rad / 8,this.rad * 2);
            PShape leg3 = createShape(LINE, 0, - this.rad * 2 ,this.rad / 8,this.rad * 2);
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
    public void checkCollision() {
        for (Platelet o : platelets) {
            // Get distances between the balls components
            PVector otherPosition = new PVector(o.cx,o.cy);
            PVector position = new PVector(cx,cy);
            PVector distanceVect = PVector.sub(otherPosition, position);
            
            
            
            // Calculate magnitude of the vector separating the balls
            float distanceVectMag = distanceVect.mag();
            
            // Minimum distance before they are touching
            
            float minDistance = this.rad + o.rad;
            
            if (distanceVectMag < minDistance) {
                if (!o.activated && this.activated) o.activate();
                else if (!this.activated && o.activated) this.activate();
            }
        }
    }
    
}