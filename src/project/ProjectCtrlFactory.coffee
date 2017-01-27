config = require('config')

serviceProject  = config.get('services.projectController.endpoint')?

getDatabaseCtrl = ->
  if config.get('application.singleDatabase')
    'SingleDatabaseProjectCtrl'
  else
    'KubernetesProjectCtrl'

require("./#{getDatabaseCtrl()}")

module.exports = getDatabaseCtrl
