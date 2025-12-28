# Use Alpine for a tiny footprint
FROM alpine:3

# Install Gource, FFmpeg, and Xvfb for headless rendering
# Also bash and sed for our log-merging logic
RUN apk add --no-cache \
    gource \
    ffmpeg \
    xvfb-run \
    xvfb \
    bash \
    sed \
    git \
    mesa-dri-gallium \
    mesa-va-gallium \
    ttf-freefont

# Set up the working directory
# We will mount your ~/git folder to /src
WORKDIR /src

# Copy configuration and scripts
# We place them in /usr/local/got so they stay together
RUN mkdir -p /usr/local/got
COPY got.conf /usr/local/got/
COPY scripts /usr/local/got/scripts/

# Make scripts executable
RUN chmod +x /usr/local/got/scripts/*.sh

# Symlink the internal runner to a simpler path if desired, or just use ENTRYPOINT
ENTRYPOINT ["/usr/local/got/scripts/internal-runner.sh"]
