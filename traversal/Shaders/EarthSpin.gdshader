shader_type canvas_item;

uniform float pixelation : hint_range(0.0, 250.0, 0.001) = 150.0;
uniform float radius : hint_range(0.0, 0.5, 0.001) = 0.5;
uniform float rotate_x : hint_range(0.0, 180.0, 0.01) = 90.0;
uniform float rotate_y : hint_range(0.0, 360.0, 0.01) = 30.0;
uniform float rotation_speed : hint_range(0.0, 1.0, 0.001) = 0.01;
uniform bool rotation_enabled = true; // Removed hint_range for boolean
uniform sampler2D terrain_map;

mat3 rotateX(float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return mat3(
        vec3(1, 0, 0),
        vec3(0, c, -s),
        vec3(0, s, c)
    );
}

mat3 rotateY(float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return mat3(
        vec3(c, 0, s),
        vec3(0, 1, 0),
        vec3(-s, 0, c)
    );
}

void fragment() {
    vec2 original_uv = UV - vec2(0.5); // Center the UV coordinates
    vec2 centered_uv = original_uv;
    float original_dist = length(original_uv);

    // Apply pixelation to the UV space
    if (pixelation > 0.0) {
        centered_uv = floor(centered_uv * pixelation) / pixelation;
    }

    if (original_dist <= radius) {
        // Normalize UV coordinates
        vec2 normalized_uv = centered_uv / radius;

        // Convert UV to 3D point on sphere
        vec3 sphere_point = vec3(
            normalized_uv.x,
            sqrt(max(0.0, 1.0 - dot(normalized_uv, normalized_uv))),
            normalized_uv.y
        );

        // Apply X and Y axis rotations if rotation is enabled
        float rot_x_r = radians(rotate_x);
        float rot_y_r = radians(rotate_y + (rotation_enabled ? 360.0 * TIME * rotation_speed : 0.0));
        mat3 rot_matrix_x = rotateX(rot_x_r);
        mat3 rot_matrix_y = rotateY(rot_y_r);
        vec3 rotated_point = rot_matrix_y * rot_matrix_x * sphere_point;

        // Convert rotated sphere coordinates to longitude (u) and latitude (v)
        float u = atan(rotated_point.z, rotated_point.x) / (2.0 * PI) + 0.5;
        float v = asin(rotated_point.y) / PI + 0.5;
        vec2 sample_point = vec2(u, v);

        // Ensure UVs are clamped within valid range
        sample_point = clamp(sample_point, vec2(0.0), vec2(1.0));

        // Sample the terrain map for color
        vec4 terrain_color = texture(terrain_map, sample_point);

        float edge_smoothness = fwidth(original_dist) * 2.0;
        float alpha = 1.0 - smoothstep(radius - edge_smoothness, radius, original_dist);

        // Display the full terrain texture without darkening
        COLOR = vec4(terrain_color.rgb, alpha);
    } else {
        COLOR = vec4(0.0); // Transparent outside the circle
    }
}
