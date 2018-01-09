#!/bin/bash
docker push sysunite/`node -p "require('./package.json').name"`:`node -p "require('./package.json').version"`
