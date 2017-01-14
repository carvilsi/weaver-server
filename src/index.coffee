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


# Path resolving local directories, making it non-relative accessible from any location.
# In other words, require('../../../../util/logger') becomes require('logger')
# Note: This must be the first running code in the application
require('app-module-path').addPath("src/#{path}") for path in [
  '.'
  'admin'
  'application'
  'auth'
  'auth/schemas'
  'cli'
  'core'
  'database'
  'project'
  'util'
]


# Load libs
Promise = require('bluebird')
conf    = require('config')       # Configuration loads files in the root config directory
Server  = require('server')
splash  = require('splash')
sounds  = require('sounds')
pjson   = require('../package.json')

# Init routes and controllers by running once
require(run) for run in [
  'routes'
  'ApplicationCtrl'
  'AuthCtrl'
  'ErrorHandler'
  'NodeCtrl'
  'ProjectCtrl'
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


# Run
Promise.all([weaver.run(), admin.run()]).then(->
  splash.printLoaded()
  sounds.loaded()
)