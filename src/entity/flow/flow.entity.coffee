module.exports =
  class Flow extends require('./../default.entity')

    getEntityIdentifier: ->
      'flow'

    getDependencyIdentifiers: ->
      components: require('./../flow/component.entity')