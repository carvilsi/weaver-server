path      = require('path')
PluginBus = require('PluginBus')

class Plugin

  constructor: (@path) ->
    @pjson          = require(path.join(@path, 'package.json'))
    @pluginFunction = require(@path)
    @pluginBus      = new PluginBus(@)

  init: ->
    @pluginFunction(@pluginBus)

  getVersion: ->
    @pjson.version

  getAuthor: ->
    @pjson.author

  getName: ->
    @pjson.name

  getDescription: ->
    @pjson.description

  toServerObject: ->
    name:        @getName()
    version:     @getVersion()
    author:      @getAuthor()
    description: @getDescription()
    functions:   @pluginBus.getFunctions()


module.exports = Plugin
