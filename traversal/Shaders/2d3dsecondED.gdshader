#define pi 3.14159265358979323

shader_type canvas_item;

uniform float rotationAngle;
uniform bool isVertical;
uniform bool isLeftOrBottomLonger;
uniform vec2 viewPosition;
uniform float thickness = 0.5;

// New uniform for scrolling speed
uniform vec2 scroll_speed = vec2(0.0, -1.0); // Direction and speed of scrolling
uniform float time_multiplier = 1.0;         // Adjust for overall speed scaling

struct ray {
    vec3 o, d;
};

ray GetRay(vec2 uv, vec3 camPos, vec3 lookAt, float zoom) {
    ray a;
    a.o = camPos;

    vec3 f = normalize(lookAt - camPos);
    vec3 r = normalize(cross(vec3(0.0, 1.0, 0.0), f));
    vec3 u = cross(f, r);
    vec3 c = camPos + f * zoom;
    vec3 i;
    i = vec3(0., 0., 1.) + uv.x * vec3(0., 1., 0.) + uv.y * vec3(1., 0., 0.);

    a.d = normalize(i - a.o);

    return a;
}

void vertex() {
    // Called for every vertex the material is visible on.
}

void fragment() {
    vec2 uv = 2. * (UV - .5);
    vec3 camPos = vec3(viewPosition.y, viewPosition.x, 0.0);
    vec3 lookAt = vec3(viewPosition.y, viewPosition.x, 1.0);

    ray r = GetRay(uv, camPos, lookAt, 1.0);

    float rotat = rotationAngle;
    // Describe the plane
    vec3 tar_point;
    vec3 tar_normal;
    if (isVertical) {
        if (isLeftOrBottomLonger) {
            tar_point = vec3(-1.0, -1.0, 1.0);
            tar_normal = vec3(0.0, sin(rotat), -cos(rotat));
        } else {
            tar_point = vec3(1.0, 1.0, 1.0);
            tar_normal = vec3(0.0, -sin(rotat), -cos(rotat));
        }
    } else {
        if (isLeftOrBottomLonger) {
            tar_point = vec3(-1.0, -1.0, 1.0);
            tar_normal = vec3(sin(rotat), 0., -cos(rotat));
        } else {
            tar_point = vec3(1.0, 1.0, 1.0);
            tar_normal = vec3(-sin(rotat), 0., -cos(rotat));
        }
    }

    float dividend = dot(tar_normal, (tar_point - r.o));
    float divider = dot(tar_normal, r.d);
    float t = 0.0;
    vec3 col = vec3(0.0);
    vec3 hitPoint;
    vec3 text_xy_10_point;
    vec3 text_xy_11_point;
    vec3 text_xy_01_point;
    vec3 text_xy_00_point;
    float text_x_bound = 4.0;
    float text_y_bound = 4.0;
    if (abs(divider) >= 1e-6 && abs(dividend) >= 1e-6) {
        t = dividend / divider;
        hitPoint = r.o + t * r.d;
        if (isVertical) {
            if (isLeftOrBottomLonger) {
                text_xy_10_point = vec3(-1.0, thickness * 2. * cos(rotat) - 1.0, 1.0 + thickness * 2. * sin(rotat));
                text_xy_11_point = vec3(1.0, thickness * 2. * cos(rotat) - 1.0, 1.0 + thickness * 2. * sin(rotat));
                text_xy_01_point = vec3(1.0, -1.0, 1.0);
                text_xy_00_point = vec3(-1.0, -1.0, 1.0);
                text_x_bound *= thickness * thickness;
            } else {
                text_xy_10_point = vec3(-1.0, 1.0, 1.0);
                text_xy_11_point = vec3(1.0, 1.0, 1.0);
                text_xy_01_point = vec3(1.0, 1. - thickness * 2. * cos(rotat), 1.0 + thickness * 2. * sin(rotat));
                text_xy_00_point = vec3(-1.0, 1. - thickness * 2. * cos(rotat), 1.0 + thickness * 2. * sin(rotat));
                text_x_bound *= thickness * thickness;
            }
        } else {
            if (isLeftOrBottomLonger) {
                text_xy_10_point = vec3(-1.0, 1.0, 1.0);
                text_xy_11_point = vec3(thickness * 2. * cos(rotat) - 1., 1.0, 1.0 + thickness * 2. * sin(rotat));
                text_xy_01_point = vec3(thickness * 2. * cos(rotat) - 1., -1.0, 1.0 + thickness * 2. * sin(rotat));
                text_xy_00_point = vec3(-1.0, -1.0, 1.0);
                text_y_bound *= thickness * thickness;
            } else {
                text_xy_10_point = vec3(1. - thickness * 2. * cos(rotat), 1.0, 1.0 + thickness * 2. * sin(rotat));
                text_xy_11_point = vec3(1.0, 1.0, 1.0);
                text_xy_01_point = vec3(1.0, -1.0, 1.0);
                text_xy_00_point = vec3(1. - thickness * 2. * cos(rotat), -1.0, 1.0 + thickness * 2. * sin(rotat));
                text_y_bound *= thickness * thickness;
            }
        }
        float text_x = dot((hitPoint - text_xy_00_point), (text_xy_10_point - text_xy_00_point));
        float text_y = dot((hitPoint - text_xy_00_point), (text_xy_01_point - text_xy_00_point));

        if (text_x < text_x_bound && text_y < text_y_bound && text_x > 0.0 && text_y > 0.0) {
            vec2 tex_coord = vec2(text_x, text_y);
            tex_coord /= 4.0;

            // Scroll texture coordinates
            tex_coord += scroll_speed * TIME * time_multiplier;

            if (isVertical) {
                tex_coord.x /= thickness * thickness;
            } else {
                tex_coord.y /= thickness * thickness;
            }
            col = vec3(texture(TEXTURE, fract(tex_coord)).x);
        } else {
            COLOR.a = 0.0;
        }
    } else {
        COLOR.a = 0.0;
    }
    // Output to screen
    COLOR.xyz = col;
    // Called for every pixel the material is visible on.
}
