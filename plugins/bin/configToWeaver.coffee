# this script copies the configuration coffee file of a weaver plugin
# to Weaver config file.

# arguments:
# default optional
# production
shelljs = require('shelljs')

arg = process.argv.slice(2)

if !arg[0]
  arg[0] = 'default'

if arg[0] isnt 'default' and arg[0] isnt 'production'
  console.error('wrong argument, use default or production')
  process.exit(1)

try
  shelljs.cat({'-n':1},"plugins/*/config/#{arg[0]}.coffee")
  .sed(/module.exports=/g,'')
  .toEnd("config/#{arg[0]}.coffee")
catch error
  console.error('something went wrong :S')
  process.exit(1)
finally
  console.log("Configuration from plugins copied to config/#{arg[0]}.coffee")
