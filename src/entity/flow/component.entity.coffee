module.exports =
  class Component extends require('./../default.entity')

    getEntityIdentifier: ->
      'component'

    getDependencyIdentifiers: ->
      inports:  require('./../flow/inport.entity')
      outports: require('./../flow/outport.entity')
      triggers: require('./../flow/trigger.entity')