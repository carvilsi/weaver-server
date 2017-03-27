Promise     = require('bluebird')
path        = require('path')
fs          = Promise.promisifyAll(require("fs"))
Plugin      = require('Plugin')

class PluginService

  constructor: ->
    #__dirname provides the absolute path to the working directory of this file
    @directory = path.resolve(__dirname, '../../plugins')
    @plugins   = {}

  load: ->
    fs.readdirAsync(@directory).then((files) =>

      # Only get the directories
      directories = files.filter((file) =>
        filePath = path.resolve(@directory, file)
        fs.statSync(filePath).isDirectory()
      )

      # From the directories, we assume it is a plugin if it has a package.json file
      pluginDirectories = directories.filter((dir) =>
        packageFile = path.resolve(@directory, dir, 'package.json')
        fs.existsSync(packageFile)
      )

      # Now we create a Plugin per plugin directory
      for pluginDir in pluginDirectories
        pluginPath = path.resolve(@directory, pluginDir)
        plugin = new Plugin(pluginPath)
        @plugins[plugin.getName()] = plugin

      # Initialize plugins
      Promise.map((plugin for name, plugin of @plugins), (plugin) ->
        plugin.init()
      )
    )

  all: ->
    (plugin.toServerObject() for name, plugin of @plugins)

  get: (name) ->
    if not @plugins[name]?
      throw {code: -1, message: "Plugin with name #{name} not found"}

    @plugins[name].toServerObject()


module.exports = new PluginService()
