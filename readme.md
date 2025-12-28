#!/bin/bash

# readme but its basically a run-me... 
 
podman build -t gource-of-truth -f Dockerfile .
podman run --rm -v ../:/src localhost/gource-of-truth:latest
