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
  'model'
  'project'
  'plugin'
  'util'
  'tracker'
  'snmp'
  'socket'
]
