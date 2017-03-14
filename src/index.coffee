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
  'project'
  'util'
  'fileSystem'
]


# Load libs
Promise         = require('bluebird')
conf            = require('config')       # Configuration loads files in the root config directory
WeaverServer    = require('WeaverServer')
splash          = require('splash')
sounds          = require('sounds')
Weaver          = require('weaver-sdk')
UserService     = require('UserService')
ProjectService  = require('ProjectService')
WeaverBus       = require('WeaverBus')
routes          = require('routes')
pjson           = require('../package.json')


# Init routes and controllers by running once
initModules = ->
  require(run) for run in [
    'routes'
    'AclCtrl'
    'ApplicationCtrl'
    'AuthCtrl'
    'NodeCtrl'
    'ProjectCtrl'
    'RoleCtrl'
    'WeaverQueryCtrl'
    'FileSystemCtrl'
  ]


# Init servers
server = new WeaverServer()


# Run servers
Promise.all([
  server.run()

  # Load services
  [
    UserService
    ProjectService
  ].forEach((service) -> service.load())
])
.then(->

  # Initialize local Weaver
  Weaver.local(routes)

).then(->
  initModules()

  splash.printLoaded()
  sounds.loaded()
)
