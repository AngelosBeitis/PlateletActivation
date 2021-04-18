import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.List; 
import controlP5.*; 
import com.thomasdiewald.pixelflow.java.DwPixelFlow; 
import com.thomasdiewald.pixelflow.java.fluid.DwFluid2D; 
import com.thomasdiewald.pixelflow.java.softbodydynamics.DwPhysics; 
import com.thomasdiewald.pixelflow.java.softbodydynamics.particle.DwParticle2D; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class PlateletActivation extends PApplet {







ControlP5 controlP5;

boolean debug = true;
//no slip condition
int nsc = 1;
int[] colors = new int[7]; 
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
int amounts = 3;
PApplet papplet;
float[] bounds;
PShape obstacles;
PShape simulationShapes;
int stuck = 0;
int group = 1;
int displayFluid = 0;
float fluidSpeed = 1;
int gridSizeX = 840;
int gridSizeY = 340;
float radius = gridSizeY / 2 - 17;
float px = gridSizeX + 70;
float py = gridSizeY / 2;
float plateletRadius = 1.5f;
float rbcRadius = 2;
float proteinRadius = 1;
int damagePosition = 10;
int endotheliumCount = 20;
int damagePositionCheck = damagePosition;
int endotheliumCheck = endotheliumCount;
int stenosis = 1;
//PShape shapePlatelets;
PGraphics2D pg_obstacle;

DwPhysics.Param param_physics = new DwPhysics.Param();

DwPhysics<DwParticle2D> physics;

public void setup() {
    //size(330,260);
    colorMode(RGB);
    controlP5 = new ControlP5(this);
    
    
    frameRate(120);
    
    param_physics.GRAVITY = new float[]{0, 0}; //no gravity
    param_physics.bounds  = new float[]{ - 100, - 500, width + 500, height + 500}; 
    param_physics.iterations_collisions = 3;
    param_physics.iterations_springs    = 0; // no springs in this demo
    
    physics = new DwPhysics<DwParticle2D>(param_physics);
    
    DwPixelFlow context = new DwPixelFlow(this);
    fluid = new Fluid(context, width, height, 1);
    
    fluid.param.dissipation_velocity = 1;
    fluid.param.dissipation_density  = 1f;
    
    // some fluid parameters
    fluid.param.apply_buoyancy = false;
    fluid.param.dissipation_temperature = 0f;
    fluid.param.timestep = 1;
    fluid.param.num_jacobi_projection = 90;
    fluid.param.gridscale = 0.1f;
    //fluid.simulation_step = 10;
    
    //adding data to the fluid simulation
    fluid.addCallback_FluiData(new  DwFluid2D.FluidData() {
        public void update(DwFluid2D fluid) {
            float  vx, vy,  vscale, r, g, b, intensity;
            
            vx = - PI * 5;
            vy = 0;
            intensity = 3;
            fluid.addDensity(px, py, radius, 1, 1, 1, intensity);
            fluid.addVelocity(px, py, radius, vx, vy);
            
            
            
        }
    } );
    
    
    // create the background along with the ArrayLists where the particles will be stored in 
    back = new Background(damagePosition,endotheliumCount);
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
    
//}   
    // for (int i = 0; i < 20;i++) {
    //     float x = random(damage.left.x + 7, damage.right.x - 7);
    //     float y = damage.top.y;
    //     proteins.add(new Protein(new PVector(x,y)));
// }
    
    pg_fluid = (PGraphics2D) createGraphics(width, height, P2D);
    pg_obstacle = (PGraphics2D) createGraphics(width, height, P2D);
    
    controlSetup();
    
    
    
    
}

public void draw() {
    
    background(255,252,182); 
    simulationShapes = new PShape();
    obstacles = new PShape();
    obstacles.addChild(back.sim);
    simulationShapes.addChild(back.sim);
    group = 1;
    RbcMechanics();
    // clear proteins so the simulation doesn't come to a hault due to extreme frame drops
    if (frameRate < 5) {
        println(frameRate);
        proteins.clear();
    }
    
    PlateletMechanics();
    Physics();
    //re create the background in case there has been a change through the GUI
    if (endotheliumCheck!= endotheliumCount || damagePositionCheck != damagePosition) {
        endotheliumCheck = endotheliumCount;
        damagePositionCheck = damagePosition;
        back = new Background(damagePosition,endotheliumCount);
        
    }
    ProteinMechanics();
    
    //add obstacles to the simulation
    pg_obstacle.noSmooth();
    pg_obstacle.beginDraw();
    pg_obstacle.clear();
    pg_obstacle.shape(obstacles);
    pg_obstacle.endDraw();
    fluid.addObstacles(pg_obstacle);
    
    fluid.update();
    fluid_velocity = fluid.getVelocity(fluid_velocity);
    
    //delete particles which are out of the grid
    DeleteContent();
    
    //create new particles at the right part of the screen(rbcs,platelets,proteins)
    CreateContent();
    //display the fluid if the button on the GUI is on
    if (displayFluid == 0) {
        pg_fluid.beginDraw();
        pg_fluid.endDraw();
        
        fluid.renderFluidTextures(pg_fluid, 0);
        image(pg_fluid, 0, 0);
    }
    
    //display shapes of the screen
    shape(simulationShapes);  
    
    
}

public void PlateletMechanics() {
    //set collision group to activated platelets so that they can collide with other particles
    for (Platelet p : platelets) {
        if (!p.activated)
            p.setCollisionGroup(0);
        else{
            p.setCollisionGroup(group);
            group++;
        }
    }
    for (Platelet p : platelets) {
        //add activated platelets to the obstacle so that we can see flow dissruption
        if (p.activated && (p.stuckToPlatelet || p.stuckToWall)) {
            obstacles.addChild(p.getShape());
        }
        if (!p.scan(damage) && !p.activated)
            p.scanForProteins();
        
        //implement shear rate activation
        if (p.getVelocity()<0.0005f && p.getVelocity()>0) {
        }
        //generate proteins at the location of activated platelets acting as signaling
        if ((millis() / 1000) - currentTime2 >= 2 && flag2 == 0) {
            for (Platelet i : platelets) {
                if (i.activated) {
                    for (int j = 0;j < 1;j++) {
                        proteins.add(new Protein(new PVector(i.cx,i.cy)));
                    }
                }
            }
            currentTime2 = millis() / 1000;
            flag2 = 1;
        }
        if ((millis() / 1000) - currentTime2 >= 2 && flag2 == 1) {
            for (Platelet i : platelets) {
                if (i.activated) {
                    for (int j = 0;j < 1;j++)
                        proteins.add(new Protein(new PVector(i.cx,i.cy)));
                }
            }
            currentTime2 = millis() / 1000;
            flag2 = 0;
        }
        p.checkBoundary();
        p.checkStuck();
        p.update(fluid_velocity);
        simulationShapes.addChild(p.getShape());
        
    }
    
}
public void RbcMechanics() {
    //add rbc to collision group if that rbc is in contact with an activated platelet to show flow dissruption
    for (Rbc r : rbcs) {
        if (r.stuck) {
            r.setCollisionGroup(group);
            group++;
        }
    }
    stuck = 0;
    for (Rbc r : rbcs) {
        if (r.stuck)
            stuck++;
    }
    for (Rbc r : rbcs) {        
        r.checkBoundary();
        r.update(fluid_velocity);
        simulationShapes.addChild(r.getShape());
        r.checkStuck();
    }
    
}
public void ProteinMechanics() {
    for (Protein prot : proteins) {
        prot.checkBoundary();
        prot.update(fluid_velocity);
        simulationShapes.addChild(prot.getShape());
    }
    
}
public void Physics() {
    if (platelets.size()>0 && rbcs.size()>0) {
        Platelet[] plateletArray = new Platelet[platelets.size()];
        Rbc[] rbcArray = new Rbc[rbcs.size()];
        
        platelets.toArray(plateletArray);
        rbcs.toArray(rbcArray);
        
        List<BloodCont> list = new ArrayList<BloodCont>();
        for (int i = 0;i < rbcArray.length;i++) {
            if (stenosis == 0) {
                list.add(rbcArray[i]);
            }
            else{
                if (rbcArray[i].stuck) {
                    list.add(rbcArray[i]);
                }
            }
        }
        
        for (int i = 0;i < plateletArray.length;i++) {
            list.add(plateletArray[i]);            
        }
        BloodCont[] finalArray = new BloodCont[list.size()];
        list.toArray(finalArray);
        
        physics.param.GRAVITY[1] = 0;
        physics.update_particle_shapes = false;
        physics.param.iterations_springs    = 0;
        physics.param.iterations_collisions = 3;
        if (finalArray.length > 0) {
            physics.setParticles(finalArray,finalArray.length);
            physics.update(1);
        }
    }
}
public void CreateContent() {
    
    // add red blood cells at a random height but at the right of the screen
    rbcs.add(new Rbc(new PVector(width + 5, random(35,height - 35))));
    rbcs.add(new Rbc(new PVector(width + 5, random(35,height - 35))));
    
    
    // add platelets every 5 seconds
    if ((millis() / 1000) - currentTime >= 5 && flag == 0) {
        for (int i = 0;i < amounts;i++) {
            platelets.add(new Platelet(new PVector(width + 5, random(33,50))));
            platelets.add(new Platelet(new PVector(width + 5, random(height - 33,height - 50))));
            float x = random(damage.left.x + 7, damage.right.x - 7);
            float y = damage.top.y + proteinRadius;
            proteins.add(new Protein(new PVector(x,y)));
        }
        currentTime = millis() / 1000;
        flag = 1;
    }
    if ((millis() / 1000) - currentTime >= 5 && flag == 1) {
        for (int i = 0;i < amounts;i++) {
            platelets.add(new Platelet(new PVector(width + 5, random(33,50))));
            platelets.add(new Platelet(new PVector(width + 5, random(height - 33,height - 50))));            
            
        }
        currentTime = millis() / 1000;
        flag = 0;
    }
    
}
public void DeleteContent() {
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
public void keyPressed() {
    if (key == 's')
        saveFrame("ScreenShots/" + year() + nf(month(), 2) + nf(day(), 2) + "-" + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2) + ".png");	
}
public int getActivated() {
    int activated = 0;
    for (Platelet p : platelets) {
        if (p.activated) 
            activated++;
    }
    return activated;
}

public void mouseClicked() {
    
    // print("Stuck: " + stuck + "\n");
    // print("Activated: " + getActivated() + "\n");
    // print("Proteins:" + proteins.size() + "\n");
    // print("Platelets:" + platelets.size() + "\n");
    // print("red blood cells:" + rbcs.size() + "\n");
    
    println(mouseX + " " + mouseY);
    
    
}

public void controlSetup() {
    int gui_w = 200;
    int gui_x = 20;
    int gui_y = 20;
    
    
    int sx, sy, px, py, oy;
    
    sx = 100; sy = 14; oy = (int)(sy * 1.5f);
    ////////////////////////////////////////////////////////////////////////////
    // GUI - FLUID
    ////////////////////////////////////////////////////////////////////////////
    Group group_fluid = controlP5.addGroup("fluid");
    {
        group_fluid.setHeight(20).setSize(gui_w, 250)
           .setBackgroundColor(color(16, 180)).setColorBackground(color(16, 180));
        group_fluid.getCaptionLabel().align(CENTER, CENTER);
        
        px = 10; py = 15;
        
        px = 10;
        
        controlP5.addSlider("velocity").setGroup(group_fluid).setSize(sx, sy).setPosition(px, py +=(int)(oy * 0.5f) - 20)
           .setRange(0, 1).setValue(fluid.param.dissipation_velocity).plugTo(fluid.param, "dissipation_velocity");
        
        controlP5.addSlider("Fluid Speed").setGroup(group_fluid).setSize(sx, sy).setPosition(px, py +=oy)
           .setRange(0, 100).setValue(fluidSpeed).plugTo(this,"fluidSpeed");
        
        controlP5.addSlider("Fluid position x").setGroup(group_fluid).setSize(sx, sy).setPosition(px, py +=oy)
           .setRange(width, 1000).setValue(this.px).plugTo(this,"px");
        
        controlP5.addSlider("Fluid position y").setGroup(group_fluid).setSize(sx, sy).setPosition(px, py +=oy)
           .setRange(0, 1000).setValue(this.py).plugTo(this,"py");
        
        controlP5.addSlider("Fluid Radius").setGroup(group_fluid).setSize(sx, sy).setPosition(px, py +=oy)
           .setRange(0, 300).setValue(radius).plugTo(this,"radius");
        
        controlP5.addSlider("density").setGroup(group_fluid).setSize(sx, sy).setPosition(px, py +=oy)
           .setRange(0, 1).setValue(fluid.param.dissipation_density).plugTo(fluid.param, "dissipation_density");
        
        controlP5.addSlider("temperature").setGroup(group_fluid).setSize(sx, sy).setPosition(px, py +=oy)
           .setRange(0, 1).setValue(fluid.param.dissipation_temperature).plugTo(fluid.param, "dissipation_temperature");
        
        controlP5.addSlider("iterations").setGroup(group_fluid).setSize(sx, sy).setPosition(px, py +=oy)
           .setRange(0, 100).setValue(fluid.param.num_jacobi_projection).plugTo(fluid.param, "num_jacobi_projection");
        
        controlP5.addSlider("timestep").setGroup(group_fluid).setSize(sx, sy).setPosition(px, py +=oy)
           .setRange(0, 10).setValue(fluid.param.timestep).plugTo(fluid.param, "timestep");
        
        controlP5.addSlider("gridscale").setGroup(group_fluid).setSize(sx, sy).setPosition(px, py +=oy)
           .setRange(0, 50).setValue(fluid.param.gridscale).plugTo(fluid.param, "gridscale");
        
        controlP5.addRadio("fluid_display").setGroup(group_fluid).setSize(sy,sy).setPosition(px, py +=oy)
           .addItem("Display Fluid", 0)
           .activate(displayFluid);
        
        
    }
    
    
    
    ////////////////////////////////////////////////////////////////////////////
    // GUI - PARTICLES
    ////////////////////////////////////////////////////////////////////////////
    Group group_particles = controlP5.addGroup("Particles");
    {
        
        group_particles.setHeight(20).setSize(gui_w, 200)
           .setBackgroundColor(color(16, 180)).setColorBackground(color(16, 180));
        group_particles.getCaptionLabel().align(CENTER, CENTER);
        
        sx = 100; px = 10; py = 10;oy = (int)(sy * 1.4f);
        controlP5.addButton("+").setGroup(group_particles).plugTo(this, "amount_increase").setSize(39, 18).setPosition(px, py);
        controlP5.addButton("-").setGroup(group_particles).plugTo(this, "amount_decrease").setSize(39, 18).setPosition(px + 50, py);
        controlP5.addSlider("endothelium").setGroup(group_particles).setSize(sx, sy).setPosition(px, py +=oy)
           .setRange(damagePosition, 20).setValue(endotheliumCount).plugTo(this,"endotheliumCount");    
        controlP5.addSlider("damaged position").setGroup(group_particles).setSize(sx, sy).setPosition(px, py +=oy)
           .setRange(1, endotheliumCount).setValue(damagePosition).plugTo(this,"damagePosition");            
        controlP5.addRadio("noSlipCondition").setGroup(group_particles).setSize(39, 18).setPosition(px, py += 50)
           .addItem("No-slip condition",0)
           .activate(nsc);
        controlP5.addRadio("stenosiSimulation").setGroup(group_particles).setSize(39, 18).setPosition(px, py += 50)
           .addItem("Stenosis simulation",0)
           .activate(stenosis);
        
        
    }
    
    
    ////////////////////////////////////////////////////////////////////////////
    // GUI - ACCORDION
    ////////////////////////////////////////////////////////////////////////////
    controlP5.addAccordion("acc").setPosition(gui_x, gui_y).setWidth(gui_w).setSize(gui_w, height)
       .setCollapseMode(Accordion.MULTI)
       .addItem(group_fluid)
       .addItem(group_particles)
       .open(0);
    
    
    
}

public void amount_increase() {
    amounts++;
    
}
public void amount_decrease() {
    if (amounts > 0) {
        amounts--;
    }
    
}
public void fluid_display(int i) {
    displayFluid = i;
}
public void noSlipCondition(int i) {
    nsc = i;
}
public void stenosiSimulation(int i) {
    stenosis = i;
    back = new Background(damagePosition,endotheliumCount);
    
    
}
class Background {
    
    // A flow field is a two dimensional array of PVectors
    
    int missing;
    int cells;
    public PShape sim;
    
    Background(int m,int c) {
        
        missing = m;
        cells = c;
        drawWalls();
    }
    public void update() {
        display();
    }
    public void display() {
        drawWalls();
    }    
    public void drawWalls() {
        float start = 0;
        float end = width / cells;
        sim = createShape(GROUP);
        
        fill(213,110,110);
        sim.addChild(createShape(RECT,0,0,width,15));
        fill(213,110,110);
        sim.addChild(createShape(RECT,0,height - 15,width,15));
        for (int i = 0;i <= cells;i++) {
            
            if (i == missing) {
                damage = new Damage(start,start + (width / cells),15,30);
                fill(255,255,0);
                sim.addChild(createShape(RECT,start, height - 30, end , 15, 7));
                fill(0,0,0);
                sim.addChild(createShape(ELLIPSE,damage.position.x,(height - (45 / 2)) ,10,5));
                start +=  width / cells; 
                
            } else{
                fill(255,255,0);
                sim.addChild(createShape(RECT,start,15,end,15,7));
                fill(0,0,0);
                sim.addChild(createShape(ELLIPSE,(start + (end / 2)),(45 / 2) ,10,5));
                fill(255,255,0);
                sim.addChild(createShape(RECT,start, height - 30, end , 15, 7));
                fill(0,0,0);
                sim.addChild(createShape(ELLIPSE,(start + (end / 2)),(height - (45 / 2)) ,10,5));
                shape(sim);
                start += width / cells;
            }
        }
        if (stenosis == 0) {
            sim.addChild(createShape(QUAD, 370,99, 491,99, 571,gridSizeY - 30,283,gridSizeY - 30));
            shape(sim);
        }
        
    }
    
    
}
abstract class BloodCont extends DwParticle2D{
    
    // fluid velocity
    public float[] fv;
    public PVector velocity;
    
    BloodCont(PVector l,float rad) {
        super(1,l.x,l.y,rad);
        this.setPosition(l.x,l.y);
        velocity = new PVector(0,0);
        
    }
    
    public float[] fluidVelocity(float[] fluid_velocity) {
        // add force: Fluid Velocity
        float[] fluid_vxy = new float[2];
        
        int px_view = Math.round(this.cx);
        int py_view = Math.round(height - 1 - this.cy); // invert y
        
        int px_grid = px_view / fluid.grid_scale;
        int py_grid = py_view / fluid.grid_scale;
        
        int w_grid  = fluid.tex_velocity.src.w;
        int h_grid  = fluid.tex_velocity.src.h;
        
        // clamp coordinates, just in case
        if (px_grid < 0) px_grid = 0; else if (px_grid >= w_grid) px_grid = w_grid;
        if (py_grid < 0) py_grid = 0; else if (py_grid >= h_grid) py_grid = h_grid;
        
        int PIDX = py_grid * w_grid + px_grid;
        fluid_vxy[0] = + fluid_velocity[PIDX * 2] * 0.05f * fluidSpeed;
        fluid_vxy[1] = - fluid_velocity[PIDX * 2 + 1] * 0.05f * fluidSpeed; // invert y
        
        return fluid_vxy;
    }
    // Method to update position
    public void update(float[] fluid_velocity) {
        
        PVector accel = new PVector(ax,ay);
        velocity.add(accel);
        this.fv = fluid_velocity;
        this.addForce(fluidVelocity(fv));
        updateShapePosition();
        updatePosition(1);
        
    }
    
    public void checkBoundary() {
        //bottom boundary
        if (cy > height - this.rad - 30) {
            cy = height - this.rad - 30;
            //no-slip condition
            if (nsc == 0) {
                cx = px;
                ax = 0;
                ay = 0;
            }
            
        }
        //top boundary
        if (cy < 30 + this.rad && (cx < damage.left.x - this.rad || cx > damage.right.x + this.rad)) {
            cy = 30 + this.rad;
            //no-slip condition
            if (nsc == 0) {
                cx = px;
                ax = 0;
                ay = 0;
            }
        }
        // within damaged cell
        if (cx > damage.left.x - this.rad && cx < damage.right.x + this.rad) {
            //ifdamage is on top
            if (cy < 15 + this.rad)
                cy = 15 + this.rad;
            // if damage is on the bottom
            if (cy > height - 15 + this.rad)
                cy = height - 15 + this.rad;
        }
        if (cx < damage.left.x + this.rad && cy > height - this.rad - 30) {
            cx = damage.left.x + this.rad;
            
        }
        if (cx > damage.right.x - this.rad && cy > height - this.rad - 30) {
            cx = damage.right.x - this.rad;
            
        }
        if (cx < damage.left.x + this.rad && cy < 30 + this.rad) {
            cx = damage.left.x + this.rad;            
        }
        if (cx > damage.right.x - this.rad && cy < 30 + this.rad) {
            cx = damage.right.x - this.rad;
            
        }
        
    }
    public void moveToTarget(float[] cnew, float m) {
        PVector position = new PVector(cx,cy);
        PVector target = new PVector(cnew[0],cnew[1]);
        //float distance = dist(this.cx,this.cy,cnew[0],cnew[1]);
        PVector desired = PVector.sub(target,position);
        //float d = desired.mag();
        desired.normalize();
        // PVector newV = new PVector(0.05,0.05);
        // desired.sub(newV);
        desired.mult(m);
        
        PVector steer = PVector.sub(desired,velocity);
        
        float[] steerNew = new float[2];
        steerNew[0] = steer.x;
        steerNew[1] = steer.y;
        addForce(steerNew);
        
    }
    
}
class Damage{
    
    PVector position;
    float width;
    float height;
    PVector top;
    PVector bottom;
    PVector left;
    PVector right;
    Damage(float l, float r,float t, float b) {
        
        float x1 = (l + r) / 2;
        float y1 = (b + t) / 2;
        position = new PVector(x1,y1);
        top = new PVector(x1,t);
        bottom = new PVector(x1,b);
        left = new PVector(l,y1);
        right = new PVector(r,y1);
        width = dist(left.x,left.y,right.x,right.y);
        height = dist(top.x,top.y,bottom.x,bottom.y);
    }
    
    
}

class Fluid extends DwFluid2D{
    
    
    Fluid(DwPixelFlow context, int viewport_width, int viewport_height, int fluidgrid_scale) {
        super(context, viewport_width, viewport_height, fluidgrid_scale);
        
    }
    
    
}
class Platelet extends BloodCont{
    
    public boolean activated;
    public int time;
    private int flag;
    public boolean stuckToWall;
    public boolean stuckToPlatelet;
    
    Platelet(PVector l) {
        super(l,1.5f);
        flag = 0;
        activated = false;
        enableCollisions(true);
        createShapes();
        stuckToWall = false;
        stuckToPlatelet = false;
        
    }
    
    
    public boolean scan(Damage d) {
        
        float distance = cy - d.top.y;
        distance = distance - this.rad;
        boolean withinDist = distance < 10;
        
        if (withinDist && !this.activated && !this.checkStuck()) {            
            float[] cnew = new float[2];
            cnew[0] = cx;
            cnew[1] = d.top.y;
            moveToTarget(cnew,0.25f);
            //activate at the damaged area
            if (distance < 1 && activated == false)
                activate();
        }
        return withinDist;
        
    }
    
    public boolean scanForProteins() {
        float distance;        
        for (Protein p : proteins) {
            float[] cnew = new float[2];
            cnew[0] = p.cx;
            cnew[1] = p.cy;
            
            distance = dist(cx,cy,p.cx,p.cy);
            distance -=(this.rad + p.rad);
            if (!this.activated && distance < 17) {                
                moveToTarget(cnew,0.5f);
            }
            if (distance < 2) {
                proteins.remove(p);
                scanForProteins();
            }
            return true;
            
        }
        
        return false;
        
    }
    
    
    public void activate() {
        activated = true;
        this.setRadius(2);
        //create the new shape
        createShapes();
        //plug.addShape(this.getShape());     
    }
    
    private void createShapes() {
        if (!activated) {
            stroke(0);
            pushMatrix();
            fill(255);
            PShape platelet = createShape(GROUP);
            
            PShape body = createShape(ELLIPSE,0,0, this.rad * 2, this.rad * 2);
            platelet.addChild(body);
            setShape(platelet);
            popMatrix();
        }
        else{
            stroke(0);
            
            pushMatrix();
            fill(255);
            //translate(cx,cy);
            PShape platelet = createShape(GROUP);
            
            // Make 4shapes
            PShape body = createShape(ELLIPSE, 0, 0,this.rad * 2,this.rad * 2);
            PShape leg1 = createShape(LINE, 0, - this.rad * 2,this.rad / 8,this.rad * 2);
            PShape leg2 = createShape(LINE, 0, - this.rad * 2 ,this.rad / 8,this.rad * 2);
            PShape leg3 = createShape(LINE, 0, - this.rad * 2 ,this.rad / 8,this.rad * 2);
            leg2.rotate(1);
            leg3.rotate(2);
            // Add the 4 "child" shapes to the parent group
            
            platelet.addChild(leg1);
            platelet.addChild(leg2);
            platelet.addChild(leg3);
            platelet.addChild(body);
            
            // Draw the group
            setShape(platelet);
            popMatrix();
        }
        
    }
    
    public boolean withinDamage() {
        if (cy < damage.bottom.y && cx > damage.left.x && cx < damage.right.x)
            return true;
        return false;
    }
    
    public void collision(List<Platelet> platelets) {
        for (Platelet p : platelets) {
            this.updateCollision(p);
            afterCollision();
        }
        
        
    }
    
    public boolean checkStuck() {
        boolean statement = false;
        if (this.activated) {                
            statement = true;
            if (cy > damage.top.y + this.rad) {
                float[] n = new float[2];
                n[0] = cx;
                n[1] = damage.top.y;
                this.stuckToWall = true;
                this.moveTo(n,0.005f);
            }
        }
        for (Platelet o : platelets) {
            // Get distances between the balls components
            PVector otherPosition = new PVector(o.cx,o.cy);
            PVector position = new PVector(cx,cy);
            PVector distanceVect = PVector.sub(otherPosition, position);
            
            // Calculate magnitude of the vector separating the balls
            float distanceVectMag = distanceVect.mag();
            
            // Minimum distance before they are touching
            
            float minDistance = this.rad  + o.rad;
            if (distanceVectMag < minDistance) {
                
                if (this.flag == 0 && o.activated) {
                    this.time = millis() / 1000;
                    this.flag = 1;
                }
                
                if (!this.activated && o.activated) {
                    this.activate();    
                    this.time = millis() / 1000;   
                    this.flag = 0;    
                    statement = true;           
                }
                if ((o.activated && !this.activated) || (this.activated && o.activated && !this.stuckToWall)) {
                    float[] newo = new float[2];
                    newo[0] = o.cx;
                    newo[1] = o.cy;
                    this.moveToTarget(newo,0.5f);
                    this.stuckToPlatelet = true;
                    return statement;
                    
                }
                
            }
            else{
                this.stuckToPlatelet = false;
                
                this.flag = 0;
                this.time = millis();
            }
            
        }
        return statement;
    }
    
}
class Protein extends BloodCont{
    
    Protein(PVector l) {
        
        super(l,1);   
        ax = 0;
        ay = 0.005f;   
        // will make them stay close to the damaged area
        //mass = 2;
        enableCollisions(false);        
        createShapes();
    }
    
    public void createShapes() {
        
        //float theta = velocity.heading2D() + radians(90);
        pushMatrix();
        fill(0,255,0);
        
        PShape protein = createShape(GROUP);
        stroke(0);
        protein.addChild(createShape(ELLIPSE,0,0,rad * 2,rad * 2));
        setShape(protein);
        popMatrix();
    }
    
}
class Rbc extends BloodCont{
    
    public boolean stuck;
    
    Rbc(PVector l) {
        super(l,2.2f);
        stuck = false;
        createShapes();
        enableCollisions(true);
        
    }
    
    private void createShapes() {
        
        stroke(0);
        pushMatrix();
        fill(180,0,0);
        
        PShape rbc = createShape(GROUP);
        
        PShape body = createShape(ELLIPSE,0,0, this.rad * 2, this.rad * 2);        
        PShape inner = createShape(ELLIPSE,0,0, this.rad / 2, this.rad / 2);
        
        rbc.addChild(body);
        rbc.addChild(inner);
        this.setShape(rbc);
        //this.setColor(color(255,0,0));
        
        popMatrix();
        
    }
    
    public void checkStuck() {
        for (Platelet o : platelets) {
            // Get distances between particles
            PVector otherPosition = new PVector(o.cx,o.cy);
            PVector position = new PVector(cx,cy);
            PVector distanceVect = PVector.sub(otherPosition, position);
            
            // Calculate magnitude of the vector separating the particles
            float distanceVectMag = distanceVect.mag();
            
            // Minimum distance before they are touching
            
            float minDistance = this.rad  + o.rad;
            if (distanceVectMag < minDistance) {
                if (o.activated) {
                    
                    this.stuck = true;
                    float[] cnew = new float[2];
                    cnew[0] = o.cx;
                    cnew[1] = o.cy;
                    moveToTarget(cnew,0.005f);
                    return;
                }
            }
            else{
                this.stuck = false;
            }
            
        }
    }
}
  public void settings() {  size(840, 340,P2D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "PlateletActivation" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}