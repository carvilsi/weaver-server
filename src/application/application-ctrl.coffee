pjson = require('../../package.json')
bus   = require('event-bus').get('weaver')

# Version
bus.on('application.version', (req, res) ->
  res.send(pjson.version)
)

# Index page
bus.on('', (req, res) ->
  res.render('weaver/index-img.html', {server : pjson.version})
)