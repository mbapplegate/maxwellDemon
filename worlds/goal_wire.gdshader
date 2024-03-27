shader_type canvas_item;
uniform float pct = 0.25;

void vertex() {
	
		
	// Called for every vertex the material is visible on.
}

void fragment() {
	if (UV[0] > pct)
		COLOR = vec4(0.0,0.0,0.0,1.0);
	else
		COLOR = vec4(1.0,0.0,0.0,1.0);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
