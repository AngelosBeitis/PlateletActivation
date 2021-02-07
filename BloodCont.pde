abstract class BloodCont{
    
    // The usual stuff
    PVector position;
    PVector velocity;
    PVector acceleration;
    float maxforce;    // Maximum steering force
    float speed;    // Maximum speed
    float radius;
    float currentSpeed;
    
    BloodCont(PVector l, float s, float mf,float rad) {
        position = l.get();
        speed = s;
        radius = rad;
        maxforce = mf;
        acceleration = new PVector(0,0);
        velocity = new PVector(0,0);
    }
    
    // Implementing Reynolds' flow field following algorithm
    // http://www.red3d.com/cwr/steer/FlowFollow.html
    public void follow(FlowField flow) {
        // What is the vector at that spot in the flow field?
        PVector desired = flow.lookup(position);
        // Scale it up by maxspeed
        desired.mult(positionSpeed());
        // Steering is desired minus velocity
        PVector steer = PVector.sub(desired, velocity);
        steer.limit(maxForce);  // Limit to maximum steering force
        applyForce(steer);
    }
    public void run() {
        update();
        display();
    }
    
    // Method to update position
    private void update() {
        // Update velocity
        velocity.add(acceleration);
        // Limit speed
        velocity.limit(flowfield.maxSpeed);
        position.add(velocity);
        // Reset accelertion to 0 each cycle
        acceleration.mult(0);
    }
    
    public void applyForce(PVector force) {
        // We could add mass here if we want A = F / M
        acceleration.add(force);
    }
    
    abstract void display();
    
    public void checkBoundary() {
        //bottom boundary
        if (position.y > height - radius - 30) {
            position.y = height - radius - 30;
            
        }
        //top boundary
        if (position.y < 30 + radius && (position.x < damage.left.x - radius || position.x > damage.right.x + radius)) {
            position.y = 30 + radius;
        }
        // within damaged cell
        if (position.x > damage.left.x + radius && position.x < damage.right.x + radius) {
            //if damage is on top
            if (position.y < 15 + radius)
                position.y = 15 + radius;
            // if damage is on the bottom
            if (position.y > height - 15 + radius)
                position.y = height - 15 + radius;
        }
        if (position.x < damage.left.x + radius && position.y > height - radius - 15) {
            position.x = damage.left.x + radius;
        }
        if (position.x > damage.right.x + radius && position.y > height - radius - 15) {
            position.x = damage.right.x + radius;
        }
        if (position.x < damage.left.x + radius && position.y < 15 + radius) {
            position.x = damage.left.x + radius;
        }
        if (position.x > damage.right.x + radius && position.y < 15 + radius) {
            position.x = damage.right.x + radius;
        }
        
    }
    public PVector flowVelocity() {
        PVector flowVelocity = flowfield.lookup(position);
        if (position.y >= height / 2)
            flowVelocity.mult(positionSpeed());
        else
            flowVelocity.mult(positionSpeed());
        
        return flowVelocity;     
    }
    
    public float positionSpeed() {
        
        if (position.y >= height / 2)
            currentSpeed = map(position.y,height / 2,height - 30 - radius ,flowfield.maxSpeed,0);
        else
            currentSpeed = map(position.y,30 + radius,height / 2,0,flowfield.maxSpeed);
        
        if (position.y <= 30 || position.y >= height - 30) {
            currentSpeed = 0;
        }
        return currentSpeed;
    }
    
    public void moveTo(float x,float y,boolean flag) {
        
        PVector target = new PVector(x,y);
        PVector desired = PVector.sub(target,position);
        float d = desired.mag();
        desired.normalize();
        float speed = positionSpeed();
        float m;
        if (flag)
            m = map(d,0,20,0,0.5);
        //m = 2;
        else
            m = map(d,0,100,flowfield.maxSpeed,currentSpeed);
        //float m = 1;
        desired.mult(m);
        PVector flowVelocity = flowVelocity();
        PVector steer = PVector.sub(desired,velocity);
        steer.add(flowVelocity);
        steer.limit(maxforce);
        applyForce(steer);
        
    }
    
    public <T extends BloodCont> void checkCollision(List<T> objects) {
        
        for (BloodCont o : objects) {
            // Get distances between the balls components
            PVector distanceVect = PVector.sub(o.position, position);
            float m = radius * .1;
            float m2 = o.radius *.1;
            
            
            // Calculate magnitude of the vector separating the balls
            float distanceVectMag = distanceVect.mag();
            
            // Minimum distance before they are touching
            float minDistance = radius + o.radius;
            
            if (distanceVectMag < minDistance) {
                float distanceCorrection = (minDistance - distanceVectMag) / 2.0;
                PVector d = distanceVect.copy();
                PVector correctionVector = d.normalize().mult(distanceCorrection);
                o.position.add(correctionVector);
                position.sub(correctionVector);
                
                //getangle of distanceVect
                float theta  = distanceVect.heading();
                // precalculate trig values
                float sine = sin(theta);
                float cosine = cos(theta);
                
                /* bTemp will hold rotated ball positions. You 
                justneed to worry about bTemp[1] position*/
                PVector[] bTemp = {
                    new PVector(), new PVector()
                    };
                
                /* this ball's position is relative to the o
                so you can use the vector between them (bVect) as the 
                reference point in the rotation expressions.
                bTemp[0].position.x and bTemp[0].position.y will initialize
                automatically to 0.0, which is what you want
                sinceb[1] will rotate around b[0] */
                bTemp[1].x  = cosine * distanceVect.x + sine * distanceVect.y;
                bTemp[1].y  = cosine * distanceVect.y - sine * distanceVect.x;
                
                // rotate Temporary velocities
                PVector[] vTemp = {
                    new PVector(), new PVector()
                    };
                
                vTemp[0].x  = cosine * velocity.x + sine * velocity.y;
                vTemp[0].y  = cosine * velocity.y - sine * velocity.x;
                vTemp[1].x  = cosine * o.velocity.x + sine * o.velocity.y;
                vTemp[1].y  = cosine * o.velocity.y - sine * o.velocity.x;
                
                /* Nowthat velocities are rotated, you can use 1D
                conservation of momentum equations to calculate 
                the final velocity along the x-axis. */
                PVector[] vFinal = {  
                    new PVector(), new PVector()
                    };
                
                // final rotated velocity for b[0]
                vFinal[0].x = ((m - m2) * vTemp[0].x + 2 * m2 * vTemp[1].x) / (m + m2);
                vFinal[0].y = vTemp[0].y;
                
                // final rotated velocity for b[0]
                vFinal[1].x = ((m2 - m) * vTemp[1].x + 2 * m * vTemp[0].x) / (m + m2);
                vFinal[1].y = vTemp[1].y;
                
                // hack to avoid clumping
                bTemp[0].x += vFinal[0].x;
                bTemp[1].x += vFinal[1].x;
                
                /* Rotate ball positions and velocities back
                Reverse signs in trig expressions to rotate 
                in the opposite direction */
                // rotate balls
                // PVector[] bFinal = { 
                //     new PVector(), new PVector()
                //     };
                
                // bFinal[0].x = cosine * bTemp[0].x - sine * bTemp[0].y;
                // bFinal[0].y = cosine * bTemp[0].y + sine * bTemp[0].x;
                // bFinal[1].x = cosine * bTemp[1].x - sine * bTemp[1].y;
                // bFinal[1].y = cosine * bTemp[1].y + sine * bTemp[1].x;
                
                // // update balls to screen position
                // o.position.x = position.x + bFinal[1].x;
                // o.position.y = position.y + bFinal[1].y;
                
                // position.add(bFinal[0]);
                
                // update velocities
                velocity.x = cosine * vFinal[0].x - sine * vFinal[0].y;
                velocity.y = cosine * vFinal[0].y + sine * vFinal[0].x;
                o.velocity.x = cosine * vFinal[1].x - sine * vFinal[1].y;
                o.velocity.y = cosine * vFinal[1].y + sine * vFinal[1].x;
            }
        }
    }
}
