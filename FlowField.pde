class FlowField {
    
    // A flow field is a two dimensional array of PVectors
    PVector[][] field;
    int cols, rows; // Columns and Rows
    int resolution; // How large is each "cell" of the flow field
    int missing;
    float zoff = 0.0; // 3rd dimension of noise
    int cells;
    float maxSpeed;
    
    FlowField(int r,int m,int c,float max) {
        resolution = r;
        // Determine the number of columns and rows based on sketch's width and height
        cols = width / resolution;
        rows = height / resolution;
        field = new PVector[cols][rows];
        missing = m;
        cells = c;
        maxSpeed = max;
        
        init();
    }
    
    public void pull() {
        
        for (Platelet p : platelets) {
            if (dist(damage.top.x,damage.top.y,p.position.x,p.position.y)<100) {
                p.moveTo(damage.top.x,damage.top.y + p.radius,false);
            }
            
        }
        for (Protein p : proteins) {
            if (dist(damage.top.x,damage.top.y,p.position.x,p.position.y)<100) {
                p.moveTo(damage.top.x,damage.top.y + p.radius,false);
            }
            
        }
        for (Rbc r : rbcs) {
            if (dist(damage.top.x,damage.top.y,r.position.x,r.position.y)<100) {
                r.moveTo(damage.top.x,damage.top.y + r.radius,false);
            }
            
        }
    }
    
    public void init() {
        // Reseed noise so we get a new flow field every time
        noiseSeed((int)random(10000));
        float xoff = 0;
        float theta;
        for (int i = 0; i < cols; i++) {
            float yoff = 0;
            for (int j = 0; j < rows; j++) {
                //theta = noise(xoff,yoff,zoff) + PI / 1.2;
                theta = PI;
                if (yoff < 3)
                    theta = 120;
                //Polar to cartesian coordinate transformation to get x and y components of the vector
                field[i][j] = new PVector(cos(theta),sin(theta));
                yoff += 0.1;
            }
            xoff += 0.1;
        }
    }
    public void update() {
        float xoff = 0;
        float theta;
        for (int i = 0; i < cols; i++) {
            float yoff = 0;
            for (int j = 0; j < rows; j++) {
                //theta = map(noise(xoff,yoff,zoff),0,1,PI / 1.1,PI * 1.1);
                theta = PI;
                if (j < 1)
                    theta = - PI / 2;
                //Make a vector from an angle
                field[i][j] = PVector.fromAngle(theta);
                yoff += 0.1;
            }
            xoff += 0.1;
        }
        // Animate by changing 3rd dimension of noise every frame
        zoff += 0.01;
    }
    
    // Draw every vector
    public void display() {
        
        //drawFlow();
        drawWalls();
        
    }
    void drawWalls() {
        float start = 0;
        float end = width / cells;
        fill(213,110,110);
        rect(0,0,width,15);
        fill(213,110,110);
        rect(0,height - 15,width,15);
        for (int i = 0;i <= cells;i++) {
            
            if (i == missing) {
                damage = new Damage(start,start + (width / cells),15,30);
                fill(255,255,0);
                rect(start, height - 30, end , 15, 7);
                fill(0,0,0);
                ellipse(damage.position.x,(height - (45 / 2)) ,10,5);
                start +=  width / cells; 
                
            } else{
                fill(255,255,0);
                rect(start,15,end,15,7);
                fill(0,0,0);
                ellipse((start + (end / 2)),(45 / 2) ,10,5);
                fill(255,255,0);
                rect(start, height - 30, end , 15, 7);
                fill(0,0,0);
                ellipse((start + (end / 2)),(height - (45 / 2)) ,10,5);
                start += width / cells;
            }
        }
    }
    void drawFlow() {
        for (int i = 0; i < cols; i++) {
            for (int j = 0; j < rows; j++) {
                drawVector(field[i][j],i * resolution,j * resolution,resolution - 2);
            }
        }
    }
    
    // Renders a vector object 'v' as an arrow and a position 'x,y'
    public void drawVector(PVector v, float x, float y, float scayl) {
        pushMatrix();
        float arrowsize = 1;
        // Translate to position to render vector
        translate(x,y);
        stroke(0,100);
        // Call vector heading function to get direction (note that pointing to the right is a heading of 0) and rotate
        rotate(v.heading2D());
        // Calculate length of vector & scale it to be bigger or smaller if necessary
        float len = v.mag() * scayl;
        // Draw three lines to make an arrow (draw pointing up since we've rotate to the proper direction)
        line(0,0,len,0);
        //line(len,0,len-arrowsize,+arrowsize/2);
        //line(len,0,len-arrowsize,-arrowsize/2);
        popMatrix();
    }
    
    public PVector lookup(PVector lookup) {
        int column = int(constrain(lookup.x / resolution,0,cols - 1));
        int row = int(constrain(lookup.y / resolution,0,rows - 1));
        return field[column][row].get();
    }
    
    public void changeSpeed(float speed) {
        this.maxSpeed = speed;
    }
    
    
}
