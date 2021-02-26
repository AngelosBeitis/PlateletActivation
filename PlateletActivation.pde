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

DwPhysics.Param param_physics = new DwPhysics.Param();

DwPhysics<DwParticle2D> physics;
void setup() {
    //size(330,260);
    
    controlP5 = new ControlP5(this);
    
    
    param_physics.GRAVITY = new float[]{0, 0};
    param_physics.bounds  = new float[]{ - 10, - 50, width + 50, height + 50}; // implement so the bounving effect of the library doesnt happen
    param_physics.iterations_collisions = 3;
    param_physics.iterations_springs    = 0; // no springs in this demo
    
    physics = new DwPhysics<DwParticle2D>(param_physics);
    
    frameRate(60);
    size(840, 340,P2D);
    DwPixelFlow context = new DwPixelFlow(this);
    //print(displayHeight + " " + displayWidth + " " + height + " " + width + "\n");
    fluid = new Fluid(context, width, height, 1);
    
    // some fluid parameters
    fluid.param.dissipation_velocity = 1;
    fluid.param.dissipation_density  = 1f;
    controlP5.addSlider("slider1",0,1,128,70,80,100,10).setValue(fluid.param.dissipation_density);
    controlP5.addSlider("slider2",0,1,128,70,100,100,10).setValue(fluid.param.dissipation_velocity);
    
    fluid.param.dissipation_temperature = 0f;
    fluid.param.timestep = 1;
    fluid.param.num_jacobi_projection = 90;
    fluid.param.vorticity = 0;
    fluid.param.gridscale = 0.1;
    //fluid.simulation_step = 10;
    
    //adding data to the fluid simulation
    fluid.addCallback_FluiData(new  DwFluid2D.FluidData() {
        public void update(DwFluid2D fluid) {
            float px, py, vx, vy, radius, vscale, r, g, b, intensity, temperature;
            px = width + 10;
            py = height / 2;
            vx = - PI;
            vy = 0;
            radius = height / 2 - 35;
            intensity = 3;
            fluid.addDensity(px, py, radius, 1, 1, 1, intensity);
            fluid.addVelocity(px, py, radius, vx, vy);
            
            
            
        }
    } );
    
    
    
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
    physics = new DwPhysics<DwParticle2D>(param_physics);
    
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
    pg_fluid.endDraw();
    fluid.renderFluidTextures(pg_fluid, 0);
    DwParticle2D[] array = new DwParticle2D[platelets.size() + rbcs.size() + proteins.size()];
    DwParticle2D[] plateletArray = new DwParticle2D[platelets.size()];
    DwParticle2D[] rbcArray = new DwParticle2D[rbcs.size()];
    DwParticle2D[] proteinsArray = new DwParticle2D[proteins.size()];
    
    platelets.toArray(plateletArray);
    proteins.toArray(proteinsArray);
    rbcs.toArray(rbcArray);
    for (int i = 0;i < array.length;i++) {
        if (i < platelets.size()) {
            array[i] = plateletArray[i];
        }
        else if (i - platelets.size()<proteins.size()) {
            array[i] = proteinsArray[i - platelets.size()];
        }
        else{
            array[i] = rbcArray[i - platelets.size() - proteins.size()];
        }
    }
    physics.param.GRAVITY[1] = 0;
    physics.param.iterations_collisions = 1;
    physics.setParticles(array, array.length);
    physics.update(1);
    
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
        
    }
    
    int g = 0;
    for (Platelet p : platelets) {
        p.setCollisionGroup(g);
        g++;
    }
    // for (Protein p : proteins) {
    //     p.setCollisionGroup(g);
    //     g++;
// }
    // for (Rbc r : rbcs) {
    //     r.setCollisionGroup(g);
    //     g++;
// }
    for (Platelet p : platelets) {
        
        if (!p.scan(damage)) p.scanForProteins();
        
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
        //p.checkCollision();
        //if (p.activated) p.collision(platelets);
        p.update(fluid_velocity);
        simulationShapes.addChild(p.getShape());
        
    }
    
    
    
    for (Protein prot : proteins) {
        prot.checkBoundary();
        prot.update(fluid_velocity);
        simulationShapes.addChild(prot.getShape());
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
            //platelets.add(new Platelet(new PVector(width, random(height - 35,height - 32.5))));
            //platelets.add(new Platelet(new PVector(width, random(32.5,50))));
            platelets.add(new Platelet(new PVector(width, random(35,height - 32.5))));
        }
        currentTime = millis() / 1000;
        flag = 1;
    }
    if ((millis() / 1000) - currentTime >= 5 && flag == 1) {
        for (int i = 0;i < amounts;i++) {
            //platelets.add(new Platelet(new PVector(width, random(height - 35,height - 32.5))));
            //platelets.add(new Platelet(new PVector(width, random(32.5,50))));
            platelets.add(new Platelet(new PVector(width, random(35,height - 32.5))));
            
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

