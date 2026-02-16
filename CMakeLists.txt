cmake_minimum_required(VERSION 3.10)

# 1. Name of your project
project(SpotifyAdMuteService LANGUAGES CXX)

# 2. Use C++17 for better string handling and modern features
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 3. Find PkgConfig (this is the tool that finds GLib/GIO)
find_package(PkgConfig REQUIRED)

# 4. Use PkgConfig to find the specific libraries
# This defines variables like GIO_LIBRARIES and GIO_INCLUDE_DIRS
pkg_check_modules(GIO REQUIRED IMPORTED_TARGET gio-2.0 glib-2.0)

# 5. Add your executable (assuming your file is named spotify_muter.cpp)
add_executable(spotify_muter spotify-muter.cpp)

# 6. Link the GIO/GLib libraries to your executable
target_link_libraries(spotify_muter PRIVATE PkgConfig::GIO)

# Optional: Print a message to confirm it found the libraries
message(STATUS "GIO include dirs: ${GIO_INCLUDE_DIRS}")
