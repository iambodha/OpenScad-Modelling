// Diamond Crown Vase - A faceted vase with crystalline pattern
// Parameters for the faceted vase
height = 200;           // Total height
base_radius = 40;       // Base radius
segments = 8;           // Number of main segments
layers = 20;           // Increased layers for smoother transition
indent_factor = 0.3;    // How deep the facets go
twist_angle = 15;      // Degrees of twist per layer
neck_ratio = 0.8;      // Adjusted for smoother top
wall_thickness = 2;    // Thickness of the vase wall
color_vase = "Teal";   // Vase color
rim_height = 8;        // Height of the decorative rim

module diamond_crown_vase() {
    // Calculate points for each layer with smoothing factor
    points = [
        for(layer = [0:layers])
            let(
                layer_ratio = layer/layers,
                layer_height = height * layer_ratio,
                // Smooth transition near the top
                smooth_factor = 1 - pow(layer_ratio, 3),
                layer_radius = base_radius * (1 - (1 - neck_ratio) * pow(layer_ratio, 1.5)),
                layer_twist = layer * twist_angle * smooth_factor
            )
            for(seg = [0:segments-1])
                let(
                    angle = 360 * seg / segments + layer_twist,
                    // Gradual reduction of indentation near top
                    current_indent = indent_factor * smooth_factor,
                    radius_mod = layer_radius * (1 - current_indent * abs(sin(angle * 2))),
                    x = radius_mod * cos(angle),
                    y = radius_mod * sin(angle),
                    z = layer_height
                )
                [x, y, z]
    ];

    // Generate faces with improved topology
    faces = concat(
        // Side faces
        [
            for(layer = [0:layers-1])
                for(seg = [0:segments-1])
                    let(
                        current = layer * segments + seg,
                        next = layer * segments + ((seg + 1) % segments),
                        above_current = (layer + 1) * segments + seg,
                        above_next = (layer + 1) * segments + ((seg + 1) % segments)
                    )
                    each [
                        [current, next, above_next],
                        [current, above_next, above_current]
                    ]
        ],
        // Bottom cap
        [[for(seg = [segments-1:-1:0]) seg]],
        // Top cap with improved vertex ordering
        [[for(seg = [0:segments-1]) layers * segments + seg]]
    );

    // Create hollow vase with improved wall generation
    module hollow_vase() {
        difference() {
            // Outer shell
            polyhedron(
                points = points,
                faces = faces,
                convexity = 10
            );
            
            // Inner shell with smooth transition
            translate([0, 0, -1])
            scale([(base_radius - wall_thickness)/base_radius, 
                   (base_radius - wall_thickness)/base_radius, 
                   1.01])
            polyhedron(
                points = points,
                faces = faces,
                convexity = 10
            );
            
            // Flat bottom
            translate([0, 0, -1])
            cube([base_radius * 3, base_radius * 3, 2], center=true);
        }
    }

    // Improved decorative rim design
    module crown_rim() {
        translate([0, 0, height - rim_height]) {
            difference() {
                // Outer rim
                union() {
                    // Main rim body
                    cylinder(
                        r1 = base_radius * neck_ratio + 2,
                        r2 = base_radius * neck_ratio + 3,
                        h = rim_height * 0.7,
                        $fn = segments * 4
                    );
                    // Decorative top lip
                    translate([0, 0, rim_height * 0.7])
                    cylinder(
                        r1 = base_radius * neck_ratio + 3,
                        r2 = base_radius * neck_ratio + 1,
                        h = rim_height * 0.3,
                        $fn = segments * 4
                    );
                }
                // Inner hollow
                translate([0, 0, -1])
                cylinder(
                    r = base_radius * neck_ratio - wall_thickness,
                    h = rim_height + 2,
                    $fn = segments * 4
                );
            }
        }
    }

    // Render complete vase
    color(color_vase) {
        hollow_vase();
        crown_rim();
    }
}

// Render the Diamond Crown Vase
diamond_crown_vase();