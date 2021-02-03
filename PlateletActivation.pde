import java.util.List;

boolean debug = true;

// Flowfield object
FlowField flowfield;
// An ArrayList of vehicles
List<Rbc> rbcs;
List<Platelet> platelets;
List<Protein> proteins;
Damage damage;
Platelet tempPlatelet;
int flag = 0;
int flag2 = 0;
int currentTime = millis() / 1000;
int currentTime2 = millis() / 1000;
float maxSpeed = 10;
float maxForce = 0.4;

void setup() {
    frameRate(60);
    size(640, 340);
    // Make a new flow field with "resolution" of 20
    flowfield = new FlowField(20,5,20);
    rbcs = new ArrayList<Rbc>();
    platelets = new ArrayList<Platelet>();
    proteins = new ArrayList<Protein>();
    
    
    for (int i = 0;i < 500;i++) {
        rbcs.add(new Rbc(new PVector(random(0,width), random(35,height - 35)), maxSpeed, maxForce));  
    }
    for (int i = 0;i < 100;i++) {
        platelets.add(new Platelet(new PVector(random(0,width), random(32.5,height - 32.5)), maxSpeed,  maxForce));
        
    }
}

void draw() {
    background(255,252,182);
    flowfield.update();
    
    // Display the flowfield in "debug" mode
    flowfield.display();
    damage.display(); 
    //flowfield.pull();
    
    
    // Tell all the vehicles to follow the flow field
    for (Rbc r : rbcs) {        
        r.follow(flowfield);
        r.checkBoundary();
        // r.checkCollision(rbcs);
        // r.checkCollision(platelets);
        for (Platelet p : platelets) {
            r.stickTo(p);
        }
        r.run();
    }
    for (int i = rbcs.size() - 1; i>= 0;i--) {
        BloodCont r = rbcs.get(i);
        if (r.position.x < 0 - r.radius || r.position.y > height + r.radius || r.position.y < 0 - r.radius) {
            rbcs.remove(i);
        }
    }
    
    for (Platelet p : platelets) {
        if (p.scan(damage,flowfield)) {
            
        }
        else if (p.scanForProteins(flowfield)) {
            p.scan(damage,flowfield);;
        }
        else{
            if (!p.activated)
                p.follow(flowfield);
        }
        
        if ((millis() / 1000) - currentTime2 >= 2 && flag2 == 0) {
            for (Platelet i : platelets) {
                if (i.activated) {
                    for (int j = 0;j < 3;j++)
                        proteins.add(new Protein(new PVector(i.position.x,i.position.y),maxSpeed, maxForce));
                }
            }
            currentTime2 = millis() / 1000;
            flag2 = 1;
        }
        if ((millis() / 1000) - currentTime2 >= 2 && flag2 == 1) {
            for (Platelet i : platelets) {
                if (i.activated) {
                    for (int j = 0;j < 3;j++)
                        proteins.add(new Protein(new PVector(i.position.x,i.position.y),maxSpeed, maxForce));
                }
            }
            currentTime2 = millis() / 1000;
            flag2 = 0;
        }
        p.checkCollision(platelets);
        p.checkBoundary();
        p.run();
        
    }
    for (int i = platelets.size() - 1; i>= 0;i--) {
        BloodCont p = platelets.get(i);
        if (p.position.x < 0 - p.radius || p.position.y > height + p.radius || p.position.y < 0 - p.radius) {
            platelets.remove(i);
        }
        
    }
    
    for (Protein prot : proteins) {
        //if (dist(prot.position.x,prot.position.y,damage.position.x,damage.position.y)>random(10,300))
        prot.follow(flowfield);
        prot.checkBoundary();
        prot.run();
        
        
    }
    for (int i = proteins.size() - 1; i>= 0;i--) {
        BloodCont prot = proteins.get(i);
        if (prot.position.x < 0 - prot.radius || prot.position.y > height + prot.radius || prot.position.y < 0 - prot.radius) {
            proteins.remove(i);
        }
        
    }
    // add red blood cells at a random height but at the right of the screen
    rbcs.add(new Rbc(new PVector(width, random(35,height - 35)), maxSpeed,  maxForce));
    rbcs.add(new Rbc(new PVector(width, random(35,height - 35)), maxSpeed,  maxForce));
    
    
    // add platelets everey 5 seconds
    if ((millis() / 1000) - currentTime >= 5 && flag == 0) {
        platelets.add(new Platelet(new PVector(width, random(32.5,height - 32.5)), maxSpeed,  maxForce));
        platelets.add(new Platelet(new PVector(width, random(32.5,height - 32.5)), maxSpeed,  maxForce));
        currentTime = millis() / 1000;
        flag = 1;
    }
    if ((millis() / 1000) - currentTime >= 5 && flag == 1) {
        platelets.add(new Platelet(new PVector(width, random(32.5,height - 32.5)), maxSpeed,  maxForce));
        platelets.add(new Platelet(new PVector(width, random(32.5,height - 32.5)), maxSpeed,  maxForce));
        currentTime = millis() / 1000;
        flag = 0;
    }
    fill(0);
    
}
//take screenshots by pressing s
void keyPressed() {
    if (key == 's')
        saveFrame("ScreenShots/" + year() + nf(month(), 2) + nf(day(), 2) + "-" + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2) + ".png");	
}

void heartBeat() {
    // simulate heart beat, making all the elements go faster
    currentTime = millis() / 1000;
    if ((millis() / 1000) - currentTime >= 1 && flag == 0) {
        for (Rbc r : rbcs) {
            r.maxspeed = 10;
        }
        currentTime = millis() / 1000;
        flag = 1;
    }
    if ((millis() / 1000) - currentTime >= 1 && flag == 1) {
        for (Rbc r : rbcs) {
            r.maxspeed = 1;
        }
        currentTime = millis() / 1000;
        flag = 0;
    }
    
}

void mouseClicked() {
    int stuck = 0;
    int activated = 0;
    for (Platelet p : platelets) {
        if (p.activated) 
            activated++;
    }
    for (Rbc r : rbcs) {
        if (r.stuck)
            stuck++;
    }
    print("Stuck: " + stuck + "\n");
    print("Activated: " + activated + "\n");
    print("Proteins:" + proteins.size() + "\n");
    print("Platelets:" + platelets.size() + "\n");
    print("red blood cells:" + rbcs.size() + "\n");
    
    
    
}

