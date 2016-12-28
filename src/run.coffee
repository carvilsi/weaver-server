express         = require('express')
app             = express()
http            = require('http').Server(app)
mustacheExpress = require('mustache-express')
pjson           = require('../package.json')
WeaverServer    = require('./index')

# CORS allow all
app.all('*', (req, res, next) ->
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'PUT, GET, POST, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type');
  next()
)

# Use Mustache as templating engine
app.engine('html', mustacheExpress())
app.set('view engine', 'html')

# Index page
app.get('/', (req, res) ->
  res.render('../html/index-img.html', {server : pjson.version})
)

# Static serving
app.use('/img', express.static('img'));
app.use('/sdk', express.static('node_modules/weaver-sdk/dist'));

getWithDefault = (env, defaultValue) ->
  if env? then env else defaultValue


# Options
opts =
  port              : getWithDefault(process.env.PORT,          9487)
  flockIp           : getWithDefault(process.env.FLOCK_IP,      'localhost')
  flockPort         : getWithDefault(process.env.FLOCK_PORT,    7343)
  weaverServiceIp   : getWithDefault(process.env.SERVICE_IP,    'localhost')
  weaverServicePort : getWithDefault(process.env.SERVICE_PORT,  9474)
  redisHost         : getWithDefault(process.env.REDIS_HOST,    'localhost')
  redisPort         : getWithDefault(process.env.REDIS_PORT,    6379)
  logDebug          : getWithDefault(process.env.LOG_DEBUG,     'false') == 'true'


# Init
weaver = new WeaverServer(opts)

# Start
weaver.wire(app, http)



# Admin app
app2 = express()
app2.get('/',  (req, res) ->
  res.send('Hello World!')
)
app2.listen(9000, ->
)




# Launch
server = http.listen(opts.port, ->
  
  ascii = []
  _ = (e) -> ascii.push(e)
  _ "                                  "
  _ "                                , "
  _ "                           `   ,` "
  _ "     ,,,:.`               .: .:,  "
  _ "    :::::::...`          :;,:::   "
  _ "   :::::::::....``    `,::::::`   "
  _ "  :::::::::::,.......,:::::::.    "
  _ " ::;;;;;:::::::...........,:.     "
  _ "      .;;;:::::...........        "
  _ "          :;::::........`         "
  _ "             ::::.....            "
  
  
  splash = []
  _ = (e) -> splash.push(e)
  _ "Weaver Server started and ready!"
  _ ""
  _ "# Versions"
  _ "Server:     #{pjson.version}"
  _ "Commons:    #{pjson.dependencies['weaver-commons-js']}"
  _ "SDK:        #{pjson.dependencies['weaver-sdk']}"
  _ ""
  _ "# Ports"
  _ "Public:     #{opts.port}"
  _ "Admin:      9550"
  _ ""
  _ "# Comm"
  _ "HTTP:       ON"
  _ "Socket.io:  ON"
  _ ""
  _ "# Services"
  _ "Connector:  ON   #{opts.weaverServiceIp}:#{opts.weaverServicePort}" 
  _ "Redis:      OFF  #{opts.redisHost}:#{opts.redisPort}"
  _ "ChirQL:     ON   localhost:8675"
  _ "Flock:      ON   #{opts.flockIp}:#{opts.flockPort}"
  _ ""
  _ "# Logging"
  _ "File:      WARNING"
  _ "Console:   ERROR"
  _ ""
  _ "# Settings"
  _ "Admin password:  yUU2PNzcs!69GZ4B4"
  _ ""
  _ require('./funnies')()
  
  
  # Get longest line in splash
  max  = -1
  max  = line.length for line in splash when line.length > max
  max += ascii[0].length
  
  compile = (line, index) ->
    if not ascii[index]?
      line + Array(max - line.length + 2).join(' ') + '│\n'
    else
      line + Array(max - ascii[0].length - line.length + 2).join(' ') + ascii[index] + '│\n'
  
  text  = '┌'  + Array(max + 3).join('─') + '┐\n'
  text += '│ ' + compile(line, index) for line, index in splash
  text += '└'  + Array(max + 3).join('─') + '┘'

  console.log(text.cyan)
)