# ============================================================================
# AndroidNDK.cmake
#
# Downloads and manages the pinned Android NDK used by this project.
# ============================================================================

include_guard(GLOBAL)

set(PVR_NDK_VERSION
    "27.3.13750724"
    CACHE STRING
    "Android NDK version"
)

set(PVR_NDK_REVISION
    "r27d"
    CACHE STRING
    "Android NDK revision"
)

set(PVR_NDK_ROOT
    "${CMAKE_SOURCE_DIR}/.toolchains/android-ndk-${PVR_NDK_REVISION}"
    CACHE PATH
    "Local Android NDK installation directory"
)

set(PVR_NDK_ARCHIVE
    "${CMAKE_BINARY_DIR}/android-ndk-${PVR_NDK_REVISION}-linux.zip"
)

set(PVR_NDK_URL
    "https://dl.google.com/android/repository/android-ndk-${PVR_NDK_REVISION}-linux.zip"
)

# Official SHA-1 published by Google for r27d Linux.
set(PVR_NDK_SHA1
    "22105e410cf29afcf163760cc95522b9fb981121"
)

set(PVR_NDK_TOOLCHAIN
    "${PVR_NDK_ROOT}/build/cmake/android.toolchain.cmake"
)

# ----------------------------------------------------------------------------
# Already installed?
# ----------------------------------------------------------------------------

if(EXISTS "${PVR_NDK_TOOLCHAIN}")

    message(STATUS
        "Android NDK ${PVR_NDK_REVISION} already installed:"
    )

    message(STATUS
        "  ${PVR_NDK_ROOT}"
    )

    set(PVR_NDK_FOUND TRUE)

    return()

endif()

# ----------------------------------------------------------------------------
# Host requirements
# ----------------------------------------------------------------------------

if(NOT CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")

    message(FATAL_ERROR
        "Automatic NDK bootstrap currently supports Linux hosts only.\n"
        "Detected host: ${CMAKE_HOST_SYSTEM_NAME}"
    )

endif()

# ----------------------------------------------------------------------------
# Download
# ----------------------------------------------------------------------------

message(STATUS "")
message(STATUS "Android NDK ${PVR_NDK_REVISION} is not installed.")
message(STATUS "Downloading:")
message(STATUS "  ${PVR_NDK_URL}")
message(STATUS "")

file(DOWNLOAD

    "${PVR_NDK_URL}"

    "${PVR_NDK_ARCHIVE}"

    SHOW_PROGRESS

    EXPECTED_HASH
        "SHA1=${PVR_NDK_SHA1}"

    STATUS
        PVR_NDK_DOWNLOAD_STATUS

    LOG
        PVR_NDK_DOWNLOAD_LOG
)

list(GET PVR_NDK_DOWNLOAD_STATUS 0
    PVR_NDK_DOWNLOAD_RESULT
)

if(NOT PVR_NDK_DOWNLOAD_RESULT EQUAL 0)

    message(FATAL_ERROR
        "Android NDK download failed.\n\n"
        "URL:\n"
        "  ${PVR_NDK_URL}\n\n"
        "Status:\n"
        "  ${PVR_NDK_DOWNLOAD_STATUS}\n\n"
        "Log:\n"
        "  ${PVR_NDK_DOWNLOAD_LOG}"
    )

endif()

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

message(STATUS "")
message(STATUS "Extracting Android NDK ${PVR_NDK_REVISION}...")
message(STATUS "")

file(MAKE_DIRECTORY
    "${CMAKE_SOURCE_DIR}/.toolchains"
)

execute_process(

    COMMAND
        "${CMAKE_COMMAND}"
        -E
        tar
        xvf
        "${PVR_NDK_ARCHIVE}"

    WORKING_DIRECTORY
        "${CMAKE_SOURCE_DIR}/.toolchains"

    RESULT_VARIABLE
        PVR_NDK_EXTRACT_RESULT
)

if(NOT PVR_NDK_EXTRACT_RESULT EQUAL 0)

    message(FATAL_ERROR
        "Failed to extract Android NDK.\n"
        "Archive:\n"
        "  ${PVR_NDK_ARCHIVE}"
    )

endif()

# ----------------------------------------------------------------------------
# Validate extraction
# ----------------------------------------------------------------------------

if(NOT EXISTS "${PVR_NDK_TOOLCHAIN}")

    message(FATAL_ERROR
        "NDK extraction completed but the Android CMake toolchain "
        "was not found.\n\n"
        "Expected:\n"
        "  ${PVR_NDK_TOOLCHAIN}"
    )

endif()

message(STATUS "")
message(STATUS "Android NDK installed successfully:")
message(STATUS "  ${PVR_NDK_ROOT}")
message(STATUS "")

set(PVR_NDK_FOUND TRUE)
