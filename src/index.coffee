# __          __                          _____
# \ \        / /                         / ____|
#  \ \  /\  / /__  __ ___   _____ _ __  | (___   ___ _ ____   _____ _ __
#   \ \/  \/ / _ \/ _` \ \ / / _ \ '__|  \___ \ / _ \ '__\ \ / / _ \ '__|
#    \  /\  /  __/ (_| |\ V /  __/ |     ____) |  __/ |   \ V /  __/ |
#     \/  \/ \___|\__,_| \_/ \___|_|    |_____/ \___|_|    \_/ \___|_|
#
#     "The secret of getting ahead is getting started." - Mark Twain


# Path resolving local directories, making it non-relative accessible from any location.
# In other words, require('../../../../application/logger') becomes require('logger')
paths = [
  'admin'
  'application'
  'auth'
  'comm'
  'database'
]
require('app-module-path').addPath('src/' + path) for path in paths


# Init routes and controllers by running once
runlist = [
  './routes'
  'ApplicationCtrl'
  'NodeCtrl'
  'AuthCtrl'
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
console.log(require('splash/splash').cyan)