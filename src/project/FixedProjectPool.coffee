_              = require('lodash')
config         = require('config')
logger         = require('logger')
Promise        = require('bluebird')
ProjectService = require('ProjectService')


class FixedProjectPool

  constructor:  (@projectPool) ->
    logger.code.info("Fixed project pool loaded")

  create: (id) ->
    # Get the database endpoints of all projects currently in use]
    usedDatabases = (p.endpoint for p in ProjectService.all())

    # See which projects in the pool are still available by matching for unused database endpoints
    availableProjects = @projectPool.filter((p) ->
      not _.includes(usedDatabases, p.database)
    )

    # Throw an error if none is available
    if _.isEmpty(availableProjects)
      throw {code: -1, message: "No more available projects to use for new project with id #{id}"}

    # Return the first best availble project
    Promise.resolve(availableProjects[0])


  clean: ->
    Promise.resolve()       # Nothing to clean

  isReady: ->
    Promise.resolve(true)   # Always ready


module.exports = new FixedProjectPool(config.get('projectPool'))
