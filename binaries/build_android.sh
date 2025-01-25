#!/bin/bash
set -e

# Android toolchain setup
export CC=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang
export CXX=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang++
export CARGO_TARGET_AARCH64_LINUX_ANDROID_LINKER=$CC
export PATH=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH

# Build C
mkdir -p c/build/android
$CC c/hello.c -o c/build/android/hello-c
strip c/build/android/hello-c

# Build C++
mkdir -p cpp/build/android
$CXX cpp/hello.cpp -o cpp/build/android/hello-cpp
strip cpp/build/android/hello-cpp

# Build Rust
# Build Rust
mkdir -p rust/build/android
cd rust
cargo build --release --target aarch64-linux-android
cp target/aarch64-linux-android/release/hello-rust ../build/android/
strip ../build/android/hello-rust
cd ..

# Build Go
mkdir -p go/build/android
cd go
export CGO_ENABLED=1 \
       GOOS=android \
       GOARCH=arm64 \
       CC=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang
go build -buildvcs=false -ldflags="-s -w" -o build/android/hello-go hello.go
cd ..
