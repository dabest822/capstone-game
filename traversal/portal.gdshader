shader_type canvas_item;

void fragment() {
    // UV coordinates between -.5 and .5
    vec2 uv = UV - vec2(0.5);
    
    // Square aspect ratio adjustment
    uv.x *= 1.0; // Adjust based on your needs
    
    // Blue part
    vec3 c1;
    float s;
    {
        // Angle & distance
        float a = atan(uv.x, uv.y);
        float d = length(uv);
        
        // Waves
        d += 0.1;
        d += 0.3 * pow(d, 2.5) * sin(a * 18.0);
        d = pow(d, 0.005);
        d *= 5999.0;
        
        // Rings
        float time = TIME * PI;
        d = 0.5 + 0.5 * sin(d - 2.0 * 8.0 * time);
        
        // Fade at sides
        float b = d;
        b *= 1.0 - length(uv);
        
        // Thin stripes at sides
        s = 1.0 + 1.0 * length(uv) * sin(a * 300.0);
        b *= s;
        
        // Color
        c1 = vec3(0.0, 0.0, b);
    }
    
    // Pink/cyan part
    vec3 c2;
    {
        float y = uv.y;
        float x = uv.x;
        
        // Skew
        x -= sin(y * 6.0) / 9.0;
        // Perspective
        x /= pow(y + sign(y), 2);
        // Waves
        float a = pow(abs(y) + 0.03, 0.1) * 32.0;
        x += 0.03 * sin(a - TIME * PI);
        // Stripes
        x = sin(x * 30.0);
        // Color - cycle pink and cyan
        float b = pow(abs(x), 20.0);
        float p = sin(TIME * PI / 2.0) * 0.5 + 0.5;
        c2 = vec3(b * p, b * (1.0 - p), b * 0.9);
        
        // Apply inverse stripes
        c2 /= s;
    }
    
    COLOR = vec4(c1 + c2 * 0.5, 1.0);
}