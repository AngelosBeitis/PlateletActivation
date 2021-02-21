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
    void drawWalls() {
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
    }
    
    
}
