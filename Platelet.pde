class Platelet extends BloodCont{
    
    public boolean activated;
    public PVector positionInDamage;    
    public int time;
    private int flag;
    private boolean stuckToWall;
    
    Platelet(PVector l) {
        super(l,1.5);
        flag = 0;
        activated = false;
        enableCollisions(true);
        createShapes();
        stuckToWall = false;
        
    }
    
    
    public boolean scan(Damage d) {
        if (positionInDamage == null) {
            float newX = random(d.left.x + 7, d.right.x - 7);
            float newY = d.top.y + 2.5;
            positionInDamage = new PVector(newX,newY);
        }
        float distance = dist(cx,cy,positionInDamage.x,positionInDamage.y);
        distance = distance - this.rad;
        boolean withinDist = distance < 20;
        float moveX = d.position.x;
        float moveY = d.position.y;
        if (withinDist && !this.activated && !this.checkStuck()) {
            float[] cnew = new float[2];
            cnew[0] = positionInDamage.x;
            cnew[1] = positionInDamage.y;
            moveToTarget(cnew,0.5);
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
                moveToTarget(cnew,0.5);
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
        //plug.addShape(this.getShape());     
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
    
    public boolean checkStuck() {
        boolean statement = false;
        if (this.activated) {                
            statement = true;
            if (cy > damage.top.y + this.rad) {
                float[] n = new float[2];
                n[0] = cx;
                n[1] = damage.top.y;
                this.stuckToWall = true;
                this.moveTo(n,0.005);
            }
        }
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
                
                if (this.flag == 0 && o.activated) {
                    this.time = millis() / 1000;
                    this.flag = 1;
                }
                
                if (!this.activated && o.activated) {
                    this.activate();    
                    this.time = millis() / 1000;   
                    this.flag = 0;    
                    statement = true;           
                }
                if ((o.activated && !this.activated) || (this.activated && o.activated && !this.stuckToWall)) {
                    float[] newo = new float[2];
                    newo[0] = o.cx;
                    newo[1] = o.cy;
                    this.moveToTarget(newo,0.5);
                    return statement;
                    // float[] newThis = new float[2];
                    // newThis[0] = this.cx;
                    // newThis[1] = this.cy;
                    // statement = true;
                    //o.moveTo(newThis,0.005);    
                }
                
            }
            else{
                this.flag = 0;
                this.time = millis();
            }
            
        }
        return statement;
    }
    
}