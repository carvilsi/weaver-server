module.exports =
  class Behaviour extends require('./../default.entity')

    getEntityIdentifier: ->
      'behaviour'

    getDependencyIdentifiers: ->
      functions: require('./../flow/function.entity')
      connections: require('./../flow/connection.entity')