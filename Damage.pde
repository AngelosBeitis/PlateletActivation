class Damage{
    
    PVector position;
    int size;
    int x;
    int y;
    float width;
    float height;
    PVector top;
    PVector bottom;
    PVector left;
    PVector right;
    Damage(float x1, float y1, int s) {
        size = s;
        position = new PVector(x1,y1);
        top = new PVector(x1,position.y - (size / 8));
        bottom = new PVector(x1,position.y + (size / 8));
        left = new PVector(position.x - size / 2 ,y1);
        right = new PVector(position.x + size / 2,y1);
        width = dist(left.x,left.y,right.x,right.y);
        height = dist(top.x,top.y,bottom.x,bottom.y);
    }
    
    void display() {
        fill(73,70,70);
        ellipse(position.x,position.y,width,height);
        
    }
    
    
    
}