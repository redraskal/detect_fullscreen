# detect_fullscreen

A Zig library for detecting fullscreen applications on Windows. This library provides functions to find fullscreen windows and get their executable paths and friendly names.

## Installation

`zig fetch --save "git+https://github.com/redraskal/detect_fullscreen#v1.0.0"`

```zig
const std = @import("std");
const detect_fullscreen = @import("detect_fullscreen");

pub fn main() !void {
    var buffer: [std.os.windows.MAX_PATH]u8 = undefined;
    var buffer_len: std.os.windows.DWORD = buffer.len;

    if (detect_fullscreen.getFullscreenWindowExecutablePath(&buffer, &buffer_len)) {
        const exe_path = buffer[0..buffer_len];
        std.debug.print("Fullscreen window found: {s}\n", .{exe_path});
    } else {
        std.debug.print("No fullscreen window found\n", .{});
    }
}
```

## Building

To build the static and dynamic libraries:

```bash
zig build
```

See the [examples](examples/) folder for more info.

To run tests:

```bash
zig build test
```
