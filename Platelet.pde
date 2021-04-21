class Platelet extends BloodCont{
    
    public boolean activated;
    public int time;
    private int flag;
    public boolean stuckToWall;
    public boolean stuckToPlatelet;
    
    Platelet(PVector l) {
        super(l,1.5);
        flag = 0;
        activated = false;
        enableCollisions(true);
        createShapes();
        stuckToWall = false;
        stuckToPlatelet = false;
        
    }
    
    
    public boolean scan(Damage d) {
        
        float distance = cy - d.top.y;
        distance = distance - this.rad;
        boolean withinDist = distance < 20;
        boolean nearDamage;
        if (cx > d.left.x && cx < d.right.x) {
            nearDamage = true;
        }
        else{
            nearDamage = false;
        }
        if (withinDist && !this.activated && (!this.stuckToWall && !this.stuckToPlatelet) && nearDamage) {            
            float[] cnew = new float[2];
            cnew[0] = cx;
            cnew[1] = d.top.y;
            moveToTarget(cnew,0.5);
            //activate at the damaged area
            if (distance < 1 && activated == false)
                activate();
        }
        return withinDist;
        
    }
    
    public void scanForProteins() {
        float distance;
        Protein closestProtein = proteins.get(0);
        float[] cnew = new float[2];
        float closestDistance =  dist(cx,cy,closestProtein.cx,closestProtein.cy); 
        for (Protein p : proteins) {
            cnew[0] = p.cx;
            cnew[1] = p.cy;
            
            distance = dist(cx,cy,p.cx,p.cy);
            if (distance < closestDistance) {
                closestProtein = p;
                closestDistance = distance;
            }
            
        }
        cnew[0] = closestProtein.cx;
        cnew[1] = closestProtein.cy;   
        if (closestDistance < 30) {
            if (closestDistance < 2 && !this.activated) {
                proteins.remove(closestProtein);
                
            }
            
            moveToTarget(cnew,0.5);
        }
        
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
            if (cy <= damage.top.y + this.rad * 2) {
                statement = true;
                float[] n = new float[2];
                n[0] = cx;
                n[1] = damage.top.y;
                this.stuckToWall = true;
                cx = px;
                cy = py;
                return true;
            }
            else{
                this.stuckToWall = false;
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
            if (distanceVectMag < minDistance && position!= otherPosition) {
                
                if (this.flag == 0 && o.activated) {
                    this.flag = 1;
                }
                
                if (!this.activated && o.activated && (o.stuckToWall || o.stuckToPlatelet)) {
                    this.activate();    
                    this.flag = 0;    
                    statement = true;           
                }
                if ((o.activated && !this.activated) || (this.activated && o.activated && !this.stuckToWall)) {
                    println("Here");
                    float[] newo = new float[2];
                    newo[0] = o.cx;
                    newo[1] = o.cy;
                    cx = px;
                    cy = py;
                    
                    this.stuckToPlatelet = true;
                    return true;
                    
                }
                else{
                    this.stuckToPlatelet = false;
                    
                }
                
            }
            else{
                this.stuckToPlatelet = false;
                this.flag = 0;
            }
            
        }
        return statement;
    }
    
    public boolean checkStuck2() {
        
        for (Platelet o : platelets) {
            // Get distances between the balls components
            PVector otherPosition = new PVector(o.cx,o.cy);
            PVector position = new PVector(cx,cy);
            PVector distanceVect = PVector.sub(otherPosition, position);
            
            // Calculate magnitude of the vector separating the balls
            float distanceVectMag = distanceVect.mag();
            
            // Minimum distance before they are touching
            
            float minDistance = this.rad  + o.rad;
            if (distanceVectMag < minDistance && position!= otherPosition) {
                
                if (!this.activated && o.activated && (o.stuckToWall || o.stuckToPlatelet) && this.withinDamage()) {
                    this.activate(); 
                }
            }
        }
        if (this.activated) {                
            if (cy < damage.bottom.y + this.rad) {
                float[] n = new float[2];
                n[0] = cx;
                n[1] = damage.top.y;
                this.stuckToWall = true;
                this.moveTo(n,0.005);
                returntrue;
            }
            
        }
        return false;
        
    }
}
