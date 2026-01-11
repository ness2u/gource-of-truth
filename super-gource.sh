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

# Determine the scan target (absolute path)
TARGET_INPUT="${1:-../../}"
TARGET_PATH="$(cd "$TARGET_INPUT" && pwd)"

echo "Scanning Root: $TARGET_PATH"

mkdir -p output

# We mount the chosen target path to /src inside the container
podman run --rm \
    -v "${TARGET_PATH}:/src:z" \
    -v "$(pwd)/output:/output:z" \
    -e SCAN_ROOT="/src" \
    -e START_DATE \
    -e RESOLUTION \
    "${IMAGE_NAME}:${CONTAINER_TAG}"

echo "✅ Done."

