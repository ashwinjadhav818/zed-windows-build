# Zed Build and Update Script for Windows
# This script builds or updates Zed from source and sets up a command-line interface.

# Enable strict mode
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Configuration
$BuildDir = "$env:GITHUB_WORKSPACE"
$InstallDir = ".\zed-install"

# Function to detect architecture
function Get-Architecture {
    return "x86_64-pc-windows-msvc"
}

# Detect architecture
$arch = Get-Architecture
Write-Host "Building for architecture: $arch"

# Check/Install WASM toolchain
Write-Host "Ensuring WASM toolchain is installed..."
rustup target add wasm32-wasi

# Update Rust
rustup update

# Fetch latest stable release
Write-Host "Fetching latest stable release..."
git fetch --all --tags
$latestTag = git describe --tags --abbrev=0
git checkout $latestTag

# Build Zed
Write-Host "Building Zed... This may take a while."
$env:RUSTFLAGS = "-C target-feature=+crt-static"
cargo build --release --target $arch

# Create installation directory
New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null

# Copy built files
Copy-Item "target\$arch\release\zed.exe" -Destination $InstallDir

# Create additional required files
Copy-Item "LICENSE" -Destination $InstallDir -ErrorAction SilentlyContinue
Copy-Item "README.md" -Destination $InstallDir -ErrorAction SilentlyContinue

Write-Host "Build completed successfully" 