shader_type canvas_item;

// Base water gradient
uniform vec4 top_color = vec4(0.0, 0.6, 0.9, 1.0);
uniform vec4 bottom_color = vec4(0.0, 0.3, 0.6, 1.0);

// Wave pattern parameters
uniform float wave_amplitude = 0.03;
uniform float wave_frequency = 10.0;
uniform float wave_speed = 1.0;

// Reflection/shimmer intensity
uniform float reflection_intensity = 0.15;

// Controls for the sharp wave crest line
uniform float crest_amplitude = 0.05;    // How tall the crest line wiggles
uniform float crest_frequency = 4.0;     // How many crests appear across the width
uniform float crest_softness = 0.01;     // How "soft" the crest transition is
uniform float crest_y_position = 0.05;   // Vertical position of the crest line (0 = top, 1 = bottom)

// For sharper peaks, you can experiment with nonlinear functions
// or multiple sine waves summed together.

void fragment() {
    float time = TIME * wave_speed;
    vec2 uv = UV;

    // Basic water distortion waves
    float wave_x = sin(uv.y * wave_frequency + time) * wave_amplitude;
    float wave_y = sin(uv.x * wave_frequency * 1.5 + time * 0.7) * wave_amplitude;
    uv.x += wave_x;
    uv.y += wave_y;

    // Vertical gradient for base color
    vec4 color = mix(top_color, bottom_color, uv.y);

    // Add shimmering "ripple" reflections
    float ripple = sin((uv.x * wave_frequency * 3.0 + time * 2.0) 
                     + (uv.y * wave_frequency * 2.0)) * reflection_intensity;
    color.rgb += ripple;

    // Now, define a crest line at the top using another sine wave.
    // This will cut into the alpha or color at the top, creating a distinct wavy top edge.
    float crest = sin(uv.x * crest_frequency + time) * crest_amplitude;

    // The actual wave line: Compare uv.y to the crest line position.
    // If uv.y is above crest_y_position + crest, fade out. This creates a "wavy" silhouette.
    float wave_line = crest_y_position + crest;
    float alpha_cutoff = smoothstep(wave_line - crest_softness, wave_line + crest_softness, uv.y);

    // Invert this if you want the top side to show the wave:
    // If you want the top line itself to be the "tips," you'd let alpha remain below the line.
    // For a top "water line," assume anything above wave_line goes transparent:
    // alpha_cutoff < 1.0 means we are cutting out above the crest line.
    // Adjust depending on if you want the wave line at the top or bottom.
    float final_alpha = alpha_cutoff;

    // Apply the alpha
    color.a = final_alpha;

    COLOR = color;
}
