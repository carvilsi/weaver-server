bus           = require('WeaverBus')
AclService    = require('AclService')
PluginService = require('PluginService')
logger        = require('logger')


bus.provide('plugin').require('name').on((req, name) ->
  PluginService.get(name)
)

bus.private('plugins').on((req) ->
  # TODO: Assert access per plugin and return filtered list
  PluginService.all()
)

bus.private('plugin.read').retrieve('user').retrieve('plugin').on((req, user, plugin) ->
  logger.usage.info "User #{user.username} retrieved plugin #{plugin.name}"
  # TODO: Assert read access
  plugin
)
