require('colors')
winston = require('winston')      # Logging library
moment  = require('moment')       # Easy date formatting library
config  = require('config')

# Return timestamp correctly formatted
timestamp = ->
  moment().format("YYYY-MM-DD HH:mm:ss")

# Return complete formatted string
formatter = (options) ->
  time    = options.timestamp()
  level   = options.level.toUpperCase()
  message = if options.message? then options.message else ''
  object  = if options.meta? && Object.keys(options.meta).length != 0 then ('\n\t'+ JSON.stringify(options.meta)) else ''
  total   = "#{time} | #{level} | #{message} #{object}"
  
  # Make message red if error
  total = total.red if level is 'ERROR'
  
  total

# Create console transports array using timestamp and formatter functions
Console    = winston.transports.Console
transports = [new Console({timestamp, formatter})]

# Create logger
Logger = winston.Logger
logger = new Logger({transports})

# Set minimum level
logger.level = "#{config.get('logging.console')}".toLowerCase()

module.exports = logger