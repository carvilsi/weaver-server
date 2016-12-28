conf   = require('config')
ascii  = require('./logo-ascii')
pack   = require('../../../package.json')
splash = [] 

BOOL = (val) -> if val then 'ON' else 'OFF'

_ = (e) -> splash.push(e)

_ "Weaver Server started and ready!"
_ ""
_ "# Versions"
_ "Server:     #{pack.version}"
_ "Commons:    #{pack['dependencies']['weaver-commons-js']}"
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
_ "Connector:  #{conf.get('services.connector.host')}:#{conf.get('services.connector.port')}"
_ "Redis:      #{conf.get('services.redis.host')}:#{conf.get('services.redis.port')}"
_ "ChirQL:     #{conf.get('services.chirql.host')}:#{conf.get('services.chirql.port')}"
_ "Flock:      #{conf.get('services.flock.host')}:#{conf.get('services.flock.port')}"
_ ""
_ "# Logging"
_ "Console:   #{conf.get('logging.console')}"
_ "File:      #{conf.get('logging.file')}"
_ ""
_ "# Settings"
_ "Admin password:  #{conf.get('server.admin.password')}"
_ ""
_ require('./funnies')()


# Get longest line in splash
max  = -1
max  = line.length for line in splash when line.length > max
max += ascii[0].length

compile = (line, index) ->
  if not ascii[index]?
    line + Array(max - line.length + 2).join(' ') + '│\n'
  else
    line + Array(max - ascii[0].length - line.length + 2).join(' ') + ascii[index] + '│\n'

text  = '┌'  + Array(max + 3).join('─') + '┐\n'
text += '│ ' + compile(line, index) for line, index in splash
text += '└'  + Array(max + 3).join('─') + '┘'

module.exports = text