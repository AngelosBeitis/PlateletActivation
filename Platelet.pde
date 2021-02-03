class Platelet extends BloodCont{
    
    boolean activated;
    PVector positionInDamage;
    
    Platelet(PVector l, float ms, float mf) {
        
        super(l,ms,mf,2.5);
        activated = false;
    }
    
    public boolean scan(Damage d, FlowField flow) {
        if (positionInDamage == null) {
            float newX = random(d.left.x + 7, d.right.x - 7);
            float newY = d.top.y + 2.5;
            positionInDamage = new PVector(newX,newY);
        }
        float distance = dist(position.x,position.y,positionInDamage.x,positionInDamage.y);
        boolean withinDist = distance < 40;
        float moveX = d.position.x;
        float moveY = d.position.y;
        if (withinDist) {
            moveTo(positionInDamage.x, positionInDamage.y,flow,true);
            if (distance <= 2)
                activate();
        }
        return withinDist;
        
    }
    
    public boolean scanForProteins(FlowField flow) {
        
        float distance;
        for (Protein p : proteins) {
            distance = dist(position.x,position.y,p.position.x,p.position.y);
            if (!activated && distance < 10) {
                moveTo(p.position.x,p.position.y,flow,true);
                if (distance < 2) {
                    proteins.remove(p);
                    scanForProteins(flow);
                }
                return true;
            }
        }
        
        return false;
        
    }
    
    
    public void activate() {
        activated = true;
        maxspeed = 0;
        
    }
    @Override
    public void display() {
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