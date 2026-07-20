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

# Add optional ignored directories (can be overridden by environment).
# Must be exported — `-e EXTRA_IGNORES` below passes it through from *this*
# process's environment, which a plain (non-exported) assignment never enters.
export EXTRA_IGNORES="${EXTRA_IGNORES:-github archive}"

echo "Scanning Root: $TARGET_PATH"
echo "Ignoring: $EXTRA_IGNORES"

mkdir -p output

# We mount the chosen target path to /src inside the container.
# got.conf is bind-mounted (not just baked in via the Dockerfile's COPY) so
# editing it on the host takes effect on the next run without needing a
# rebuild — removes any ambiguity about whether a rebuild actually picked up
# the edit. -t allocates a pty so Ctrl+C actually reaches the container's
# process (without it, SIGINT delivery to a non-tty podman run is unreliable —
# the client can exit while the container keeps running orphaned under conmon).
podman run --rm -t \
    -v "${TARGET_PATH}:/src:z" \
    -v "$(pwd)/output:/output:z" \
    -v "$(pwd)/got.conf:/usr/local/got/got.conf:z" \
    -e SCAN_ROOT="/src" \
    -e START_DATE \
    -e RESOLUTION \
    -e EXTRA_IGNORES \
    "${IMAGE_NAME}:${CONTAINER_TAG}"

echo "✅ Done."

