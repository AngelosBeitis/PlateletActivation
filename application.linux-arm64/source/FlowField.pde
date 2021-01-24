class FlowField {
	
	// A flow field is a two dimensional array of PVectors
	PVector[][] field;
	int cols, rows; // Columns and Rows
	int resolution; // How large is each "cell" of the flow field
	
	float zoff = 0.0; // 3rd dimension of noise
	
	FlowField(int r) {
		resolution = r;
		// Determine the number of columns and rows based on sketch's width and height
		cols = width / resolution;
		rows = height / resolution;
		field = new PVector[cols][rows];
		init();
	}
	
	void init() {
		// Reseed noise so we get a new flow field every time
		noiseSeed((int)random(10000));
		float xoff = 0;
		float theta;
		for (int i = 0; i < cols; i++) {
			float yoff = 0;
			for (int j = 0; j < rows; j++) {
				theta = noise(xoff,yoff,zoff) + PI / 1.2;
				//theta = PI/4;
				//Polar to cartesian coordinate transformation to get x and y components of the vector
				field[i][j] = new PVector(cos(theta),sin(theta));
				yoff += 0.1;
			}
			xoff += 0.1;
		}
	}
	void update() {
		float xoff = 0;
		float theta;
		for (int i = 0; i < cols; i++) {
			float yoff = 0;
			for (int j = 0; j < rows; j++) {
				theta = map(noise(xoff,yoff,zoff),0,1,PI / 1.1,PI * 1.1);
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
	void display() {
		// for (int i = 0; i < cols; i++) {
		// 	for (int j = 0; j < rows; j++) {
		// 		drawVector(field[i][j],i * resolution,j * resolution,resolution - 2);
		// 	}
		// }
		fill(213,110,110);
		ellipse(width / 2,height - 5,width,20);
		fill(213,110,110);
		ellipse(width / 2,5,width,20);
	}
	
	// Renders a vector object 'v' as an arrow and a position 'x,y'
	void drawVector(PVector v, float x, float y, float scayl) {
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
	
	PVector lookup(PVector lookup) {
		int column = int(constrain(lookup.x / resolution,0,cols - 1));
		int row = int(constrain(lookup.y / resolution,0,rows - 1));
		return field[column][row].get();
	}
	
	
}
