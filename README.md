# Docker images for Matlab TraX support

This repository contains a collection of build scripts to support packaging Matlab trackers in Docker containers. The main idea is to create a transferable trackers for remote evaluation using Docker and Singularity.

## How does it work?

Since Matlab cannot be distributed in Docker image due to obvious licensing reasons, it is mounted from host machine into the `/opt/matlab` directory. This means that the images only work if the volume containing Matlab is correctly mounted. Also, since Matlab is required during build stage and Docker does not support mounting volumes during this stage, the build procedure is not based on `Dockerfile` but rather on committing a working image and tagging it. We provide a script that does most of the work if it is given correct information (check subdirectories for some examples).
