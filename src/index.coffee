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

require('./module-path') # Contains module paths

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
Tracker         = require('Tracker')
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
    'snmp'
  ]

servicesToLoad = [
  UserService
  AclService
  RoleService
  ProjectService
  PluginService
]

# Initialize services
Promise.map(servicesToLoad, (service) ->
  service.load()
).then(->

  # Run the express and socket server
  server = require('WeaverServer')
  server.run()

).then(->
  # Initialize local Weaver
  new Weaver().local(routes)
).then(->
  initModules()

  logger.config.info('weaver-server restarted')
  splash.printLoaded()
  sounds.loaded()
)
