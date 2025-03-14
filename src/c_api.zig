const std = @import("std");
const root = @import("root.zig");
const windows = std.os.windows;

/// C ABI compatible function to get the executable path of the currently fullscreen window
/// Returns 1 on success, 0 on failure
/// @param buffer Buffer to store the executable path
/// @param buffer_len Pointer to the buffer length. On input, it should contain the buffer size.
///                   On output, it will contain the actual length of the path.
pub export fn get_fullscreen_window_executable_path(buffer: [*c]u8, buffer_len: [*c]u32) callconv(.C) i32 {
    // Convert C types to Zig types
    const zig_buffer_len = @as(*windows.DWORD, @ptrCast(buffer_len));

    // Call the Zig function
    const result = root.getFullscreenWindowExecutablePath(buffer, zig_buffer_len);

    // Convert Windows BOOL to C int (1 for success, 0 for failure)
    return if (result) 1 else 0;
}

/// C ABI compatible function to get the friendly name (executable filename without path) of the currently fullscreen window
/// Returns 1 on success, 0 on failure
/// @param buffer Buffer to store the friendly name
/// @param buffer_len Pointer to the buffer length. On input, it should contain the buffer size.
///                   On output, it will contain the actual length of the friendly name.
pub export fn get_fullscreen_window_friendly_name(buffer: [*c]u8, buffer_len: [*c]u32) callconv(.C) i32 {
    // Convert C types to Zig types
    const zig_buffer_len = @as(*windows.DWORD, @ptrCast(buffer_len));

    // Call the Zig function
    const result = root.getFullscreenWindowFriendlyName(buffer, zig_buffer_len);

    // Convert Windows BOOL to C int (1 for success, 0 for failure)
    return if (result) 1 else 0;
}

// DLL entry point for Windows
pub fn DllMain(
    hinstDLL: windows.HINSTANCE,
    fdwReason: windows.DWORD,
    lpvReserved: windows.LPVOID,
) windows.BOOL {
    _ = hinstDLL;
    _ = fdwReason;
    _ = lpvReserved;
    return windows.TRUE;
}

pub fn main() void {}
