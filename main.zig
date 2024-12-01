// main.zig
const std = @import("std");

const Vtop = opaque {};

extern fn Vtop_new() *Vtop;
extern fn Vtop_delete(wrapper: *Vtop) void;
extern fn Vtop_eval(wrapper: *Vtop) void;
extern fn Vtop_set_input(wrapper: *Vtop, Vtope: u32) void;
extern fn Vtop_get_output(wrapper: *Vtop) u32;

pub fn main() !void {
    const model = Vtop_new();
    defer Vtop_delete(model);

    // Example usage
    Vtop_set_input(model, 42);
    Vtop_eval(model);
    const result = Vtop_get_output(model);

    std.debug.print("Output: {}\n", .{result});
}
