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

## Project Structure

```text
lab/gource-of-truth/
├── docker/                 # Container definition (Dockerfile)
├── output/                 # Generated video artifacts (mp4)
├── scripts/                # Management tools and internal logic
│   ├── common.sh           # Shared library for repo discovery
│   ├── internal-runner.sh  # The engine running inside the container
│   ├── super-git-pull.sh   # Mass-updater
│   ├── super-git-push.sh   # Mass-pusher
│   └── super-git-status.sh # Mass-reporter
├── got.conf                # Configuration (ignored patterns)
├── readme.md               # You are here
└── super-gource.sh         # Main entry point for video generation
```

## Quick Start

### Prerequisites
*   Podman (or Docker)
*   A folder containing all your git repositories (e.g., `~/git/`).

### Setup
1.  Clone this repository alongside your other projects (e.g., inside `~/git/`).
2.  Review `got.conf` to configure ignored repositories.

### Generating the Visualization
Run the wrapper script, optionally specifying the root directory to scan (defaults to `../../`):

```bash
./super-gource.sh [PATH_TO_SCAN]
```

Examples:
```bash
./super-gource.sh ~/git
./super-gource.sh ~/git/projects
```

You can customize the rendering using environment variables:

```bash
START_DATE="2023-01-01" RESOLUTION="1280x720" ./super-gource.sh
```

*   `START_DATE`: The date to start the visualization from (default: `2025-01-01`).
*   `RESOLUTION`: The output video resolution (default: `1920x1080`).

This will:
1.  Build the container image.
2.  Mount the target directory to `/src` inside the container.
3.  **Recursively scan** the target for all git repositories (including **submodules**), respecting `got.conf` and ignoring the `work` directory.
4.  Render the evolution video to `output/YYYY-MM-DD.mp4`.

## Empire Management Tools

We include a suite of "Super" tools to manage your multi-repo empire. These scripts utilize the same `got.conf` and `common.sh` discovery logic as the visualizer.

### `scripts/super-git-status.sh`
Scans all tracked repositories and gives you a unified status report (Dirty, Ahead, Behind, Synced).

```bash
./scripts/super-git-status.sh
```

### `scripts/super-git-pull.sh`
Attempts to safely update all tracked repositories. Skips dirty repos, those without upstreams, or those that have diverged.

```bash
./scripts/super-git-pull.sh
```

### `scripts/super-git-push.sh`
Safely pushes changes for all repositories that are ahead of their upstream.
*   **Skips:** Dirty repos, diverged histories, or repos with no upstream.
*   **Pushes:** Only if the local branch is strictly ahead of remote.

```bash
./scripts/super-git-push.sh
```

## Configuration
Edit `got.conf` to control the scan scope:
*   `IGNORE_NAMES`: List of directory names to exclude (e.g., `node_modules`, `vendor`).
