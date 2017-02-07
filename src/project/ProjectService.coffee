LokiService = require('LokiService')

class ProjectService extends LokiService

  constructor: ->
    super('projects',
      projects:    ['id', 'acl']
    )

module.exports = new UserService()
