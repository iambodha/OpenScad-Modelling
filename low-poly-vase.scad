// Define the shape and size parameters for the vase
shape_type = "vase2";  // Shape of the vase
base_radius = 60;       // Base radius of the vase
spike_amplitude = 10;   // Amplitude of spikes added to the surface
num_sides = 30;         // Number of sides for the vase's base (higher = smoother)
num_levels = 15;        // Number of vertical levels for detail
twist_factor = 0.4;     // Twisting factor for the shape
vase_color = "cyan";   // Visualization color

// Module to generate the vase
module vase() {
    total_height = 180 - 180 % num_levels;  // Total height adjusted to levels
    vertical_step = floor(180 / num_levels);  // Vertical step size
    angular_step = 360 / num_sides;          // Angular step size for sides

    // Generate the vertex points
    vertex_points = [
        for (z = [0:vertical_step:total_height])
            for (i = [0:angular_step:359])
                let(
                    // Calculate radius modifier based on shape and vertical position
                    radius_modifier = (shape_type == "cylinder") ? 1 :
                                     (shape_type == "vase1") ? 0.7 + 0.4 * sin(z * 1.9) :
                                     (shape_type == "vase2") ? 0.6 + 0.4 * pow(sin(z + 60), 2) :
                                     (shape_type == "glass") ? 0.6 + 0.4 * pow(sin(z * 0.7 - 30), 2) :
                                     (shape_type == "cup1") ? 0.65 + 0.3 * cos(z * 2 + 35) :
                                     (shape_type == "cup2") ? 0.6 + 0.35 * cos(180 - z + 50) * sin(180 - z * 2.5 + 45) :
                                     (shape_type == "bowl") ? 0.6 + 0.4 * sin(z * 0.5) :
                                     cos(z * 0.5),
                    // Adjust spike size dynamically
                    dynamic_spike = ((z / vertical_step) % 2 == 1 && (i / angular_step) % 2 == 1) ? spike_amplitude * sin(z * 0.1) : 0,
                    twist = z * twist_factor, // Twisting effect
                    final_radius = dynamic_spike + radius_modifier * base_radius,  // Total radius
                    x_coord = final_radius * cos(i + twist),  // X coordinate
                    y_coord = final_radius * sin(i + twist)   // Y coordinate
                )
                [x_coord, y_coord, z]
    ];

    // Define faces to connect vertices
    face_connections = concat(
        [
            for (z = [0:(total_height / vertical_step) - 1])
                for (s = [0:num_sides - 1])
                    let(
                        bottom_left = s + num_sides * z,       // Bottom-left
                        top_left = s + num_sides * (z + 1),   // Top-left
                        top_right = ((s + 1) % num_sides) + num_sides * (z + 1), // Top-right
                        bottom_right = ((s + 1) % num_sides) + num_sides * z    // Bottom-right
                    )
                    ((s + z) % 2 == 0) ? [bottom_left, top_left, top_right] : [top_left, top_right, bottom_right]
        ],
        [
            for (z = [0:(total_height / vertical_step) - 1])
                for (s = [0:num_sides - 1])
                    let(
                        bottom_left = s + num_sides * z,
                        top_left = s + num_sides * (z + 1),
                        top_right = ((s + 1) % num_sides) + num_sides * (z + 1),
                        bottom_right = ((s + 1) % num_sides) + num_sides * z
                    )
                    ((s + z) % 2 == 0) ? [top_right, bottom_right, bottom_left] : [bottom_right, bottom_left, top_left]

        ],
        (shape_type != "cone") ? [[for (s = [num_sides - 1:-1:0]) (total_height / vertical_step) * (num_sides) + s]] : [], // Top cap
        [[for (s = [0:num_sides - 1]) s]] // Bottom cap
    );

    // Apply color and scale the vase
    color(vase_color) 
    scale([1, 1, (shape_type == "bowl") ? 0.33 : 1]) 
    polyhedron(points = vertex_points, faces = face_connections);
}

// Render the vase
vase();

