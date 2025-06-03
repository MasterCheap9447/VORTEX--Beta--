shader_type particles;


uniform sampler2D blood_texture : hint_albedo;
uniform vec4 blood_color : source_color = vec4(1.0, 0.1, 0.1, 1.0); // ULTRAKILL red
uniform float alpha_cutoff = 0.5;
uniform float pixel_size = 0.0; // Set to >0 to enable pixelation

void fragment() {
    vec2 uv = UV;

    // Optional pixelation effect
    if (pixel_size > 0.0) {
        uv = floor(uv * pixel_size) / pixel_size;
    }

    // Sample blood texture (chunky sprite)
    vec4 tex_color = texture(blood_texture, uv);
    
    // Combine with blood color
    vec4 final_color = tex_color * blood_color;

    // Fade out based on lifetime
    float age = TIME / LIFETIME;
    final_color.a *= 1.0 - age;

    // Hard alpha clip (like ULTRAKILL)
    if (final_color.a < alpha_cutoff) {
        discard;
    }

    COLOR = final_color;
}