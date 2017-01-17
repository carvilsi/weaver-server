config      = require('config')

serviceDatabase = config.get('services.database.endpoint')
serviceProject  = config.get('services.project.endpoint')?

if serviceDatabase?
  require('./SingleDatabaseProjectCtrl')
else if serviceProject?
  require('./KubernetesProjectCtrl')
else
  console.error "Either a static database or a projects service needs to be configured"
  process.exit(-1)
