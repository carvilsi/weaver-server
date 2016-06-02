winston = require('winston')      # Logging library
moment  = require('moment')       # Easy date formatting library

# Return timestamp correctly formatted
timestamp = ->
  moment().format("YYYY-MM-DD HH:mm:ss")

# Return complete formatted string
formatter = (options) ->
  time = options.timestamp()
  level = options.level.toUpperCase()
  message = if options.message? then options.message else ''
  object = if options.meta? && Object.keys(options.meta).length != 0 then ('\n\t'+ JSON.stringify(options.meta)) else ''

  time + ' | ' + level + ' | ' + message + object

# Create console transports array using timestamp and formatter functions
Console = winston.transports.Console
transports = [new Console({timestamp, formatter})]

# Return logger
Logger = winston.Logger
logger = new Logger({transports})
logger.level = 'debug'
module.exports = logger