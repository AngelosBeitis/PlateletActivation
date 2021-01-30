class Platelet extends BloodCont{
    
    boolean activated;
    PVector positionInDamage;
    
    Platelet(PVector l, float ms, float mf) {
        
        super(l,ms,mf,2.5);
        activated = false;
    }
    
    boolean scan(Damage d, FlowField flow) {
        if (positionInDamage == null) {
            float newX = random(d.left.x + 7, d.right.x - 7);
            float newY = random(d.top.y, d.bottom.y);
            positionInDamage = new PVector(newX,newY);
        }
        float distance = dist(position.x,position.y,positionInDamage.x,positionInDamage.y);
        boolean withinDist = distance < 40;
        float moveX = d.position.x;
        float moveY = d.position.y;
        if (withinDist) {
            moveTo(positionInDamage.x, positionInDamage.y,flow);
            if (distance <= 2)
                activate();
        }
        return withinDist;
        
    }
    
    boolean scanForProteins(FlowField flow) {
        
        float distance;
        for (Protein p : proteins) {
            distance = dist(position.x,position.y,p.position.x,p.position.y);
            if (!activated && distance < 10) {
                moveTo(p.position.x,p.position.y,flow);
                if (distance < 2) {
                    proteins.remove(p);
                    scanForProteins(flow);
                }
                return true;
            }
        }
        
        return false;
        
    }
    
    void moveTo(float x,float y,FlowField flow) {
        
        PVector target = new PVector(x,y);
        PVector desired = PVector.sub(target,position);
        float d = desired.mag();
        desired.normalize();
        float speed = positionSpeed();
        float m = map(d,0,20,0.5,1);
        //float m = 1;
        desired.mult(m);
        PVector flowVelocity = flowVelocity(flow);
        PVector steer = PVector.sub(desired,velocity);
        steer.add(flowVelocity);
        steer.limit(maxforce);
        applyForce(steer);
        
    }
    
    void activate() {
        activated = true;
        maxspeed = 0;
        
    }
    @Override
    void display() {
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