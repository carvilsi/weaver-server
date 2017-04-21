Promise     = require('bluebird')
loki        = require('lokijs')
exitHandler = require('exitHandler')

class LokiService

  # _fileName is where the database file is stored
  # _collectionKeys is an object of collection name to indices array to persist in Loki, such as 'users'
  constructor: (@_fileName, @_collectionKeys)->

    # Store all loki files in this folder
    @_folder = 'loki'

    # Keep track of all the collectionKeys to make for instance wiping possible
    @_collections = []

  # Loads the database from file
  load: ->
    new Promise((resolve) =>

      # This function is called when Loki has loaded the file
      # The promise resolves when this function has run
      loaded = =>
        for collectionName, indices of @_collectionKeys
          @_collections.push(collectionName)

          # Here, the collection name is set on the current object, so that @users becomes available
          # It tries to get it if available, otherwise it will create it
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
