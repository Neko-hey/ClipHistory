#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR"
killall ClipHistory 2>/dev/null || true
nohup ./ClipHistory > /dev/null 2>&1 &
killall Terminal 2>/dev/null || exit