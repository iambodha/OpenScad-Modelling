// Parameters for the ripple vase
base_radius = 50;        // Base radius
height = 200;            // Total height
wall_thickness = 2;      // Wall thickness
ripple_frequency = 3;    // Frequency of ripples
wave_height = 8;         // Height of waves
segments = 60;           // Number of segments (smoothness)
vertical_segments = 40;  // Number of vertical segments
ripple_phase = 2;       // Phase shift for ripple pattern
color_vase = "PaleGreen"; // Vase color

module ripple_vase() {
    points = [
        for(h = [0:height/vertical_segments:height])
            for(a = [0:360/segments:359])
                let(
                    // Create complex ripple pattern
                    radius_mod = base_radius + 
                        wave_height * sin(h * ripple_frequency + a * ripple_phase) * 
                        (1 - pow(h/height, 2)) +  // Taper towards top
                        wave_height/2 * cos(a * 3 + h * 2),  // Additional wave pattern
                    
                    // Calculate coordinates
                    x = radius_mod * cos(a),
                    y = radius_mod * sin(a),
                    z = h
                )
                [x, y, z]
    ];

    // Generate faces
    faces = concat(
        // Side faces
        [
            for(v = [0:vertical_segments-1])
                for(h = [0:segments-1])
                    let(
                        current = v * segments + h,
                        next = v * segments + ((h + 1) % segments),
                        above_current = (v + 1) * segments + h,
                        above_next = (v + 1) * segments + ((h + 1) % segments)
                    )
                    each [
                        [current, next, above_next],
                        [current, above_next, above_current]
                    ]
        ],
        // Bottom cap
        [[for(h = [segments-1:-1:0]) h]],
        // Top cap
        [[for(h = [0:segments-1]) vertical_segments * segments + h]]
    );

    // Create inner shell for hollow vase
    module hollow_vase() {
        difference() {
            // Outer shell
            polyhedron(
                points = points,
                faces = faces,
                convexity = 10
            );
            
            // Inner shell (scaled down)
            translate([0, 0, -1])
            scale([(base_radius - wall_thickness)/base_radius, 
                   (base_radius - wall_thickness)/base_radius, 
                   1.02])
            polyhedron(
                points = points,
                faces = faces,
                convexity = 10
            );
            
            // Flatten bottom
            translate([0, 0, -1])
            cube([base_radius * 3, base_radius * 3, 2], center=true);
        }
    }

    // Render the vase
    color(color_vase)
    hollow_vase();
}

// Render the vase
ripple_vase();