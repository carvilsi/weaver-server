bus    = require('EventBus').get('weaver')
config = require('config')
rp     = require('request-promise')

bus.on('project', (req, res) ->
  res.promise(
    rp({
      uri: "#{config.get('services.project.endpoint')}/list"
    })
  )
)

bus.on('project.create', (req, res) ->
)

bus.on('project.delete', (req, res) ->
)

