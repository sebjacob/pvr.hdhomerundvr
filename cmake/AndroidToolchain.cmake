# ============================================================================
# AndroidToolchain.cmake
#
# Internal wrapper around the Android NDK's official CMake toolchain.
# ============================================================================

if(NOT DEFINED PVR_NDK_ROOT)

    message(FATAL_ERROR
        "PVR_NDK_ROOT must be defined before loading "
        "AndroidToolchain.cmake"
    )

endif()

set(_PVR_ANDROID_NDK_TOOLCHAIN
    "${PVR_NDK_ROOT}/build/cmake/android.toolchain.cmake"
)

if(NOT EXISTS "${_PVR_ANDROID_NDK_TOOLCHAIN}")

    message(FATAL_ERROR
        "Android NDK toolchain not found:\n"
        "  ${_PVR_ANDROID_NDK_TOOLCHAIN}"
    )

endif()

# Load Google's official Android NDK toolchain.
include("${_PVR_ANDROID_NDK_TOOLCHAIN}")
