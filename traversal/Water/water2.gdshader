shader_type canvas_item;

uniform vec2 resolution = vec2(512.0, 512.0);  // Resolution of the sprite
uniform float scale = 0.25;                     // Scale of the water effect
uniform float speed = 0.5;                     // Animation speed
uniform vec3 direction = vec3(1, 1, 0);        // Wave direction
uniform float distortion = 0.5;                // Distortion factor
uniform float layers = 2.0;                    // Number of wave layers
uniform float shades = 3.0;                    // Number of shading steps
uniform int steps = 6;                         // Steps for FBM noise
uniform vec3 tint = vec3(0.459, 0.765, 1.0);  // Tint color

// Crest parameters
uniform float crest_amplitude = 0.04;
uniform float crest_frequency = 10.0;
uniform float crest_softness = 0.012;
uniform float crest_y_position = 0.05;
uniform float rock_speed = 1.0;
uniform float rock_amount = 0.02;

float gyroid(vec3 seed) {
   return dot(sin(seed), cos(seed.yzx));
}

float fbm(vec3 seed) {
   float result = 0.0;
   float amplitude = 0.5;
   for (int i = 0; i < steps; ++i, amplitude /= 2.0) {
       seed += direction * TIME * speed * 0.01 / amplitude;
       seed.z += result * distortion;
       result += gyroid(seed / amplitude) * amplitude;
   }
   return result;
}

void fragment() {
   vec2 p = (UV * resolution - resolution * 0.5) / resolution.y;
   p *= scale;
   
   float shape = fbm(vec3(p, 0.0));
   float gradient = fract(shape * layers);
   float shade = round(pow(gradient, 4.0) * shades) / shades;
   vec3 color = mix(tint * mix(0.6, 0.8, gradient), vec3(1.0), shade);
   
   // Add wave crest system with rocking motion
   float time = TIME * speed;
   float rock = sin(time * rock_speed) * rock_amount;
   float crest = sin(UV.x * crest_frequency + time + rock) * crest_amplitude;
   float wave_line = crest_y_position + crest + rock;
   float alpha_cutoff = smoothstep(wave_line - crest_softness, wave_line + crest_softness, UV.y);
   
   COLOR = vec4(color, alpha_cutoff);
}