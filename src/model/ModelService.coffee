Promise     = require('bluebird')
path        = require('path')
yaml        = require('js-yaml');
fs          = Promise.promisifyAll(require("fs"))
Weaver      = require('weaver-sdk')

class ModelService

  constructor: ->
    #__dirname provides the absolute path to the working directory of this file
    @directory = path.resolve(__dirname, '../../models')
    @models    = {}
    @modelPath = {}

  _yamlLoad: (filepath) ->
    yaml.safeLoad(fs.readFileSync(path.join(@directory, filepath), 'utf8'))

  load: ->
    # Only YAML rootfiles are considered valid model files
    fs.readdirAsync(@directory).then((filePaths) =>
      # Filter on .yml or .yaml extension
      yamlFilePaths = filePaths.filter((filePath) =>
        extension = path.extname(filePath)
        extension is '.yml' or extension is '.yaml'
      )

      for filepath in yamlFilePaths
        m = @_yamlLoad(filepath)
        @models[m.name] = m
        @modelPath[m.name] = filepath
    )

  reload: (name) ->
    @models[name] = @_yamlLoad(@modelPath[name])
    @models[name]

  get: (name, version) ->
    if not @models[name]?
      throw {code: Weaver.Error.MODEL_NOT_FOUND, message: "Model #{name} could not be found"}
    else if @models[name].version isnt version
      throw {code: Weaver.Error.MODEL_VERSION_NOT_FOUND, message: "Model #{name} with version #{version} could not be found"}

    @models[name]

module.exports = new ModelService()
