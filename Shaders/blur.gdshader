shader_type canvas_item;

uniform float blur_ammount : hint_range(0.0, 1.0, 0.01) = 1;

float blur(float x, float y) {
	return (1.0/(2.0 * PI * pow(blur_ammount,2))) * pow(E, -((pow(x, 2) + pow(y, 2)) / (2.0 * pow(blur_ammount,2))));
}

void fragment() {
	vec2 uv = UV - vec2(0.5, 0.5);
	
	float b = blur(uv.x, uv.y);
	vec4 t = texture(TEXTURE, UV);
	
	t.a = b;
	
	COLOR = vec4(t);
}


//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
