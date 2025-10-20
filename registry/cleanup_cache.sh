#!/bin/bash

CACHE_DIR="./cache/docker/registry/v2/blobs/sha256"
MAX_SIZE_GB=10

used=$(du -s --block-size=1G "$CACHE_DIR" | cut -f1)

echo "[cleanup] Used: ${used} GB / Max: ${MAX_SIZE_GB} GB"

if (( used > MAX_SIZE_GB )); then
  echo "[cleanup] Cache exceeds limit. Cleaning..."
  find "$CACHE_DIR" -type f -printf '%T@ %p\n' | sort -n | head -n 1000 | cut -d' ' -f2- | xargs rm -f
  echo "[cleanup] Done."
else
  echo "[cleanup] No action needed."
fi
