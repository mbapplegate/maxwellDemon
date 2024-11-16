shader_type canvas_item;

//uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	//vec4 lastTex = textureLod(screen_texture, SCREEN_UV, 0.0);
	
	float r = sqrt((UV.x-.5)*(UV.x-.5) + (UV.y-.5)*(UV.y-.5));
	float theta = atan(UV.y,UV.x);
	float val = cos(1.0*2.0*PI*TIME -abs(r)*2.0*PI*5.0);
	if (val < 0.0)
		COLOR = vec4(0.0,0.0,abs(val),1.0);
	
	else
		COLOR = vec4(val,0.0,0.0,1.0);

}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
