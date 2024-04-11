shader_type spatial;
render_mode unshaded, depth_draw_never;

uniform vec4 shine_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec3 shine_direction = vec3(0.0, 1.0, 1.0);
uniform vec2 cubemap_scroll_spd = vec2(0.01, 0.02);
uniform sampler2D cubemap : source_color;
uniform float shine_speed : hint_range(0.1, 5.0) = 0.7;
uniform float shine_width : hint_range(1.0, 500.0) = 150.0;
uniform float scale_factor : hint_range(1.0, 10.0) = 3.0;
uniform float edge_feathering : hint_range(1.0, 500.0) = 50.0;
uniform float camera_influence = 1.5; // Control the influence of camera rotation

void fragment()
{
    // Transform vertex position back to world space using INV_VIEW_MATRIX for consistency in shine effect
    vec3 vertex_world_space = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
    
    // Extract Y-axis rotation from the camera's view matrix directly
    // atan2 is used for a more accurate Y-axis rotation extraction
    float camYRotation = atan(MODEL_MATRIX[0][0], -MODEL_MATRIX[0][2]);
    
    // Apply the dynamic offset based on the camera's Y-axis rotation to the shine's positioning
    float dynamic_offset = camYRotation * camera_influence;

    // Calculation for sine wave, adjusted for shine width and feathering
    float angle = dot(vertex_world_space, shine_direction) + TIME * shine_speed + dynamic_offset;
    float sine_wave = sin(angle / scale_factor) * 0.5 + 0.5;

    // Calculate the shine effect with adjustable width and soft edges
    float center = 0.5; // Center of the shine effect in the normalized range
    float start = max(center - shine_width * 0.001, 0.0); // Start of the shine effect
    float end = min(center + shine_width * 0.001, 1.0); // End of the shine effect
    float softness = edge_feathering * 0.001; // Convert edge_feathering to a value that affects the softness

    // Use smoothstep to create soft edges within the normalized sine wave
    float soft_edge = smoothstep(start - softness, start, sine_wave) * (1.0 - smoothstep(end, end + softness, sine_wave));

 	// Sample from the cubemap based on reflected direction
    vec3 reflection_vec = reflect(VERTEX, NORMAL); 
    vec3 cubemap_color = texture(cubemap, reflection_vec.xy * vec2(-0.2) + vec2(TIME*cubemap_scroll_spd.x, TIME*cubemap_scroll_spd.y)).rgb;

    // Using soft_edge for ALPHA calculation
    ALBEDO = shine_color.rgb * cubemap_color;
    ALPHA = clamp((1.0 - dot(NORMAL, VIEW)) * soft_edge * shine_color.a, 0.01, 1.0);
}