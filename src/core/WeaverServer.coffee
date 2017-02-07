Promise         = require('bluebird')
express         = require('express')
http            = require('http')
mustacheExpress = require('mustache-express')   # Templating
bodyParser      = require('body-parser')        # POST requests
HttpComm        = require('HttpComm')
SocketComm      = require('SocketComm')
config = require('config')
pjson       = require('../../package.json')

module.exports =
class Server

  constructor: () ->

    @options =
      views:[
        {path: '/', file: 'weaver/index.html', vars: {server : pjson.version}}
      ]

      port: config.get('server.port')
      cors: config.get('server.cors')


    # Set default options
    require('util/options').defaults(@options,
      host: '0.0.0.0'
      cors:  false
      views:  []
      static: {}
    )

    # Init express
    @app  = express()
    @http = http.Server(@app)

    # Use Mustache as templating engine
    @app.engine('html', mustacheExpress())
    @app.set('view engine', 'html')

    # CORS allow all
    if @options.cors
      @app.all('*', (req, res, next) ->
        res.header('Access-Control-Allow-Origin', '*');
        res.header('Access-Control-Allow-Methods', 'PUT, GET, POST, DELETE, OPTIONS');
        res.header('Access-Control-Allow-Headers', 'Content-Type');
        next()
      )

    # For POST requests
    @app.use(bodyParser.json({limit: '1000000mb'}))                        # Support json encoded bodies
    @app.use(bodyParser.urlencoded({limit: '1000000mb', extended: true })) # Support encoded bodies

    # Default static serving
    @app.use('/img', express.static('img'));
    @app.use('/sdk', express.static('node_modules/weaver-sdk/dist'));

    # Additional static serving
    for path, folder of @options.static
      @app.use(path, express.static(folder));

    # Views
    for view in @options.views
      @app.get(view.path, (req, res) ->
        res.render(view.file, view.vars)
      )

    # Connection test
    @app.get('/connection', (req, res) ->
      res.status(204).send()
    )

    # Retrieve routes
    @routes = require('routes')

    # Wire HTTP
    @httpComm  = new HttpComm(@routes)
    @httpComm.wire(@app)

    # Wire Socket
    @socketComm  = new SocketComm(@routes)
    @socketComm.wire(@http)


  run: ->
    new Promise((resolve, reject) =>
      @http.listen(@options.port, @options.host, (error) ->
        if error then reject(error) else resolve()
      )
    )
