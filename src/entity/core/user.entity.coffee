redis = new require('ioredis')()

module.exports =
  class User extends require('./../default.entity')

    getEntityIdentifier: ->
      'user'

    getDependencyIdentifiers: ->
      workspaces: require('./../core/workspace.entity')
      organizations: require('./../core/organization.entity')
      sessions: require('./../core/session.entity')
      environments: require('./../core/environment.entity')

    @getUserIdForUsername: (username) ->
      redis.get('username:' + username)

    # Override for username lookup
    update: (attribute, value) ->
      if attribute is 'username'
        redis.set('username:' + value, @id)

      redis.hset(@getEntityIdentifier()+ ':' +@id, attribute, value)
