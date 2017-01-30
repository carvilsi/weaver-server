config = require('config')
logger = require('logger')

serviceProject = config.get('services.projectController.endpoint')?
singleDatabase = config.get('application.singleDatabase') is "true"

getDatabaseCtrl = ->
  logger.debug("Getting project controller name, single database #{singleDatabase}")
  if singleDatabase
    'SingleDatabaseProjectCtrl'
  else
    'KubernetesProjectCtrl'

require("./#{getDatabaseCtrl()}")

module.exports = getDatabaseCtrl
