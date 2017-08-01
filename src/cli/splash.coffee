require('colors')
conf   = require('config')
logo   = require('./logo')
packServer = require('../../package.json')
packSDK    = require('../../node_modules/weaver-sdk/package.json')
cursor = require('cursor')

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
_ "Project Controller:    #{conf.get('services.projectController.endpoint')}"
_ ""
_ "# Logging"
_ "Console:   #{conf.get('logging.console').toUpperCase()}"
_ "File:      #{conf.get('logging.file').toUpperCase()}"
_ ""
_ "# Settings"
_ "Admin userName: #{conf.get('admin.username')}"
_ "Project pool:   #{conf.get('application.projectpool')}"
_ "System wipe:    #{BOOL conf.get('application.wipe')}"
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

getText = ->
  logo = JSON.parse(JSON.stringify(require('./logo')))

  text  = '┌'  + Array(max + 3).join('─') + '┐\n'
  text += '│ ' + compile(line, index) for line, index in splash
  text += '└'  + Array(max + 3).join('─') + '┘'
  text

module.exports =

  printLoaded: ->
    cursor.clear()
    cursor.toTop()
    console.log(getText().cyan)
