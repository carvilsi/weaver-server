conf        = require('config')
LokiService = require('LokiService')
cuid        = require('cuid')
_           = require('lodash')
logger      = require('logger')

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

  getRolesForUser: (userId) ->
    # TODO: It is not recursive now respecting the role inheritance
    (role for role in @all() when role.users.indexOf(userId) >= 0)

  update: (update) ->
    # TODO Lots of checking (is the username/email correct?, does the user exist? etc)
    role = @roles.findOne({roleId: update.roleId})
    role.name   = update.name
    role.users  = update._users
    role.roles  = update._roles
    @roles.update(role)
    return


  # Expects role id's
  # Recursively go down all roles and add the users
  getUsersFromRoles: (roles, users) ->
    users = users or {}
    for roleId in roles
      role = @getRole(roleId)

      if role?
        users[u] = null for u in role.users

        # TODO: Fix that this breaks due to circular dependency
        @getUsersFromRole(r, users) for r in role.roles
      else
        logger.usage.warn "Role #{roleId} users requested, but no longer present in the RoleService"

    # Return unique users
    (user for user of users)

  destroy: (roleId) ->
    role = @roles.findOne({roleId})
    @roles.remove(role)

  all: ->
    @roles.find()

module.exports = new RoleService()
