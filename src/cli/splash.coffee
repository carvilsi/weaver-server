require('colors')
conf   = require('config')
logo  = require('./logo')
pack   = require('../../package.json')
cursor = require('cursor')
delay  = require('delay')
splash = []

BOOL = (val) ->
  if val then 'ON' else 'OFF'

_ = (e) -> splash.push(e)

_ "Weaver Server started and ready!"
_ ""
_ "# Versions"
_ "Server:     #{pack.version}"
_ "SDK:        #{pack['dependencies']['weaver-sdk']}"
_ ""
_ "# Ports"
_ "Public:     #{conf.get('server.weaver.port')}"
_ "Admin:      #{conf.get('server.admin.port')}"
_ ""
_ "# Comm"
_ "HTTP:       #{BOOL conf.get('comm.http.enable')}"
_ "Socket.io:  #{BOOL conf.get('comm.socket.enable')}"
_ ""
_ "# Services"
_ "System Database:       #{conf.get('services.systemDatabase.endpoint')}"
_ "Project Database:      #{conf.get('services.projectDatabase.endpoint')}"
_ "Project Controller:    #{conf.get('services.projectController.endpoint')}"
_ "FileSystem Controller: #{conf.get('services.fileSystem.endpoint')}"
_ "FileSystem Region:     #{conf.get('services.fileSystem.region')}"
_ ""
_ "# Logging"
_ "Console:   #{conf.get('logging.console').toUpperCase()}"
_ "File:      #{conf.get('logging.file').toUpperCase()}"
_ ""
_ "# Settings"
_ "Single database:  #{BOOL conf.get('application.singleDatabase')}"
_ "CORS allow all:   #{BOOL conf.get('server.weaver.cors')}"
_ "Admin password:   #{conf.get('server.admin.password')}"
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
    spaceUp = splash.length

    print = ->
      cursor.clear()
      cursor.toTop()
      console.log(getText(spaceUp).cyan)
      spaceUp--

      delay(30, print) if spaceUp > 0

    print()
