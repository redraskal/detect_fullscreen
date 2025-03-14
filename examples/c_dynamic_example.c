#include <stdio.h>
#include <windows.h>
#include "detect_fullscreen.h"

// Function pointer types for dynamic loading
typedef int (*GetFullscreenWindowExecutablePathFunc)(char*, unsigned int);
typedef int (*GetFullscreenWindowFriendlyNameFunc)(char*, unsigned int);

int main() {
    HMODULE dll = LoadLibrary("detect_fullscreen.dll");
    if (dll == NULL) {
        printf("Failed to load DLL\n");
        return 1;
    }
    
    // Get executable path function
    GetFullscreenWindowExecutablePathFunc get_path_func = 
        (GetFullscreenWindowExecutablePathFunc)GetProcAddress(dll, "get_fullscreen_window_executable_path");
    
    if (get_path_func == NULL) {
        printf("Failed to get executable path function address\n");
        FreeLibrary(dll);
        return 1;
    }
    
    char buffer[MAX_PATH];
    
    int result = get_path_func(buffer, MAX_PATH);
    if (result == 0) {
        printf("Fullscreen window found: %s\n", buffer);
    } else {
        printf("No fullscreen window found or error occurred\n");
    }
    
    // Get friendly name function
    GetFullscreenWindowFriendlyNameFunc get_name_func = 
        (GetFullscreenWindowFriendlyNameFunc)GetProcAddress(dll, "get_fullscreen_window_friendly_name");
    
    if (get_name_func == NULL) {
        printf("Failed to get friendly name function address\n");
        FreeLibrary(dll);
        return 1;
    }
    
    char friendly_buffer[MAX_PATH];
    
    result = get_name_func(friendly_buffer, MAX_PATH);
    if (result == 0) {
        printf("Fullscreen window friendly name: %s\n", friendly_buffer);
    } else {
        printf("Could not get friendly name\n");
    }
    
    FreeLibrary(dll);
    
    return 0;
} 