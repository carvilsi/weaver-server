config = require('config')

serviceDatabase = config.get('services.projectDatabase.endpoint')
serviceProject  = config.get('services.projectController.endpoint')?

getDatabaseCtrl = ->
  switch
    when !!serviceDatabase then 'SingleDatabaseProjectCtrl'
    when !!serviceProject then 'KubernetesProjectCtrl'
    else throw "No database or project service defined"

require("./#{getDatabaseCtrl()}")

module.exports = getDatabaseCtrl
