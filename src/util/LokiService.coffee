Promise     = require('bluebird')
loki        = require('lokijs')
exitHandler = require('exitHandler')

class LokiService

  # _collectionKeys is an object of collection name to indices array
  constructor: (@_fileName, @_collectionKeys)->
    @_folder = 'loki'
    @_collections = []

  load: ->
    new Promise((resolve) =>
      loaded = =>
        for collectionName, indices of @_collectionKeys
          @_collections.push(collectionName)
          @[collectionName] = @db.getCollection(collectionName) or @db.addCollection(collectionName, {indices})

        exitHandler(=> @db.close())
        resolve()

      @db = new loki("#{@_folder}/#{@_fileName}.json",
        autoload: true
        autosave: true
        autoloadCallback: loaded.bind(@)
        autosaveInterval: 1000  # ms
      )
    )

  # Wipes all collections
  wipe: ->
    for collectionName in @_collections
      @[collectionName].clear()


module.exports = LokiService
