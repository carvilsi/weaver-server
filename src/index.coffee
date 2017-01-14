#                                                    .
#                                           `      ~~
#                    ~~~~~~_____         ````  ~~~~~
#                 ~~~~~~~~~~~~_________~~~~~~~~~~~
#                ~```````~~~~~~~~___________~~~
#                        ````~~~~~~_____                                     
#

# Path resolving local directories, making it non-relative accessible from any location.
# In other words, require('../../../../util/logger') becomes require('logger')
paths = [
  'admin'
  'application'
  'auth'
  'auth/schemas'
  'core'
  'database'
  'splash'
  'project'
  'util'
]
require('app-module-path').addPath('src/' + path) for path in paths


# Init routes and controllers by running once
runlist = [
  './routes'
  'ApplicationCtrl'
  'NodeCtrl'
  'AuthCtrl'
  'ProjectCtrl'
]
require(run) for run in runlist


# Run servers
Server = require('server')
conf   = require('config')   # Configuration loads files in the root config directory

new Server({
  port:   conf.get('server.weaver.port')
  routes: 'weaver'
}).run()

new Server({
  port:    conf.get('server.admin.port')
  routes: 'admin'
  host:   'localhost'
}).run()

# Print splash
require('colors')
console.log(require('splash').cyan)

# Play chirp sound
#player = require('play-sound')()
#player.play('sounds/chirp.wav')