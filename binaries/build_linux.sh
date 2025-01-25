#!/bin/bash
set -e

# Create main build directory
mkdir -p build/linux

# Build C
echo "Building C..."
gcc c/hello.c -o build/linux/hello-c
strip build/linux/hello-c

# Build C++
echo "Building C++..."
g++ cpp/hello.cpp -o build/linux/hello-cpp
strip build/linux/hello-cpp

# Build Rust
echo "Building Rust..."
cd rust
cargo build --release --target x86_64-unknown-linux-gnu
cp target/x86_64-unknown-linux-gnu/release/hello-rust ../build/linux/
strip ../build/linux/hello-rust
cd ..

# Build Go
echo "Building Go..."
cd go
GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o ../build/linux/hello-go hello.go
cd ..

# Verify outputs
echo "Build outputs:"
ls -lh build/linux/
