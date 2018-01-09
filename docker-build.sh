#!/bin/bash
docker build -t sysunite/`node -p "require('./package.json').name"`:`node -p "require('./package.json').version"` .
