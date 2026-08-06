#!/bin/bash
set -e

APP_NAME="ClipHistory"
rm -f "${APP_NAME}"

# コンパイル
clang++ -std=c++17 \
    -framework Cocoa \
    -framework ApplicationServices \
    -framework Carbon \
    main.mm -o "${APP_NAME}"

echo "ok"