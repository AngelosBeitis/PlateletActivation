class Platelet extends BloodCont{
    
    boolean activated;
    PVector positionInDamage;
    
    Platelet(PVector l, float ms, float mf) {
        
        super(l,ms,mf,2.5);
        activated = false;
    }
    
    // public boolean scan(Damage d) {
    //     if (positionInDamage == null) {
    //         float newX = random(d.left.x + 7, d.right.x - 7);
    //         float newY = d.top.y + 2.5;
    //         positionInDamage = new PVector(newX,newY);
    //     }
    //     float distance = dist(position.x,position.y,positionInDamage.x,positionInDamage.y);
    //     distance = distance - this.radius;
    //     boolean withinDist = distance < 10;
    //     float moveX = d.position.x;
    //     float moveY = d.position.y;
    //     if (withinDist) {
    //         moveTo(positionInDamage.x, positionInDamage.y,true);
    //         //activate at the damaged area
    //         if (distance < 0.2)
    //             activate();
    //     }
    //     return withinDist;
    
// }
    @Override
    public void update() {
        // Update velocity
        if (!this.activated) {
            velocity.add(acceleration);
            if (positionSpeed() == 0)
                velocity.limit(speed);
            else
                velocity.limit(maxSpeed);
            position.add(velocity);
            // Reset accelertion to 0 each cycle
            acceleration.mult(0);
        }
    }
    
    // public boolean scanForProteins() {
    
    //     float distance;
    //     for (Protein p : proteins) {
    //         distance = dist(position.x,position.y,p.position.x,p.position.y);
    //         if (!activated && distance < 10) {
    //             moveTo(p.position.x,p.position.y,true);
    //             if (distance < 2) {
    //                 proteins.remove(p);
    //                 scanForProteins();
    //             }
    //             return true;
    //         }
    //     }
    
    //     return false;
    
// }
    
    
    public void activate() {
        activated = true;
        currentSpeed = 0;
        this.radius = 4;
        
    }
    @Override
    public void display() {
        if (!activated) {
            fill(255);
            stroke(0);
            //ellipse(position.x,position.y,this.radius * 2,this.radius * 2);
            setShape(createShape(RECT,position.x,position.y,100,50));
        }
        else{
            float theta = velocity.heading2D() + radians(90);
            fill(255);
            stroke(0);
            pushMatrix();
            translate(position.x,position.y);
            rotate(theta);
            PShape platelet = createShape(GROUP);
            
            // Make 4shapes
            PShape body = createShape(ELLIPSE, 0, 0,this.radius * 2,this.radius * 2);
            PShape leg1 = createShape(LINE, 0, - this.radius * 2,this.radius / 8,this.radius * 2);
            PShape leg2 = createShape(LINE, 0, - this.radius * 2 ,this.radius / 8,this.radius * 2);
            PShape leg3 = createShape(LINE, 0, - this.radius * 2 ,this.radius / 8,this.radius * 2);
            body.fill(255);
            leg2.rotate(1);
            leg3.rotate(2);
            // Add the 4 "child" shapes to the parent group
            
            platelet.addChild(leg1);
            platelet.addChild(leg2);
            platelet.addChild(leg3);
            platelet.addChild(body);
            
            
            // Draw the group
            
            shape(platelet);
            popMatrix();
        }
    }
    public void checkCollision() {
        for (Platelet o : platelets) {
            if (this.activated || o.activated) {
                // Get distances between the balls components
                PVector distanceVect = PVector.sub(o.position, position);
                float m = this.radius * .1;
                float m2 = o.radius *.1;
                
                
                // Calculate magnitude of the vector separating the balls
                float distanceVectMag = distanceVect.mag();
                
                // Minimum distance before they are touching
                float minDistance = this.radius + o.radius;
                
                if (distanceVectMag < minDistance) {
                    float distanceCorrection = (minDistance - distanceVectMag) / 2.0;
                    PVector d = distanceVect.copy();
                    PVector correctionVector = d.normalize().mult(distanceCorrection);
                    
                    if (!o.activated) {
                        o.position.add(correctionVector);
                        if (this.activated && o.withinDamage())
                            o.activate();
                    }
                    if (!this.activated) {
                        position.sub(correctionVector);
                        if (o.activated && this.withinDamage()) 
                            this.activate();
                    }
                }
            }
        }
    }
    
    public boolean withinDamage() {
        if (position.y < damage.bottom.y && position.x > damage.left.x && position.x < damage.right.x)
            return true;
        return false;
    }
}