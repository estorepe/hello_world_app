#!/bin/bash
NDK_HOME=~/Android/Sdk/ndk/25.1.8937393  # Update NDK path
export TOOLCHAIN=$NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64
export TARGET=aarch64-linux-android
export API=21

# Build C
$TOOLCHAIN/bin/$TARGET$API-clang binaries/c/hello.c -o binaries/c/hello-c

# Build C++
$TOOLCHAIN/bin/$TARGET$API-clang++ binaries/cpp/hello.cpp -o binaries/cpp/hello-cpp

# Build Rust
cd binaries/rust && cargo build --target aarch64-linux-android --release
cp target/aarch64-linux-android/release/hello-rust ../..

# Build Go (static binary)
CC=$TOOLCHAIN/bin/$TARGET$API-clang \
CGO_ENABLED=1 GOOS=android GOARCH=arm64 \
go build -o binaries/go/hello-go binaries/go/hello.go

# Copy Android binaries to Flutter assets
mkdir -p ../flutter_app/assets/android
cp binaries/c/hello-c binaries/cpp/hello-cpp binaries/rust/hello-rust binaries/go/hello-go ../flutter_app/assets/android/
