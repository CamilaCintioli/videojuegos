shader_type canvas_item;

uniform float width = 0.01;
uniform float progress : hint_range(0.1,0.9) = 0.9;
uniform vec4 color : hint_color;

float sdSegment( in vec2 p, in vec2 a, in vec2 b )
{
    vec2 pa = p-a, ba = b-a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return length( pa - ba*h );
}

void fragment() {
	float backScale = sdSegment(UV, vec2(0.1, 0.5), vec2(0.9, 0.5));
	vec3 backline = vec3(1.0 - smoothstep(width, width + 0.01, backScale));
	
	float frontScale = sdSegment(UV, vec2(0.1, 0.5), vec2(progress, 0.5));
	float frontline = 1.0  - smoothstep(width, width + 0.01, frontScale);
	
	vec3 bar = mix(backline,color.rgb, frontline);
	COLOR = vec4(bar, 1.0);
}	
