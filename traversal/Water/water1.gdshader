shader_type canvas_item;

uniform float speed : hint_range(0.1, 5.0) = 1.0;
uniform float frequency : hint_range(1.0, 20.0) = 10.0;
uniform float amplitude : hint_range(0.001, 0.1) = 0.005;

void vertex() {
    // Add vertex animation if needed
}

void fragment() {
    // Create wave effect
    vec2 uv = UV;
    
    // Time-based displacement
    float time = TIME * speed;
    
    // Add wave distortion
    uv.x += sin(uv.y * frequency + time) * amplitude;
    uv.y += cos(uv.x * frequency + time) * amplitude;
    
    // Apply the effect to the texture
    vec4 tex_color = texture(TEXTURE, uv);
    COLOR = tex_color;
}