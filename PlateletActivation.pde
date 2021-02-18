import java.util.List;
import controlP5.*;
import com.thomasdiewald.pixelflow.java.DwPixelFlow;
import com.thomasdiewald.pixelflow.java.fluid.DwFluid2D;
import com.thomasdiewald.pixelflow.java.softbodydynamics.DwPhysics;
import com.thomasdiewald.pixelflow.java.softbodydynamics.particle.DwParticle2D;
ControlP5 controlP5;

boolean debug = true;
color[] colors = new color[7]; 
// Flowfield object
FlowField flowfield;
Fluid fluid;
// An ArrayList of vehicles
List<Rbc> rbcs;
PGraphics2D pg_fluid;
List<Platelet> platelets;
List<Protein> proteins;
float[] fluid_velocity;
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
PApplet papplet;
PShape shapePlatelets;


void setup() {
    //size(330,260);
    
    //controlP5 = new ControlP5(this);
    
    // controlP5.addSlider("slider1",0,50,128,70,80,100,10).setValue(amounts);
    // controlP5.addSlider("slider2",0,20,128,70,100,100,10).setValue(maxSpeed);
    
    
    
    frameRate(60);
    size(640, 340,FX2D);
    //fullScreen(P2D);
    DwPixelFlow context = new DwPixelFlow(this);
    //print(displayHeight + " " + displayWidth + " " + height + " " + width + "\n");
    fluid = new Fluid(context, width, height, 1);
    
    // some fluid parameters
    fluid.param.dissipation_velocity = 0.70f;
    fluid.param.dissipation_density  = 0.99f;
    
    //adding data to the fluid simulation
    fluid.addCallback_FluiData(new  DwFluid2D.FluidData() {
        public void update(DwFluid2D fluid) {
            
            float px     = width / 2;
            float py     = height / 2 - 30;
            float vx     = - 100;
            float vy     = 0;
            fluid.addVelocity(px, py , 14, vx, vy);
            fluid.addDensity(px, py , 20, 1.0f, 1.0f, 1.0f, 1.0f);
            
            
        }
    });
    
    
    
    
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
    this.shapeMode(PConstants.CORNER);
    shapePlatelets = this.createShape(PShape.GROUP);    
    
    for (int i = 0; i < 20;i++) {
        float x = random(damage.left.x + 7, damage.right.x - 7);
        float y = random(damage.top.y,damage.bottom.y);
        proteins.add(new Protein(new PVector(x,y),contentSpeed,maxForce));
    }
    pg_fluid = (PGraphics2D) createGraphics(width, height, P2D);
    
}

void draw() {
    
    background(255,252,182);
    flowfield.update();
    fluid.update();
    fluid_velocity = fluid.getVelocity(fluid_velocity);
    
    pg_fluid.beginDraw();
    pg_fluid.background(0);
    pg_fluid.endDraw();
    fluid.renderFluidTextures(pg_fluid, 0);
    
    PGraphics pg = this.g;
    //print(frameRate + "\n");
    
    image(pg_fluid, 0, 0);
    
    // Display the flowfield in "debug" mode
    flowfield.display();
    damage.display(); 
    //flowfield.pull();
    //heartBeat();
    
    // Tell all the vehicles to follow the flow field
    for (Rbc r : rbcs) {        
        //r.follow(flowfield);
        //r.checkBoundary();
        
        // r.checkCollision(rbcs);
        // r.checkCollision(platelets);
        // for (Platelet p : platelets) {
        //     r.stickTo(p);
    // }
        r.update(fluid_velocity);
        r.display(pg);
    }
    
    
    
    for (int i = rbcs.size() - 1; i>= 0;i--) {
        BloodCont r = rbcs.get(i);
        if (r.position.x < 0 - r.radius || r.position.y > height + r.radius || r.position.y < 0 - r.radius) {
            rbcs.remove(i);
        }
    }
    
    for (Platelet p : platelets) {
        // if (p.scan(damage)) {
        
    // }
        // else if (p.scanForProteins()) {
        //     p.scan(damage);;
    // }
        // else{
        //     if (!p.activated)
        //         //p.follow(flowfield);
        //        ;
        //    }
        
        //    if ((millis() / 1000) - currentTime2 >= 2 && flag2 == 0) {
        //        for (Platelet i : platelets) {
        //            if (i.activated) {
        //                for (int j = 0;j < 3;j++)
        //                    proteins.add(new Protein(new PVector(i.position.x,i.position.y),5, maxForce));
        //            }
        //     }
        //     currentTime2 = millis() / 1000;
        //     flag2 = 1;
    // }
        // if ((millis() / 1000) - currentTime2 >= 2 && flag2 == 1) {
        //     for (Platelet i : platelets) {
        //         if (i.activated) {
        //             for (int j = 0;j < 3;j++)
        //                 proteins.add(new Protein(new PVector(i.position.x,i.position.y),5, maxForce));
        //         }
        //     }
        //     currentTime2 = millis() / 1000;
        //     flag2 = 0;
    // }
        // p.checkCollision();
        p.checkBoundary();
        //p.update(fluid_velocity);
        p.display(pg);
        
    }
    
    
    for (int i = platelets.size() - 1; i>= 0;i--) {
        BloodCont p = platelets.get(i);
        if (p.position.x < 0 - p.radius || p.position.y > height + p.radius || p.position.y < 0 - p.radius) {
            platelets.remove(i);
        }
        
    }
    
    for (Protein prot : proteins) {
        //if (dist(prot.position.x,prot.position.y,damage.position.x,damage.position.y)>random(10,300))
        //prot.follow(flowfield);
        prot.checkBoundary();
        prot.update(fluid_velocity);
        //prot.display();
    }
    for (int i = proteins.size() - 1; i>= 0;i--) {
        BloodCont prot = proteins.get(i);
        if (prot.position.x < 0 - prot.radius || prot.position.y > height + prot.radius || prot.position.y < 0 - prot.radius) {
            proteins.remove(i);
        }
        
    }
    // add red blood cells at a random height but at the right of the screen
    // rbcs.add(new Rbc(new PVector(width, random(35,height - 35)), contentSpeed,  maxForce));
    // rbcs.add(new Rbc(new PVector(width, random(35,height - 35)), contentSpeed,  maxForce));
    
    
    // // add platelets everey 5 seconds
    // if ((millis() / 1000) - currentTime >= 5 && flag == 0) {
    //     for (int i = 0;i < amounts;i++) {
    //         platelets.add(new Platelet(new PVector(width, random(height - 35,height - 32.5)), contentSpeed,  maxForce));
    //         platelets.add(new Platelet(new PVector(width, random(32.5,50)), contentSpeed,  maxForce));
    //     }
    //     currentTime = millis() / 1000;
    //     flag = 1;
// }
    // if ((millis() / 1000) - currentTime >= 5 && flag == 1) {
    //     for (int i = 0;i < amounts;i++) {
    //         platelets.add(new Platelet(new PVector(width, random(height - 35,height - 32.5)), contentSpeed,  maxForce));
    //         platelets.add(new Platelet(new PVector(width, random(32.5,50)), contentSpeed,  maxForce));
    //     }
    //     currentTime = millis() / 1000;
    //     flag = 0;
// }
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

