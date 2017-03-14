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
Promise       = require('bluebird')
conf          = require('config')       # Configuration loads files in the root config directory
server        = require('WeaverServer')
splash        = require('splash')
sounds        = require('sounds')
Weaver        = require('weaver-sdk')
WeaverBus     = require('WeaverBus')
routes        = require('routes')
pjson         = require('../package.json')

# Init routes and controllers by running once
initModules = ->
  require(run) for run in [
    'routes'
    'ApplicationCtrl'
    'AuthCtrl'
    'NodeCtrl'
    'ProjectAuthCtrl'
    'ProjectCtrlFactory'
    'WeaverQueryCtrl'
    'FileSystemCtrl'
  ]

# Run servers
Promise.all([
  server.run()
])
.then(->
  # Initialize local Weaver
  Weaver.local(routes)
).then(->
  initModules()

  splash.printLoaded()
  sounds.loaded()
)
