shader_type canvas_item;
render_mode blend_add;

const float END_WIDTH_UV = 0.005;
uniform float red = 1.0;
uniform float green = 0.0;
uniform float blue = 1.0;
uniform float energy = 1.0;
uniform float propVisibleFront =1.0;
uniform float propVisibleEnd = 1.0;

//varying vec2 v;

//void vertex() {
//	v = VERTEX;
//}

void fragment() {
	
	float intensity_x = energy * exp(-((UV[0]-0.5)*(UV[0]-0.5))/(2.0*.175*.175));
	float intensity_y = energy * exp(-((UV[1]-0.5)*(UV[1]-0.5))/(2.0*.15*.15));
	float alpha = intensity_x*intensity_y;
	
	if ((UV[0] < propVisibleEnd+END_WIDTH_UV) && (UV[0] > propVisibleEnd-END_WIDTH_UV) && (propVisibleEnd < 1.0) )
		alpha = exp(-((UV[1]-0.5)*(UV[1]-0.5))/(2.0*.15*.15));
	else if (UV[0] > propVisibleEnd)
		alpha = 0.0;
		
	if ((UV[0] < 1.0-propVisibleFront+END_WIDTH_UV) && (UV[0] > 1.0-propVisibleFront-END_WIDTH_UV) && propVisibleFront < 1.0)
		alpha = exp(-((UV[1]-0.5)*(UV[1]-0.5))/(2.0*.15*.15));
	else if (UV[0] < (1.0 - propVisibleFront))
		alpha = 0.0;
		
		
	COLOR = vec4(red,green, blue,alpha);
	
}