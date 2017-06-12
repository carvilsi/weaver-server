config          = require('config')
pjson           = require('../../package.json')
bus             = require('WeaverBus')
Promise         = require('bluebird')
logger          = require('logger')
conf            = require('config')


# Version
bus.public('application.version').on(->
  pjson.version
)

# Server time
bus.public('application.time').on(->
  servertime = new Date().getTime()
  servertime
)

# Provide Weaver SKD the plugin must take care about the sigIn (with authToken better)
bus.provide("weaver").retrieve('project').on((req, project) ->
  Weaver = require('weaver-sdk')
  weaver = Weaver.getInstance()
  weaver
)
