#!/bin/bash

# Remove directories if they exist
for dir in logs build install; do
  if [ -d "$dir" ]; then
    echo "Removing directory: $dir"
    rm -rf "$dir"
  else
    echo "Directory does not exist: $dir"
  fi
done