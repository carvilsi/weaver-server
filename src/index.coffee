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
  'application'
  'auth'
  'cli'
  'core'
  'database'
  'file'
  'project'
  'plugin'
  'util'
  'tracker'
]


# Load libs
Promise         = require('bluebird')
conf            = require('config')       # Configuration loads files in the root config directory
splash          = require('splash')
sounds          = require('sounds')
Weaver          = require('weaver-sdk')
UserService     = require('UserService')
AclService      = require('AclService')
FclService      = require('FclService')
RoleService     = require('RoleService')
ProjectService  = require('ProjectService')
PluginService   = require('PluginService')
WeaverBus       = require('WeaverBus')
routes          = require('routes')
pjson           = require('../package.json')
tracker         = require('Tracker')
logger          = require('logger')


# Init routes and controllers by running once
initModules = ->
  require(run) for run in [
    'routes'
    'AclCtrl'
    'ApplicationCtrl'
    'FileCtrl'
    'FclCtrl'
    'NodeCtrl'
    'PluginCtrl'
    'ProjectCtrl'
    'RoleCtrl'
    'UserCtrl'
    'WeaverQueryCtrl'
    'TrackerCtrl'
  ]


# Initialize
Promise.all([

  # Load services
  [
    UserService
    AclService
    RoleService
    ProjectService
    PluginService
  ].forEach((service) -> service.load())

  # Initialize the Tracker database
  tracker.initDb()

]).then(->

  # Run the express and socket server
  server = require('WeaverServer')
  server.run()

).then(->

  # Initialize local Weaver
  Weaver.local(routes)

).then(->
  initModules()

  logger.config.info('weaver-server restarted')
  splash.printLoaded()
  sounds.loaded()
)
