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
int amounts = 3;
PApplet papplet;
float[] bounds;
PShape obstacles;
PShape simulationShapes;
public Plug plug; 
int stuck = 0;
int group = 1;


//PShape shapePlatelets;
PGraphics2D pg_obstacle;

DwPhysics.Param param_physics = new DwPhysics.Param();

DwPhysics<DwParticle2D> physics;
void setup() {
    //size(330,260);
    colorMode(RGB);
    controlP5 = new ControlP5(this);
    
    size(840, 340,P2D);
    frameRate(120);
    
    param_physics.GRAVITY = new float[]{0, 0};
    param_physics.bounds  = new float[]{ - 10, - 50, width + 50, height + 50}; // implement so the bounving effect of the library doesnt happen
    param_physics.iterations_collisions = 3;
    param_physics.iterations_springs    = 0; // no springs in this demo
    
    physics = new DwPhysics<DwParticle2D>(param_physics);
    
    DwPixelFlow context = new DwPixelFlow(this);
    //print(displayHeight + " " + displayWidth + " " + height + " " + width + "\n");
    fluid = new Fluid(context, width, height, 1);
    
    // some fluid parameters
    fluid.param.dissipation_velocity = 1;
    fluid.param.dissipation_density  = 1f;
    controlP5.addSlider("Fluid Density",0,1,128,70,80,100,10).setValue(fluid.param.dissipation_density);
    controlP5.addSlider("Fluid Velocity",0,1,128,70,100,100,10).setValue(fluid.param.dissipation_velocity);
    controlP5.addSlider("Platelet amounts",0,1,128,70,120,100,10).setValue(amounts);
    
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
            px = width + 70;
            py = height / 2;
            vx = - TWO_PI;
            vy = 0;
            radius = height / 2 - 15;
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
    
    plug = new Plug();
    
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
    // for (int i = 0; i < 20;i++) {
    //     float x = random(damage.left.x + 7, damage.right.x - 7);
    //     float y = random(damage.top.y,damage.bottom.y);
    //     proteins.add(new Protein(new PVector(x,y)));
// }
    
    pg_fluid = (PGraphics2D) createGraphics(width, height, P2D);
    pg_obstacle = (PGraphics2D) createGraphics(width, height, P2D);
    
    
    
    
    
}

void draw() {
    
    background(255,252,182); 
    simulationShapes = new PShape();
    obstacles = new PShape();
    obstacles.addChild(back.sim);
    simulationShapes.addChild(back.sim);
    
    RbcMechanics();
    
    
    // for (Rbc r : rbcs) {
    //    r.setCollisionGroup(g);
    //    g++;
// }
    PlateletMechanics();
    //print("activated" + activated + "\n");
    Physics();
    
    ProteinMechanics();
    //if (activated > 0) simulationShapes.addChild(plug.shape);
    
    pg_obstacle.noSmooth();
    pg_obstacle.beginDraw();
    pg_obstacle.clear();
    pg_obstacle.shape(obstacles);
    pg_obstacle.endDraw();
    fluid.addObstacles(pg_obstacle);
    
    fluid.update();
    fluid_velocity = fluid.getVelocity(fluid_velocity);
    
    pg_fluid.beginDraw();
    pg_fluid.endDraw();
    
    fluid.renderFluidTextures(pg_fluid, 0);
    DeleteContent();
    CreateContent();
    
    image(pg_fluid, 0, 0);
    
    //display shapes of the screen
    shape(simulationShapes);  
    
    
}

void PlateletMechanics() {
    for (Platelet p : platelets) {
        if (!p.activated)
            p.setCollisionGroup(0);
        else{
            p.setCollisionGroup(group);
            group++;
        }
    }
    for (Platelet p : platelets) {
        if (p.activated) {
            obstacles.addChild(p.getShape());
        }
        if (!p.scan(damage) && !p.activated)
            p.scanForProteins();
        
        
        // if ((millis() / 1000) - currentTime2 >= 2 && flag2 == 0) {
        //     for (Platelet i : platelets) {
        //         if (i.activated) {
        //             for (int j = 0;j < 1;j++) {
        //                 proteins.add(new Protein(new PVector(i.cx,i.cy)));
        //             }
        //         }
        //     }
        //     currentTime2 = millis() / 1000;
        //     flag2 = 1;
    // }
        // if ((millis() / 1000) - currentTime2 >= 2 && flag2 == 1) {
        //     for (Platelet i : platelets) {
        //         if (i.activated) {
        //             for (int j = 0;j < 1;j++)
        //                 proteins.add(new Protein(new PVector(i.cx,i.cy)));
        //         }
        //     }
        //     currentTime2 = millis() / 1000;
        //     flag2 = 0;
    // }
        p.checkBoundary();
        p.checkCollision();
        //if(p.activated) p.collision(platelets);
        p.update(fluid_velocity);
        //if (!p.activated) 
        simulationShapes.addChild(p.getShape());
        
    }
    
}
void RbcMechanics() {
    stuck = 0;
    for (Rbc r : rbcs) {
        if (r.stuck)
            stuck++;
    }
    for (Rbc r : rbcs) {        
        r.checkBoundary();
        
        for (Platelet p : platelets) {
            r.stickTo(p);
        }
        r.checkBoundary();
        r.update(fluid_velocity);
        simulationShapes.addChild(r.getShape());
        
    }
    
}
void ProteinMechanics() {
    for (Protein prot : proteins) {
        prot.checkBoundary();
        prot.update(fluid_velocity);
        simulationShapes.addChild(prot.getShape());
    }
    
}
void Physics() {
    Platelet[] plateletArray = new Platelet[platelets.size()];
    List<Platelet> activatedList = new ArrayList<Platelet>();
    
    platelets.toArray(plateletArray);
    for (int i = 0;i < plateletArray.length;i++) {
        if (plateletArray[i].activated || plateletArray[i].checkCollision()) {
            activatedList.add(plateletArray[i]);            
        }
    }
    Platelet[] activatedArray = new Platelet[activatedList.size()];
    activatedList.toArray(activatedArray);
    physics.param.GRAVITY[1] = 0;
    physics.update_particle_shapes = false;
    physics.param.iterations_springs    = 0;
    physics.param.iterations_collisions = 3;
    physics.setParticles(activatedArray, activatedArray.length);
    physics.update(1);
}
void CreateContent() {
    
    // add red blood cells at a random height but at the right of the screen
    rbcs.add(new Rbc(new PVector(width + 5, random(35,height - 35))));
    rbcs.add(new Rbc(new PVector(width + 5, random(35,height - 35))));
    
    
    // add platelets everey 5 seconds
    if ((millis() / 1000) - currentTime >= 5 && flag == 0) {
        for (int i = 0;i < amounts;i++) {
            platelets.add(new Platelet(new PVector(width + 5, random(33,height - 33))));
            //platelets.add(new Platelet(new PVector(width + 5, random(33,height - 33))));
        }
        currentTime = millis() / 1000;
        flag = 1;
    }
    if ((millis() / 1000) - currentTime >= 5 && flag == 1) {
        for (int i = 0;i < amounts;i++) {
            platelets.add(new Platelet(new PVector(width + 5, random(33,height - 33))));
            //platelets.add(new Platelet(new PVector(width + 5, random(33,height - 33))));
            
        }
        currentTime = millis() / 1000;
        flag = 0;
    }
    
}
void DeleteContent() {
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
}
//take screenshots by pressing s
void keyPressed() {
    if (key == 's')
        saveFrame("ScreenShots/" + year() + nf(month(), 2) + nf(day(), 2) + "-" + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2) + ".png");	
}
int getActivated() {
    int activated = 0;
    for (Platelet p : platelets) {
        if (p.activated) 
            activated++;
    }
    return activated;
}

void mouseClicked() {
    
    print("Stuck: " + stuck + "\n");
    print("Activated: " + getActivated() + "\n");
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

