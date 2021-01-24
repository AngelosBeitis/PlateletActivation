class Platelet extends BloodCont{
    
    boolean activated;
    
    Platelet(PVector l, float ms, float mf) {
        
        super(l,ms,mf,2.5);
        activated = false;
    }
    
    boolean scan(Damage d) {
        float newX = random(d.left.x, d.right.x);
        float newY = random(d.top.y, d.bottom.y);
        float distance = dist(position.x,position.y,newX,newY);
        boolean withinDist = distance < d.width;
        float moveX = d.position.x;
        float moveY = d.position.y;
        if (withinDist) {
            moveTo(newX, newY);
            if (distance <= 1)
                activate();
        }
        return withinDist;
        
    }
    
    boolean scanForProteins(List<Protein> proteins) {
        
        float distance;
        for (Protein p : proteins) {
            distance = dist(position.x,position.y,p.position.x,p.position.y);
            if (!activated && distance < 10) {
                moveTo(p.position.x,p.position.y);
                return true;
            }
        }
        
        return false;
        
    }
    
    void moveTo(float x,float y) {
        
        PVector target = new PVector(x,y);
        PVector desired = PVector.sub(target,position);
        float d = desired.mag();
        desired.normalize();
        
        if (d < 50) {
            float m = map(d,0,100,0,maxspeed);
            desired.mult(m);
            
        } else{
            desired.mult(maxspeed);
        }
        PVector steer = PVector.sub(desired,velocity);
        steer.limit(maxforce);
        applyForce(steer);
        
    }
    
    void activate() {
        activated = true;
        maxspeed = 0;
        
    }
    @Override
    void display() {
        // Draw a triangle rotated in the direction of velocity
        if (!activated) {
            fill(255);
            stroke(0);
            ellipse(position.x,position.y,radius * 2,radius * 2);
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
            PShape body = createShape(ELLIPSE, 0, 0, radius * 3, radius * 3);
            PShape leg1 = createShape(LINE, 0, - 4 * radius, radius / 8, radius * 4);
            PShape leg2 = createShape(LINE, 0, - 4 * radius , radius / 8,radius * 4);
            PShape leg3 = createShape(LINE, 0, - 4 * radius , radius / 8,radius * 4);
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
    
    
}