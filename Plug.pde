class Plug{
    
    public PShape shape;
    
    Plug() {
        shape = new PShape();
        
    }
    
    
    public void addShape(PShape s) {
        
        shape.addChild(s);
    }
}