Promise     = require('bluebird')
loki        = require('lokijs')
exitHandler = require('exitHandler')

class LokiService

  # _collectionKeys is an object of collection name to indices array
  constructor: (@_fileName, @_collectionKeys)->
    @folder = 'loki'

  load: ->
    new Promise((resolve) =>
      loaded = =>
        for collectionName, indices of @_collectionKeys
          @[collectionName] = @db.getCollection(collectionName) or @db.addCollection(collectionName, {indices})

        exitHandler(=> @db.close())
        resolve()

      @db = new loki("#{@folder}/#{@_fileName}.json",
        autoload: true
        autosave: true
        autoloadCallback: loaded.bind(@)
        autosaveInterval: 1000  # ms
      )
    )


module.exports = LokiService
