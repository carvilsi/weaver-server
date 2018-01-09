#!/bin/bash
# docker build -t sysunite/weaver-server:3.3.2-beta.1 .
echo sysunite/`node -p "require('./package.json').name"`:`node -p "require('./package.json').version"`
