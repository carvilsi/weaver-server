# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#                                                    .                #
#                                           `      ~~                 #
#                    ~~~~~~_____         ````  ~~~~~                  #
#                 ~~~~~~~~~~~~_________~~~~~~~~~~~                    #
#                ~```````~~~~~~~~___________~~~                       #
#                        ````~~~~~~_____                              #                      
#                                                                     #
#                                                       Weaver Server #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


# Loading
console.log(`'\033[2J'`)             # Clear terminal
console.log(`'\033[0;0H'`)           # To top
console.log(`'\033[36mLoading...'`)  # Loading in cyan


# Path resolving local directories, making it non-relative accessible from any location.
# In other words, require('../../../../util/logger') becomes require('logger')
# Note: This must be the first running code in the application before any require() works
require('app-module-path').addPath("#{__dirname}/#{path}") for path in [
  '.'
  'admin'
  'application'
  'auth'
  'schemas'
  'cli'
  'core'
  'database'
  'project'
  'util'
  'fileSystem'
]


# Load libs
Promise  = require('bluebird')
conf     = require('config')       # Configuration loads files in the root config directory
Server   = require('Server')
splash   = require('splash')
sounds   = require('sounds')
Weaver   = require('weaver-sdk')
EventBus = require('EventBus')
pjson    = require('../package.json')

# Init routes and controllers by running once
initModules = ->
  require(run) for run in [
    'routes'
    'ApplicationCtrl'
    'AuthCtrl'
    'ErrorHandler'
    'NodeCtrl'
    'ProjectAuthCtrl'
    'ProjectCtrlFactory'
    'WeaverQueryCtrl'
    'FileSystemCtrl'
  ]


# Init servers
weaver = new Server({
  routes: 'weaver'
  views:[
    {path: '/', file: 'weaver/index.html', vars: {server : pjson.version}}
  ]

  port: conf.get('server.weaver.port')
  cors: conf.get('server.weaver.cors')
})

admin = new Server({
  routes: 'admin'
  host:   '127.0.0.1'
  views:[
    {path: '/', file: 'admin/index.html', vars: {server : pjson.version}}
  ]
  static:
    '/portal': 'admin'

  port: conf.get('server.admin.port')
})


# Run servers
Promise.all([weaver.run(), admin.run()])
.then(->
  # Initialize local Weaver
  Weaver.local(EventBus.get('weaver'))
).then(->
  initModules()
  splash.printLoaded()
  sounds.loaded()
)
