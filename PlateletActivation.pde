import java.util.List;

boolean debug = true;

// Flowfield object
FlowField flowfield;
// An ArrayList of vehicles
List<Rbc> rbcs;
List<Platelet> platelets;
List<Protein> proteins;
Damage damage;
int flag = 0;
int currentTime = millis() / 1000;
int currentTime2 = millis() / 1000;

void setup() {
    frameRate(60);
    size(640, 340);
    // Make a new flow field with "resolution" of 16
    flowfield = new FlowField(20);
    rbcs = new ArrayList<Rbc>();
    platelets = new ArrayList<Platelet>();
    proteins = new ArrayList<Protein>();
    damage = new Damage(350,15,50);
}

void draw() {
    background(255,252,182);
    flowfield.update();
    
    // Display the flowfield in "debug" mode
    flowfield.display();
    damage.display(); 
    // Tell all the vehicles to follow the flow field
    for (Rbc r : rbcs) {
        r.follow(flowfield);
        r.checkBoundary();
        for (Platelet p : platelets) {
            r.stickTo(p);
        }
        r.run();
    }
    for (int i = rbcs.size() - 1; i>= 0;i--) {
        BloodCont r = rbcs.get(i);
        if (r.position.x < 0 - r.radius) {
            rbcs.remove(i);
        }
    }
    
    for (Platelet p : platelets) {
        
        if (p.scan(damage)) {
            
        } else if (p.scanForProteins(proteins)) {
            p.scan(damage);
        }
        else{
            if (!p.activated)
                p.follow(flowfield);
        }
        if (p.activated) {
            if ((millis() / 1000) - currentTime2 >= 1 && flag == 0) {
                proteins.add(new Protein(new PVector(p.position.x,p.position.y),0.5,0.1));
                currentTime2 = millis() / 1000;
                flag = 1;
            }
            if ((millis() / 1000) - currentTime2 >= 1 && flag == 1) {
                proteins.add(new Protein(new PVector(p.position.x,p.position.y),0.5,0.1));
                currentTime2 = millis() / 1000;
                flag = 0;
            }
        }
        
        
        p.checkBoundary();
        p.run();
        
    }
    for (int i = platelets.size() - 1; i>= 0;i--) {
        BloodCont p = platelets.get(i);
        if (p.position.x < 0 - p.radius) {
            platelets.remove(i);
        }
        
    }
    
    for (Protein prot : proteins) {
        prot.follow(flowfield);
        prot.checkBoundary();
        prot.run();
        
        
    }
    for (int i = proteins.size() - 1; i>= 0;i--) {
        BloodCont prot = proteins.get(i);
        if (prot.position.x < 0 - prot.radius) {
            proteins.remove(i);
        }
        
    }
    // add red blood cells at a random height but at the right of the screen
    rbcs.add(new Rbc(new PVector(width, random(10,height - 20)), 2, 0.4));
    
    // add platelets everey 5 seconds
    if ((millis() / 1000) - currentTime >= 5 && flag == 0) {
        platelets.add(new Platelet(new PVector(width, random(1,height / 2)), 2, 0.1));
        platelets.add(new Platelet(new PVector(width, random(height - 100,height)), 2, 0.1));
        currentTime = millis() / 1000;
        flag = 1;
    }
    if ((millis() / 1000) - currentTime >= 5 && flag == 1) {
        platelets.add(new Platelet(new PVector(width, random(1,height / 2)), 2, 0.1));
        platelets.add(new Platelet(new PVector(width, random(height - height / 2,height)), 2, 0.1));
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
}


