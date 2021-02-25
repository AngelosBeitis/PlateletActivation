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
Background back;
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
int amounts = 10;
PApplet papplet;
float[] bounds;

PShape shapePlatelets;
PGraphics2D pg_obstacle;


void setup() {
    //size(330,260);
    
    //controlP5 = new ControlP5(this);
    
    // controlP5.addSlider("slider1",0,50,128,70,80,100,10).setValue(amounts);
    // controlP5.addSlider("slider2",0,20,128,70,100,100,10).setValue(maxSpeed);
    
    
    
    frameRate(60);
    size(840, 340,P2D);
    DwPixelFlow context = new DwPixelFlow(this);
    //print(displayHeight + " " + displayWidth + " " + height + " " + width + "\n");
    fluid = new Fluid(context, width, height, 1);
    
    // some fluid parameters
    fluid.param.dissipation_velocity = 1f;
    fluid.param.dissipation_density  = 1;
    //fluid.param.timestep = 1;
    
    //adding data to the fluid simulation
    fluid.addCallback_FluiData(new  DwFluid2D.FluidData() {
        public void update(DwFluid2D fluid) {
            float px, py, vx, vy, radius, vscale, r, g, b, intensity, temperature;
            px = width;
            py = height / 2;
            vx = - 100;
            vy = 0;
            radius = height / 2;
            //radius = 60;
            intensity = 1;
            fluid.addDensity(px, py, radius, 1, 1, 1, intensity);
            // //radius = height / 2 - 30;
            // //radius = 30;
            fluid.addVelocity(px, py, radius, vx, vy);
            
            
            
        }
    });
    
    
    
    // Make a new flow field with "resolution" of 20
    back = new Background(10,20);
    rbcs = new ArrayList<Rbc>();
    platelets = new ArrayList<Platelet>();
    proteins = new ArrayList<Protein>();
    
    
    
    bounds = new float[4];
    bounds[0] = 0;
    bounds[1] = 0;
    bounds[2] = width;
    bounds[3] = height;
    
    
    // for (int i = 0;i < 500;i++) {
    //     rbcs.add(new Rbc(new PVector(random(0,width), random(35,height - 35))));  
// }
    // for (int i = 0;i < 5;i++) {
    //     platelets.add(new Platelet(new PVector(random(0,width), random(height - 35,height - 32.5))));
    //     platelets.add(new Platelet(new PVector(random(0,width), random(32.5,50))));
    
// }      
    for (int i = 0; i < 20;i++) {
        float x = random(damage.left.x + 7, damage.right.x - 7);
        float y = random(damage.top.y,damage.bottom.y);
        proteins.add(new Protein(new PVector(x,y)));
    }
    
    pg_fluid = (PGraphics2D) createGraphics(width, height, P2D);
    pg_obstacle = (PGraphics2D) createGraphics(width, height, P2D);
    
    
    
    
    
}

void draw() {
    
    background(255,252,182); 
    PGraphics pgSimulation = this.g;
    PShape simulationShapes = new PShape();
    simulationShapes.addChild(back.sim);
    
    pg_obstacle.noSmooth();
    pg_obstacle.beginDraw();
    pg_obstacle.clear();
    
    // border-obstacle
    pg_obstacle.strokeWeight(20);
    pg_obstacle.stroke(64);
    pg_obstacle.fill(255);
    
    pg_obstacle.shape(simulationShapes);
    
    pg_obstacle.endDraw();
    
    fluid.addObstacles(pg_obstacle);
    
    fluid.update();
    fluid_velocity = fluid.getVelocity(fluid_velocity);
    
    pg_fluid.beginDraw();
    //background(0); 
    pg_fluid.endDraw();
    fluid.renderFluidTextures(pg_fluid, 0);
    
    //print(frameRate + "\n");
    
    image(pg_fluid, 0, 0);
    
    // Display the flowfield in "debug" mode
    
    damage.display(); 
    // Tell all the vehicles to follow the flow field
    for (Rbc r : rbcs) {        
        r.checkBoundary();
        
        
        for (Platelet p : platelets) {
            r.stickTo(p);
        }
        r.update(fluid_velocity);
        simulationShapes.addChild(r.getShape());
        //r.updateBounds(bounds);
        //r.display(pgRBC);
        
    }
    
    int g = 0;
    for (Platelet p : platelets) {
        p.setCollisionGroup(g);
        g++;
    }
    for (Platelet p : platelets) {
        
        if (p.scan(damage)) {
            
        }
        else if (p.scanForProteins()) {
            p.scan(damage);;
        }
        
        if ((millis() / 1000) - currentTime2 >= 2 && flag2 == 0) {
            for (Platelet i : platelets) {
                if (i.activated) {
                    for (int j = 0;j < 3;j++)
                        proteins.add(new Protein(new PVector(i.cx,i.cy)));
                }
            }
            currentTime2 = millis() / 1000;
            flag2 = 1;
        }
        if ((millis() / 1000) - currentTime2 >= 2 && flag2 == 1) {
            for (Platelet i : platelets) {
                if (i.activated) {
                    for (int j = 0;j < 3;j++)
                        proteins.add(new Protein(new PVector(i.cx,i.cy)));
                }
            }
            currentTime2 = millis() / 1000;
            flag2 = 0;
        }
        p.checkBoundary();
        // if (p.activated)
        //     p.collision(platelets);
        p.update(fluid_velocity);
        simulationShapes.addChild(p.getShape());
        
    }
    
    
    
    for (Protein prot : proteins) {
        prot.checkBoundary();
        prot.update(fluid_velocity);
        simulationShapes.addChild(prot.getShape());
        //prot.moveTo();
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////////////
    //delete content out of the grid
    for (int i = platelets.size() - 1; i>= 0;i--) {
        BloodCont p = platelets.get(i);
        if (p.cx <= 0 || p.cy >= height  || p.cy <= 0) {
            platelets.remove(i);
        }
        
    }
    for (int i = rbcs.size() - 1; i>= 0;i--) {
        BloodCont r = rbcs.get(i);
        if (r.cx <= 0  || r.cy >= height || r.cy <= 0) {
            rbcs.remove(i);
        }
    }
    for (int i = proteins.size() - 1; i>= 0;i--) {
        BloodCont prot = proteins.get(i);
        if (prot.cx <= 0 || prot.cy >= height  || prot.cy <= 0) {
            proteins.remove(i);
        }
        
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    //display shapes of the screen
    pgSimulation.shape(simulationShapes);    
    
    // add red blood cells at a random height but at the right of the screen
    rbcs.add(new Rbc(new PVector(width, random(35,height - 35))));
    rbcs.add(new Rbc(new PVector(width, random(35,height - 35))));
    
    
    // add platelets everey 5 seconds
    if ((millis() / 1000) - currentTime >= 5 && flag == 0) {
        for (int i = 0;i < amounts;i++) {
            platelets.add(new Platelet(new PVector(width, random(height - 35,height - 32.5))));
            platelets.add(new Platelet(new PVector(width, random(32.5,50))));
        }
        currentTime = millis() / 1000;
        flag = 1;
    }
    if ((millis() / 1000) - currentTime >= 5 && flag == 1) {
        for (int i = 0;i < amounts;i++) {
            platelets.add(new Platelet(new PVector(width, random(height - 35,height - 32.5))));
            platelets.add(new Platelet(new PVector(width, random(32.5,50))));
        }
        currentTime = millis() / 1000;
        flag = 0;
    }
    //fill(0);
    
}
//take screenshots by pressing s
void keyPressed() {
    if (key == 's')
        saveFrame("ScreenShots/" + year() + nf(month(), 2) + nf(day(), 2) + "-" + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2) + ".png");	
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
        }
        if (theEvent.getController().getName() == "slider2") {
        }
        if (theEvent.getController().getName() == "slider3") {
        }
    } 
}

