pjson = require('../../package.json')
bus   = require('WeaverBus')

# Version
bus.private('application.version').on(->
  pjson.version
)
