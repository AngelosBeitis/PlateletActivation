import java.util.List;
import controlP5.*;
ControlP5 controlP5;

boolean debug = true;
color[] colors = new color[7]; 
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
int flag3 = 0;
int currentTime = millis() / 1000;
int currentTime2 = millis() / 1000;
int currentTime3 = millis() / 1000;
float maxSpeed = 10;
float contentSpeed = 1;
float maxForce = 0.6;
int amounts = 2;

void setup() {
    //size(330,260);
    
    controlP5 = new ControlP5(this);
    
    // controlP5.addSlider("slider1",0,50,128,70,80,100,10).setValue(amounts);
    // controlP5.addSlider("slider2",0,20,128,70,100,100,10).setValue(maxSpeed);
    
    
    frameRate(70);
    size(640, 340,FX2D);
    // Make a new flow field with "resolution" of 20
    flowfield = new FlowField(20,5,20,maxSpeed);
    rbcs = new ArrayList<Rbc>();
    platelets = new ArrayList<Platelet>();
    proteins = new ArrayList<Protein>();
    
    flowfield.display();
    
    for (int i = 0;i < 500;i++) {
        rbcs.add(new Rbc(new PVector(random(0,width), random(35,height - 35)), contentSpeed, maxForce));  
    }
    for (int i = 0;i < 5;i++) {
        platelets.add(new Platelet(new PVector(random(0,width), random(height - 35,height - 32.5)), contentSpeed,  maxForce));
        platelets.add(new Platelet(new PVector(random(0,width), random(32.5,50)), contentSpeed,  maxForce));
        
    }
    for (int i = 0; i < 20;i++) {
        float x = random(damage.left.x + 7, damage.right.x - 7);
        float y = random(damage.top.y,damage.bottom.y);
        proteins.add(new Protein(new PVector(x,y),contentSpeed,maxForce));
    }
}


void draw() {
    
    background(255,252,182);
    flowfield.update();
    
    // Display the flowfield in "debug" mode
    flowfield.display();
    damage.display(); 
    //flowfield.pull();
    //heartBeat();
    
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
        if (p.scan(damage)) {
            
        }
        else if (p.scanForProteins()) {
            p.scan(damage);;
        }
        else{
            if (!p.activated)
                p.follow(flowfield);
        }
        
        if ((millis() / 1000) - currentTime2 >= 2 && flag2 == 0) {
            for (Platelet i : platelets) {
                if (i.activated) {
                    for (int j = 0;j < 3;j++)
                        proteins.add(new Protein(new PVector(i.position.x,i.position.y),5, maxForce));
                }
            }
            currentTime2 = millis() / 1000;
            flag2 = 1;
        }
        if ((millis() / 1000) - currentTime2 >= 2 && flag2 == 1) {
            for (Platelet i : platelets) {
                if (i.activated) {
                    for (int j = 0;j < 3;j++)
                        proteins.add(new Protein(new PVector(i.position.x,i.position.y),5, maxForce));
                }
            }
            currentTime2 = millis() / 1000;
            flag2 = 0;
        }
        p.checkCollision();
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
    rbcs.add(new Rbc(new PVector(width, random(35,height - 35)), contentSpeed,  maxForce));
    rbcs.add(new Rbc(new PVector(width, random(35,height - 35)), contentSpeed,  maxForce));
    
    
    // add platelets everey 5 seconds
    if ((millis() / 1000) - currentTime >= 5 && flag == 0) {
        for (int i = 0;i < amounts;i++) {
            platelets.add(new Platelet(new PVector(width, random(height - 35,height - 32.5)), contentSpeed,  maxForce));
            platelets.add(new Platelet(new PVector(width, random(32.5,50)), contentSpeed,  maxForce));
        }
        currentTime = millis() / 1000;
        flag = 1;
    }
    if ((millis() / 1000) - currentTime >= 5 && flag == 1) {
        for (int i = 0;i < amounts;i++) {
            platelets.add(new Platelet(new PVector(width, random(height - 35,height - 32.5)), contentSpeed,  maxForce));
            platelets.add(new Platelet(new PVector(width, random(32.5,50)), contentSpeed,  maxForce));
        }
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
    
    if (currentTime3 >= 2 && flag3 == 0) {
        print("Hello");
        flowfield.maxSpeed = 1;
        
        currentTime3 = millis() / 1000;
        flag3 = 1;
    }
    if (currentTime3 >= 2 && flag3 == 1) {
        
        flowfield.maxSpeed = 10;
        
        currentTime3 = millis() / 1000;
        flag3 = 0;
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
void controlEvent(ControlEvent theEvent) {
    
    if (theEvent.isController()) { 
        
        if (theEvent.getController().getName() == "slider1") {
            amounts = round(theEvent.getController().getValue());
        }
        if (theEvent.getController().getName() == "slider2") {
            maxSpeed = theEvent.getController().getValue();
            flowfield.changeSpeed(maxSpeed);
        }
        if (theEvent.getController().getName() == "slider3") {
        }
    } 
}

