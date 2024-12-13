shader_type canvas_item;

uniform float border_width : hint_range(0.0, 0.1) = 0.05;
uniform vec4 border_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);

    // Calculate distance from edge
    vec2 center = vec2(0.5, 0.5);
    float dist = length(UV - center);

    // Create border
    if (dist > 0.5 - border_width && tex_color.a > 0.0) {
        COLOR = border_color;
    } else {
        COLOR = tex_color;
    }
}