#====================================================================#
#                   NORDIX gaming ENVIRONMENT 
#====================================================================#

# Location: /etc/profile.d/nordix.sh (system-wide)
# OR: ~/.profile (per-user)
#
# Only verified environment variables from official documentation
#====================================================================#

#====================================================================#
#                   WINE/PROTON CORE SETTINGS
#       Compatibility fallbacks for older Wine/Proton versions
#====================================================================#

# Enable Fsync (fast synchronization)
# Requires kernel 5.16+ OR patched kernel
# Falls back to Esync automatically if Fsync is not supported
export WINEFSYNC=1

# Enable Esync (eventfd-based synchronization)
# Requires: ulimit -n 524288 (increase file descriptors)
export WINEESYNC=1

# Disable Wine debug output (performance)
export WINEDEBUG=-all

#====================================================================#
#                  PROTON SPECIFIC SETTINGS
#====================================================================#

# PERFORMANCE DEFAULT: Disable Proton log generation for maximum performance
export PROTON_LOG=0

# DEBUGGING & OPTIONS (Uncomment to use)
# --------------------------------------------------------------------
# To enable detailed game logging (creates ~/steam-<appid>.log), change to:
# export PROTON_LOG=1

# Note: PROTON_FORCE_LARGE_ADDRESS_AWARE and PROTON_USE_WINED3D are handled
# automatically by modern Proton releases and should not be forced globally.

#====================================================================#
#                      DXVK CONFIGURATION
#====================================================================#

# Global configuration file location
export DXVK_CONFIG_FILE="$HOME/.config/dxvk.conf"

# PERFORMANCE DEFAULT: Disable logging and HUD for best performance
export DXVK_LOG_LEVEL=none
export DXVK_HUD=0

# DEBUGGING & OPTIONS (Uncomment to use)
# --------------------------------------------------------------------
# export DXVK_LOG_LEVEL=warn               # Options: none, error, warn, info, debug
# export DXVK_LOG_PATH="$HOME/.cache/dxvk-log"
# export DXVK_HUD=fps                       # Options: 0, fps, devinfo, compiler, full
# export DXVK_FILTER_DEVICE_NAME=""         # Force a specific GPU (e.g., "AMD Radeon...")

# Note: DXVK_STATE_CACHE_PATH is intentionally left out to allow Proton/Wine 
# to isolate state caches per game prefix, preventing cache collisions.


#====================================================================#
#            VKD3D CONFIGURATION (DirectX 12 → Vulkan)
#====================================================================#
# Note: VKD3D-Proton runs in performance mode (no debug) by default.
# Shaders are automatically routed to your MESA/NVIDIA cache directories.
#
# If a user needs to enable debugging/logging, uncomment one of these:
# export VKD3D_DEBUG=err     # Log errors only (minimal overhead)
# export VKD3D_DEBUG=warn    # Log warnings and errors
export VKD3D_DEBUG=none

#====================================================================#
#          NORDIX DISRO - GPU GRAPHICS CONFIGURATION
#====================================================================#

# Detect GPU vendor ID via sysfs
if [ -d /sys/class/drm ]; then
    CURRENT_GPU=$(cat /sys/class/drm/card*/device/vendor 2>/dev/null)
fi

# AMD RADV/MESA CONFIGURATION
if echo "$CURRENT_GPU" | grep -q "0x1002"; then

#====================================================================#
#            AMD RADV/MESA CONFIGURATION (AMD GPU only)
#====================================================================#

# DISABLE ANTI-LAG (Recommended for consistent frametimes at high FPS)
#
# - At ultra-high frame rates (300+ FPS), driver-level frame pacing can
#   introduce micro-stuttering and degrade overall smoothness.
#
# - For heavy, GPU-bound AAA titles running at lower/normal frame rates
#   (60-120 FPS), you can comment out this line to enable the extension
#   and potentially reduce input latency.
#
# export vulkan_disable_extensions=VK_AMD_anti_lag

# SHADER CACHE MANAGEMENT (Optimized for ZFS dataset)
# Ensure MESA_SHADER_CACHE_DIR points to your high-performance ZFS dataset.

export MESA_SHADER_CACHE_DIR="$HOME/.cache/mesa_shader"
export MESA_SHADER_CACHE_MAX_SIZE_MB=10240
export MESA_SHADER_CACHE_DISABLE_DFR=1

fi

# NVIDIA CONFIGURATION
if echo "$CURRENT_GPU" | grep -q "0x10de"; then
#====================================================================#
#             NVIDIA SHADER CACHE (NVIDIA GPU only)
#====================================================================#

# SHADER CACHE MANAGEMENT (Optimized for ZFS dataset)
# Enable shader disk cache and set custom location (Great for ZFS datasets)
#export __GL_SHADER_DISK_CACHE=1
export __GL_SHADER_DISK_CACHE_PATH="$HOME/.cache/nv_shader"

# Set cache size limit (10GB)
export __GL_SHADER_DISK_CACHE_SIZE=10737418240

# CRITICAL: Prevent the NVIDIA driver from automatically purging your optimized cache files
export __GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1
fi


#====================================================================#
#                      Intel - None 
#====================================================================#
