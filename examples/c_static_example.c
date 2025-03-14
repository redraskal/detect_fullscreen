#include <stdio.h>
#include <windows.h>
#include "detect_fullscreen.h"

int main() {
    char buffer[MAX_PATH];
    unsigned int buffer_len = MAX_PATH;
    
    int result = get_fullscreen_window_executable_path(buffer, &buffer_len);
    if (result) {
        printf("Fullscreen window found: %s\n", buffer);
    } else {
        printf("No fullscreen window found or error occurred\n");
    }
    
    // Try the friendly name function as well
    char friendly_buffer[MAX_PATH];
    unsigned int friendly_buffer_len = MAX_PATH;
    
    result = get_fullscreen_window_friendly_name(friendly_buffer, &friendly_buffer_len);
    if (result) {
        printf("Fullscreen window friendly name: %s\n", friendly_buffer);
    } else {
        printf("Could not get friendly name\n");
    }
    
    return 0;
} 