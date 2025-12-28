#!/bin/bash

# Super Gource Wrapper
# Builds and runs the Gource of Truth container.

IMAGE_NAME="gource-of-truth"
CONTAINER_TAG="latest"

echo "🔨 Building Image..."
podman build -t "${IMAGE_NAME}:${CONTAINER_TAG}" -f docker/Dockerfile .

if [ $? -ne 0 ]; then
    echo "❌ Build failed."
    exit 1
fi

echo "🎬 Running Gource..."
# We mount the parent directory (..) to /src so we can see all peer repos.
# We set SCAN_ROOT=/src because that's where the repos are inside the container.
# We mount local ./output to /output so results persist cleanly.
mkdir -p output
podman run --rm \
    -v "$(pwd)/..:/src:z" \
    -v "$(pwd)/output:/output:z" \
    -e SCAN_ROOT="/src" \
    -e START_DATE \
    -e RESOLUTION \
    "${IMAGE_NAME}:${CONTAINER_TAG}"

echo "✅ Done."

