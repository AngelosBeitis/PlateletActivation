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
    
    void display() {
        
        //fill(73,70,70);
        noFill();
        noStroke();
        rect(left.x, top.y, right.x , bottom.y, 7);
        
        
    }
}