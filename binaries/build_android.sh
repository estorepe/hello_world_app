#!/bin/bash
set -e

# Create main build directory
mkdir -p build/android

# Android toolchain setup
export CC=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang
export CXX=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang++
export PATH=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH

# Build C
echo "Building C..."
$CC c/hello.c -o build/android/hello-c
$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-strip build/android/hello-c

# Build C++
echo "Building C++..."
$CXX cpp/hello.cpp -o build/android/hello-cpp
$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-strip build/android/hello-cpp

# Build Rust
echo "Building Rust..."
cd rust
cargo build --release --target aarch64-linux-android
cp target/aarch64-linux-android/release/hello-rust ../build/android/
$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-strip ../build/android/hello-rust
cd ..

# Build Go
echo "Building Go..."
cd go
export CGO_ENABLED=1 \
       GOOS=android \
       GOARCH=arm64 \
       CC=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang
go build -buildvcs=false -ldflags="-s -w" -o ../build/android/hello-go hello.go
cd ..

# Verify outputs
echo "Build outputs:"
ls -lh build/android/
