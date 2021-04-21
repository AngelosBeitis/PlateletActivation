import java.util.List;
import controlP5.*;
import com.thomasdiewald.pixelflow.java.DwPixelFlow;
import com.thomasdiewald.pixelflow.java.fluid.DwFluid2D;
import com.thomasdiewald.pixelflow.java.softbodydynamics.DwPhysics;
import com.thomasdiewald.pixelflow.java.softbodydynamics.particle.DwParticle2D;
ControlP5 controlP5;
PrintWriter file;
boolean debug = true;
//no slip condition
int nsc = 1;
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
int amounts = 1;
PApplet papplet;
float[] bounds;
PShape obstacles;
PShape simulationShapes;
int stuck = 0;
int group = 1;
int displayFluid = 0;
float fluidSpeed = 1;
int gridSizeX = 850;
int gridSizeY = 200;
float radius = gridSizeY / 2-10;
float px = gridSizeX + 70;
float py = gridSizeY / 2;
float plateletRadius = 1.5;
float rbcRadius = 2;
float proteinRadius = 1;
int damagePosition = 7;
int endotheliumCount = 10;
int damagePositionCheck = damagePosition;
int endotheliumCheck = endotheliumCount;
int stenosis = 1;
int rbcAmount = 2;
int allowCollision = 1;
float[] a = new float[2];
float[] b = new float[2];
float[] c = new float[2];
float[] d = new float[2];
int frame = 100;
int obstaclesSimulation =1;
int methods = 0;
//PShape shapePlatelets;
PGraphics2D pg_obstacle;

DwPhysics.Param param_physics = new DwPhysics.Param();

DwPhysics<DwParticle2D> physics;

void setup() {
    colorMode(RGB);
    // used to create the shape in the stenosis simulation
    a[0] = 491;
    a[1] = 99;
    b[0] = 571;
    b[1] = gridSizeY - 30;
    c[0] = 370;
    c[1] = 99;
    d[0] = 283;
    d[1] = gridSizeY - 30;
    /////////////////////////////////////////////////////
    controlP5 = new ControlP5(this);
    //create file to write the results of the simulation
    
    file= createWriter("results.txt");
    size(850, 200,P2D);
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
    fluid.param.gridscale = 0.1;
    //fluid.simulation_step = 10;
    
    //adding data to the fluid simulation
    fluid.addCallback_FluiData(new  DwFluid2D.FluidData() {
        public void update(DwFluid2D fluid) {
            float  vx, vy, intensity;
            
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
    
    
    pg_fluid = (PGraphics2D) createGraphics(width, height, P2D);
    pg_obstacle = (PGraphics2D) createGraphics(width, height, P2D);
    
    controlSetup();
    
    file.print("Stuck ");
    file.print("Activated ");
    file.print("Proteins ");
    file.print("Platelets ");
    file.print("red blood cells ");
    file.println("Frame");
    
    
}

void draw() {
    
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
    damage.display();
    shape(simulationShapes);  
    if(frameCount % frame ==0){
         file.print(stuck + " ");
         file.print( getActivated() + " ");
         file.print(proteins.size() + " ");
         file.print(platelets.size() + " ");
         file.print(rbcs.size() + " ");
         file.println(frameCount + " ");
      }
    
}

void PlateletMechanics() {
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
        if (p.activated && (p.stuckToPlatelet || p.stuckToWall) && obstaclesSimulation ==0) {
            obstacles.addChild(p.getShape());
        }
        if (!p.scan(damage) && !p.activated)
          if(proteins.size()>0){
            p.scanForProteins();
          }
        p.checkBoundary();
        if(methods==0)
          p.checkStuck();
        else
          p.checkStuck2();
        p.update(fluid_velocity);
        simulationShapes.addChild(p.getShape());
    }
}
   
   
   
   void RbcMechanics() {
       //add rbc to collision group if that rbc is in contact with an activated platelet to show flow dissruption
       for (Rbc r : rbcs) {
           if (allowCollision != 0) {
               if (r.stuck) {
                   r.setCollisionGroup(group);
                   group++;
               }
           } else{
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
   void ProteinMechanics() {
       for (Protein prot : proteins) {
           prot.checkBoundary();
           prot.update(fluid_velocity);
           simulationShapes.addChild(prot.getShape());
       }
       
   }
   void Physics() {
       if (platelets.size()>0 && rbcs.size()>0) {
           Platelet[] plateletArray = new Platelet[platelets.size()];
           Rbc[] rbcArray = new Rbc[rbcs.size()];
           
           platelets.toArray(plateletArray);
           rbcs.toArray(rbcArray);
           
           List<BloodCont> list = new ArrayList<BloodCont>();
           for (int i = 0;i < rbcArray.length;i++) {
               if (allowCollision == 0) {
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
    void CreateContent() {
       
       // add red blood cells at a random height but at the right of the screen
        
       // add platelets every 100 frames
        if(frameCount % frame == 0){
            for (int i = 0;i < rbcAmount;i++) {
              rbcs.add(new Rbc(new PVector(width + 5, random(35,height - 35))));
            }
            for (int i = 0;i < amounts;i++) {
                platelets.add(new Platelet(new PVector(width + 5, random(33,50))));
                platelets.add(new Platelet(new PVector(width + 5, random(height - 33,height - 50))));
                
                
            }
            if(proteins.size()<1000 && frameCount % 500 ==0){
              float x = random(damage.left.x + 7, damage.right.x - 7);
              float y = damage.top.y + proteinRadius;
              proteins.add(new Protein(new PVector(x,y)));
            }
           
        }
        //generate proteins at the location of activated platelets acting as signaling
        if (frameCount % 300 == 0) {
            for (Platelet i : platelets) {
                if (i.activated) {
                    for (int j = 0;j < 1;j++) {
                        proteins.add(new Protein(new PVector(i.cx,i.cy)));
                    }
                }
            }
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
         print("Frame:" + frameCount + "\n");
       //println(mouseX + " " + mouseY);
       
       
   }
   
   void controlSetup() {
       int gui_w = 250;
       int gui_x = 0;
       int gui_y = 0;
       
       
       int sx, sy, px, py, oy;
       
       sx = 100; sy = 14; oy = (int)(sy * 1.2f);
       ////////////////////////////////////////////////////////////////////////////
       // GUI - SIMULATION
       ////////////////////////////////////////////////////////////////////////////
       Group group_simulation = controlP5.addGroup("Simulation");
    {
           px = 10; py = 10;
           group_simulation.setHeight(20).setSize(gui_w, 140)
             .setBackgroundColor(color(16, 180)).setColorBackground(color(16, 180));
           group_simulation.getCaptionLabel().align(CENTER, CENTER);
           
           controlP5.addSlider("endothelium cells").setGroup(group_simulation).setSize(sx, sy).setPosition(px, py )
             .setRange(damagePosition, 20).setValue(endotheliumCount).plugTo(this,"endotheliumCount");    
           controlP5.addSlider("damaged position").setGroup(group_simulation).setSize(sx, sy).setPosition(px, py +=oy)
             .setRange(1, endotheliumCount).setValue(damagePosition).plugTo(this,"damagePosition");            
           controlP5.addRadio("noSlipCondition").setGroup(group_simulation).setSize(39, 18).setPosition(px, py += oy)
             .addItem("No-slip condition",0)
             .activate(nsc);
           controlP5.addRadio("stenosiSimulation").setGroup(group_simulation).setSize(39, 18).setPosition(px, py += oy)
             .addItem("Stenosis simulation",0)
             .activate(stenosis);
           controlP5.addRadio("particleCollision").setGroup(group_simulation).setSize(39, 18).setPosition(px, py += oy)
             .addItem("Particle collision",0)
             .activate(allowCollision);
           controlP5.addRadio("obstaclesFlowSimulation").setGroup(group_simulation).setSize(39, 18).setPosition(px, py += oy)
             .addItem("Flow obstacle simulation",0);
           controlP5.addRadio("stopSimulation").setGroup(group_simulation).setSize(39, 18).setPosition(px, py += oy)
             .addItem("Stop simulation",0);
           
       }
       ////////////////////////////////////////////////////////////////////////////
       // GUI - FLUID
       ////////////////////////////////////////////////////////////////////////////
       Group group_fluid = controlP5.addGroup("Fluid");
    {
           group_fluid.setHeight(20).setSize(gui_w, 250)
             .setBackgroundColor(color(16, 180)).setColorBackground(color(16, 180));
           group_fluid.getCaptionLabel().align(CENTER, CENTER);
           
           px = 10; py = 15;
           
           controlP5.addSlider("velocity").setGroup(group_fluid).setSize(sx, sy).setPosition(px, py +=(int)(oy * 0.5f) - 20)
             .setRange(0, 1).setValue(fluid.param.dissipation_velocity).plugTo(fluid.param, "dissipation_velocity");
           
           controlP5.addSlider("Fluid Speed").setGroup(group_fluid).setSize(sx, sy).setPosition(px, py +=oy)
             .setRange(0, 100).setValue(fluidSpeed).plugTo(this,"fluidSpeed");
           
           controlP5.addSlider("Fluid position x").setGroup(group_fluid).setSize(sx, sy).setPosition(px, py +=oy)
             .setRange(width, 1000).setValue(this.px).plugTo(this,"px");
           
           
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
           controlP5.addSlider("Platelets generated").setGroup(group_particles).setRange(0, 20).setValue(amounts).setSize(sx,sy).setPosition(px, py).plugTo(this,"amounts");
           controlP5.addSlider("Red blood cells generated").setGroup(group_particles).setRange(0,500).setValue(rbcAmount).setSize(sx,sy).setPosition(px,py +=oy).plugTo(this,"rbcAmount");
           controlP5.addSlider("Sticking method").setGroup(group_particles).setRange(0,1).setValue(methods).setSize(sx,sy).setPosition(px,py +=oy).plugTo(this,"methods");
           
           
       }
       
       
       ////////////////////////////////////////////////////////////////////////////
       // GUI - ACCORDION
       ////////////////////////////////////////////////////////////////////////////
       controlP5.addAccordion("acc").setPosition(gui_x, gui_y).setWidth(gui_w).setSize(gui_w, height)
         .setCollapseMode(Accordion.MULTI)
         .addItem(group_simulation)
         .addItem(group_fluid)
         .addItem(group_particles)
         .open(0);
       
       
       
   }
   
   void fluid_display(int i) {
       displayFluid = i;
   }
   void particleCollision(int i) {
       allowCollision = i;
   }
   void noSlipCondition(int i) {
       nsc = i;
   }
   void stenosiSimulation(int i) {
       stenosis = i;
       back = new Background(damagePosition,endotheliumCount);
   }
   void stopSimulation(int i){
     file.flush();
     file.close();
     exit();
   }
   void obstacleFlowSimulation(int i){
     obstaclesSimulation = i;
   }
   
   
