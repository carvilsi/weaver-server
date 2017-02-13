pjson = require('../../package.json')
bus   = require('WeaverBus')

# Version
bus.public('application.version').on(->
  pjson.version
)
