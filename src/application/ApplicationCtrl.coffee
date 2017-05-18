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

# Provide Weaver SKD
bus.provide("weaver").retrieve('project').on((req, project) ->

  Weaver = require('weaver-sdk')
  weaver = Weaver.getInstance()

  adminUser = conf.get('admin.username')
  adminPass = conf.get('admin.password')

  weaver.signInWithUsername(adminUser, adminPass).then( =>
    weaverProject = new Weaver.Project(project.name, project.id)
    weaver.useProject(weaverProject)
    weaver
  ).catch((error)->
    logger.code.error(error)
  )
)
