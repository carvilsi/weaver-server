express         = require('express')
mustacheExpress = require('mustache-express')   # Templating
bodyParser      = require('body-parser')        # POST requests
HttpComm        = require('http-comm')
SocketComm      = require('socket-comm')

module.exports = 
  class Server
    
    constructor: (@options) ->
      
      # Init express
      @app  = express()
      @http = require('http').Server(@app)

      # Use Mustache as templating engine
      @app.engine('html', mustacheExpress())
      @app.set('view engine', 'html')

      # CORS allow all
      @app.all('*', (req, res, next) ->
        res.header('Access-Control-Allow-Origin', '*');
        res.header('Access-Control-Allow-Methods', 'PUT, GET, POST, DELETE, OPTIONS');
        res.header('Access-Control-Allow-Headers', 'Content-Type');
        next()
      )

      # For POST requests
      @app.use(bodyParser.json({limit: '1000000mb'}))                        # Support json encoded bodies
      @app.use(bodyParser.urlencoded({limit: '1000000mb', extended: true })) # Support encoded bodies

      # Static serving
      @app.use('/img', express.static('img'));
      @app.use('/sdk', express.static('node_modules/weaver-sdk/dist'));

      # Connection test
      @app.get('/connection', (req, res) ->
        res.status(204).send()
      )
      
      # Retrieve routes
      @routes = require('route-registry').get(@options.routes)
      
      # Wire HTTP
      @httpComm  = new HttpComm(@routes)
      @httpComm.wire(@app)
      
      # Wire Socket
      @socketComm  = new SocketComm(@routes)
      @socketComm.wire(@http)


    run: ->
      @http.listen(@options.port)
      