#!/usr/bin/env bash

# Run this script in a Docker Terminal
docker build -t sysunite/weaver-server-beta:0.0.1 .
docker push sysunite/weaver-server-beta:0.0.1