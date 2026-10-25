
shader_type canvas_item;

uniform float blur_strength : hint_range(0.0, 5.0, 0.1) = 1.3;

void fragment() {
    vec4 color = vec4(0.0);
    vec2 pixel = TEXTURE_PIXEL_SIZE * blur_strength;

    color += texture(TEXTURE, UV + vec2(-2.0, -2.0) * pixel) * 0.0625;
    color += texture(TEXTURE, UV + vec2( 0.0, -2.0) * pixel) * 0.125;
    color += texture(TEXTURE, UV + vec2( 2.0, -2.0) * pixel) * 0.0625;

    color += texture(TEXTURE, UV + vec2(-2.0,  0.0) * pixel) * 0.125;
    color += texture(TEXTURE, UV) * 0.25;
    color += texture(TEXTURE, UV + vec2( 2.0,  0.0) * pixel) * 0.125;

    color += texture(TEXTURE, UV + vec2(-2.0,  2.0) * pixel) * 0.0625;
    color += texture(TEXTURE, UV + vec2( 0.0,  2.0) * pixel) * 0.125;
    color += texture(TEXTURE, UV + vec2( 2.0,  2.0) * pixel) * 0.0625;

    COLOR = color;
}
