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
ModelService    = require('ModelService')
WeaverBus       = require('WeaverBus')
routes          = require('routes')
pjson           = require('../package.json')
logger          = require('logger')
tracker         = require('Tracker')


# Init routes and controllers by running once
initModules = ->
  require(run) for run in [
    'routes'
    'AclCtrl'
    'ApplicationCtrl'
    'FileCtrl'
    'FclCtrl'
    'ModelCtrl'
    'NodeCtrl'
    'PluginCtrl'
    'ProjectCtrl'
    'RoleCtrl'
    'UserCtrl'
    'WeaverQueryCtrl'
    'snmp'
    'TrackerCtrl'
  ]

servicesToLoad = [
  UserService
  AclService
  RoleService
  ProjectService
  PluginService
  ModelService
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

  logger.config.info('weaver-server started and ready')
  splash.printLoaded()
  sounds.loaded()
)
