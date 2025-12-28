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

# Create a script to handle the "Pseudo-Mono" merging
COPY gource-of-truth.sh /usr/local/bin/gource-of-truth.sh
RUN chmod +x /usr/local/bin/gource-of-truth.sh

ENTRYPOINT ["/usr/local/bin/gource-of-truth.sh"]
