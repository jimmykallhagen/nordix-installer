#!/bin/bash
##=====================================#
## NORDIX gaming ENVIRONMENT #
##=====================================#==========#
# Location: /etc/profile.d/nordix.sh (system-wide)
# OR: ~/.bashrc (per-user)
#
# Only verified environment variables from official documentation
#====================================================================#

#====================================================================#
#                   WINE/PROTON CORE SETTINGS
#====================================================================#

# Enable Fsync (fast synchronization)
# Requires kernel 5.16+ OR patched kernel
# Falls back to Esync automatically if Fsync is not supported
export WINEFSYNC=1

# Enable Esync (eventfd-based synchronization)
# Requires: ulimit -n 524288 (increase file descriptors)
export WINEESYNC=1

# Enable the best sync for gamnging
export PROTON_USE_NTSYNC=1

# Disable Wine debug output (performance)
export WINEDEBUG=-all

#====================================================================#
#                  PROTON SPECIFIC SETTINGS
#====================================================================#

# Test
export DISABLE_LAYER_MESA_ANTI_LAG=1
# Force Large Address Aware (32-bit games can use 4GB RAM)
export PROTON_FORCE_LARGE_ADDRESS_AWARE=1

# Use DXVK instead of WineD3D
# 0 = use DXVK (recommended)
# 1 = use WineD3D (fallback)
export PROTON_USE_WINED3D=0

# Disable Proton logging (performance)
export PROTON_LOG=

#====================================================================#
#                      DXVK CONFIGURATION
#====================================================================#

# State cache path (automatically managed by DXVK)
export DXVK_STATE_CACHE_PATH="/home/core/.cache/dxvk"

# Log path
export DXVK_LOG_PATH="/home/core/.cache/dxvk-log"

# Config file
export DXVK_CONFIG_FILE="/home/core/.config/dxvk.conf"

# HUD disabled (0=off, fps=show FPS, full=all)
export DXVK_HUD=0

# Log level (none=best performance)
export DXVK_LOG_LEVEL=none

# Filter device (empty = auto-detect)
export DXVK_FILTER_DEVICE_NAME=""

#====================================================================#
#            VKD3D CONFIGURATION (DirectX 12 → Vulkan)
#====================================================================#

# Enable features (dxr=raytracing, dxr11=DXR 1.1)
export VKD3D_CONFIG="dxr11,dxr"

# Shader cache path
export VKD3D_SHADER_CACHE_PATH="/home/core/.cache/vkd3d"

# Debug level (none for performance)
export VKD3D_DEBUG=none

#====================================================================#
#             NVIDIA SHADER CACHE (NVIDIA GPU only)
#====================================================================#

# Enable shader disk cache
#export __GL_SHADER_DISK_CACHE=1

# Cache location
#export __GL_SHADER_DISK_CACHE_PATH="$HOME/.cache/nv_shader"

# Cache size (10GB = 10737418240 bytes)
#export __GL_SHADER_DISK_CACHE_SIZE=10737418240

# Threaded optimization
#export __GL_THREADED_OPTIMIZATION=1

# Sync to VBlank (0=off, let games control)
#export __GL_SYNC_TO_VBLANK=0

# Yield behavior (NOTHING=performance)
#export __GL_YIELD="NOTHING"

#====================================================================#
#            AMD RADV/MESA CONFIGURATION (AMD GPU only)
#====================================================================#

# Performance test features
# gpl=Graphics Pipeline Library, nggc=NGG culling, sam=Smart Access Memory
export RADV_PERFTEST="gpl,nggc,sam"

# Mesa shader cache directory
export MESA_SHADER_CACHE_DIR="/home/core/.cache/mesa_shader"

# Mesa shader cache size
export MESA_SHADER_CACHE_MAX_SIZE="10G"

# Enable Mesa threaded context (OpenGL)
export mesa_glthread=true

#====================================================================#
#                       VULKAN CONFIGURATION
#====================================================================#

# ICD selection (uncomment for your GPU):
# AMD:
# export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/radeon_icd.x86_64.json
# export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/radeon_icd.x86_64.json:/usr/share/vulkan/icd.d/radeon_icd.i686.json
# NVIDIA:
# export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json
# Intel:
# export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/intel_icd.x86_64.json



#====================================================================#
#                        SDL2 CONFIGURATION
#====================================================================#

# Dynamic API (use system SDL2)
#export SDL_DYNAMIC_API=/usr/lib/libSDL2-2.0.so.0


#====================================================================#
#                       DIRECTORY CREATION
#====================================================================#

mkdir -p "/home/core/.cache/dxvk/dxvk-log" 2>/dev/null
mkdir -p "/home/core/.cache/vkd3d" 2>/dev/null
mkdir -p "/home/core/.cache/mesa_shader" 2>/dev/null
mkdir -p "/home/core/.cache/nv_shader" 2>/dev/null
