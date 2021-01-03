class Damage{
	
	PVector position;
	int size;
	int x;
	int y;
	Damage(float x1, float y1, int s) {
		size = s;
		position = new PVector(x1,y1);
	}
	
	void display() {
		fill(73,70,70);
		ellipse(position.x,position.y,size,size / 4);    
	}
	
}