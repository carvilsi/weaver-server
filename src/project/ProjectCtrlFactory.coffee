config = require('config')
logger = require('logger')

serviceDatabase = config.get('services.database.endpoint')
serviceProject  = config.get('services.project.endpoint')?

getDatabaseCtrl = ->
  switch
    when !!serviceDatabase then 'SingleDatabaseProjectCtrl'
    when !!serviceProject then 'KubernetesProjectCtrl'
    else throw "No database or project service defined"

require("./#{getDatabaseCtrl()}")

module.exports = getDatabaseCtrl
