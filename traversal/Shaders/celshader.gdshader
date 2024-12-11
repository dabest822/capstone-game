shader_type canvas_item;

// Kept all uniforms for future customization, even though many were related to old lighting logic.
uniform float first_stage : hint_range(0.0, 1.0) = 0.5; 
uniform float first_smooth : hint_range(0.0, 1.0) = 0.0;
uniform float second_stage : hint_range(0.0, 1.0) = 0.0;   
uniform float second_smooth : hint_range(0.0, 1.0) = 0.0;
uniform bool rim_light = false;
uniform float rim_thickness : hint_range(0, 40) = 5.0;
uniform float rim_intense : hint_range(0, 1) = 1.0;
uniform bool rim_extra_thick = false;
uniform float min_light : hint_range(0.0, 1.0) = 0.0;
uniform float mid_light : hint_range(0.0, 1.0) = 0.0;
uniform float max_light : hint_range(0.0, 1.0) = 1.0;
uniform float obj_light_add : hint_range(0.0, 1.0) = 0.0;
// Light height variables (no longer functional without old pipeline)
uniform bool fake_light_depth = false;
uniform float obj_height : hint_range(-2048.0, 2048.0) = 0.0; 
uniform float min_scale : hint_range(0.0, 10.0) = 0.2;
uniform float max_scale : hint_range(0.0, 10.0) = 2.0; 
uniform float light_change_thresh : hint_range(0.0, 4080.0) = 0.0;
uniform bool light_fade = false;
uniform float light_fade_end : hint_range(0.0, 4080.0) = 0.0;
uniform bool fake_spot_light = false;
uniform float first_shrink_speed : hint_range(0.0, 120.0) = 0.0; 
uniform float second_shrink_speed : hint_range(0.0, 120.0) = 0.0;
// Color override
uniform vec4 before_light_modulate = vec4(1.0,1.0,1.0,1.0);

void fragment() {
    vec4 texture_color = texture(TEXTURE, UV);
    // Since we no longer have separate light passes in canvas_item,
    // just apply the before_light_modulate directly.
    COLOR = texture_color * before_light_modulate;
}

// The following functions and logic related to the old `light()` pipeline 
// can't be used. We'll remove them to avoid errors.
//
// float light_calc(float light_strength, float would_be_strength) {
//     float target_strength = light_strength + would_be_strength * obj_light_add;
//     if (target_strength == 0.0) {target_strength = 0.000001;}
//     if (would_be_strength == 0.0) {would_be_strength = 1.0;}
//     return(target_strength / would_be_strength);
// }

// The old `light()` function is removed because it's not supported in Godot 4.
// All lighting must be done in `fragment()` or using a `canvas_light` shader type.
