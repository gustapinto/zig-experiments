const std = @import("std");
const cl = @import("clay");
const rl = @import("raylib");
const renderer = @import("clay_renderer");

const Pages = enum {
    home,
    lorem_ipsum,
};

fn cl_container() bool {
    return cl.open(.{
        .layout = .{
            .direction = .top_to_bottom,
            .sizing = cl.Sizing.grow,
            .padding = cl.Padding.all(16),
            .child_gap = 16,
        },
        .rectangle = .{
            .color = cl.Color.dark_gray,
        },
    });
}

fn cl_title_box(resize: bool) bool {
    const h = if (resize) cl.SizingAxis.grow else cl.SizingAxis.fixed(60);

    return cl.open(.{
        .layout = .{
            .sizing = .{
                .w = cl.SizingAxis.grow,
                .h = h,
            },
            .padding = cl.Padding.all(16),
            .child_gap = 16,
            .alignment = .center_center,
        },
        .rectangle = .{
            .color = cl.Color.yellow,
            .corner_radius = cl.CornerRadius.all(16),
        },
    });
}

fn render_home_page() !void {
    if (cl_container()) {
        defer cl.close();

        if (cl_title_box(false)) {
            defer cl.close();

            cl.text("Hello Clay!", .{
                .font_size = 32,
                .text_color = cl.Color.dark_gray,
            });
        }
    }
}

fn render_lorem_ipsum_page() !void {
    if (cl_container()) {
        defer cl.close();

        if (cl_title_box(true)) {
            defer cl.close();

            cl.text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis mollis elementum dignissim. Donec dui orci, rutrum aliquam enim a, auctor ullamcorper nunc. Praesent neque velit, congue eu arcu et, dapibus imperdiet arcu. Nam egestas enim eget dolor mollis, id dictum arcu varius. Vestibulum vehicula volutpat convallis. Morbi id orci nec nunc ornare rhoncus. Morbi massa elit, tempus id pretium vel, euismod vel eros. Etiam libero mi, auctor non metus blandit, auctor vestibulum odio. Nulla urna velit, vulputate ac dui at, egestas laoreet metus. Curabitur nisl tortor, vulputate et ornare vel, fringilla et ligula. Curabitur eu consequat sapien.\n\nMorbi tincidunt est lacus, ut tristique ante lacinia ut. Fusce vel nisl enim. Mauris eu rhoncus velit, volutpat ullamcorper mauris. Proin vitae odio vitae massa pretium commodo. Etiam sed felis ac enim malesuada malesuada ut vel magna. Praesent elementum lorem sed laoreet venenatis. Etiam eleifend et lacus id ultrices. Vivamus vitae mauris eu ipsum tempor dapibus. Pellentesque dapibus arcu vel felis bibendum tincidunt. Proin nec dictum ante, et consequat urna.", .{
                .font_size = 24,
                .text_color = cl.Color.dark_gray,
            });
        }
    }
}

pub fn main() !void {
    // Inicializa a biblioteca Raylib (renderização)
    rl.setConfigFlags(.{
        .window_resizable = true,
        .window_highdpi = true,
        .msaa_4x_hint = true,
        .vsync_hint = true,
    });
    rl.setTraceLogLevel(.all);
    rl.initWindow(1024, 768, "Hello Clay!");
    defer rl.closeWindow();

    // Inicializa alocadores de memória
    const alloc = std.heap.page_allocator;
    const clay_memory = try alloc.alloc(u8, cl.minMemorySize());
    defer alloc.free(clay_memory);

    const clay_arena = cl.Arena.init(clay_memory);
    var frame_arena = std.heap.ArenaAllocator.init(alloc);
    defer frame_arena.deinit();

    // Inicializa a biblioteca Clay
    cl.initialize(clay_arena, .{
        .w = @floatFromInt(rl.getScreenWidth()),
        .h = @floatFromInt(rl.getScreenHeight()),
    }, .{});
    cl.setMeasureTextFunction(renderer.measureText);

    // Configura fonte
    renderer.fonts[0] = rl.cdef.LoadFontEx("assets/fonts/Roboto-Regular.ttf", 48, 0, 400);
    rl.setTextureFilter(renderer.fonts[0].?.texture, .bilinear);

    var current_page: Pages = .home;

    while (!rl.windowShouldClose()) {
        cl.setLayoutDimensions(.{
            .w = @floatFromInt(rl.getScreenWidth()),
            .h = @floatFromInt(rl.getScreenHeight()),
        });

        const mousePosition = rl.getMousePosition();
        const scrollDelta = rl.getMouseWheelMoveV();
        cl.setPointerState(mousePosition, rl.isMouseButtonDown(.left));
        cl.updateScrollContainers(true, scrollDelta, rl.getFrameTime());

        // Toggle the inspector with spacebar
        if (rl.isKeyPressed(.space)) {
            cl.setDebugModeEnabled(!cl.isDebugModeEnabled());
        }

        cl.beginLayout();

        switch (current_page) {
            .home => {
                if (rl.isKeyPressed(.enter)) {
                    current_page = .lorem_ipsum;
                }
            },
            .lorem_ipsum => {
                if (rl.isKeyPressed(.enter)) {
                    current_page = .home;
                }
            },
        }

        switch (current_page) {
            .home => try render_home_page(),
            .lorem_ipsum => try render_lorem_ipsum_page(),
        }

        const render_commands = cl.endLayout();

        rl.beginDrawing();
        rl.clearBackground(rl.Color.black);
        renderer.render(render_commands, frame_arena.allocator());
        rl.endDrawing();

        _ = frame_arena.reset(.retain_capacity);
    }
}
