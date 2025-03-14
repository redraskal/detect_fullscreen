#ifndef DETECT_FULLSCREEN_H
#define DETECT_FULLSCREEN_H

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Gets the executable path of the currently fullscreen window.
 * 
 * @param buffer Buffer to store the executable path
 * @param buffer_len Length of the buffer
 * @return 0 on success, 1 on failure
 */
int get_fullscreen_window_executable_path(char* buffer, unsigned int buffer_len);

/**
 * Gets the friendly name (executable filename without path) of the currently fullscreen window.
 * 
 * @param buffer Buffer to store the friendly name
 * @param buffer_len Length of the buffer
 * @return 0 on success, 1 on failure
 */
int get_fullscreen_window_friendly_name(char* buffer, unsigned int buffer_len);

#ifdef __cplusplus
}
#endif

#endif /* DETECT_FULLSCREEN_H */ 
