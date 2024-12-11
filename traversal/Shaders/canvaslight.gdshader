shader_type canvas_item;

// Number of discrete shading steps.
// Increase this for smoother transitions, decrease for more pronounced "toon" bands.
uniform int shade_steps = 3;

// The direction of the "light" you are faking.
// For example, (-1, -1) means light coming from top-left.
uniform vec2 light_direction = vec2(-1.0, -1.0);

// Overall brightness multiplier for the fake light.
uniform float light_intensity = 1.0;

void fragment() {
    vec4 base_col = texture(TEXTURE, UV);

    // If the pixel is transparent, you can discard it if you want:
    // if (base_col.a < 0.01) {
    //     discard;
    // }

    // We define a flat normal facing "up" for simplicity.
    // If you have no normal maps, this results in uniform shading across the sprite.
    vec2 N = vec2(0.0, -1.0);
    vec2 L = normalize(light_direction);

    // Compute how much light hits the sprite.
    float NdotL = dot(N, L);
    NdotL = clamp(NdotL * light_intensity, 0.0, 1.0);

    // Quantize the shading into `shade_steps` discrete bands.
    float stepsf = float(shade_steps);
    float shade = floor(NdotL * stepsf) / (stepsf - 1.0);

    // Apply the quantized shading to the base color.
    COLOR = vec4(base_col.rgb * shade, base_col.a);
}
