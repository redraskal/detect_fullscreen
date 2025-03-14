const std = @import("std");
const testing = std.testing;
const windows = std.os.windows;

/// https://learn.microsoft.com/en-us/windows/win32/procthread/process-security-and-access-rights
const PROCESS_QUERY_LIMITED_INFORMATION: windows.DWORD = 0x1000;

/// https://learn.microsoft.com/en-us/windows/win32/winmsg/extended-window-styles
const WS_EX_LAYERED: windows.DWORD = 0x00080000;
const WS_EX_TOOLWINDOW: windows.DWORD = 0x00000080;
const WS_EX_NOACTIVATE: windows.DWORD = 0x08000000;

const GWL_EXSTYLE: i32 = -20;
const LWA_ALPHA: windows.DWORD = 0x00000002;

/// Constants for GetWindow function
const GW_HWNDNEXT: u32 = 2;

/// Windows types not defined in std.os.windows
const COLORREF = windows.DWORD;
const BYTE = u8;

const user32 = struct {
    /// https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getwindowrect
    pub extern "user32" fn GetWindowRect(
        hwnd: windows.HWND,
        lpRect: *std.os.windows.RECT,
    ) callconv(windows.WINAPI) windows.BOOL;

    /// https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-iszoomed
    pub extern "user32" fn IsZoomed(
        hwnd: windows.HWND,
    ) callconv(windows.WINAPI) windows.BOOL;

    /// https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getwindowthreadprocessid
    pub extern "user32" fn GetWindowThreadProcessId(
        hwnd: windows.HWND,
        lpdwProcessId: *windows.DWORD,
    ) callconv(windows.WINAPI) windows.DWORD;

    /// https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getdesktopwindow
    pub extern "user32" fn GetDesktopWindow() callconv(windows.WINAPI) windows.HWND;

    /// https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getforegroundwindow
    pub extern "user32" fn GetForegroundWindow() callconv(windows.WINAPI) ?windows.HWND;

    /// https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-iswindowvisible
    pub extern "user32" fn IsWindowVisible(
        hwnd: windows.HWND,
    ) callconv(windows.WINAPI) windows.BOOL;

    /// https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getwindowlongw
    pub extern "user32" fn GetWindowLongW(
        hwnd: windows.HWND,
        nIndex: i32,
    ) callconv(windows.WINAPI) windows.LONG;

    /// https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getlayeredwindowattributes
    pub extern "user32" fn GetLayeredWindowAttributes(
        hwnd: windows.HWND,
        pcrKey: ?*COLORREF,
        pbAlpha: ?*BYTE,
        pdwFlags: ?*windows.DWORD,
    ) callconv(windows.WINAPI) windows.BOOL;

    /// https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getwindow
    pub extern "user32" fn GetWindow(
        hwnd: windows.HWND,
        uCmd: u32,
    ) callconv(windows.WINAPI) ?windows.HWND;
};

const kernel32 = struct {
    /// https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-openprocess
    pub extern "kernel32" fn OpenProcess(
        dwDesiredAccess: windows.DWORD,
        bInheritHandle: windows.BOOL,
        dwProcessId: windows.DWORD,
    ) callconv(windows.WINAPI) ?windows.HANDLE;

    /// https://learn.microsoft.com/en-us/windows/win32/api/handleapi/nf-handleapi-closehandle
    pub extern "kernel32" fn CloseHandle(
        hObject: windows.HANDLE,
    ) callconv(windows.WINAPI) windows.BOOL;

    /// https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-queryfullprocessimagenamew
    pub extern "kernel32" fn QueryFullProcessImageNameW(
        hProcess: windows.HANDLE,
        dwFlags: windows.DWORD,
        lpExeName: [*]u16,
        lpdwSize: *windows.DWORD,
    ) callconv(windows.WINAPI) windows.BOOL;
};

/// Checks if a window is fullscreen
/// Returns true if the window is fullscreen, false otherwise
pub fn isWindowFullscreen(hwnd: std.os.windows.HWND) bool {
    var windowRect: std.os.windows.RECT = undefined;
    var desktopRect: std.os.windows.RECT = undefined;

    // Check if the window is maximized
    if (user32.IsZoomed(hwnd) == std.os.windows.TRUE) {
        return true;
    }

    // Check if the window is visible
    if (user32.IsWindowVisible(hwnd) == std.os.windows.FALSE) {
        return false;
    }

    // Get window style
    const exStyle = user32.GetWindowLongW(hwnd, GWL_EXSTYLE);

    // Skip tool windows (small floating toolbars, etc.)
    if ((exStyle & WS_EX_TOOLWINDOW) != 0) {
        return false;
    }

    // Skip windows that can't be activated (usually system windows)
    if ((exStyle & WS_EX_NOACTIVATE) != 0) {
        return false;
    }

    // Check if the window is transparent
    if ((exStyle & WS_EX_LAYERED) != 0) {
        var alpha: BYTE = 0;
        var flags: windows.DWORD = 0;

        // If GetLayeredWindowAttributes succeeds and the window uses alpha blending
        if (user32.GetLayeredWindowAttributes(hwnd, null, &alpha, &flags) == windows.TRUE) {
            // If the window uses alpha blending and is mostly transparent (alpha < 128)
            if ((flags & LWA_ALPHA) != 0 and alpha < 128) {
                return false;
            }
        }
    }

    if (user32.GetWindowRect(hwnd, &windowRect) == std.os.windows.FALSE) {
        return false;
    }

    if (user32.GetWindowRect(user32.GetDesktopWindow(), &desktopRect) == std.os.windows.FALSE) {
        return false;
    }

    return windowRect.left <= desktopRect.left and
        windowRect.top <= desktopRect.top and
        windowRect.right >= desktopRect.right and
        windowRect.bottom >= desktopRect.bottom;
}

/// Finds a fullscreen window
/// Returns the window handle if found, NULL otherwise
pub fn findFullscreenWindow() ?windows.HWND {
    const foreground_hwnd = user32.GetForegroundWindow();
    if (foreground_hwnd != null and isWindowFullscreen(foreground_hwnd.?)) {
        return foreground_hwnd;
    }

    // Traverse the Z-order starting from the current window
    const hwnd = foreground_hwnd orelse user32.GetDesktopWindow();
    return traverseZOrder(hwnd);
}

fn traverseZOrder(parent: windows.HWND) ?windows.HWND {
    var hwnd = user32.GetWindow(parent, GW_HWNDNEXT);
    while (hwnd != null) {
        if (isWindowFullscreen(hwnd.?)) {
            return hwnd;
        }
        hwnd = user32.GetWindow(hwnd.?, GW_HWNDNEXT);
    }
    return null;
}

/// Gets the executable path of a window
/// Returns true if the executable path was retrieved, false otherwise
pub fn getWindowExecutablePath(hwnd: windows.HWND, buffer: [*]u8, buffer_len: *windows.DWORD) bool {
    var process_id: windows.DWORD = undefined;
    _ = user32.GetWindowThreadProcessId(hwnd, &process_id);

    const process_handle = kernel32.OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, windows.FALSE, process_id);
    if (process_handle == null) {
        return false;
    }
    defer _ = kernel32.CloseHandle(process_handle.?);

    var wide_buffer: [windows.MAX_PATH]u16 = undefined;
    var wide_size: windows.DWORD = wide_buffer.len;

    if (kernel32.QueryFullProcessImageNameW(process_handle.?, 0, &wide_buffer, &wide_size) == windows.FALSE) {
        return false;
    }

    // Convert wide string to UTF-8
    const result_len = std.unicode.utf16LeToUtf8(buffer[0..buffer_len.*], wide_buffer[0..wide_size]) catch {
        return false;
    };

    // Update the buffer length to the actual length
    buffer_len.* = @as(windows.DWORD, @intCast(result_len));

    return true;
}

/// Gets the executable path of the currently fullscreen window
/// Returns true if a fullscreen window was found and its path retrieved, false otherwise
pub fn getFullscreenWindowExecutablePath(buffer: [*]u8, buffer_len: *windows.DWORD) bool {
    const hwnd = findFullscreenWindow();

    if (hwnd == null) {
        return false;
    }

    return getWindowExecutablePath(hwnd.?, buffer, buffer_len);
}

/// Gets the friendly name (executable filename without path) of the currently fullscreen window
/// Returns true if a fullscreen window was found and its name retrieved, false otherwise
pub fn getFullscreenWindowFriendlyName(buffer: [*]u8, buffer_len: *windows.DWORD) bool {
    var path_buffer: [windows.MAX_PATH]u8 = undefined;
    var path_buffer_len: windows.DWORD = path_buffer.len;

    // Get the full executable path
    if (!getFullscreenWindowExecutablePath(&path_buffer, &path_buffer_len)) {
        return false;
    }

    const path = path_buffer[0..path_buffer_len];

    // Find last path separator
    var last_sep: usize = 0;
    for (path, 0..) |c, i| {
        if (c == '\\' or c == '/') last_sep = i + 1;
    }

    // Get filename and find truncation point
    const fname = path[last_sep..];
    var end = fname.len;
    for (fname, 0..) |c, i| {
        if (c == '-' or c == '_' or c == '.') {
            end = i;
            break;
        }
    }

    // Check buffer size and copy result
    if (buffer_len.* < end) {
        buffer_len.* = @intCast(end);
        return false;
    }

    @memcpy(buffer[0..end], fname[0..end]);
    buffer_len.* = @intCast(end);
    return true;
}

test "getFullscreenWindowExecutablePath" {
    var exe_buffer: [windows.MAX_PATH]u8 = undefined;
    var exe_buffer_len: windows.DWORD = exe_buffer.len;

    if (!getFullscreenWindowExecutablePath(&exe_buffer, &exe_buffer_len)) {
        std.debug.print("No fullscreen window found or failed to get executable path\n", .{});
        return;
    }

    const exe_path = exe_buffer[0..exe_buffer_len];
    std.debug.print("Fullscreen window executable: {s}\n", .{exe_path});
}

test "getFullscreenWindowFriendlyName" {
    var friendly_name_buffer: [windows.MAX_PATH]u8 = undefined;
    var friendly_name_buffer_len: windows.DWORD = friendly_name_buffer.len;

    if (!getFullscreenWindowFriendlyName(&friendly_name_buffer, &friendly_name_buffer_len)) {
        std.debug.print("No fullscreen window found or failed to get friendly name\n", .{});
        return;
    }

    const friendly_name = friendly_name_buffer[0..friendly_name_buffer_len];
    std.debug.print("Fullscreen window friendly name: {s}\n", .{friendly_name});
}
