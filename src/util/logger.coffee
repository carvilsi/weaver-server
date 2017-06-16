require('colors')
winston = require('winston')      # Logging library
require('winston-daily-rotate-file');
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

configTransports = []
codeTransports = []
usageTransports = []

consoleLogger = new Console({
  timestamp
  formatter
  level: "#{config.get('logging.console')}"
  })
configTransports.push(consoleLogger)
codeTransports.push(consoleLogger)
usageTransports.push(consoleLogger)

# Create file transport

configTransports.push(new (winston.transports.DailyRotateFile)({
  filename: "#{config.get('logging.logFilePath.config')}"
  formatter
  datePattern: '.yyyy-MM-dd.log'
  prepend: false
  level: "#{config.get('logging.file')}"
  }))
codeTransports.push(new (winston.transports.DailyRotateFile)({
  filename: "#{config.get('logging.logFilePath.code')}"
  formatter
  datePattern: '.yyyy-MM-dd.log'
  prepend: false
  level: "#{config.get('logging.file')}"
  }))
usageTransports.push(new (winston.transports.DailyRotateFile)({
  filename: "#{config.get('logging.logFilePath.usage')}"
  formatter
  datePattern: '.yyyy-MM-dd.log'
  prepend: false
  level: "#{config.get('logging.file')}"
  }))
authTransports.push(new (winston.transports.DailyRotateFile)({
  filename: "#{config.get('logging.logFilePath.auth')}"
  formatter
  datePattern: '.yyyy-MM-dd.log'
  prepend: false
  level: "info" # this value is harcoded to have more tune. INFO: normal auth behaviour WARN: fails logIn attempts
  }))



# Create logger
Logger = winston.Logger
logger = {}
logger.config = new Logger({transports:configTransports})
logger.code = new Logger({transports:codeTransports})
logger.usage = new Logger({transports:usageTransports})
logger.auth = new Logger({transports:authTransports})


module.exports = logger
