#!/bin/bash
set -e

# Build C
mkdir -p c/build/linux
gcc c/hello.c -o c/build/linux/hello-c
strip c/build/linux/hello-c

# Build C++
mkdir -p cpp/build/linux
g++ cpp/hello.cpp -o cpp/build/linux/hello-cpp
strip cpp/build/linux/hello-cpp

# Build Rust
mkdir -p rust/build/linux
cd rust
cargo build --release --target x86_64-unknown-linux-gnu
cp target/x86_64-unknown-linux-gnu/release/hello-rust ../build/linux/
strip ../build/linux/hello-rust
cd ..

# Build Go
mkdir -p go/build/linux
cd go
GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o build/linux/hello-go hello.go
cd ..
