#!/bin/bash
rm -rf lib
npm run prepublish
docker build -t sysunite/weaver-server:2.2.0 .