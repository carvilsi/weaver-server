module.exports =
  class Function extends require('./../default.entity')

    getEntityIdentifier: ->
      'function'

    getDependencyIdentifiers: ->
      arguments: require('./../flow/argument.entity')
      triggers: require('./../flow/trigger.entity')