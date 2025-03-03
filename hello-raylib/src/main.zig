const std = @import("std");
const rl = @import("raylib");

const Pages = enum {
    hello,
    lorem_ipsum,
};

fn render_hello_page() !void {
    rl.clearBackground(rl.Color.dark_gray);
    rl.drawText("Hello Raylib!", 16, 16, 100, rl.Color.yellow);
}

fn render_lorem_ipsum_page() !void {
    rl.clearBackground(rl.Color.dark_gray);
    rl.drawText("Lorem ipsum dolor sit amet", 16, 16, 36, rl.Color.yellow);
}

pub fn main() !void {
    rl.initWindow(800, 400, "Hello Clay With Zig");
    defer rl.closeWindow();

    var current_page: Pages = .hello;

    while (!rl.windowShouldClose()) {
        switch (current_page) {
            .hello => {
                if (rl.isKeyPressed(.space) or rl.isGestureDetected(.doubletap)) {
                    current_page = .lorem_ipsum;
                }
            },
            .lorem_ipsum => {
                if (rl.isKeyPressed(.space)) {
                    current_page = .hello;
                }
            },
        }

        {
            rl.beginDrawing();
            defer rl.endDrawing();

            switch (current_page) {
                .hello => try render_hello_page(),
                .lorem_ipsum => try render_lorem_ipsum_page(),
            }
        }
    }
}
