module.exports =
  class Environment extends require('./../default.entity')

    getEntityIdentifier: ->
      'environment'

    getDependencyIdentifiers: ->
      variables: require('./../app/variable.entity')