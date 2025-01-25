#!/bin/bash
# Build C
gcc binaries/c/hello.c -o binaries/c/hello-c

# Build C++
g++ binaries/cpp/hello.cpp -o binaries/cpp/hello-cpp

# Build Rust
cd binaries/rust && cargo build --release
cp target/release/hello-rust ../..

# Build Go
GOOS=linux GOARCH=amd64 go build -o binaries/go/hello-go binaries/go/hello.go

# Copy Linux binaries to Flutter assets
mkdir -p ../flutter_app/assets/linux
cp binaries/c/hello-c binaries/cpp/hello-cpp binaries/rust/hello-rust binaries/go/hello-go ../flutter_app/assets/linux/
