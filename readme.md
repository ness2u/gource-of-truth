# Gource of Truth

> **"Ex Diversis, Unum Gource"** (From many, one Gource)

The **Gource of Truth** is the definitive, ego-driven visualization of a fragmented digital empire. It collapses a lifetime of scattered git repositories into a single, cinematic "pseudo-monorepo" reality. This is a visual reckoning—a fluid-motion proof of work that harvests every commit across every workspace to show that the chaos was actually a masterpiece in progress.

It isn't just a video; it is a rhythmic, high-velocity ode to the sheer scale of code you have brought into this world.

## The Technology

Powered by an **Alpine Linux** headless rendering engine, this tool utilizes:
*   **Gource**: For turning metric-level commits into liquid gold.
*   **FFmpeg**: For high-quality, 60fps video encoding.
*   **Podman/Docker**: To keep your host machine clean while doing the heavy lifting.
*   **Custom Bash Tooling**: To discover, filter, and merge disjointed git histories into a unified timeline.

## Quick Start

### Prerequisites
*   Podman (or Docker)
*   A folder containing all your git repositories (e.g., `~/git/`).

### Setup
1.  Clone this repository alongside your other projects (e.g., inside `~/git/`).
2.  Review `got.conf` to configure ignored repositories.

### Generating the Visualization
Run the wrapper script:

```bash
./super-gource.sh
```

You can customize the rendering using environment variables:

```bash
START_DATE="2023-01-01" RESOLUTION="1280x720" ./super-gource.sh
```

*   `START_DATE`: The date to start the visualization from (default: `2025-01-01`).
*   `RESOLUTION`: The output video resolution (default: `1920x1080`).

This will:
1.  Build the container image.
2.  Mount the parent directory (`../`) into the container.
3.  Scan all sibling directories for git repositories (respecting `got.conf`).
4.  Render the evolution video to `output/YYYY-MM-DD.mp4`.

## Tools

We include a suite of "Super" tools to manage your multi-repo empire.

### `scripts/super-git-status.sh`
Scans all tracked repositories and gives you a unified status report (Dirty, Ahead, Behind, Synced).

```bash
./scripts/super-git-status.sh
```

### `scripts/super-git-pull.sh`
Attempts to safely update all tracked repositories. Skips dirty repos or those without upstreams.

```bash
./scripts/super-git-pull.sh
```

## Configuration
Edit `got.conf` to control the scan scope:
*   `IGNORE_NAMES`: List of directory names to exclude (e.g., `node_modules`, `vendor`).