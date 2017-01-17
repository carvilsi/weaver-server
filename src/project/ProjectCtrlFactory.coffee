config = require('config')
logger = require('logger')

serviceDatabase = config.get('services.database.endpoint')
serviceProject  = config.get('services.project.endpoint')?

if !!serviceDatabase
  logger.info "Using single database at #{serviceDatabase}"
  require('./SingleDatabaseProjectCtrl')
else if !!serviceProject
  logger.info "Using kubernetes service at #{serviceProject}"
  require('./KubernetesProjectCtrl')
else
  logger.error "Either a static database or a projects service needs to be configured"
  throw "No database or project service defined"
