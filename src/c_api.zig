const std = @import("std");
const root = @import("root.zig");
const windows = std.os.windows;

/// C ABI compatible function to get the executable path of the currently fullscreen window
/// Returns 1 on success, 0 on failure
/// @param buffer Buffer to store the executable path
/// @param buffer_len Length of the buffer
pub export fn get_fullscreen_window_executable_path(buffer: [*c]u8, buffer_len: u32) callconv(.C) c_int {
    var zig_buffer_len: windows.DWORD = buffer_len;
    const result = root.getFullscreenWindowExecutablePath(buffer, &zig_buffer_len);

    // null termination
    if (result and zig_buffer_len < windows.MAX_PATH) {
        buffer[zig_buffer_len] = 0;
    }

    return if (result) 0 else 1;
}

/// C ABI compatible function to get the friendly name (executable filename without path) of the currently fullscreen window
/// Returns 1 on success, 0 on failure
/// @param buffer Buffer to store the friendly name
/// @param buffer_len Length of the buffer
pub export fn get_fullscreen_window_friendly_name(buffer: [*c]u8, buffer_len: u32) callconv(.C) c_int {
    var zig_buffer_len: windows.DWORD = buffer_len;
    const result = root.getFullscreenWindowFriendlyName(buffer, &zig_buffer_len);

    // null termination
    if (result and zig_buffer_len < windows.MAX_PATH) {
        buffer[zig_buffer_len] = 0;
    }

    return if (result) 0 else 1;
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
