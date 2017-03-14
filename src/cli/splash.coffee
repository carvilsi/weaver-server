require('colors')
conf   = require('config')
logo   = require('./logo')
packServer = require('../../package.json')
packSDK    = require('../../node_modules/weaver-sdk/package.json')
cursor = require('cursor')
delay  = require('delay')

getProjectsCtrlType = require('ProjectCtrlFactory')

splash = []

BOOL = (val) ->
  if val then 'ON' else 'OFF'

_ = (e) -> splash.push(e)

_ "Weaver Server started and ready!"
_ ""
_ "# Versions"
_ "Server:     #{packServer.version}"
_ "SDK:        #{packSDK.version}"
_ ""
_ "# Server"
_ "Port:       #{conf.get('server.port')}"
_ "HTTP:       #{BOOL conf.get('comm.http.enable')}"
_ "CORS allow: #{BOOL conf.get('server.cors')}"
_ "Socket.io:  #{BOOL conf.get('comm.socket.enable')}"
_ ""
_ "# Services"
_ "System Database:       #{conf.get('services.systemDatabase.endpoint')}"
_ "Project Database:      #{conf.get('services.projectDatabase.endpoint')}"
_ "Project Controller:    #{conf.get('services.projectController.endpoint')}"
_ "FileSystem Controller: #{conf.get('services.fileSystem.endpoint')}"
_ "FileSystem Region:     #{conf.get('services.fileSystem.region')}"
_ "FileSystem Access Key: #{conf.get('services.fileSystem.accessKey')}"
_ "FileSystem Secret Key: #{conf.get('services.fileSystem.secretKey')}"
_ ""
_ "# Logging"
_ "Console:   #{conf.get('logging.console').toUpperCase()}"
_ "File:      #{conf.get('logging.file').toUpperCase()}"
_ ""
_ "# Settings"
_ "Projects:         #{getProjectsCtrlType()}"
_ "Single database:  #{BOOL conf.get('application.singleDatabase')}"
_ "Admin password:   #{conf.get('admin.password')}"
_ ""
_ require('./funnies')()


# Get longest line in splash
max = require('util/array').maxLength(splash)
max += logo[0].length


# DISCLAIMER
# Apologies for all the code down below, its a bit complex and need refactoring or at least some more explaining


compile = (line, index) ->
  if not logo[index]?
    line + Array(max - line.length + 2).join(' ') + '│\n'
  else
    line + Array(max - logo[0].length - line.length + 2).join(' ') + logo[index] + '│\n'

getText = (spaceUp) ->
  logo = JSON.parse(JSON.stringify(require('./logo')))
  for i in [0..spaceUp]
    logo.unshift("                                     ")

  text  = '┌'  + Array(max + 3).join('─') + '┐\n'
  text += '│ ' + compile(line, index) for line, index in splash
  text += '└'  + Array(max + 3).join('─') + '┘'
  text

module.exports =

  printLoaded: ->
    if conf.get('application.scroll')
      spaceUp = splash.length
    else
      spaceUp = 1

    print = ->
      cursor.clear()
      cursor.toTop()
      console.log(getText(spaceUp).cyan)
      spaceUp--

      delay(30, print) if spaceUp > 0

    print()
