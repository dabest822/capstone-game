shader_type canvas_item;
render_mode unshaded;

// Gradient properties
uniform vec2 direction = vec2(0.0, -1.0);
uniform vec4 start_color : source_color;
uniform vec4 end_color : source_color;

// Rounded corners properties
uniform float radius_scale: hint_range(0.0, 1.0, 0.1) = 0.1;
uniform bool rounded_corner_top_left = true;
uniform bool rounded_corner_top_right = true;
uniform bool rounded_corner_bottom_left = true;
uniform bool rounded_corner_bottom_right = true;
uniform float width = 1.0;
uniform float height = 1.0;

float vmax(vec4 vec) {
    return max(vec.x, max(vec.y, max(vec.z, vec.w)));
}

float random(vec2 seed, float pmin, float pmax) {
    return pmin + fract(sin(dot(seed.xy, vec2(12.9898, 78.233))) * 43758.5453123) * (pmax - pmin);
}

float get_color_count(float range) {
    return ceil(clamp(range, 0.0, 1.0) * 255.0);
}

float get_delta(vec2 uv) {
    vec2 dir = normalize(direction);
    return (dir.x < 0.0 ? (1.0 - uv.x) : uv.x) * dir.x * dir.x + (dir.y < 0.0 ? (1.0 - uv.y) : uv.y) * dir.y * dir.y;
}

void fragment() {
    // Gradient background
    float color_count = get_color_count(vmax(abs(end_color - start_color)));
    float inv_color_count = 1.0 / color_count;
    float color_index = floor(get_delta(UV) * color_count);
    vec4 color1 = mix(start_color, end_color, color_index / color_count);
    vec4 color2 = mix(start_color, end_color, (color_index + 1.0) / color_count);
    float ratio = clamp(mod(get_delta(UV), inv_color_count) * color_count + random(UV, -0.5, 0.5), 0.0, 1.0);
    vec4 background_color = color1 * (1.0 - ratio) + color2 * ratio;

    // Rounded corners
    vec2 pos = vec2(UV.x * width, UV.y * height);
    float radius = min(width, height) * radius_scale / 2.0;
    float dist;

    // Top left corner
    if (rounded_corner_top_left) {
        dist = length(pos - vec2(radius));
        if (dist > radius && pos.x < radius && pos.y < radius) {
            background_color.a = 0.0;
        }
    }

    // Top right corner
    if (rounded_corner_top_right) {
        dist = length(pos - vec2(width - radius, radius));
        if (dist > radius && pos.x > width - radius && pos.y < radius) {
            background_color.a = 0.0;
        }
    }

    // Bottom left corner
    if (rounded_corner_bottom_left) {
        dist = length(pos - vec2(radius, height - radius));
        if (dist > radius && pos.x < radius && pos.y > height - radius) {
            background_color.a = 0.0;
        }
    }

    // Bottom right corner
    if (rounded_corner_bottom_right) {
        dist = length(pos - vec2(width - radius, height - radius));
        if (dist > radius && pos.x > width - radius && pos.y > height - radius) {
            background_color.a = 0.0;
        }
    }

    COLOR = background_color;
}