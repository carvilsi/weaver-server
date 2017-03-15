conf        = require('config')
LokiService = require('LokiService')
cuid        = require('cuid')
_           = require('lodash')

class RoleService extends LokiService

  constructor: ->
    super('roles',
      roles: ['users', 'roles']
    )

  createRole: (role, aclId) ->
    roleId = role.roleId

    if @roles.find({roleId}).length isnt 0
      throw {code:-1, message: "Role with id #{roleId} already exists"}

    @roles.insert({
      roleId: role.roleId
      name: role.name
      users: role._users
      roles: role._roles
      acl: aclId
    })


  getRole: (roleId) ->
    @roles.findOne({roleId})

module.exports = new RoleService()
