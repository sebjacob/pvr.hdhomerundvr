# ============================================================================
# pvr.hdhomerundvr Android CMake bootstrap
#
# Usage:
#
#   cmake -P bootstrap/android.cmake
#
# Optional:
#
#   cmake -P bootstrap/android.cmake \
#       -DPVR_ANDROID_ABI=arm64-v8a \
#       -DPVR_ANDROID_API=21
#
# ============================================================================

cmake_minimum_required(VERSION 3.22)

# ============================================================================
# Configuration
# ============================================================================

if(NOT DEFINED PVR_ANDROID_ABI)

    set(PVR_ANDROID_ABI
        "arm64-v8a"
    )

endif()

if(NOT DEFINED PVR_ANDROID_API)

    set(PVR_ANDROID_API
        "21"
    )

endif()

set(PVR_NDK_REVISION
    "r27d"
)

set(PVR_NDK_VERSION
    "27.3.13750724"
)

set(PROJECT_ROOT
    "${CMAKE_CURRENT_LIST_DIR}/.."
)

get_filename_component(
    PROJECT_ROOT
    "${PROJECT_ROOT}"
    ABSOLUTE
)

set(NDK_ROOT
    "${PROJECT_ROOT}/.toolchains/android-ndk-${PVR_NDK_REVISION}"
)

set(NDK_TOOLCHAIN
    "${NDK_ROOT}/build/cmake/android.toolchain.cmake"
)

set(BUILD_DIR
    "${PROJECT_ROOT}/.build/android-${PVR_ANDROID_ABI}"
)

# ============================================================================
# Download NDK
#
# This section deliberately uses CMake's standalone scripting mode.
# ============================================================================

if(NOT EXISTS "${NDK_TOOLCHAIN}")

    message(STATUS "")
    message(STATUS "============================================================")
    message(STATUS " Android NDK bootstrap")
    message(STATUS "============================================================")
    message(STATUS "Revision: ${PVR_NDK_REVISION}")
    message(STATUS "Version:  ${PVR_NDK_VERSION}")
    message(STATUS "Target:   ${PVR_ANDROID_ABI}")
    message(STATUS "API:      ${PVR_ANDROID_API}")
    message(STATUS "")
    message(STATUS "Downloading NDK...")

    set(NDK_URL
        "https://dl.google.com/android/repository/android-ndk-${PVR_NDK_REVISION}-linux.zip"
    )

    set(NDK_ARCHIVE
        "${PROJECT_ROOT}/.toolchains/android-ndk-${PVR_NDK_REVISION}-linux.zip"
    )

    set(NDK_SHA1
        "22105e410cf29afcf163760cc95522b9fb981121"
    )

    file(MAKE_DIRECTORY
        "${PROJECT_ROOT}/.toolchains"
    )

    file(DOWNLOAD

        "${NDK_URL}"

        "${NDK_ARCHIVE}"

        SHOW_PROGRESS

        EXPECTED_HASH
            "SHA1=${NDK_SHA1}"

        STATUS
            DOWNLOAD_STATUS
    )

    list(GET DOWNLOAD_STATUS 0
        DOWNLOAD_RESULT
    )

    if(NOT DOWNLOAD_RESULT EQUAL 0)

        message(FATAL_ERROR
            "Failed to download Android NDK.\n\n"
            "URL:\n"
            "  ${NDK_URL}\n\n"
            "Status:\n"
            "  ${DOWNLOAD_STATUS}"
        )

    endif()

    message(STATUS "Extracting NDK...")

    execute_process(

        COMMAND
            "${CMAKE_COMMAND}"
            -E
            tar
            xvf
            "${NDK_ARCHIVE}"

        WORKING_DIRECTORY
            "${PROJECT_ROOT}/.toolchains"

        RESULT_VARIABLE
            EXTRACT_RESULT
    )

    if(NOT EXTRACT_RESULT EQUAL 0)

        message(FATAL_ERROR
            "Failed to extract Android NDK."
        )

    endif()

endif()

# ============================================================================
# Verify NDK
# ============================================================================

if(NOT EXISTS "${NDK_TOOLCHAIN}")

    message(FATAL_ERROR
        "Android NDK installation is incomplete.\n\n"
        "Expected:\n"
        "  ${NDK_TOOLCHAIN}"
    )

endif()

# ============================================================================
# Configure actual project
# ============================================================================

message(STATUS "")
message(STATUS "============================================================")
message(STATUS " Configuring pvr.hdhomerundvr")
message(STATUS "============================================================")
message(STATUS "ABI:       ${PVR_ANDROID_ABI}")
message(STATUS "API:       ${PVR_ANDROID_API}")
message(STATUS "NDK:       ${NDK_ROOT}")
message(STATUS "Build dir: ${BUILD_DIR}")
message(STATUS "")

file(MAKE_DIRECTORY
    "${BUILD_DIR}"
)

# ============================================================================
# Invoke real CMake configuration
# ============================================================================

execute_process(

    COMMAND
        "${CMAKE_COMMAND}"

        -S
        "${PROJECT_ROOT}"

        -B
        "${BUILD_DIR}"

        -DCMAKE_TOOLCHAIN_FILE=${NDK_TOOLCHAIN}

        -DANDROID_ABI=${PVR_ANDROID_ABI}

        -DANDROID_PLATFORM=android-${PVR_ANDROID_API}

        -DCMAKE_BUILD_TYPE=Release

    RESULT_VARIABLE
        CONFIGURE_RESULT
)

if(NOT CONFIGURE_RESULT EQUAL 0)

    message(FATAL_ERROR
        "CMake configuration failed."
    )

endif()

# ============================================================================
# Build
# ============================================================================

message(STATUS "")
message(STATUS "============================================================")
message(STATUS " Building pvr.hdhomerundvr")
message(STATUS "============================================================")
message(STATUS "")

execute_process(

    COMMAND
        "${CMAKE_COMMAND}"

        --build
        "${BUILD_DIR}"

        --parallel

    RESULT_VARIABLE
        BUILD_RESULT
)

if(NOT BUILD_RESULT EQUAL 0)

    message(FATAL_ERROR
        "Build failed."
    )

endif()

# ============================================================================
# Success
# ============================================================================

message(STATUS "")
message(STATUS "============================================================")
message(STATUS " BUILD COMPLETE")
message(STATUS "============================================================")
message(STATUS "")
message(STATUS
    "Library:"
)
message(STATUS
    "  ${PROJECT_ROOT}/out/android-${PVR_ANDROID_ABI}/libhdhomerundvr.so"
)
message(STATUS "")
