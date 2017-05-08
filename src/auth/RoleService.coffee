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
      name:   role.name
      users:  role._users
      roles:  role._roles
      acl:    aclId
    })


  getRole: (roleId) ->
    @roles.findOne({roleId})

  # Expects role id's
  # Recursively go down all roles and add the users
  getUsersFromRoles: (roles, users) ->
    users = users or {}
    for roleId in roles
      role = @getRole(roleId)

      users[u] = null for u in role.users

      # TODO: Fix that this breaks due to circular dependency
      @getUsersFromRole(r, users) for r in role.roles

    # Return unique users
    (user for user of users)

  all: ->
    @roles.find()

module.exports = new RoleService()
