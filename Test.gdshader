shader_type canvas_item;

uniform float change_frequency = 0.25;
uniform float grain_size = 0.006;
uniform float grain_opacity = 0.025;

float random (vec2 uv) {
	float time = floor(TIME);
	while(time < TIME){
		time += max(change_frequency, 0.02);
	}
    return fract(sin(dot(uv.xy,
        vec2(12.9898*time,78.233*time))) * 43758.5453123*time);
}

void fragment() {
	COLOR = vec4(1, 1, 1, grain_opacity);
	vec2 uv = vec2(0, 0);
	while(uv.x < UV.x){
		uv.x += max(0.00002, grain_size);
	}
	while(uv.y < UV.y){
		uv.y += max(0.00002, grain_size);
	}
	COLOR.b -= random(uv);
	COLOR.r -= random(uv);
	COLOR.g -= random(uv);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
