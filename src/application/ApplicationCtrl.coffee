pjson = require('../../package.json')
bus   = require('EventBus').get('weaver')

# Version
bus.on('application.version', (req, res) ->
  res.send(pjson.version)
)

# Index page
bus.on('', (req, res) ->
  res.render('index.html', {server : pjson.version})
)