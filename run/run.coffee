# Libs
app            = require('express')()
http           = require('http').Server(app)
EmptyConnector = require('weaver-connector')
WeaverServer   = require('../src/index')
RevitInterface = require('weaver-plugin-interface-revit')

# CORS allow all
app.all('*', (req, res, next) ->
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'PUT, GET, POST, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type');
  next()
)

# Index page
path = require('path').resolve(__dirname, '../html/index.html')
app.get('/', (req, res) ->
  res.sendFile(path)
)

# Init Weaver Server
weaver = null
if process.env.REDIS_URL?
  weaver = new WeaverServer(process.env.REDIS_URL)
else
  weaver = new WeaverServer('localhost:6379')

emptyConnector = new EmptyConnector()
weaver.setConnector(emptyConnector).then(->

# Turtle plugin
#weaver.addPlugin(new TurtlePlugin())

  # Revit interface
  weaver.addPlugin(new RevitInterface({apiKey: 'kj6tEWz#4Kmr23fsV'}))

  # Wire weaver-server to express
  weaver.wire(app, http)

  # Launch
  port = process.env.PORT || 9487
  server = http.listen(port, ->

    top      = '┌──────────────────────────────────────┐'
    title    = '│ Weaver Server                        │'
    ready    = '│ Ready to serve clients on port: '
    endReady =                                       ' │'
    bottom   = '└──────────────────────────────────────┘'

    console.log(top + '\n' + title + '\n' + ready + port + endReady + '\n' + bottom)
  )
)